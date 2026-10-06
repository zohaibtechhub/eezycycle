/**
 * Calendar-date helpers (DATE columns, no time-of-day).
 * Never use Date#toISOString().slice(0,10) — that shifts the day in UTC+ timezones.
 */

const DATE_RE = /^\d{4}-\d{2}-\d{2}$/;

/**
 * @param {unknown} value
 * @returns {string|null} YYYY-MM-DD
 */
function toDateString(value) {
  if (value == null) return null;

  if (value instanceof Date && !Number.isNaN(value.getTime())) {
    const y = value.getFullYear();
    const m = String(value.getMonth() + 1).padStart(2, '0');
    const d = String(value.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  const raw = String(value).trim();
  if (DATE_RE.test(raw)) return raw;

  // mysql2 dateStrings / "Fri Sep 25 2026 ..." — take leading YYYY-MM-DD if present
  const leading = raw.slice(0, 10);
  if (DATE_RE.test(leading)) return leading;

  const parsed = new Date(raw);
  if (!Number.isNaN(parsed.getTime())) {
    const y = parsed.getFullYear();
    const m = String(parsed.getMonth() + 1).padStart(2, '0');
    const d = String(parsed.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  return null;
}

/**
 * @param {string} ymd
 * @param {number} days
 * @returns {string}
 */
function addDays(ymd, days) {
  const base = toDateString(ymd);
  const d = new Date(`${base}T12:00:00`);
  d.setDate(d.getDate() + days);
  return toDateString(d);
}

/**
 * @param {string} a
 * @param {string} b
 * @returns {number}
 */
function diffDays(a, b) {
  const aa = toDateString(a);
  const bb = toDateString(b);
  const ms =
    new Date(`${bb}T12:00:00`).getTime() -
    new Date(`${aa}T12:00:00`).getTime();
  return Math.round(ms / 86400000);
}

module.exports = {
  DATE_RE,
  toDateString,
  addDays,
  diffDays,
};
