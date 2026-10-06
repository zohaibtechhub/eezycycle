const { createError, ErrorCodes } = require('../utils/error');
const {
  normalizeConsentType,
  normalizeExperienceMode,
  normalizeUsagePath,
} = require('../utils/normalize');
const { toDateString } = require('../utils/date');
const flo = require('./flo_calendar_service');
const userRepository = require('../repositories/user_repository');
const profileRepository = require('../repositories/profile_repository');
const consentRepository = require('../repositories/consent_repository');
const goalRepository = require('../repositories/goal_repository');
const reminderRepository = require('../repositories/reminder_repository');
const periodRepository = require('../repositories/period_repository');
const pushDeviceRepository = require('../repositories/push_device_repository');
const notificationPlanner = require('./notification_planner_service');

function serializeReminders(reminders) {
  if (!reminders) return null;
  return {
    fertile_days_enabled: Boolean(reminders.fertile_days_enabled),
    pregnancy_test_enabled: Boolean(reminders.pregnancy_test_enabled),
    daily_tips_enabled: Boolean(reminders.daily_tips_enabled),
    period_reminder_enabled: Boolean(reminders.period_reminder_enabled),
    quiet_hours_start: reminders.quiet_hours_start || null,
    quiet_hours_end: reminders.quiet_hours_end || null,
    timezone: reminders.timezone || null,
  };
}

function serializeProfile(profile) {
  if (!profile) return null;
  return {
    birth_year: profile.birth_year,
    height_cm: profile.height_cm != null ? Number(profile.height_cm) : null,
    weight_kg: profile.weight_kg != null ? Number(profile.weight_kg) : null,
    is_metric: Boolean(profile.is_metric),
    experience_mode: profile.experience_mode,
    pregnancy_mode_active: Boolean(profile.pregnancy_mode_active),
    due_date: profile.due_date,
    lmp_based_edd: profile.lmp_based_edd || null,
    clinician_edd: profile.clinician_edd || null,
    edd_source: profile.edd_source || null,
    discovery_source: profile.discovery_source,
    usage_path: profile.usage_path,
    partner_code_entered: profile.partner_code_entered,
    avg_cycle_length: profile.avg_cycle_length,
    avg_period_length: profile.avg_period_length,
    luteal_phase_days: profile.luteal_phase_days,
    fertile_window_mode: profile.fertile_window_mode,
    timezone: profile.timezone,
    onboarding_completed_at: profile.onboarding_completed_at,
  };
}

/**
 * @param {number} userId
 */
async function getMe(userId) {
  const user = await userRepository.findActiveById(userId);
  if (!user) {
    throw createError('Account not found.', 404, ErrorCodes.NOT_FOUND);
  }

  await profileRepository.ensureExists(userId);

  const [profile, consents, goals, reminders] = await Promise.all([
    profileRepository.findByUserId(userId),
    consentRepository.listByUserId(userId),
    goalRepository.listByUserId(userId),
    reminderRepository.findByUserId(userId),
  ]);

  // Light replan on app open when the next scheduled push is missing/past
  // (keeps daily_tip rolling without a server cron).
  maybeRebuildIfStale(userId, reminders).catch(() => {});

  return {
    id: user.id,
    account_status: user.account_status,
    email: user.email,
    name: user.name,
    avatar_url: user.avatar_url || null,
    profile: serializeProfile(profile),
    consents: consents.map((c) => ({
      consent_type: c.consent_type,
      accepted: Boolean(c.accepted),
      accepted_at: c.accepted_at,
      document_version: c.document_version,
    })),
    goals: goals.map((g) => g.goal_key),
    reminders: serializeReminders(reminders),
  };
}

/**
 * Fire-and-forget: rebuild when any reminder is on but no future schedule exists.
 * @param {number} userId
 * @param {object|null} reminders
 */
async function maybeRebuildIfStale(userId, reminders) {
  if (!reminders) return;

  const anyOn =
    Boolean(reminders.period_reminder_enabled) ||
    Boolean(reminders.fertile_days_enabled) ||
    Boolean(reminders.pregnancy_test_enabled) ||
    (reminders.daily_tips_enabled == null
      ? true
      : Boolean(reminders.daily_tips_enabled));
  if (!anyOn) return;

  const scheduledNotificationRepository = require('../repositories/scheduled_notification_repository');
  const rows = await scheduledNotificationRepository.listScheduledByUserId(userId);
  const now = Date.now();
  const hasFuture = (rows || []).some((r) => {
    if (!r.fire_at_utc) return false;
    let t;
    if (r.fire_at_utc instanceof Date) {
      t = r.fire_at_utc.getTime();
    } else {
      const raw = String(r.fire_at_utc).trim();
      // Stored as UTC wall time ("YYYY-MM-DD HH:MM:SS") or ISO.
      const normalized = /Z$/i.test(raw) || raw.includes('T')
        ? raw
        : raw.replace(' ', 'T') + 'Z';
      t = new Date(normalized).getTime();
    }
    return Number.isFinite(t) && t > now + 60_000;
  });

  if (!hasFuture) {
    notificationPlanner.rebuildSafe(userId, { reason: 'get_me_stale' });
  }
}

/**
 * @param {number} userId
 * @param {Record<string, unknown>} body
 */
async function updateProfile(userId, body) {
  await profileRepository.ensureExists(userId);

  const fields = {};

  if (body.birth_year !== undefined) {
    const year = Number(body.birth_year);
    const currentYear = new Date().getFullYear();
    if (!Number.isInteger(year) || year < currentYear - 90 || year > currentYear - 13) {
      throw createError(
        'Birth year must be for ages 13–90.',
        400,
        ErrorCodes.VALIDATION,
      );
    }
    fields.birth_year = year;
  }

  if (body.height_cm !== undefined) {
    const height = Number(body.height_cm);
    if (Number.isNaN(height) || height < 50 || height > 300) {
      throw createError('Invalid height_cm.', 400, ErrorCodes.VALIDATION);
    }
    fields.height_cm = height;
  }

  if (body.weight_kg !== undefined) {
    const weight = Number(body.weight_kg);
    if (Number.isNaN(weight) || weight < 20 || weight > 500) {
      throw createError('Invalid weight_kg.', 400, ErrorCodes.VALIDATION);
    }
    fields.weight_kg = weight;
  }

  if (body.is_metric !== undefined) {
    fields.is_metric = body.is_metric ? 1 : 0;
  }

  if (body.experience_mode !== undefined) {
    // Explicit null / empty clears mode (e.g. incomplete partner gate reset)
    if (body.experience_mode === null || body.experience_mode === '') {
      fields.experience_mode = null;
    } else {
      const mode = normalizeExperienceMode(body.experience_mode);
      if (!mode) {
        throw createError('Invalid experience_mode.', 400, ErrorCodes.VALIDATION);
      }
      fields.experience_mode = mode;
    }
  }

  if (body.onboarding_completed_at !== undefined) {
    if (
      body.onboarding_completed_at === null ||
      body.onboarding_completed_at === '' ||
      body.onboarding_completed_at === false
    ) {
      fields.onboarding_completed_at = null;
    } else {
      fields.onboarding_completed_at = body.onboarding_completed_at;
    }
  }

  if (body.usage_path !== undefined) {
    const path = normalizeUsagePath(body.usage_path);
    if (!path) {
      throw createError('Invalid usage_path.', 400, ErrorCodes.VALIDATION);
    }
    fields.usage_path = path;
  }

  if (body.discovery_source !== undefined) {
    fields.discovery_source = body.discovery_source
      ? String(body.discovery_source).slice(0, 64)
      : null;
  }

  if (body.partner_code_entered !== undefined) {
    fields.partner_code_entered = body.partner_code_entered
      ? String(body.partner_code_entered).slice(0, 16)
      : null;
  }

  if (body.timezone !== undefined) {
    fields.timezone = body.timezone ? String(body.timezone).slice(0, 64) : null;
  }

  if (body.pregnancy_mode_active !== undefined) {
    fields.pregnancy_mode_active = body.pregnancy_mode_active ? 1 : 0;
  }

  if (body.due_date !== undefined) {
    fields.due_date = body.due_date || null;
  }

  // Phase 4 — clinician / ultrasound EDD
  const clinicianRaw =
    body.clinician_edd ??
    body.clinicianEdd ??
    body.ultrasound_edd ??
    body.ultrasoundEdd;
  if (clinicianRaw !== undefined) {
    const d = clinicianRaw ? toDateString(clinicianRaw) : null;
    fields.clinician_edd = d;
    if (d) {
      fields.due_date = d;
      fields.edd_source = 'clinician_ultrasound';
    }
  }

  if (body.edd_source !== undefined && clinicianRaw === undefined) {
    const src = String(body.edd_source || '').toLowerCase();
    if (src === 'lmp' || src === 'clinician_ultrasound') {
      fields.edd_source = src;
    }
  }

  // Leaving pregnancy mode — clear active flag (and dating fields) + rebuild cycle predictions
  const deactivatingPregnancy =
    body.pregnancy_mode_active === false ||
    body.pregnancy_mode_active === 0 ||
    body.pregnancy_mode_active === '0' ||
    body.pregnancy_mode_active === 'false';
  if (deactivatingPregnancy) {
    fields.pregnancy_mode_active = 0;
    if (body.due_date === undefined) {
      fields.due_date = null;
    }
    if (clinicianRaw === undefined) {
      fields.clinician_edd = null;
      fields.lmp_based_edd = null;
      fields.edd_source = null;
    }
  }

  // When turning pregnancy mode on: LMP+280 as history; clinician wins if provided
  const activatingPregnancy =
    body.pregnancy_mode_active === true ||
    body.pregnancy_mode_active === 1 ||
    body.pregnancy_mode_active === '1';
  if (activatingPregnancy) {
    const periodRows = await periodRepository.listByUserId(userId);
    const loggedDates = periodRows
      .filter((r) => !r.is_predicted)
      .map((r) => toDateString(r.log_date))
      .filter(Boolean)
      .sort();
    const runs = flo.groupBleedRuns(loggedDates);
    const lmpEdd =
      runs.length > 0 ? flo.dueDateFromLmp(runs[runs.length - 1].start) : null;
    if (lmpEdd) {
      fields.lmp_based_edd = lmpEdd;
    }

    if (fields.clinician_edd) {
      fields.due_date = fields.clinician_edd;
      fields.edd_source = 'clinician_ultrasound';
    } else if (lmpEdd) {
      fields.due_date = lmpEdd;
      fields.edd_source = 'lmp';
    } else if (body.due_date) {
      fields.due_date = body.due_date;
      fields.edd_source = fields.edd_source || 'lmp';
    }
  }

  // Switching to a non-pregnancy experience also turns pregnancy mode off
  if (
    fields.experience_mode &&
    fields.experience_mode !== 'track_pregnancy' &&
    body.pregnancy_mode_active === undefined
  ) {
    fields.pregnancy_mode_active = 0;
  }

  const profile = await profileRepository.update(userId, fields);

  const leftPregnancy =
    deactivatingPregnancy ||
    (fields.pregnancy_mode_active === 0 &&
      fields.experience_mode &&
      fields.experience_mode !== 'track_pregnancy');

  if (leftPregnancy) {
    try {
      // Lazy require avoids circular init with cycle_service
      const cycleService = require('./cycle_service');
      await cycleService.rebuildPredictions(userId);
    } catch (_) {
      // Profile already saved — /cycle/today will rebuild on next fetch
    }
  }

  // Replan push schedules when experience / pregnancy / timezone changes
  if (
    body.experience_mode !== undefined ||
    body.experienceMode !== undefined ||
    body.pregnancy_mode_active !== undefined ||
    body.timezone !== undefined ||
    leftPregnancy ||
    activatingPregnancy
  ) {
    notificationPlanner.rebuildSafe(userId, { reason: 'profile_update' });
  }

  return serializeProfile(profile);
}

/**
 * @param {number} userId
 * @param {{ consents: Array<{ type: string, accepted: boolean, document_version?: string }> }} body
 */
async function saveConsents(userId, body) {
  const items = Array.isArray(body.consents) ? body.consents : null;
  if (!items || items.length === 0) {
    throw createError('consents array is required.', 400, ErrorCodes.VALIDATION);
  }

  for (const item of items) {
    const type = normalizeConsentType(item.type || item.consent_type);
    if (!type) {
      throw createError(
        `Invalid consent type: ${item.type || item.consent_type}`,
        400,
        ErrorCodes.VALIDATION,
      );
    }
    if (typeof item.accepted !== 'boolean') {
      throw createError('Each consent must include accepted: true|false.', 400, ErrorCodes.VALIDATION);
    }

    // Health / terms must be affirmative (not pre-ticked rejection of false for required ones is client's job;
    // we still store accepted=false if sent).
    await consentRepository.upsert(userId, {
      consentType: type,
      accepted: item.accepted,
      documentVersion: item.document_version || item.documentVersion || null,
    });
  }

  const consents = await consentRepository.listByUserId(userId);
  return consents.map((c) => ({
    consent_type: c.consent_type,
    accepted: Boolean(c.accepted),
    accepted_at: c.accepted_at,
    document_version: c.document_version,
  }));
}

/**
 * Saves profile photo under /uploads/avatars and syncs secret chat avatar.
 * @param {number} userId
 * @param {string} relativeUrl e.g. /uploads/avatars/avatar_….jpg
 */
async function updateAvatar(userId, relativeUrl) {
  if (!relativeUrl || typeof relativeUrl !== 'string') {
    throw createError('Avatar image is required.', 400, ErrorCodes.VALIDATION);
  }
  const user = await userRepository.findActiveById(userId);
  if (!user) {
    throw createError('Account not found.', 404, ErrorCodes.NOT_FOUND);
  }

  await userRepository.updateAvatarUrl(userId, relativeUrl);

  // Keep secret chat author photo in sync when a community profile exists.
  try {
    const secretProfileRepository = require('../repositories/secret_profile_repository');
    const existing = await secretProfileRepository.findByUserId(userId);
    if (existing) {
      await secretProfileRepository.upsertProfile(userId, {
        username: existing.username,
        avatarUrl: relativeUrl,
      });
    }
  } catch (_) {
    // Non-fatal — main avatar still saved on users.
  }

  return getMe(userId);
}

/**
 * PATCH /me/push — register OneSignal subscription id for this user.
 * @param {number} userId
 * @param {Record<string, unknown>} body
 */
async function updatePush(userId, body) {
  const subscriptionId =
    body.onesignal_subscription_id ||
    body.onesignalSubscriptionId ||
    body.subscription_id ||
    body.player_id ||
    body.playerId;

  if (!subscriptionId || String(subscriptionId).trim() === '') {
    throw createError(
      'onesignal_subscription_id is required.',
      400,
      ErrorCodes.VALIDATION,
    );
  }

  let platform = String(body.platform || 'other').toLowerCase();
  if (!['ios', 'android', 'other'].includes(platform)) {
    platform = 'other';
  }

  const enabled =
    body.enabled === undefined
      ? true
      : !(body.enabled === false || body.enabled === 0 || body.enabled === '0');

  const device = await pushDeviceRepository.upsert(userId, {
    subscriptionId: String(subscriptionId).trim(),
    platform,
    enabled,
  });

  // Device just registered — rebuild schedule so External ID targeting works soon.
  notificationPlanner.rebuildSafe(userId, { reason: 'push_register' });

  return {
    id: device.id,
    user_id: device.user_id,
    onesignal_subscription_id: device.onesignal_subscription_id,
    platform: device.platform,
    enabled: Boolean(device.enabled),
    last_seen_at: device.last_seen_at,
  };
}

/**
 * PATCH /me/reminders — update reminder preferences and replan pushes.
 * @param {number} userId
 * @param {Record<string, unknown>} body
 */
async function updateReminders(userId, body) {
  const existing = await reminderRepository.findByUserId(userId);

  const boolOr = (snake, camel, fallback) => {
    if (body[snake] !== undefined) return Boolean(body[snake]);
    if (body[camel] !== undefined) return Boolean(body[camel]);
    return fallback;
  };

  const strOr = (snake, camel, fallback) => {
    if (body[snake] !== undefined) {
      return body[snake] ? String(body[snake]).slice(0, 64) : null;
    }
    if (body[camel] !== undefined) {
      return body[camel] ? String(body[camel]).slice(0, 64) : null;
    }
    return fallback;
  };

  const reminders = await reminderRepository.upsert(userId, {
    fertileDaysEnabled: boolOr(
      'fertile_days_enabled',
      'fertileDaysEnabled',
      Boolean(existing?.fertile_days_enabled),
    ),
    pregnancyTestEnabled: boolOr(
      'pregnancy_test_enabled',
      'pregnancyTestEnabled',
      Boolean(existing?.pregnancy_test_enabled),
    ),
    dailyTipsEnabled: boolOr(
      'daily_tips_enabled',
      'dailyTipsEnabled',
      existing?.daily_tips_enabled == null
        ? true
        : Boolean(existing.daily_tips_enabled),
    ),
    periodReminderEnabled: boolOr(
      'period_reminder_enabled',
      'periodReminderEnabled',
      Boolean(existing?.period_reminder_enabled),
    ),
    quietHoursStart: strOr(
      'quiet_hours_start',
      'quietHoursStart',
      existing?.quiet_hours_start || null,
    ),
    quietHoursEnd: strOr(
      'quiet_hours_end',
      'quietHoursEnd',
      existing?.quiet_hours_end || null,
    ),
    timezone: strOr('timezone', 'timezone', existing?.timezone || null),
  });

  // Keep profile timezone in sync when provided
  if (body.timezone) {
    await profileRepository.ensureExists(userId);
    await profileRepository.update(userId, {
      timezone: String(body.timezone).slice(0, 64),
    });
  }

  notificationPlanner.rebuildSafe(userId, { reason: 'reminders_update' });

  return serializeReminders(reminders);
}

module.exports = {
  getMe,
  updateProfile,
  saveConsents,
  updateAvatar,
  updatePush,
  updateReminders,
  serializeProfile,
  serializeReminders,
};
