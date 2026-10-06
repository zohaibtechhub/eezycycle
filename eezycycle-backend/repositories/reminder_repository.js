const { pool } = require('../config/db');

const SELECT_FULL = `SELECT user_id, fertile_days_enabled, pregnancy_test_enabled,
            daily_tips_enabled, period_reminder_enabled,
            quiet_hours_start, quiet_hours_end, timezone,
            created_at, updated_at
     FROM reminder_preferences
     WHERE user_id = ?
     LIMIT 1`;

const SELECT_LEGACY = `SELECT user_id, fertile_days_enabled, pregnancy_test_enabled,
            daily_tips_enabled, period_reminder_enabled,
            created_at, updated_at
     FROM reminder_preferences
     WHERE user_id = ?
     LIMIT 1`;

let supportsQuietHours = true;

async function findByUserId(userId) {
  try {
    const sql = supportsQuietHours ? SELECT_FULL : SELECT_LEGACY;
    const [rows] = await pool.execute(sql, [userId]);
    const row = rows[0] || null;
    if (row && !supportsQuietHours) {
      row.quiet_hours_start = null;
      row.quiet_hours_end = null;
      row.timezone = null;
    }
    return row;
  } catch (err) {
    if (supportsQuietHours && /Unknown column|ER_BAD_FIELD_ERROR/i.test(String(err?.message || err))) {
      supportsQuietHours = false;
      return findByUserId(userId);
    }
    throw err;
  }
}

async function upsert(userId, prefs, connection) {
  const db = connection || pool;

  if (!supportsQuietHours) {
    await db.execute(
      `INSERT INTO reminder_preferences (
         user_id, fertile_days_enabled, pregnancy_test_enabled,
         daily_tips_enabled, period_reminder_enabled
       ) VALUES (?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         fertile_days_enabled = VALUES(fertile_days_enabled),
         pregnancy_test_enabled = VALUES(pregnancy_test_enabled),
         daily_tips_enabled = VALUES(daily_tips_enabled),
         period_reminder_enabled = VALUES(period_reminder_enabled)`,
      [
        userId,
        prefs.fertileDaysEnabled ? 1 : 0,
        prefs.pregnancyTestEnabled ? 1 : 0,
        prefs.dailyTipsEnabled !== false ? 1 : 0,
        prefs.periodReminderEnabled ? 1 : 0,
      ],
    );
    return findByUserId(userId);
  }

  try {
    await db.execute(
      `INSERT INTO reminder_preferences (
         user_id, fertile_days_enabled, pregnancy_test_enabled,
         daily_tips_enabled, period_reminder_enabled,
         quiet_hours_start, quiet_hours_end, timezone
       ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         fertile_days_enabled = VALUES(fertile_days_enabled),
         pregnancy_test_enabled = VALUES(pregnancy_test_enabled),
         daily_tips_enabled = VALUES(daily_tips_enabled),
         period_reminder_enabled = VALUES(period_reminder_enabled),
         quiet_hours_start = VALUES(quiet_hours_start),
         quiet_hours_end = VALUES(quiet_hours_end),
         timezone = VALUES(timezone)`,
      [
        userId,
        prefs.fertileDaysEnabled ? 1 : 0,
        prefs.pregnancyTestEnabled ? 1 : 0,
        prefs.dailyTipsEnabled !== false ? 1 : 0,
        prefs.periodReminderEnabled ? 1 : 0,
        prefs.quietHoursStart || null,
        prefs.quietHoursEnd || null,
        prefs.timezone || null,
      ],
    );
  } catch (err) {
    if (/Unknown column|ER_BAD_FIELD_ERROR/i.test(String(err?.message || err))) {
      supportsQuietHours = false;
      return upsert(userId, prefs, connection);
    }
    throw err;
  }
  return findByUserId(userId);
}

module.exports = {
  findByUserId,
  upsert,
};
