const { pool } = require('../config/db');

async function findByUserId(userId) {
  try {
    const [rows] = await pool.execute(
      `SELECT user_id, birth_year, height_cm, weight_kg, is_metric,
              experience_mode, pregnancy_mode_active, due_date,
              lmp_based_edd, clinician_edd, edd_source,
              discovery_source, usage_path, partner_code_entered,
              avg_cycle_length, avg_period_length, luteal_phase_days,
              fertile_window_mode, timezone, onboarding_completed_at,
              created_at, updated_at
       FROM user_profiles
       WHERE user_id = ?
       LIMIT 1`,
      [userId],
    );
    return rows[0] || null;
  } catch (err) {
    // Before migration 016 — fall back without EDD columns
    if (err && (err.code === 'ER_BAD_FIELD_ERROR' || err.errno === 1054)) {
      const [rows] = await pool.execute(
        `SELECT user_id, birth_year, height_cm, weight_kg, is_metric,
                experience_mode, pregnancy_mode_active, due_date,
                discovery_source, usage_path, partner_code_entered,
                avg_cycle_length, avg_period_length, luteal_phase_days,
                fertile_window_mode, timezone, onboarding_completed_at,
                created_at, updated_at
         FROM user_profiles
         WHERE user_id = ?
         LIMIT 1`,
        [userId],
      );
      return rows[0] || null;
    }
    throw err;
  }
}

async function ensureExists(userId, connection) {
  const db = connection || pool;
  await db.execute(
    `INSERT IGNORE INTO user_profiles (user_id) VALUES (?)`,
    [userId],
  );
}

/**
 * Partial update — only provided keys are written.
 * @param {number} userId
 * @param {Record<string, unknown>} fields
 * @param {import('mysql2/promise').PoolConnection} [connection]
 */
async function update(userId, fields, connection) {
  const db = connection || pool;
  const allowed = [
    'birth_year',
    'height_cm',
    'weight_kg',
    'is_metric',
    'experience_mode',
    'pregnancy_mode_active',
    'due_date',
    'lmp_based_edd',
    'clinician_edd',
    'edd_source',
    'discovery_source',
    'usage_path',
    'partner_code_entered',
    'avg_cycle_length',
    'avg_period_length',
    'luteal_phase_days',
    'fertile_window_mode',
    'timezone',
    'onboarding_completed_at',
  ];

  const sets = [];
  const values = [];

  for (const key of allowed) {
    if (Object.prototype.hasOwnProperty.call(fields, key)) {
      sets.push(`${key} = ?`);
      values.push(fields[key]);
    }
  }

  if (sets.length === 0) {
    return findByUserId(userId);
  }

  values.push(userId);
  try {
    await db.execute(
      `UPDATE user_profiles SET ${sets.join(', ')} WHERE user_id = ?`,
      values,
    );
  } catch (err) {
    if (err && (err.code === 'ER_BAD_FIELD_ERROR' || err.errno === 1054)) {
      const legacyAllowed = new Set([
        'birth_year',
        'height_cm',
        'weight_kg',
        'is_metric',
        'experience_mode',
        'pregnancy_mode_active',
        'due_date',
        'discovery_source',
        'usage_path',
        'partner_code_entered',
        'avg_cycle_length',
        'avg_period_length',
        'luteal_phase_days',
        'fertile_window_mode',
        'timezone',
        'onboarding_completed_at',
      ]);
      const legacySets = [];
      const legacyValues = [];
      for (const key of allowed) {
        if (
          Object.prototype.hasOwnProperty.call(fields, key) &&
          legacyAllowed.has(key)
        ) {
          legacySets.push(`${key} = ?`);
          legacyValues.push(fields[key]);
        }
      }
      if (legacySets.length) {
        legacyValues.push(userId);
        await db.execute(
          `UPDATE user_profiles SET ${legacySets.join(', ')} WHERE user_id = ?`,
          legacyValues,
        );
      }
    } else {
      throw err;
    }
  }
  return findByUserId(userId);
}

module.exports = {
  findByUserId,
  ensureExists,
  update,
};
