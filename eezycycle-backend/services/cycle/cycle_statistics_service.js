const flo = require('../flo_calendar_service');
const { C_SELECTION_THRESHOLDS } = require('./constants');

function median(nums) {
  if (!nums.length) return null;
  const sorted = [...nums].sort((a, b) => a - b);
  const mid = Math.floor(sorted.length / 2);
  if (sorted.length % 2 === 0) {
    return Math.round((sorted[mid - 1] + sorted[mid]) / 2);
  }
  return sorted[mid];
}

function stddev(nums) {
  if (nums.length < 2) return 0;
  const mean = nums.reduce((s, n) => s + n, 0) / nums.length;
  const variance =
    nums.reduce((s, n) => s + (n - mean) ** 2, 0) / nums.length;
  return Math.sqrt(variance);
}

/**
 * Recency weights — more weight on newer cycles.
 * For n=6 → [1,1,2,2,3,4] (matches roadmap example).
 * @param {number} n
 * @returns {number[]}
 */
function recencyWeights(n) {
  if (n <= 0) return [];
  if (n === 1) return [1];
  const weights = [];
  for (let i = 0; i < n; i++) {
    weights.push(1 + Math.floor((i * 3) / Math.max(n - 1, 1)));
  }
  weights[n - 1] = Math.max(weights[n - 1], weights[n - 2] + 1);
  return weights;
}

/**
 * @param {number[]} values chronological (oldest → newest)
 */
function weightedMean(values) {
  if (!values.length) return null;
  const weights = recencyWeights(values.length);
  let num = 0;
  let den = 0;
  for (let i = 0; i < values.length; i++) {
    num += values[i] * weights[i];
    den += weights[i];
  }
  return den > 0 ? num / den : null;
}

/**
 * Build Personal Cycle Profile (Phase 2 — weighted recency + variability).
 *
 * Outliers (<21 or >45) are excluded from *forecast* averages but remain in history.
 *
 * @param {{ start: string, cycleLength: number, periodLength: number }[]} completed
 * @param {{ length: number }[]} bleedRuns
 * @param {{ declaredC?: number|null, declaredP?: number|null, lutealDays?: number|null }} [opts]
 */
function buildPersonalCycleProfile(completed, bleedRuns, opts = {}) {
  const recent = (completed || []).slice(-12);
  const allLengths = recent.map((c) => c.cycleLength);
  const usable = recent.filter(
    (c) => c.cycleLength >= 21 && c.cycleLength <= 45,
  );
  const usableLengths = usable.map((c) => c.cycleLength);

  const averages = flo.computeAverages(completed || [], {
    declaredC: opts.declaredC,
    declaredP: opts.declaredP,
    bleedLengths: (bleedRuns || []).map((r) => r.length),
  });

  const periodLens = usable.length
    ? usable.map((c) => c.periodLength)
    : (bleedRuns || []).map((r) => r.length).filter((n) => n >= 3 && n <= 7);

  const cycleMean =
    usableLengths.length > 0
      ? Math.round(
          usableLengths.reduce((s, n) => s + n, 0) / usableLengths.length,
        )
      : averages.C;

  const wMeanRaw = weightedMean(usableLengths);
  const cycleWeightedMean =
    wMeanRaw != null ? Math.round(wMeanRaw) : cycleMean;
  const cycleMedian = median(usableLengths) ?? averages.C;
  const cycleStddev = stddev(usableLengths);
  const cycleRange =
    usableLengths.length > 0
      ? Math.max(...usableLengths) - Math.min(...usableLengths)
      : 0;

  // Recent variability: last up to 3 usable cycles
  const recentSlice = usableLengths.slice(-3);
  const recentCycleMean =
    recentSlice.length > 0
      ? Math.round(
          recentSlice.reduce((s, n) => s + n, 0) / recentSlice.length,
        )
      : cycleMean;
  const recentCycleStddev = stddev(recentSlice);

  const periodMean =
    periodLens.length > 0
      ? Math.round(periodLens.reduce((s, n) => s + n, 0) / periodLens.length)
      : averages.P;
  const periodMedian = median(periodLens) ?? averages.P;
  const periodWeightedRaw = weightedMean(periodLens);
  const periodWeightedMean =
    periodWeightedRaw != null ? Math.round(periodWeightedRaw) : periodMean;

  const lutealMean = opts.lutealDays || flo.DEFAULT_L;

  // Explicit thresholds (C_SELECTION_THRESHOLDS) — median when noisy
  let C;
  let cSource = 'declared_or_default';
  if (usableLengths.length > 0) {
    const pull = Math.abs(cycleWeightedMean - cycleMedian);
    const noisy =
      cycleStddev >= C_SELECTION_THRESHOLDS.HIGH_STDDEV ||
      pull >= C_SELECTION_THRESHOLDS.WEIGHTED_MEDIAN_PULL ||
      cycleRange >= C_SELECTION_THRESHOLDS.LARGE_RANGE;
    if (noisy) {
      C = cycleMedian;
      cSource = 'median_robust';
    } else {
      C = cycleWeightedMean;
      cSource = 'weighted_mean';
    }
  } else {
    C = averages.C;
  }
  C = Math.min(45, Math.max(21, C));
  let P = periodLens.length >= 3 ? periodWeightedMean : averages.P;
  if (
    periodLens.length >= 3 &&
    Math.abs(periodWeightedMean - periodMedian) >=
      C_SELECTION_THRESHOLDS.PERIOD_WEIGHTED_MEDIAN_PULL
  ) {
    P = periodMedian;
  }
  P = Math.min(7, Math.max(3, P));

  const irregular =
    averages.irregular ||
    cycleStddev >= 7 ||
    (usableLengths.length >= 3 && cycleRange >= 10);

  return {
    cycle_mean: cycleMean,
    cycle_median: cycleMedian,
    cycle_weighted_mean: cycleWeightedMean,
    cycle_stddev: Math.round(cycleStddev * 100) / 100,
    cycle_range: cycleRange,
    recent_cycle_mean: recentCycleMean,
    recent_cycle_stddev: Math.round(recentCycleStddev * 100) / 100,
    period_mean: periodMean,
    period_median: periodMedian,
    period_weighted_mean: periodWeightedMean,
    luteal_mean: lutealMean,
    luteal_stddev: null,
    C,
    P,
    L: lutealMean,
    c_source: cSource,
    N: usableLengths.length,
    irregular,
    fertile_window_mode: irregular ? 'wide' : 'standard',
    regularity_score: null,
    data_quality: null,
    prediction_confidence: null,
    prediction_confidence_score: null,
    period_uncertainty_days: null,
    ovulation_uncertainty_days: null,
    history_cycle_count: allLengths.length,
    forecast_cycle_count: usableLengths.length,
    cycle_weights: recencyWeights(usableLengths.length),
  };
}

module.exports = {
  buildPersonalCycleProfile,
  median,
  stddev,
  recencyWeights,
  weightedMean,
  C_SELECTION_THRESHOLDS,
};
