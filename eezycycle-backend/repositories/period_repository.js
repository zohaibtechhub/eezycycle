const { pool } = require('../config/db');

/**
 * @param {number} userId
 * @param {string} [from] YYYY-MM-DD
 * @param {string} [to] YYYY-MM-DD
 */
async function listByUserId(userId, from, to) {
  if (from && to) {
    const [rows] = await pool.execute(
      `SELECT id, user_id, log_date, flow_intensity, is_predicted, cycle_id, created_at, updated_at
       FROM period_days
       WHERE user_id = ? AND log_date BETWEEN ? AND ?
       ORDER BY log_date ASC`,
      [userId, from, to],
    );
    return rows;
  }

  const [rows] = await pool.execute(
    `SELECT id, user_id, log_date, flow_intensity, is_predicted, cycle_id, created_at, updated_at
     FROM period_days
     WHERE user_id = ?
     ORDER BY log_date ASC`,
    [userId],
  );
  return rows;
}

/**
 * Replace logged (non-predicted) period days with the given date list.
 * @param {number} userId
 * @param {string[]} dates YYYY-MM-DD unique
 * @param {import('mysql2/promise').PoolConnection} [connection]
 */
async function replaceLoggedDates(userId, dates, connection) {
  const db = connection || pool;

  await db.execute(
    `DELETE FROM period_days WHERE user_id = ? AND is_predicted = 0`,
    [userId],
  );

  for (const logDate of dates) {
    await db.execute(
      `INSERT INTO period_days (user_id, log_date, is_predicted)
       VALUES (?, ?, 0)
       ON DUPLICATE KEY UPDATE
         is_predicted = 0,
         updated_at = CURRENT_TIMESTAMP`,
      [userId, logDate],
    );
  }
}

module.exports = {
  listByUserId,
  replaceLoggedDates,
};
