const { pool } = require('../config/db');

function parseJson(value, fallback) {
  if (value == null) return fallback;
  if (typeof value === 'object') return value;
  try {
    return JSON.parse(value);
  } catch (_) {
    return fallback;
  }
}

function mapRow(row) {
  if (!row) return null;
  return {
    id: `preg_insight_w${row.week}`,
    week: Number(row.week),
    day_in_week: row.day_in_week === -1 ? null : Number(row.day_in_week),
    locale: row.locale || 'en',
    is_published: Boolean(row.is_published),
    baby: {
      title: row.baby_title,
      short_summary: row.baby_short_summary,
      size_label: row.baby_size_label,
      size_asset: row.baby_size_asset,
      illustration_asset: row.baby_illustration_asset,
      body_markdown: row.baby_body_markdown,
      length_cm:
        row.baby_length_cm != null ? Number(row.baby_length_cm) : null,
      weight_g: row.baby_weight_g != null ? Number(row.baby_weight_g) : null,
      milestones: parseJson(row.baby_milestones_json, []),
    },
    body: {
      title: row.body_title,
      short_summary: row.body_short_summary,
      illustration_asset: row.body_illustration_asset,
      body_markdown: row.body_body_markdown,
      highlights: parseJson(row.body_highlights_json, []),
    },
    symptoms: {
      title: row.symptoms_title || 'Symptoms',
      common_keys: parseJson(row.symptoms_common_keys_json, []),
      tip: row.symptoms_tip,
    },
    stories: parseJson(row.stories_json, []),
    what_to_expect: parseJson(row.what_to_expect_json, null),
  };
}

/**
 * Prefer exact day override, else week row (-1), else nearest previous week.
 * @param {number} week
 * @param {number|null} dayInWeek
 * @param {string} [locale]
 */
async function findForWeek(week, dayInWeek = null, locale = 'en') {
  const w = Math.max(0, Math.min(42, Number(week) || 0));
  const day =
    dayInWeek == null || Number.isNaN(Number(dayInWeek))
      ? null
      : Math.max(0, Math.min(6, Number(dayInWeek)));

  try {
    if (day != null) {
      const [exact] = await pool.execute(
        `SELECT * FROM pregnancy_weekly_insights
         WHERE week = ? AND day_in_week = ? AND locale = ? AND is_published = 1
         LIMIT 1`,
        [w, day, locale],
      );
      if (exact[0]) return mapRow(exact[0]);
    }

    const [weekRow] = await pool.execute(
      `SELECT * FROM pregnancy_weekly_insights
       WHERE week = ? AND day_in_week = -1 AND locale = ? AND is_published = 1
       LIMIT 1`,
      [w, locale],
    );
    if (weekRow[0]) return mapRow(weekRow[0]);

    const [prev] = await pool.execute(
      `SELECT * FROM pregnancy_weekly_insights
       WHERE week <= ? AND day_in_week = -1 AND locale = ? AND is_published = 1
       ORDER BY week DESC
       LIMIT 1`,
      [w, locale],
    );
    return mapRow(prev[0] || null);
  } catch (err) {
    // Table not imported yet — caller falls back to empty.
    if (err && (err.code === 'ER_NO_SUCH_TABLE' || err.errno === 1146)) {
      return null;
    }
    throw err;
  }
}

module.exports = {
  findForWeek,
  mapRow,
};
