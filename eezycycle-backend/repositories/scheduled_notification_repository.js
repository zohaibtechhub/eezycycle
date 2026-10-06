const { pool } = require('../config/db');

async function listScheduledByUserId(userId) {
  const [rows] = await pool.execute(
    `SELECT id, user_id, notification_type, onesignal_notification_id,
            fire_at_utc, status, payload_json, created_at, updated_at
     FROM scheduled_notifications
     WHERE user_id = ? AND status = 'scheduled'`,
    [userId],
  );
  return rows;
}

async function findByUserAndType(userId, notificationType) {
  const [rows] = await pool.execute(
    `SELECT id, user_id, notification_type, onesignal_notification_id,
            fire_at_utc, status, payload_json, created_at, updated_at
     FROM scheduled_notifications
     WHERE user_id = ? AND notification_type = ?
     LIMIT 1`,
    [userId, notificationType],
  );
  return rows[0] || null;
}

/**
 * Upsert one active schedule row per (user, type).
 */
async function upsertScheduled(userId, data) {
  const payload =
    data.payloadJson == null
      ? null
      : typeof data.payloadJson === 'string'
        ? data.payloadJson
        : JSON.stringify(data.payloadJson);

  await pool.execute(
    `INSERT INTO scheduled_notifications (
       user_id, notification_type, onesignal_notification_id,
       fire_at_utc, status, payload_json
     ) VALUES (?, ?, ?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE
       onesignal_notification_id = VALUES(onesignal_notification_id),
       fire_at_utc = VALUES(fire_at_utc),
       status = VALUES(status),
       payload_json = VALUES(payload_json)`,
    [
      userId,
      data.notificationType,
      data.onesignalNotificationId || null,
      data.fireAtUtc,
      data.status || 'scheduled',
      payload,
    ],
  );

  return findByUserAndType(userId, data.notificationType);
}

async function markCancelled(userId, notificationType) {
  await pool.execute(
    `UPDATE scheduled_notifications
     SET status = 'cancelled', onesignal_notification_id = NULL
     WHERE user_id = ? AND notification_type = ? AND status = 'scheduled'`,
    [userId, notificationType],
  );
}

async function markAllCancelledForUser(userId) {
  await pool.execute(
    `UPDATE scheduled_notifications
     SET status = 'cancelled'
     WHERE user_id = ? AND status = 'scheduled'`,
    [userId],
  );
}

module.exports = {
  listScheduledByUserId,
  findByUserAndType,
  upsertScheduled,
  markCancelled,
  markAllCancelledForUser,
};
