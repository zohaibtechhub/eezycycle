const { pool } = require('../config/db');

async function listByUser(userId) {
  try {
    const [rows] = await pool.execute(
      `SELECT article_id, created_at
       FROM article_bookmarks
       WHERE user_id = ?
       ORDER BY created_at DESC`,
      [userId],
    );
    return rows;
  } catch (err) {
    if (err && err.code === 'ER_NO_SUCH_TABLE') {
      const { createError, ErrorCodes } = require('../utils/error');
      throw createError(
        'Bookmarks table is missing. Import sql/migrations/022_create_article_bookmarks.sql in phpMyAdmin.',
        503,
        ErrorCodes.INTERNAL,
      );
    }
    throw err;
  }
}

async function findOne(userId, articleId) {
  const [rows] = await pool.execute(
    `SELECT id, article_id, created_at
     FROM article_bookmarks
     WHERE user_id = ? AND article_id = ?
     LIMIT 1`,
    [userId, articleId],
  );
  return rows[0] || null;
}

async function create(userId, articleId) {
  await pool.execute(
    `INSERT IGNORE INTO article_bookmarks (user_id, article_id)
     VALUES (?, ?)`,
    [userId, articleId],
  );
  return findOne(userId, articleId);
}

async function remove(userId, articleId) {
  const [result] = await pool.execute(
    `DELETE FROM article_bookmarks
     WHERE user_id = ? AND article_id = ?`,
    [userId, articleId],
  );
  return result.affectedRows > 0;
}

module.exports = {
  listByUser,
  findOne,
  create,
  remove,
};
