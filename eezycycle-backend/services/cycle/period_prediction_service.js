const flo = require('../flo_calendar_service');
const { dateRange } = require('./uncertainty_service');
const { ESTIMATE_STATUS } = require('./constants');

/**
 * Period predictions with explicit forecast vs estimate (v4.1 freeze).
 *
 * Today both start equal (no period-moving biomarkers yet), but fields are
 * distinct so validation can compare original forecast vs later estimate.
 *
 * @param {{
 *   lastPeriodStart: string,
 *   C: number,
 *   P: number,
 *   cyclesAhead?: number,
 *   periodUncertaintyDays?: number,
 *   forecastPeriodStart?: string|null,
 *   estimatedPeriodStart?: string|null,
 * }} input
 * @param {Set<string>} loggedSet
 */
function predictPeriodDays(input, loggedSet) {
  const S = input.lastPeriodStart;
  const C = input.C;
  const P = input.P;
  const cyclesAhead = input.cyclesAhead ?? 6;
  const half = input.periodUncertaintyDays ?? 2;
  const rows = [];

  // Open-cycle next period (k=1) — primary validation target
  const forecastStart =
    input.forecastPeriodStart || flo.addDays(S, C);
  const estimatedStart =
    input.estimatedPeriodStart || forecastStart;

  for (let k = 1; k <= cyclesAhead; k++) {
    const nextStart =
      k === 1 ? estimatedStart : flo.addDays(S, k * C);
    const forecastForCycle =
      k === 1 ? forecastStart : flo.addDays(S, k * C);

    for (let d = 0; d < P; d++) {
      const date = flo.addDays(nextStart, d);
      if (loggedSet.has(date)) continue;
      const { rangeStart, rangeEnd } = dateRange(date, half, flo.addDays);
      rows.push({
        date,
        predictionType: 'period',
        dayType: 'period',
        periodDay: d + 1,
        rangeStart,
        rangeEnd,
        predictedValue: 'period',
        estimateStatus: ESTIMATE_STATUS.FORECAST,
        forecastPeriodStart: forecastForCycle,
        estimatedPeriodStart: nextStart,
        // Day-1 carries the period-start envelope
        ...(d === 0
          ? {
              periodRangeStart: flo.addDays(nextStart, -half),
              periodRangeEnd: flo.addDays(nextStart, half),
            }
          : {}),
      });
    }
  }

  return rows;
}

/**
 * Summarize next period forecast/estimate for API / validation.
 */
function summarizeNextPeriod(input) {
  const S = input.lastPeriodStart;
  const C = input.C;
  const half = input.periodUncertaintyDays ?? 2;
  const forecast = input.forecastPeriodStart || flo.addDays(S, C);
  const estimated = input.estimatedPeriodStart || forecast;
  return {
    forecast_period_start: forecast,
    estimated_period_start: estimated,
    period_range_start: flo.addDays(estimated, -half),
    period_range_end: flo.addDays(estimated, half),
    estimate_status: ESTIMATE_STATUS.FORECAST,
  };
}

module.exports = {
  predictPeriodDays,
  summarizeNextPeriod,
};
