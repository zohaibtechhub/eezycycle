const { pool } = require('../config/db');

async function findByDeviceId(deviceId) {
  const [rows] = await pool.execute(
    `SELECT d.id, d.user_id, d.device_id, d.platform, d.app_version, d.last_seen_at,
            u.account_status, u.is_active, u.deleted_at
     FROM devices d
     INNER JOIN users u ON u.id = d.user_id
     WHERE d.device_id = ?
     LIMIT 1`,
    [deviceId],
  );
  return rows[0] || null;
}

async function create(connection, { userId, deviceId, platform, appVersion }) {
  const db = connection || pool;
  const [result] = await db.execute(
    `INSERT INTO devices (user_id, device_id, platform, app_version, last_seen_at)
     VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)`,
    [userId, deviceId, platform, appVersion || null],
  );
  return result.insertId;
}

async function touch(deviceId, { platform, appVersion } = {}) {
  await pool.execute(
    `UPDATE devices
     SET last_seen_at = CURRENT_TIMESTAMP,
         platform = COALESCE(?, platform),
         app_version = COALESCE(?, app_version)
     WHERE device_id = ?`,
    [platform || null, appVersion || null, deviceId],
  );
}

/**
 * Move this device to another user (login / merge attach).
 */
async function reassignUser(deviceId, newUserId, connection) {
  const db = connection || pool;
  await db.execute(
    `UPDATE devices
     SET user_id = ?, last_seen_at = CURRENT_TIMESTAMP
     WHERE device_id = ?`,
    [newUserId, deviceId],
  );
}

module.exports = {
  findByDeviceId,
  create,
  touch,
  reassignUser,
};
