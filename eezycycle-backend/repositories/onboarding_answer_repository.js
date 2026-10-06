const { pool } = require('../config/db');

async function listByUserId(userId, flowKey) {
  if (flowKey) {
    const [rows] = await pool.execute(
      `SELECT id, user_id, flow_key, step_id, answer_values, created_at, updated_at
       FROM onboarding_answers
       WHERE user_id = ? AND flow_key = ?
       ORDER BY updated_at ASC`,
      [userId, flowKey],
    );
    return rows;
  }

  const [rows] = await pool.execute(
    `SELECT id, user_id, flow_key, step_id, answer_values, created_at, updated_at
     FROM onboarding_answers
     WHERE user_id = ?
     ORDER BY flow_key ASC, updated_at ASC`,
    [userId],
  );
  return rows;
}

/**
 * Bulk upsert answers for one flow.
 * @param {number} userId
 * @param {string} flowKey
 * @param {{ stepId: string, answerValues: unknown[] }[]} answers
 * @param {import('mysql2/promise').PoolConnection} [connection]
 */
async function upsertMany(userId, flowKey, answers, connection) {
  const db = connection || pool;

  for (const item of answers) {
    await db.execute(
      `INSERT INTO onboarding_answers (user_id, flow_key, step_id, answer_values)
       VALUES (?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         answer_values = VALUES(answer_values),
         updated_at = CURRENT_TIMESTAMP`,
      [userId, flowKey, item.stepId, JSON.stringify(item.answerValues)],
    );
  }
}

module.exports = {
  listByUserId,
  upsertMany,
};
