const flo = require('../flo_calendar_service');

/**
 * Group logged period dates into bleed runs (truth → cycle history).
 * @param {string[]} loggedDates
 */
function buildBleedRuns(loggedDates) {
  return flo.groupBleedRuns(loggedDates || []);
}

/**
 * @param {{ start: string, length: number }[]} runs
 */
function completedCycles(runs) {
  return flo.completedCyclesFromRuns(runs);
}

/**
 * @param {string[]} loggedDates
 * @returns {string|null}
 */
function lastPeriodStart(loggedDates) {
  const runs = buildBleedRuns(loggedDates);
  if (!runs.length) return null;
  return runs[runs.length - 1].start;
}

module.exports = {
  buildBleedRuns,
  completedCycles,
  lastPeriodStart,
};
