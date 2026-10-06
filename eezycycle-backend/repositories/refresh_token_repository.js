const { pool } = require('../config/db');

async function create(connection, { userId, tokenHash, deviceId, expiresAt }) {
  const db = connection || pool;
  const [result] = await db.execute(
    `INSERT INTO refresh_tokens (user_id, token_hash, device_id, expires_at)
     VALUES (?, ?, ?, ?)`,
    [userId, tokenHash, deviceId || null, expiresAt],
  );
  return result.insertId;
}

async function findValidByHash(tokenHash) {
  const [rows] = await pool.execute(
    `SELECT id, user_id, device_id, expires_at, revoked_at
     FROM refresh_tokens
     WHERE token_hash = ?
       AND revoked_at IS NULL
       AND expires_at > CURRENT_TIMESTAMP
     LIMIT 1`,
    [tokenHash],
  );
  return rows[0] || null;
}

async function revokeByHash(tokenHash) {
  const [result] = await pool.execute(
    `UPDATE refresh_tokens
     SET revoked_at = CURRENT_TIMESTAMP
     WHERE token_hash = ? AND revoked_at IS NULL`,
    [tokenHash],
  );
  return result.affectedRows;
}

async function revokeAllForUserDevice(userId, deviceId) {
  if (!deviceId) {
    const [result] = await pool.execute(
      `UPDATE refresh_tokens
       SET revoked_at = CURRENT_TIMESTAMP
       WHERE user_id = ? AND revoked_at IS NULL`,
      [userId],
    );
    return result.affectedRows;
  }

  const [result] = await pool.execute(
    `UPDATE refresh_tokens
     SET revoked_at = CURRENT_TIMESTAMP
     WHERE user_id = ? AND device_id = ? AND revoked_at IS NULL`,
    [userId, deviceId],
  );
  return result.affectedRows;
}

module.exports = {
  create,
  findValidByHash,
  revokeByHash,
  revokeAllForUserDevice,
};
