const { pool } = require('../config/db');

/**
 * @param {number} userId
 * @param {string} observationType
 * @param {import('mysql2/promise').PoolConnection} [connection]
 */
async function deleteByUserAndType(userId, observationType, connection) {
  const db = connection || pool;
  await db.execute(
    `DELETE FROM cycle_observations WHERE user_id = ? AND observation_type = ?`,
    [userId, observationType],
  );
}

/**
 * Delete one observation (user, date, type).
 * @param {number} userId
 * @param {string} obsDate
 * @param {string} observationType
 * @param {import('mysql2/promise').PoolConnection} [connection]
 */
async function deleteOne(userId, obsDate, observationType, connection) {
  const db = connection || pool;
  await db.execute(
    `DELETE FROM cycle_observations
     WHERE user_id = ? AND obs_date = ? AND observation_type = ?`,
    [userId, obsDate, observationType],
  );
}

/**
 * Upsert a single observation row.
 * @param {number} userId
 * @param {{ date: string, type: string, value?: object|null, source?: string }} row
 * @param {import('mysql2/promise').PoolConnection} [connection]
 */
async function upsert(userId, row, connection) {
  const db = connection || pool;
  const valueJson =
    row.value == null ? null : JSON.stringify(row.value);
  await db.execute(
    `INSERT INTO cycle_observations
       (user_id, obs_date, observation_type, value_json, source)
     VALUES (?, ?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE
       value_json = VALUES(value_json),
       source = VALUES(source),
       updated_at = CURRENT_TIMESTAMP`,
    [
      userId,
      row.date,
      row.type,
      valueJson,
      row.source || 'user',
    ],
  );
}

/**
 * Replace all period observations for a user with the given dates (truth layer).
 * @param {number} userId
 * @param {string[]} dates YYYY-MM-DD
 * @param {import('mysql2/promise').PoolConnection} [connection]
 */
async function replacePeriodObservations(userId, dates, connection) {
  const db = connection || pool;
  await deleteByUserAndType(userId, 'period', db);

  for (const obsDate of dates) {
    await upsert(
      userId,
      {
        date: obsDate,
        type: 'period',
        value: { logged: true },
        source: 'user',
      },
      db,
    );
  }
}

/**
 * @param {number} userId
 * @param {string} [observationType]
 * @param {{ from?: string, to?: string }} [range]
 */
async function listByUserId(userId, observationType, range = {}) {
  const clauses = ['user_id = ?'];
  const params = [userId];

  if (observationType) {
    clauses.push('observation_type = ?');
    params.push(observationType);
  }
  if (range.from) {
    clauses.push('obs_date >= ?');
    params.push(range.from);
  }
  if (range.to) {
    clauses.push('obs_date <= ?');
    params.push(range.to);
  }

  const [rows] = await pool.execute(
    `SELECT id, user_id, obs_date, observation_type, value_json, source, created_at, updated_at
     FROM cycle_observations
     WHERE ${clauses.join(' AND ')}
     ORDER BY obs_date ASC, observation_type ASC`,
    params,
  );
  return rows;
}

module.exports = {
  deleteByUserAndType,
  deleteOne,
  upsert,
  replacePeriodObservations,
  listByUserId,
};
