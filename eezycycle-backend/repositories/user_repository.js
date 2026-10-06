const { pool } = require('../config/db');

async function findActiveById(userId) {
  const [rows] = await pool.execute(
    `SELECT id, account_status, email, name, avatar_url, password_hash, google_sub,
            is_active, created_at, updated_at, deleted_at
     FROM users
     WHERE id = ? AND deleted_at IS NULL AND is_active = 1
     LIMIT 1`,
    [userId],
  );
  return rows[0] || null;
}

async function findActiveByEmail(email) {
  const [rows] = await pool.execute(
    `SELECT id, account_status, email, name, avatar_url, password_hash, google_sub,
            is_active, created_at, updated_at, deleted_at
     FROM users
     WHERE email = ? AND deleted_at IS NULL AND is_active = 1
     LIMIT 1`,
    [email],
  );
  return rows[0] || null;
}

async function findActiveByGoogleSub(googleSub) {
  const [rows] = await pool.execute(
    `SELECT id, account_status, email, name, avatar_url, password_hash, google_sub,
            is_active, created_at, updated_at, deleted_at
     FROM users
     WHERE google_sub = ? AND deleted_at IS NULL AND is_active = 1
     LIMIT 1`,
    [googleSub],
  );
  return rows[0] || null;
}

async function createGuest(connection) {
  const db = connection || pool;
  const [result] = await db.execute(
    `INSERT INTO users (account_status, is_active)
     VALUES ('guest', 1)`,
  );
  return result.insertId;
}

async function touchLastLogin(userId, connection) {
  const db = connection || pool;
  await db.execute(
    `UPDATE users SET last_login_at = CURRENT_TIMESTAMP WHERE id = ?`,
    [userId],
  );
}

/**
 * Upgrade a guest row in place (same user_id).
 * @param {number} userId
 * @param {{ email?: string|null, passwordHash?: string|null, googleSub?: string|null, name?: string|null, emailVerified?: boolean }} fields
 */
async function upgradeGuestToRegistered(userId, fields, connection) {
  const db = connection || pool;
  await db.execute(
    `UPDATE users
     SET account_status = 'registered',
         email = COALESCE(?, email),
         password_hash = COALESCE(?, password_hash),
         google_sub = COALESCE(?, google_sub),
         name = COALESCE(?, name),
         email_verified_at = CASE
           WHEN ? = 1 THEN CURRENT_TIMESTAMP
           ELSE email_verified_at
         END,
         registered_at = COALESCE(registered_at, CURRENT_TIMESTAMP),
         last_login_at = CURRENT_TIMESTAMP
     WHERE id = ? AND account_status = 'guest' AND deleted_at IS NULL`,
    [
      fields.email || null,
      fields.passwordHash || null,
      fields.googleSub || null,
      fields.name || null,
      fields.emailVerified ? 1 : 0,
      userId,
    ],
  );
}

async function softDeleteUser(userId, connection) {
  const db = connection || pool;
  await db.execute(
    `UPDATE users
     SET is_active = 0, deleted_at = CURRENT_TIMESTAMP
     WHERE id = ? AND deleted_at IS NULL`,
    [userId],
  );
}

async function updatePasswordHash(userId, passwordHash, connection) {
  const db = connection || pool;
  await db.execute(
    `UPDATE users
     SET password_hash = ?, updated_at = CURRENT_TIMESTAMP
     WHERE id = ? AND deleted_at IS NULL AND is_active = 1`,
    [passwordHash, userId],
  );
}

async function updateAvatarUrl(userId, avatarUrl, connection) {
  const db = connection || pool;
  await db.execute(
    `UPDATE users
     SET avatar_url = ?, updated_at = CURRENT_TIMESTAMP
     WHERE id = ? AND deleted_at IS NULL AND is_active = 1`,
    [avatarUrl, userId],
  );
}

/**
 * Rough check whether a guest has any meaningful health/onboarding data.
 */
async function countMeaningfulData(userId) {
  const [periodRows] = await pool.execute(
    `SELECT COUNT(*) AS c FROM period_days WHERE user_id = ? AND is_predicted = 0`,
    [userId],
  );
  const [answerRows] = await pool.execute(
    `SELECT COUNT(*) AS c FROM onboarding_answers WHERE user_id = ?`,
    [userId],
  );
  const periods = Number(periodRows[0]?.c || 0);
  const answers = Number(answerRows[0]?.c || 0);
  return { periods, answers, total: periods + answers };
}

module.exports = {
  findActiveById,
  findActiveByEmail,
  findActiveByGoogleSub,
  createGuest,
  touchLastLogin,
  upgradeGuestToRegistered,
  softDeleteUser,
  updatePasswordHash,
  updateAvatarUrl,
  countMeaningfulData,
};
