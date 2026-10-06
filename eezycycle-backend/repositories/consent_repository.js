const { pool } = require('../config/db');

async function listByUserId(userId) {
  const [rows] = await pool.execute(
    `SELECT id, user_id, consent_type, accepted, accepted_at, document_version, created_at, updated_at
     FROM user_consents
     WHERE user_id = ?`,
    [userId],
  );
  return rows;
}

async function upsert(userId, { consentType, accepted, documentVersion }) {
  await pool.execute(
    `INSERT INTO user_consents (user_id, consent_type, accepted, accepted_at, document_version)
     VALUES (?, ?, ?, CURRENT_TIMESTAMP, ?)
     ON DUPLICATE KEY UPDATE
       accepted = VALUES(accepted),
       accepted_at = CURRENT_TIMESTAMP,
       document_version = VALUES(document_version)`,
    [userId, consentType, accepted ? 1 : 0, documentVersion || null],
  );
}

/**
 * @param {number} userId
 * @param {string[]} requiredTypes
 * @returns {Promise<string[]>} missing consent types
 */
async function findMissingAccepted(userId, requiredTypes) {
  if (!requiredTypes.length) return [];

  const placeholders = requiredTypes.map(() => '?').join(', ');
  const [rows] = await pool.execute(
    `SELECT consent_type
     FROM user_consents
     WHERE user_id = ?
       AND consent_type IN (${placeholders})
       AND accepted = 1`,
    [userId, ...requiredTypes],
  );

  const accepted = new Set(rows.map((r) => r.consent_type));
  return requiredTypes.filter((t) => !accepted.has(t));
}

module.exports = {
  listByUserId,
  upsert,
  findMissingAccepted,
};
