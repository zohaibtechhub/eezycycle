const crypto = require('crypto');
const { pool } = require('../config/db');
const { hashToken } = require('../utils/token');

const MAX_ATTEMPTS = 5;

function hashOtp(otp) {
  return hashToken(String(otp));
}

function timingSafeEqualString(a, b) {
  try {
    const bufA = Buffer.from(String(a), 'utf8');
    const bufB = Buffer.from(String(b), 'utf8');
    if (bufA.length !== bufB.length) return false;
    return crypto.timingSafeEqual(bufA, bufB);
  } catch (_) {
    return false;
  }
}

async function invalidateOpenForEmail(email, connection) {
  const db = connection || pool;
  await db.execute(
    `UPDATE password_reset_otps
     SET consumed_at = CURRENT_TIMESTAMP
     WHERE email = ? AND consumed_at IS NULL`,
    [email],
  );
}

async function createOtp({ userId, email, otp, expiresAt, connection }) {
  const db = connection || pool;
  await invalidateOpenForEmail(email, db);
  const [result] = await db.execute(
    `INSERT INTO password_reset_otps (user_id, email, otp_hash, expires_at)
     VALUES (?, ?, ?, ?)`,
    [userId, email, hashOtp(otp), expiresAt],
  );
  return result.insertId;
}

async function findLatestOpenByEmail(email) {
  const [rows] = await pool.execute(
    `SELECT id, user_id, email, otp_hash, attempts, expires_at, consumed_at, created_at
     FROM password_reset_otps
     WHERE email = ? AND consumed_at IS NULL
     ORDER BY id DESC
     LIMIT 1`,
    [email],
  );
  return rows[0] || null;
}

async function incrementAttempts(id) {
  await pool.execute(
    `UPDATE password_reset_otps SET attempts = attempts + 1 WHERE id = ?`,
    [id],
  );
}

async function markConsumed(id) {
  await pool.execute(
    `UPDATE password_reset_otps
     SET consumed_at = CURRENT_TIMESTAMP
     WHERE id = ?`,
    [id],
  );
}

async function verifyOtp({ email, otp }) {
  const row = await findLatestOpenByEmail(email);
  if (!row) {
    return { ok: false, reason: 'not_found' };
  }
  if (row.attempts >= MAX_ATTEMPTS) {
    return { ok: false, reason: 'locked' };
  }
  if (new Date(row.expires_at).getTime() < Date.now()) {
    return { ok: false, reason: 'expired' };
  }
  if (!timingSafeEqualString(row.otp_hash, hashOtp(otp))) {
    await incrementAttempts(row.id);
    return { ok: false, reason: 'mismatch' };
  }
  return { ok: true, row };
}

module.exports = {
  MAX_ATTEMPTS,
  createOtp,
  findLatestOpenByEmail,
  incrementAttempts,
  markConsumed,
  verifyOtp,
  invalidateOpenForEmail,
  hashOtp,
};
