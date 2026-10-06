const { pool } = require('../config/db');

async function listByUserId(userId) {
  const [rows] = await pool.execute(
    `SELECT id, user_id, goal_key, created_at
     FROM user_goals
     WHERE user_id = ?
     ORDER BY created_at ASC`,
    [userId],
  );
  return rows;
}

/**
 * Replace all goals for a user with the given keys (transaction-friendly).
 * @param {number} userId
 * @param {string[]} goalKeys
 * @param {import('mysql2/promise').PoolConnection} [connection]
 */
async function replaceAll(userId, goalKeys, connection) {
  const db = connection || pool;
  await db.execute(`DELETE FROM user_goals WHERE user_id = ?`, [userId]);

  for (const goalKey of goalKeys) {
    await db.execute(
      `INSERT INTO user_goals (user_id, goal_key) VALUES (?, ?)`,
      [userId, goalKey],
    );
  }
}

module.exports = {
  listByUserId,
  replaceAll,
};
