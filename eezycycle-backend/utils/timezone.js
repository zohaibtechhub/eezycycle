/**
 * Convert a local wall-clock time in `timeZone` to a UTC Date.
 * Handles DST with a two-pass offset correction.
 *
 * @param {string} ymd YYYY-MM-DD
 * @param {string} hhmm HH:mm (24h)
 * @param {string} timeZone IANA timezone e.g. Asia/Karachi
 * @returns {Date}
 */
function zonedLocalToUtc(ymd, hhmm, timeZone) {
  const tz = timeZone && String(timeZone).trim() ? String(timeZone).trim() : 'UTC';
  const [y, m, d] = ymd.split('-').map(Number);
  const [hh, mm] = hhmm.split(':').map(Number);

  const asUtcMs = (offsetMs) =>
    Date.UTC(y, m - 1, d, hh || 0, mm || 0, 0) - offsetMs;

  let utcMs = asUtcMs(0);
  for (let i = 0; i < 2; i += 1) {
    const offsetMs = getTimezoneOffsetMs(tz, new Date(utcMs));
    utcMs = asUtcMs(offsetMs);
  }
  return new Date(utcMs);
}

/**
 * @param {string} timeZone
 * @param {Date} date
 * @returns {number} offset such that local = utc + offset (ms)
 */
function getTimezoneOffsetMs(timeZone, date) {
  const dtf = new Intl.DateTimeFormat('en-US', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hourCycle: 'h23',
  });
  const parts = dtf.formatToParts(date);
  const map = {};
  for (const p of parts) {
    if (p.type !== 'literal') map[p.type] = p.value;
  }
  const asUtc = Date.UTC(
    Number(map.year),
    Number(map.month) - 1,
    Number(map.day),
    Number(map.hour),
    Number(map.minute),
    Number(map.second),
  );
  return asUtc - date.getTime();
}

/**
 * Today as YYYY-MM-DD in the given timezone.
 * @param {string} [timeZone]
 * @param {Date} [now]
 */
function todayYmdInZone(timeZone, now = new Date()) {
  const tz = timeZone && String(timeZone).trim() ? String(timeZone).trim() : 'UTC';
  const dtf = new Intl.DateTimeFormat('en-CA', {
    timeZone: tz,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
  return dtf.format(now); // en-CA → YYYY-MM-DD
}

/**
 * Add calendar days to a YYYY-MM-DD string.
 * @param {string} ymd
 * @param {number} days
 */
function addDaysYmd(ymd, days) {
  const [y, m, d] = ymd.split('-').map(Number);
  const dt = new Date(Date.UTC(y, m - 1, d + days));
  const yy = dt.getUTCFullYear();
  const mm = String(dt.getUTCMonth() + 1).padStart(2, '0');
  const dd = String(dt.getUTCDate()).padStart(2, '0');
  return `${yy}-${mm}-${dd}`;
}

/**
 * OneSignal send_after expects "YYYY-MM-DD HH:MM:SS GMT" or ISO-8601.
 * @param {Date} date
 */
function toOnesignalSendAfter(date) {
  return date.toISOString().replace(/\.\d{3}Z$/, 'Z');
}

module.exports = {
  zonedLocalToUtc,
  getTimezoneOffsetMs,
  todayYmdInZone,
  addDaysYmd,
  toOnesignalSendAfter,
};
