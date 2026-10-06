const { pool } = require('../config/db');

async function findLogByUserAndDate(userId, logDate) {
  const [rows] = await pool.execute(
    `SELECT id, user_id, log_date, created_at, updated_at
     FROM daily_logs
     WHERE user_id = ? AND log_date = ?
     LIMIT 1`,
    [userId, logDate],
  );
  return rows[0] || null;
}

async function ensureLog(userId, logDate, connection) {
  const db = connection || pool;
  await db.execute(
    `INSERT INTO daily_logs (user_id, log_date)
     VALUES (?, ?)
     ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP`,
    [userId, logDate],
  );
  const [rows] = await db.execute(
    `SELECT id, user_id, log_date, created_at, updated_at
     FROM daily_logs
     WHERE user_id = ? AND log_date = ?
     LIMIT 1`,
    [userId, logDate],
  );
  return rows[0];
}

async function listItems(dailyLogId) {
  const [rows] = await pool.execute(
    `SELECT id, daily_log_id, category, item_key, sensitivity
     FROM daily_log_items
     WHERE daily_log_id = ?
     ORDER BY id ASC`,
    [dailyLogId],
  );
  return rows;
}

async function replaceItems(dailyLogId, items, connection) {
  const db = connection || pool;
  await db.execute(`DELETE FROM daily_log_items WHERE daily_log_id = ?`, [
    dailyLogId,
  ]);

  for (const item of items) {
    await db.execute(
      `INSERT INTO daily_log_items
         (daily_log_id, category, item_key, sensitivity)
       VALUES (?, ?, ?, ?)`,
      [dailyLogId, item.category, item.itemKey, item.sensitivity],
    );
  }
}

module.exports = {
  findLogByUserAndDate,
  ensureLog,
  listItems,
  replaceItems,
};
