const mysql = require('mysql2/promise');
const { env } = require('./env');

const pool = mysql.createPool({
  host: env.db.host,
  port: env.db.port,
  user: env.db.user,
  password: env.db.password,
  database: env.db.database,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  charset: 'utf8mb4',
  // Keep DATE columns as 'YYYY-MM-DD' strings (avoids UTC day-shift from JS Date)
  dateStrings: true,
});

/**
 * Verifies the pool can reach MySQL / eezycycle.
 * @returns {Promise<{ ok: true, database: string }>}
 */
async function pingDb() {
  const connection = await pool.getConnection();
  try {
    await connection.query('SELECT 1 AS ok');
    return { ok: true, database: env.db.database };
  } finally {
    connection.release();
  }
}

module.exports = {
  pool,
  pingDb,
};
