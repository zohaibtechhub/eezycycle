const { pool } = require('../config/db');

async function listByUserId(userId) {
  const [rows] = await pool.execute(
    `SELECT id, user_id, onesignal_subscription_id, platform, enabled,
            last_seen_at, created_at, updated_at
     FROM push_devices
     WHERE user_id = ?
     ORDER BY updated_at DESC`,
    [userId],
  );
  return rows;
}

async function listEnabledByUserId(userId) {
  const [rows] = await pool.execute(
    `SELECT id, user_id, onesignal_subscription_id, platform, enabled,
            last_seen_at, created_at, updated_at
     FROM push_devices
     WHERE user_id = ? AND enabled = 1
     ORDER BY updated_at DESC`,
    [userId],
  );
  return rows;
}

/**
 * Upsert by OneSignal subscription id (unique). Moves the row to this user_id.
 * @param {number} userId
 * @param {{ subscriptionId: string, platform?: string, enabled?: boolean }} data
 */
async function upsert(userId, data) {
  const subscriptionId = String(data.subscriptionId || '').trim().slice(0, 64);
  if (!subscriptionId) {
    throw new Error('onesignal_subscription_id is required');
  }

  const platform = ['ios', 'android', 'other'].includes(data.platform)
    ? data.platform
    : 'other';
  const enabled = data.enabled === false || data.enabled === 0 ? 0 : 1;

  await pool.execute(
    `INSERT INTO push_devices (
       user_id, onesignal_subscription_id, platform, enabled, last_seen_at
     ) VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)
     ON DUPLICATE KEY UPDATE
       user_id = VALUES(user_id),
       platform = VALUES(platform),
       enabled = VALUES(enabled),
       last_seen_at = CURRENT_TIMESTAMP`,
    [userId, subscriptionId, platform, enabled],
  );

  const [rows] = await pool.execute(
    `SELECT id, user_id, onesignal_subscription_id, platform, enabled,
            last_seen_at, created_at, updated_at
     FROM push_devices
     WHERE onesignal_subscription_id = ?
     LIMIT 1`,
    [subscriptionId],
  );
  return rows[0] || null;
}

async function disableBySubscriptionId(subscriptionId) {
  const id = String(subscriptionId || '').trim();
  if (!id) return;
  await pool.execute(
    `UPDATE push_devices SET enabled = 0 WHERE onesignal_subscription_id = ?`,
    [id],
  );
}

async function disableAllForUser(userId) {
  await pool.execute(
    `UPDATE push_devices SET enabled = 0 WHERE user_id = ?`,
    [userId],
  );
}

module.exports = {
  listByUserId,
  listEnabledByUserId,
  upsert,
  disableBySubscriptionId,
  disableAllForUser,
};
