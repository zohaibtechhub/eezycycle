const { pool } = require('../config/db');

async function listPosts({ viewerUserId, mineOnly = false, limit = 50 }) {
  const safeLimit = Math.min(Math.max(Number(limit) || 50, 1), 100);
  const params = [viewerUserId];
  let mineClause = '';
  if (mineOnly) {
    mineClause = 'AND p.user_id = ?';
    params.push(viewerUserId);
  }

  const [rows] = await pool.execute(
    `SELECT
       p.id,
       p.user_id,
       p.content,
       p.image_url,
       p.likes_count,
       p.comments_count,
       p.created_at,
       sp.username AS author_username,
       u.avatar_url AS author_avatar_url,
       CASE WHEN pl.id IS NULL THEN 0 ELSE 1 END AS liked_by_me
     FROM posts p
     LEFT JOIN secret_profiles sp ON sp.user_id = p.user_id
     LEFT JOIN users u ON u.id = p.user_id
     LEFT JOIN post_likes pl
       ON pl.post_id = p.id AND pl.user_id = ?
     WHERE p.deleted_at IS NULL
       AND p.is_hidden = 0
       ${mineClause}
     ORDER BY p.created_at DESC
     LIMIT ${safeLimit}`,
    params,
  );
  return rows;
}

async function findPostById(postId) {
  const [rows] = await pool.execute(
    `SELECT id, user_id, content, image_url, likes_count, comments_count,
            created_at, deleted_at, is_hidden
     FROM posts
     WHERE id = ?
     LIMIT 1`,
    [postId],
  );
  return rows[0] || null;
}

async function createPost({ userId, content, imageUrl = null }) {
  const [result] = await pool.execute(
    `INSERT INTO posts (user_id, content, image_url)
     VALUES (?, ?, ?)`,
    [userId, content, imageUrl],
  );
  return findPostById(result.insertId);
}

async function softDeletePost(postId, userId) {
  const [result] = await pool.execute(
    `UPDATE posts
     SET deleted_at = CURRENT_TIMESTAMP
     WHERE id = ?
       AND user_id = ?
       AND deleted_at IS NULL`,
    [postId, userId],
  );
  return result.affectedRows > 0;
}

async function findPostLike(postId, userId) {
  const [rows] = await pool.execute(
    `SELECT id FROM post_likes WHERE post_id = ? AND user_id = ? LIMIT 1`,
    [postId, userId],
  );
  return rows[0] || null;
}

async function addPostLike(postId, userId) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    await conn.execute(
      `INSERT IGNORE INTO post_likes (post_id, user_id) VALUES (?, ?)`,
      [postId, userId],
    );
    await conn.execute(
      `UPDATE posts
       SET likes_count = (
         SELECT COUNT(*) FROM post_likes WHERE post_id = ?
       )
       WHERE id = ?`,
      [postId, postId],
    );
    await conn.commit();
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

async function removePostLike(postId, userId) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    await conn.execute(
      `DELETE FROM post_likes WHERE post_id = ? AND user_id = ?`,
      [postId, userId],
    );
    await conn.execute(
      `UPDATE posts
       SET likes_count = (
         SELECT COUNT(*) FROM post_likes WHERE post_id = ?
       )
       WHERE id = ?`,
      [postId, postId],
    );
    await conn.commit();
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

async function listComments(postId, viewerUserId) {
  const [rows] = await pool.execute(
    `SELECT
       c.id,
       c.post_id,
       c.user_id,
       c.body,
       c.likes_count,
       c.created_at,
       sp.username AS author_username,
       u.avatar_url AS author_avatar_url,
       CASE WHEN cl.id IS NULL THEN 0 ELSE 1 END AS liked_by_me
     FROM post_comments c
     LEFT JOIN secret_profiles sp ON sp.user_id = c.user_id
     LEFT JOIN users u ON u.id = c.user_id
     LEFT JOIN comment_likes cl
       ON cl.comment_id = c.id AND cl.user_id = ?
     WHERE c.post_id = ?
       AND c.deleted_at IS NULL
     ORDER BY c.created_at ASC`,
    [viewerUserId, postId],
  );
  return rows;
}

async function findCommentById(commentId) {
  const [rows] = await pool.execute(
    `SELECT id, post_id, user_id, body, likes_count, created_at, deleted_at
     FROM post_comments
     WHERE id = ?
     LIMIT 1`,
    [commentId],
  );
  return rows[0] || null;
}

async function createComment({ postId, userId, body }) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [result] = await conn.execute(
      `INSERT INTO post_comments (post_id, user_id, body)
       VALUES (?, ?, ?)`,
      [postId, userId, body],
    );
    await conn.execute(
      `UPDATE posts
       SET comments_count = (
         SELECT COUNT(*) FROM post_comments
         WHERE post_id = ? AND deleted_at IS NULL
       )
       WHERE id = ?`,
      [postId, postId],
    );
    await conn.commit();
    return findCommentById(result.insertId);
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

async function findCommentLike(commentId, userId) {
  const [rows] = await pool.execute(
    `SELECT id FROM comment_likes WHERE comment_id = ? AND user_id = ? LIMIT 1`,
    [commentId, userId],
  );
  return rows[0] || null;
}

async function addCommentLike(commentId, userId) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    await conn.execute(
      `INSERT IGNORE INTO comment_likes (comment_id, user_id) VALUES (?, ?)`,
      [commentId, userId],
    );
    await conn.execute(
      `UPDATE post_comments
       SET likes_count = (
         SELECT COUNT(*) FROM comment_likes WHERE comment_id = ?
       )
       WHERE id = ?`,
      [commentId, commentId],
    );
    await conn.commit();
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

async function removeCommentLike(commentId, userId) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    await conn.execute(
      `DELETE FROM comment_likes WHERE comment_id = ? AND user_id = ?`,
      [commentId, userId],
    );
    await conn.execute(
      `UPDATE post_comments
       SET likes_count = (
         SELECT COUNT(*) FROM comment_likes WHERE comment_id = ?
       )
       WHERE id = ?`,
      [commentId, commentId],
    );
    await conn.commit();
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

module.exports = {
  listPosts,
  findPostById,
  createPost,
  softDeletePost,
  findPostLike,
  addPostLike,
  removePostLike,
  listComments,
  findCommentById,
  createComment,
  findCommentLike,
  addCommentLike,
  removeCommentLike,
};
