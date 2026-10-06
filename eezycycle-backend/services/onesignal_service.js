const { env } = require('../config/env');

const DEFAULT_API_URL = 'https://api.onesignal.com';

function isConfigured() {
  return Boolean(env.onesignal?.appId && env.onesignal?.restApiKey);
}

/**
 * @param {string} path
 * @param {{ method?: string, body?: object }} [opts]
 */
async function request(path, opts = {}) {
  if (!isConfigured()) {
    const err = new Error('OneSignal is not configured (missing ONESIGNAL_APP_ID / REST key).');
    err.code = 'ONESIGNAL_NOT_CONFIGURED';
    throw err;
  }

  const method = opts.method || 'GET';
  const url = `${(env.onesignal.apiUrl || DEFAULT_API_URL).replace(/\/$/, '')}${path}`;
  const headers = {
    Authorization: `Key ${env.onesignal.restApiKey}`,
    'Content-Type': 'application/json',
    Accept: 'application/json',
  };

  const res = await fetch(url, {
    method,
    headers,
    body: opts.body != null ? JSON.stringify(opts.body) : undefined,
  });

  let json = null;
  const text = await res.text();
  if (text) {
    try {
      json = JSON.parse(text);
    } catch {
      json = { raw: text };
    }
  }

  if (!res.ok) {
    const message =
      json?.errors?.[0] ||
      json?.error ||
      json?.message ||
      `OneSignal HTTP ${res.status}`;
    const err = new Error(typeof message === 'string' ? message : JSON.stringify(message));
    err.statusCode = res.status;
    err.onesignal = json;
    throw err;
  }

  return json;
}

function isMissingUserError(err) {
  const msg = String(err?.message || '');
  return (
    err?.statusCode === 404 ||
    /doesn't match an existing user/i.test(msg) ||
    /could not find.*user/i.test(msg) ||
    /not found/i.test(msg)
  );
}

/**
 * Create a push notification targeted at a backend user (OneSignal External ID).
 *
 * Channels are created in the Flutter app (`cycle_reminders`, `daily_tips`, …),
 * so we must send `existing_android_channel_id` (app channel string) — not
 * `android_channel_id` (OneSignal dashboard category UUID).
 *
 * @param {{
 *   externalUserId: string|number,
 *   heading: string,
 *   content: string,
 *   data?: Record<string, unknown>,
 *   sendAfter?: string|null,
 *   androidChannelId?: string,
 *   buttons?: Array<{ id: string, text: string }>,
 *   subscriptionIds?: string[],
 * }} opts
 * @returns {Promise<{ id: string|null, raw: object }>}
 */
async function createNotification(opts) {
  const externalId = String(opts.externalUserId);
  const body = {
    app_id: env.onesignal.appId,
    target_channel: 'push',
    include_aliases: { external_id: [externalId] },
    headings: { en: opts.heading },
    contents: { en: opts.content },
    data: opts.data || {},
    priority: 5,
    ios_sound: 'default',
    android_accent_color: 'FFE85078',
  };

  if (opts.sendAfter) {
    body.send_after = opts.sendAfter;
  }

  // App-defined Android 8+ channels (see NotificationService in Flutter).
  if (opts.androidChannelId) {
    body.existing_android_channel_id = opts.androidChannelId;
  }

  if (Array.isArray(opts.buttons) && opts.buttons.length > 0) {
    body.buttons = opts.buttons;
  }

  const raw = await request('/notifications', { method: 'POST', body });
  return { id: raw?.id || null, raw };
}

/**
 * Cancel a previously created (scheduled) notification.
 * @param {string} notificationId
 */
async function cancelNotification(notificationId) {
  const id = String(notificationId || '').trim();
  if (!id) return null;

  // OneSignal: DELETE /notifications/{id}?app_id=
  return request(
    `/notifications/${encodeURIComponent(id)}?app_id=${encodeURIComponent(env.onesignal.appId)}`,
    { method: 'DELETE' },
  );
}

/**
 * Ensure a OneSignal User exists for this External ID (no-op if already present).
 * Optionally seeds Data Tags on create.
 * @param {string|number} externalUserId
 * @param {Record<string, string|number>} [tags]
 */
async function ensureExternalUser(externalUserId, tags) {
  const id = String(externalUserId);
  const appId = encodeURIComponent(env.onesignal.appId);

  try {
    await request(`/apps/${appId}/users/by/external_id/${encodeURIComponent(id)}`, {
      method: 'GET',
    });
    return { created: false };
  } catch (err) {
    if (!isMissingUserError(err)) throw err;
  }

  const body = {
    identity: { external_id: id },
  };
  if (tags && Object.keys(tags).length > 0) {
    body.properties = { tags };
  }

  try {
    await request(`/apps/${appId}/users`, { method: 'POST', body });
    return { created: true };
  } catch (err) {
    // Race: SDK login or another rebuild created the user between GET and POST.
    if (
      err?.statusCode === 409 ||
      /already|exist|conflict|duplicate/i.test(String(err?.message || ''))
    ) {
      return { created: false };
    }
    throw err;
  }
}

/**
 * Attach External ID to an existing push subscription (server-side login).
 * Safe if already linked or subscription unknown.
 * @param {string} subscriptionId
 * @param {string|number} externalUserId
 */
async function linkSubscriptionToExternalId(subscriptionId, externalUserId) {
  const subId = String(subscriptionId || '').trim();
  const externalId = String(externalUserId);
  if (!subId) return null;

  const appId = encodeURIComponent(env.onesignal.appId);
  try {
    return await request(
      `/apps/${appId}/users/by/subscription_id/${encodeURIComponent(subId)}/identity`,
      {
        method: 'PATCH',
        body: {
          identity: { external_id: externalId },
        },
      },
    );
  } catch (err) {
    // Subscription may already be owned by this external_id, or not yet in OS.
    if (isMissingUserError(err) || /already|conflict|duplicate/i.test(String(err?.message || ''))) {
      return null;
    }
    throw err;
  }
}

/**
 * Update Data Tags on a user (External ID).
 * Creates the OneSignal user first when the alias does not exist yet.
 * @param {string|number} externalUserId
 * @param {Record<string, string|number>} tags
 */
async function updateUserTags(externalUserId, tags) {
  const id = encodeURIComponent(String(externalUserId));
  const appId = encodeURIComponent(env.onesignal.appId);
  const body = {
    properties: {
      tags,
    },
  };

  try {
    return await request(`/apps/${appId}/users/by/external_id/${id}`, {
      method: 'PATCH',
      body,
    });
  } catch (err) {
    if (!isMissingUserError(err)) throw err;

    // Alias not registered yet (app hasn't called OneSignal.login) — create then set tags.
    await ensureExternalUser(externalUserId, tags);
    return request(`/apps/${appId}/users/by/external_id/${id}`, {
      method: 'PATCH',
      body,
    });
  }
}

module.exports = {
  isConfigured,
  createNotification,
  cancelNotification,
  updateUserTags,
  ensureExternalUser,
  linkSubscriptionToExternalId,
  isMissingUserError,
};
