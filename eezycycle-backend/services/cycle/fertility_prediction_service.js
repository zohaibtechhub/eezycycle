const flo = require('../flo_calendar_service');
const { FERTILE_WINDOW } = require('./constants');

/**
 * Fertile window (v4.1 freeze):
 *
 * CORE (ASRM-style counseling interval):
 *   ovulation − 5  →  ovulation   (6 days ending on ovulation)
 *
 * EXTENDED (optional product conservatism):
 *   ovulation − 5  →  ovulation + 1
 *
 * Timing uncertainty is stored on the ovulation estimate range and does NOT
 * paint extra days as equally fertile.
 *
 * Calendar rows: ovulation day itself is prediction_type=ovulation;
 * fertility rows are the neighbors in the chosen window.
 *
 * @param {{ date: string }[]} ovulationRows
 * @param {{ mode?: 'core'|'extended' }} [opts]
 * @param {Set<string>} loggedSet
 * @param {Set<string>} [skipDates]
 */
function predictFertilityDays(ovulationRows, opts, loggedSet, skipDates) {
  const mode = opts?.mode || FERTILE_WINDOW.DEFAULT_MODE;
  const skipSet = skipDates || new Set();
  const rows = [];
  const seen = new Set();

  for (const ovRow of ovulationRows || []) {
    const ov = ovRow.date;
    const windows = computeFertileWindows(ov);
    const active =
      mode === FERTILE_WINDOW.CORE ? windows.core : windows.extended;

    let cursor = active.start;
    while (cursor <= active.end) {
      if (
        cursor !== ov &&
        !loggedSet.has(cursor) &&
        !skipSet.has(cursor) &&
        !seen.has(cursor)
      ) {
        seen.add(cursor);
        rows.push({
          date: cursor,
          predictionType: 'fertility',
          dayType: 'fertility',
          periodDay: null,
          rangeStart: active.start,
          rangeEnd: active.end,
          predictedValue: 'fertility',
          fertileWindowMode: mode,
          coreFertileStart: windows.core.start,
          coreFertileEnd: windows.core.end,
          extendedFertileStart: windows.extended.start,
          extendedFertileEnd: windows.extended.end,
          // Back-compat aliases (extended by default)
          biologicalFertileStart: windows.extended.start,
          biologicalFertileEnd: windows.extended.end,
        });
      }
      cursor = flo.addDays(cursor, 1);
    }
  }

  return rows;
}

/**
 * @param {string} ov estimated ovulation YYYY-MM-DD
 * @returns {{
 *   core: { start: string, end: string },
 *   extended: { start: string, end: string },
 * }}
 */
function computeFertileWindows(ov) {
  return {
    core: {
      start: flo.addDays(ov, -5),
      end: ov,
    },
    extended: {
      start: flo.addDays(ov, -5),
      end: flo.addDays(ov, 1),
    },
  };
}

/**
 * @deprecated Prefer computeFertileWindows().core / .extended
 * Returns EXTENDED window for older call sites that expected ov−5…ov+1.
 */
function computeBiologicalFertileWindow(ov) {
  const w = computeFertileWindows(ov).extended;
  return { fertileStart: w.start, fertileEnd: w.end };
}

/**
 * @deprecated Uncertainty must not expand fertile calendar days.
 */
function computeFertileWindowFromUncertainty(ov, _uncertaintyDays) {
  return computeBiologicalFertileWindow(ov);
}

module.exports = {
  predictFertilityDays,
  computeFertileWindows,
  computeBiologicalFertileWindow,
  computeFertileWindowFromUncertainty,
  FERTILE_WINDOW,
};
