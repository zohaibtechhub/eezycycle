const flo = require('../flo_calendar_service');
const lutealPhaseService = require('./luteal_phase_service');
const { dateRange } = require('./uncertainty_service');
const { ESTIMATE_STATUS } = require('./constants');

/**
 * Ovulation estimates: next_period − L, with optional current-cycle evidence update.
 * Ranges express timing uncertainty — not confirmed ovulation.
 *
 * @param {{
 *   lastPeriodStart: string,
 *   C: number,
 *   L?: number,
 *   cyclesAhead?: number,
 *   ovulationUncertaintyDays?: number,
 *   currentOvulationOverride?: string|null,
 *   estimateStatus?: string,
 *   ovulationRangeStart?: string|null,
 *   ovulationRangeEnd?: string|null,
 *   forecastOvulationDate?: string|null,
 * }} input
 * @param {Set<string>} loggedSet
 */
function predictOvulationDays(input, loggedSet) {
  const S = input.lastPeriodStart;
  const C = input.C;
  const L = input.L || lutealPhaseService.DEFAULT_L;
  const cyclesAhead = input.cyclesAhead ?? 6;
  const half = input.ovulationUncertaintyDays ?? 2;
  const override = input.currentOvulationOverride || null;
  const estimateStatus = input.estimateStatus || ESTIMATE_STATUS.FORECAST;
  const rows = [];

  const pushOv = (ov, meta = {}) => {
    if (loggedSet.has(ov)) return;
    if (rows.some((r) => r.date === ov)) return;
    const fallback = dateRange(ov, half, flo.addDays);
    const rangeStart = meta.rangeStart || fallback.rangeStart;
    const rangeEnd = meta.rangeEnd || fallback.rangeEnd;
    rows.push({
      date: ov,
      predictionType: 'ovulation',
      dayType: 'ovulation',
      periodDay: null,
      rangeStart,
      rangeEnd,
      predictedValue: 'ovulation',
      ovulationUncertaintyDays: half,
      estimateStatus: meta.estimateStatus || ESTIMATE_STATUS.FORECAST,
      forecastDate: meta.forecastDate || null,
      ...meta,
    });
  };

  const currentNext = flo.addDays(S, C);
  const calendarOv = flo.addDays(currentNext, -L);
  const currentOv = override || calendarOv;
  pushOv(currentOv, {
    isCurrentCycle: true,
    calendarPrior: calendarOv,
    forecastDate: input.forecastOvulationDate || calendarOv,
    estimateStatus: override ? estimateStatus : ESTIMATE_STATUS.FORECAST,
    rangeStart: input.ovulationRangeStart || undefined,
    rangeEnd: input.ovulationRangeEnd || undefined,
  });

  for (let k = 1; k <= cyclesAhead; k++) {
    const nextStart = flo.addDays(S, k * C);
    pushOv(flo.addDays(nextStart, -L), {
      isCurrentCycle: false,
      estimateStatus: ESTIMATE_STATUS.FORECAST,
    });
  }

  return rows;
}

module.exports = {
  predictOvulationDays,
};
