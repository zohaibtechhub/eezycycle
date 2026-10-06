/**
 * Phase 4 — validation hooks: predicted vs actual period starts.
 * Stores data for future tuning; does not invent weight formulas.
 */

const flo = require('../flo_calendar_service');
const predictionRepository = require('../../repositories/prediction_repository');
const validationRepository = require('../../repositories/prediction_validation_repository');
const { ALGORITHM_VERSION } = require('./constants');
const { toDateString, diffDays } = require('../../utils/date');

/**
 * Detect new bleed-run starts vs previous logged set and log vs nearest
 * predicted period day-1.
 *
 * @param {number} userId
 * @param {string[]} previousDates
 * @param {string[]} nextDates
 */
async function logNewPeriodStarts(userId, previousDates, nextDates) {
  const prev = new Set((previousDates || []).map(toDateString).filter(Boolean));
  const next = [...new Set((nextDates || []).map(toDateString).filter(Boolean))].sort();

  const prevRuns = flo.groupBleedRuns([...prev].sort());
  const nextRuns = flo.groupBleedRuns(next);
  const prevStarts = new Set(prevRuns.map((r) => r.start));

  const newStarts = nextRuns
    .map((r) => r.start)
    .filter((s) => !prevStarts.has(s));

  if (newStarts.length === 0) return [];

  let predictions = [];
  try {
    predictions = await predictionRepository.listByUserId(userId);
  } catch (_) {
    predictions = [];
  }

  const predictedStarts = predictions
    .filter(
      (p) =>
        (p.prediction_type || p.day_type) === 'period' &&
        (p.period_day == null || Number(p.period_day) === 1),
    )
    .map((p) => toDateString(p.pred_date))
    .filter(Boolean);

  const logged = [];
  for (const actual of newStarts) {
    let best = null;
    let bestAbs = Infinity;
    for (const pred of predictedStarts) {
      const d = Math.abs(diffDays(pred, actual));
      if (d < bestAbs && d <= 10) {
        bestAbs = d;
        best = pred;
      }
    }
    const delta = best != null ? diffDays(best, actual) : null;
    try {
      await validationRepository.insert({
        userId,
        eventType: 'period_start',
        actualDate: actual,
        predictedDate: best,
        deltaDays: delta,
        algorithmVersion: ALGORITHM_VERSION,
        meta: {
          matched_within_days: best != null ? bestAbs : null,
        },
      });
      logged.push({ actual, predicted: best, delta_days: delta });
    } catch (_) {
      // Table may not exist until migration 017
    }
  }

  return logged;
}

module.exports = {
  logNewPeriodStarts,
};
