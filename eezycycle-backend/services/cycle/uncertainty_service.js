/**
 * Phase 2 — uncertainty half-widths (days) from variability + confidence.
 * Used for prediction ranges and fertile-window expansion.
 */

/**
 * @param {{
 *   cycle_stddev?: number,
 *   recent_cycle_stddev?: number,
 *   cycle_range?: number,
 *   N?: number,
 *   prediction_confidence?: string,
 *   irregular?: boolean,
 * }} profile
 */
function computeUncertainty(profile) {
  const sd = Math.max(
    Number(profile.cycle_stddev) || 0,
    Number(profile.recent_cycle_stddev) || 0,
  );
  const range = Number(profile.cycle_range) || 0;
  const conf = profile.prediction_confidence || 'low';
  const N = profile.N || 0;

  // Base from stddev / range
  let periodHalf = Math.max(1, Math.round(sd || range / 4 || 2));
  if (N < 3) periodHalf = Math.max(periodHalf, 3);
  if (profile.irregular) periodHalf = Math.max(periodHalf, 3);

  if (conf === 'high') {
    periodHalf = Math.min(Math.max(periodHalf, 1), 2);
  } else if (conf === 'medium') {
    periodHalf = Math.min(Math.max(periodHalf, 2), 4);
  } else {
    periodHalf = Math.min(Math.max(periodHalf, 3), 7);
  }

  // Ovulation uncertainty slightly tighter than period (Luteal assumed fixed)
  let ovHalf = Math.max(1, Math.round(periodHalf * 0.75));
  if (conf === 'high') ovHalf = Math.min(ovHalf, 2);
  if (conf === 'low') ovHalf = Math.max(ovHalf, 2);
  ovHalf = Math.min(ovHalf, 5);

  return {
    period_uncertainty_days: periodHalf,
    ovulation_uncertainty_days: ovHalf,
  };
}

/**
 * Expand a most-likely date into [earliest, latest].
 * @param {string} date YYYY-MM-DD
 * @param {number} halfDays
 * @param {(d: string, n: number) => string} addDays
 */
function dateRange(date, halfDays, addDays) {
  const half = Math.max(0, Number(halfDays) || 0);
  return {
    rangeStart: addDays(date, -half),
    rangeEnd: addDays(date, half),
  };
}

module.exports = {
  computeUncertainty,
  dateRange,
};
