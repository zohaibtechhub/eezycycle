const { pool } = require('../config/db');

/**
 * @param {{
 *   userId: number,
 *   eventType?: string,
 *   actualDate: string,
 *   predictedDate?: string|null,
 *   deltaDays?: number|null,
 *   algorithmVersion?: string|null,
 *   meta?: object|null,
 * }} row
 */
async function insert(row) {
  await pool.execute(
    `INSERT INTO prediction_validation_log
       (user_id, event_type, actual_date, predicted_date, delta_days,
        algorithm_version, meta_json)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [
      row.userId,
      row.eventType || 'period_start',
      row.actualDate,
      row.predictedDate || null,
      row.deltaDays ?? null,
      row.algorithmVersion || null,
      row.meta ? JSON.stringify(row.meta) : null,
    ],
  );
}

/**
 * @param {number} userId
 * @param {{ limit?: number }} [opts]
 */
async function listByUserId(userId, opts = {}) {
  const limit = Math.min(100, Math.max(1, Number(opts.limit) || 20));
  const [rows] = await pool.execute(
    `SELECT id, user_id, event_type, actual_date, predicted_date, delta_days,
            algorithm_version, meta_json, created_at
     FROM prediction_validation_log
     WHERE user_id = ?
     ORDER BY created_at DESC
     LIMIT ${limit}`,
    [userId],
  );
  return rows;
}

module.exports = {
  insert,
  listByUserId,
};
