const { pool } = require('../config/db');

async function deletePredictedForUser(userId, connection) {
  const db = connection || pool;
  await db.execute(`DELETE FROM cycle_predictions WHERE user_id = ?`, [userId]);
}

/**
 * @param {number} userId
 * @param {Array<{
 *   date: string,
 *   predictionType: string,
 *   dayType?: string,
 *   periodDay?: number|null,
 *   rangeStart?: string|null,
 *   rangeEnd?: string|null,
 *   confidence?: string,
 *   confidenceScore?: number|null,
 *   evidenceLevel?: string,
 *   evidenceSources?: string[],
 *   predictedValue?: string|null,
 * }>} rows
 * @param {string} algorithmVersion
 * @param {import('mysql2/promise').PoolConnection} [connection]
 */
async function replaceAll(userId, rows, algorithmVersion, connection) {
  // Dedupe by (date, predictionType)
  const byKey = new Map();
  for (const row of rows || []) {
    if (!row?.date || !row?.predictionType) continue;
    byKey.set(`${row.date}|${row.predictionType}`, row);
  }
  const unique = [...byKey.values()];

  const ownConn = !connection;
  const conn = connection || (await pool.getConnection());

  try {
    if (ownConn) await conn.beginTransaction();
    await deletePredictedForUser(userId, conn);

    for (const row of unique) {
      const dayType = row.dayType || row.predictionType;
      const sources = Array.isArray(row.evidenceSources)
        ? JSON.stringify(row.evidenceSources)
        : row.evidenceSources
          ? JSON.stringify(row.evidenceSources)
          : JSON.stringify(['historical_cycle_data']);

      await conn.execute(
        `INSERT INTO cycle_predictions
           (user_id, pred_date, prediction_type, day_type, period_day,
            range_start, range_end, confidence, confidence_score,
            evidence_level, evidence_sources, predicted_value,
            algorithm_version, generated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
         ON DUPLICATE KEY UPDATE
           day_type = VALUES(day_type),
           period_day = VALUES(period_day),
           range_start = VALUES(range_start),
           range_end = VALUES(range_end),
           confidence = VALUES(confidence),
           confidence_score = VALUES(confidence_score),
           evidence_level = VALUES(evidence_level),
           evidence_sources = VALUES(evidence_sources),
           predicted_value = VALUES(predicted_value),
           algorithm_version = VALUES(algorithm_version),
           generated_at = CURRENT_TIMESTAMP`,
        [
          userId,
          row.date,
          row.predictionType,
          dayType,
          row.periodDay ?? null,
          row.rangeStart || row.date,
          row.rangeEnd || row.date,
          row.confidence || 'low',
          row.confidenceScore ?? null,
          row.evidenceLevel || 'A',
          sources,
          row.predictedValue || dayType,
          algorithmVersion,
        ],
      );
    }

    if (ownConn) await conn.commit();
  } catch (err) {
    if (ownConn) {
      try {
        await conn.rollback();
      } catch (_) {
        /* ignore */
      }
    }
    throw err;
  } finally {
    if (ownConn) conn.release();
  }
}

/**
 * TODAY UPDATE helper — delete predictions in [from, to], then upsert rows.
 * Leaves predictions outside the window untouched.
 *
 * @param {number} userId
 * @param {string} from YYYY-MM-DD
 * @param {string} to YYYY-MM-DD
 * @param {Array<object>} rows
 * @param {string} algorithmVersion
 */
async function replaceInRange(userId, from, to, rows, algorithmVersion) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    await conn.execute(
      `DELETE FROM cycle_predictions
       WHERE user_id = ? AND pred_date BETWEEN ? AND ?`,
      [userId, from, to],
    );

    const byKey = new Map();
    for (const row of rows || []) {
      if (!row?.date || !row?.predictionType) continue;
      if (row.date < from || row.date > to) continue;
      byKey.set(`${row.date}|${row.predictionType}`, row);
    }

    for (const row of byKey.values()) {
      const dayType = row.dayType || row.predictionType;
      const sources = Array.isArray(row.evidenceSources)
        ? JSON.stringify(row.evidenceSources)
        : row.evidenceSources
          ? JSON.stringify(row.evidenceSources)
          : JSON.stringify(['historical_cycle_data']);

      await conn.execute(
        `INSERT INTO cycle_predictions
           (user_id, pred_date, prediction_type, day_type, period_day,
            range_start, range_end, confidence, confidence_score,
            evidence_level, evidence_sources, predicted_value,
            algorithm_version, generated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
         ON DUPLICATE KEY UPDATE
           day_type = VALUES(day_type),
           period_day = VALUES(period_day),
           range_start = VALUES(range_start),
           range_end = VALUES(range_end),
           confidence = VALUES(confidence),
           confidence_score = VALUES(confidence_score),
           evidence_level = VALUES(evidence_level),
           evidence_sources = VALUES(evidence_sources),
           predicted_value = VALUES(predicted_value),
           algorithm_version = VALUES(algorithm_version),
           generated_at = CURRENT_TIMESTAMP`,
        [
          userId,
          row.date,
          row.predictionType,
          dayType,
          row.periodDay ?? null,
          row.rangeStart || row.date,
          row.rangeEnd || row.date,
          row.confidence || 'low',
          row.confidenceScore ?? null,
          row.evidenceLevel || 'A',
          sources,
          row.predictedValue || dayType,
          algorithmVersion,
        ],
      );
    }

    await conn.commit();
  } catch (err) {
    try {
      await conn.rollback();
    } catch (_) {
      /* ignore */
    }
    throw err;
  } finally {
    conn.release();
  }
}

async function listByUserId(userId, from, to) {
  if (from && to) {
    const [rows] = await pool.execute(
      `SELECT pred_date, prediction_type, day_type, period_day,
              range_start, range_end, confidence, confidence_score,
              evidence_level, evidence_sources, predicted_value,
              algorithm_version, generated_at, updated_at
       FROM cycle_predictions
       WHERE user_id = ? AND pred_date BETWEEN ? AND ?
       ORDER BY pred_date ASC, prediction_type ASC`,
      [userId, from, to],
    );
    return rows;
  }

  const [rows] = await pool.execute(
    `SELECT pred_date, prediction_type, day_type, period_day,
            range_start, range_end, confidence, confidence_score,
            evidence_level, evidence_sources, predicted_value,
            algorithm_version, generated_at, updated_at
     FROM cycle_predictions
     WHERE user_id = ?
     ORDER BY pred_date ASC, prediction_type ASC`,
    [userId],
  );
  return rows;
}

module.exports = {
  deletePredictedForUser,
  replaceAll,
  replaceInRange,
  listByUserId,
};
