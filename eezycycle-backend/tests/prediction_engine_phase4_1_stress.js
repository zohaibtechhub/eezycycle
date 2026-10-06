/**
 * Stress test for ecc_prediction_v4_1 corrections.
 * Run: node tests/prediction_engine_phase4_1_stress.js
 */

const pred = require('../services/cycle/prediction_service');
const evidence = require('../services/cycle/evidence_processor');
const fertility = require('../services/cycle/fertility_prediction_service');
const stats = require('../services/cycle/cycle_statistics_service');
const confidence = require('../services/cycle/confidence_service');
const pregnancy = require('../services/cycle/pregnancy_service');
const flo = require('../services/flo_calendar_service');
const { ALGORITHM_VERSION } = require('../services/cycle/constants');
const { diffDays } = require('../utils/date');

function addDays(d, n) {
  return flo.addDays(d, n);
}
function bleedDays(S, P) {
  const out = [];
  for (let i = 0; i < P; i++) out.push(addDays(S, i));
  return out;
}
function simulateHistory({ start, C, P, cycles }) {
  let S = start;
  const logged = [];
  for (let i = 0; i < cycles; i++) {
    logged.push(...bleedDays(S, P));
    S = addDays(S, C);
  }
  logged.push(...bleedDays(S, P));
  return { loggedDates: [...new Set(logged)].sort(), lastStart: S };
}

const results = { scenarios: 0, assertions: 0, passed: 0, failed: [] };
function assert(cond, msg, ctx) {
  results.assertions++;
  if (cond) {
    results.passed++;
    return true;
  }
  if (results.failed.length < 25) results.failed.push({ msg, ...ctx });
  return false;
}

assert(ALGORITHM_VERSION === 'ecc_prediction_v4_1', 'version', {
  ALGORITHM_VERSION,
});

// --- Median protects C when outlier pulls weighted mean ---
{
  results.scenarios++;
  const lengths = [28, 28, 29, 28, 40, 28];
  let S = '2023-01-01';
  const logged = [];
  for (const L of lengths) {
    logged.push(...bleedDays(S, 5));
    S = addDays(S, L);
  }
  logged.push(...bleedDays(S, 5));
  const out = pred.generatePredictions({
    loggedDates: logged,
    profile: {},
    observations: [],
  });
  assert(
    out.profile.c_source === 'median_robust' ||
      Math.abs(out.profile.C - out.profile.cycle_median) <= 1,
    'outlier → median-protected C',
    {
      C: out.profile.C,
      median: out.profile.cycle_median,
      weighted: out.profile.cycle_weighted_mean,
      source: out.profile.c_source,
    },
  );
}

// --- Biological fertile: core vs extended ---
{
  results.scenarios++;
  const w = fertility.computeFertileWindows('2026-03-15');
  assert(w.core.start === '2026-03-10' && w.core.end === '2026-03-15', 'core ov-5→ov', w.core);
  assert(
    w.extended.start === '2026-03-10' && w.extended.end === '2026-03-16',
    'extended ov-5→ov+1',
    w.extended,
  );
  const coreW = diffDays(w.core.start, w.core.end) + 1;
  const extW = diffDays(w.extended.start, w.extended.end) + 1;
  assert(coreW === 6, 'core width = 6', { coreW });
  assert(extW === 7, 'extended width = 7', { extW });
  const legacy = fertility.computeFertileWindowFromUncertainty('2026-03-15', 5);
  assert(legacy.fertileEnd === w.extended.end, 'legacy helper = extended', legacy);
}

// --- Period forecast vs estimate fields ---
{
  results.scenarios++;
  const hist = simulateHistory({ start: '2024-05-01', C: 28, P: 5, cycles: 3 });
  const out = pred.generatePredictions({
    loggedDates: hist.loggedDates,
    profile: {},
    observations: [],
  });
  assert(!!out.period?.forecast_period_start, 'forecast_period_start', {
    p: out.period,
  });
  assert(!!out.period?.estimated_period_start, 'estimated_period_start', {
    p: out.period,
  });
  assert(
    out.period.forecast_period_start === out.period.estimated_period_start,
    'today forecast===estimate (no period biomarkers)',
    { period: out.period },
  );
  assert(!!out.period?.period_range_start && !!out.period?.period_range_end, 'period range', {
    period: out.period,
  });
}

// --- Explicit C thresholds exported ---
{
  results.scenarios++;
  const t = stats.C_SELECTION_THRESHOLDS;
  assert(t.HIGH_STDDEV === 5, 'HIGH_STDDEV=5', t);
  assert(t.WEIGHTED_MEDIAN_PULL === 3, 'PULL=3', t);
  assert(t.LARGE_RANGE === 10, 'RANGE=10', t);
}

// --- OPK updates estimate toward surge; does not hard-set T+1 as fact ---
{
  results.scenarios++;
  const hist = simulateHistory({ start: '2024-02-01', C: 28, P: 5, cycles: 4 });
  const priorOv = addDays(addDays(hist.lastStart, 28), -14);
  const T = addDays(priorOv, -2);
  const surgeCenter = addDays(T, 1);

  const out = pred.generatePredictions({
    loggedDates: hist.loggedDates,
    profile: { avg_cycle_length: 28 },
    observations: [
      { date: T, type: 'ovulation_test', value: { result: 'positive' } },
    ],
  });

  assert(out.evidence?.layers?.includes('C'), 'layer C present', {
    layers: out.evidence?.layers,
  });
  assert(
    out.evidence?.estimate_status === 'updated_estimate',
    'OPK → updated_estimate not confirmed',
    { status: out.evidence?.estimate_status },
  );
  assert(
    out.evidence?.forecast_ovulation_date != null,
    'forecast preserved',
    { f: out.evidence?.forecast_ovulation_date },
  );

  const est = out.evidence.estimated_ovulation_date;
  const distPrior = Math.abs(diffDays(priorOv, est));
  const distSurge = Math.abs(diffDays(surgeCenter, est));
  assert(
    distSurge <= distPrior,
    'estimate pulled toward surge vs prior',
    { est, priorOv, surgeCenter, distPrior, distSurge },
  );
  assert(
    (out.evidence.ovulation_uncertainty_days || 0) >= 1,
    'OPK keeps uncertainty',
    { U: out.evidence.ovulation_uncertainty_days },
  );

  const fert = out.predictions.filter((r) => r.predictionType === 'fertility');
  const ovRow = out.predictions.find(
    (r) => r.predictionType === 'ovulation' && r.isCurrentCycle,
  );
  if (ovRow) {
    const bio = fertility.computeFertileWindows(ovRow.date).extended;
    // Only fertility days tagged with this cycle's extended window
    const fertForOv = fert.filter(
      (f) =>
        f.extendedFertileStart === bio.start &&
        f.extendedFertileEnd === bio.end,
    );
    const fertOutside = fertForOv.filter(
      (f) => f.date < bio.start || f.date > bio.end,
    );
    assert(fertOutside.length === 0, 'no fertile days outside bio window', {
      outside: fertOutside.map((f) => f.date),
    });
    assert(fertForOv.length > 0, 'fertile days inside bio window', {
      n: fertForOv.length,
    });
  }
}

// --- BBT = retrospective estimate ---
{
  results.scenarios++;
  const hist = simulateHistory({ start: '2024-03-01', C: 28, P: 5, cycles: 3 });
  const priorOv = addDays(addDays(hist.lastStart, 28), -14);
  const observations = [];
  for (let d = 0; d < 6; d++) {
    observations.push({
      date: addDays(priorOv, -8 + d),
      type: 'bbt',
      value: { celsius: 36.3 },
    });
  }
  const riseStart = addDays(priorOv, -2);
  for (let d = 0; d < 3; d++) {
    observations.push({
      date: addDays(riseStart, d),
      type: 'bbt',
      value: { celsius: 36.7 },
    });
  }
  const out = pred.generatePredictions({
    loggedDates: hist.loggedDates,
    profile: {},
    observations,
  });
  assert(
    out.evidence?.estimate_status === 'retrospective_estimate',
    'BBT → retrospective',
    { status: out.evidence?.estimate_status },
  );
  assert(out.evidence?.layers?.includes('D'), 'layer D', {
    layers: out.evidence?.layers,
  });
  assert(
    (out.evidence.ovulation_uncertainty_days || 0) >= 1,
    'BBT keeps uncertainty',
    { U: out.evidence.ovulation_uncertainty_days },
  );
}

// --- Confidence semantics ---
{
  results.scenarios++;
  const label = confidence.softConfidenceLabel('high', 8, 'A');
  assert(/timing estimate/i.test(label), 'soft label says timing', { label });
  assert(!/fertile|conception|safe/i.test(label), 'not fertility probability', {
    label,
  });
}

// --- Pregnancy wording ---
{
  results.scenarios++;
  const lab = pregnancy.eddSourceLabel('clinician_ultrasound');
  assert(/you entered/i.test(lab), 'clinician = user-entered, not verified', {
    lab,
  });
  assert(!/verified/i.test(lab), 'no clinically verified claim', { lab });
}

// --- Evidence layers combine ---
{
  results.scenarios++;
  const r = evidence.processEvidence({
    observations: [],
    completedCycles: [],
    lastPeriodStart: '2024-01-01',
    C: 28,
    L: 14,
    priorCurrentOvulation: '2024-01-15',
    ovulationUncertaintyDays: 3,
  });
  assert(
    JSON.stringify(r.evidence_layers) === JSON.stringify(['A']),
    'baseline layer A only',
    { layers: r.evidence_layers },
  );
  assert(r.estimate_status === 'forecast', 'baseline forecast', {
    s: r.estimate_status,
  });
}

const summary = {
  engine: 'ecc_prediction_v4_1',
  scenarios_run: results.scenarios,
  assertions: results.assertions,
  passed: results.passed,
  failed: results.assertions - results.passed,
  pass_rate: `${((results.passed / results.assertions) * 100).toFixed(2)}%`,
  sample_failures: results.failed.slice(0, 15),
};
console.log(JSON.stringify(summary, null, 2));
process.exit(summary.failed === 0 ? 0 : 1);
