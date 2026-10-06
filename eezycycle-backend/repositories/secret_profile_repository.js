const { pool } = require('../config/db');

function serializeProfile(row, tags = [], avatarUrl = null) {
  if (!row) return null;
  return {
    user_id: row.user_id,
    username: row.username,
    avatar_url: avatarUrl || row.avatar_url || null,
    tags: Array.isArray(tags) ? tags : [],
    created_at: row.created_at,
    updated_at: row.updated_at,
  };
}

async function findByUserId(userId) {
  const [rows] = await pool.execute(
    `SELECT user_id, username, avatar_url, created_at, updated_at
     FROM secret_profiles
     WHERE user_id = ?
     LIMIT 1`,
    [userId],
  );
  return rows[0] || null;
}

async function findByUsername(username) {
  const [rows] = await pool.execute(
    `SELECT user_id, username, avatar_url, created_at, updated_at
     FROM secret_profiles
     WHERE username = ?
     LIMIT 1`,
    [username],
  );
  return rows[0] || null;
}

async function listTags(userId) {
  const [rows] = await pool.execute(
    `SELECT tag_key
     FROM secret_profile_tags
     WHERE user_id = ?
     ORDER BY id ASC`,
    [userId],
  );
  return rows.map((r) => r.tag_key);
}

async function upsertProfile(userId, { username, avatarUrl = null }) {
  await pool.execute(
    `INSERT INTO secret_profiles (user_id, username, avatar_url)
     VALUES (?, ?, ?)
     ON DUPLICATE KEY UPDATE
       username = VALUES(username),
       avatar_url = COALESCE(VALUES(avatar_url), avatar_url),
       updated_at = CURRENT_TIMESTAMP`,
    [userId, username, avatarUrl],
  );
  return findByUserId(userId);
}

async function replaceTags(userId, tags = []) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    await conn.execute(
      `DELETE FROM secret_profile_tags WHERE user_id = ?`,
      [userId],
    );

    const unique = [...new Set(tags.map((t) => String(t).trim()).filter(Boolean))];
    for (const tag of unique) {
      // eslint-disable-next-line no-await-in-loop
      await conn.execute(
        `INSERT INTO secret_profile_tags (user_id, tag_key) VALUES (?, ?)`,
        [userId, tag.slice(0, 64)],
      );
    }

    await conn.commit();
    return unique;
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

async function getUserAvatarUrl(userId) {
  const [rows] = await pool.execute(
    `SELECT avatar_url FROM users
     WHERE id = ? AND deleted_at IS NULL AND is_active = 1
     LIMIT 1`,
    [userId],
  );
  return rows[0]?.avatar_url || null;
}

async function getPublicAuthor(userId) {
  const row = await findByUserId(userId);
  const avatarUrl = await getUserAvatarUrl(userId);
  if (!row) {
    return {
      username: 'Anonymous',
      avatar_url: avatarUrl,
    };
  }
  return {
    username: row.username,
    avatar_url: avatarUrl || row.avatar_url || null,
  };
}

module.exports = {
  serializeProfile,
  findByUserId,
  findByUsername,
  listTags,
  upsertProfile,
  replaceTags,
  getPublicAuthor,
  getUserAvatarUrl,
};
