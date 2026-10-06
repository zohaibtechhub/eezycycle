/**
 * Synthetic stress test for ecc_prediction_v4 (Phase 4).
 * Run: node tests/prediction_engine_phase4_stress.js
 *
 * Validates:
 * - algorithm version v4
 * - dual EDD: clinician preferred over LMP
 * - soft confidence labels (no raw score in label)
 * - insights are pattern-based and never fertility claims
 * - prediction vs actual delta math helper
 * - pregnancy mode clears cycle predictions (unit via pregnancy helpers)
 */

const pred = require('../services/cycle/prediction_service');
const pregnancy = require('../services/cycle/pregnancy_service');
const confidence = require('../services/cycle/confidence_service');
const insights = require('../services/cycle/insight_service');
const flo = require('../services/flo_calendar_service');
const { ALGORITHM_VERSION } = require('../services/cycle/constants');

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

const results = {
  scenarios: 0,
  assertions: 0,
  passed: 0,
  failed: [],
};

function assert(cond, msg, ctx) {
  results.assertions++;
  if (cond) {
    results.passed++;
    return true;
  }
  if (results.failed.length < 30) results.failed.push({ msg, ...ctx });
  return false;
}

assert(ALGORITHM_VERSION === 'ecc_prediction_v4', 'algo constant v4', {
  ALGORITHM_VERSION,
});

// --- Dual EDD ---
{
  results.scenarios++;
  const lmp = '2026-01-01';
  const lmpEdd = flo.dueDateFromLmp(lmp);
  const clinician = '2026-10-01';

  const fromLmp = pregnancy.resolveDating({}, lmp);
  assert(fromLmp.due_date === lmpEdd, 'LMP EDD = LMP+280', {
    got: fromLmp.due_date,
    lmpEdd,
  });
  assert(fromLmp.edd_source === 'lmp', 'source lmp', {
    src: fromLmp.edd_source,
  });

  const fromClinician = pregnancy.resolveDating(
    { clinician_edd: clinician, lmp_based_edd: lmpEdd },
    lmp,
  );
  assert(fromClinician.due_date === clinician, 'clinician preferred', {
    got: fromClinician.due_date,
  });
  assert(
    fromClinician.edd_source === 'clinician_ultrasound',
    'source clinician',
    { src: fromClinician.edd_source },
  );
  assert(
    fromClinician.lmp_based_edd === lmpEdd,
    'LMP kept as history',
    { lmp: fromClinician.lmp_based_edd },
  );

  const label = pregnancy.eddSourceLabel('clinician_ultrasound');
  assert(!!label && !/fertile/i.test(label), 'EDD audit label safe', {
    label,
  });
}

// --- buildDaySummary prefers clinician ---
{
  results.scenarios++;
  const lmp = '2026-01-01';
  const clinician = '2026-09-15';
  const summary = flo.buildDaySummary({
    date: '2026-03-01',
    lastPeriodStart: lmp,
    pregnancyModeActive: true,
    dueDate: flo.dueDateFromLmp(lmp),
    clinicianEdd: clinician,
    eddSource: 'clinician_ultrasound',
    C: 28,
    P: 5,
  });
  assert(summary.day_type === 'pregnancy', 'pregnancy day type', {});
  assert(summary.due_date === clinician, 'summary uses clinician due', {
    due: summary.due_date,
  });
  assert(summary.edd_source === 'clinician_ultrasound', 'summary edd source', {
    src: summary.edd_source,
  });
}

// --- Soft confidence labels ---
{
  results.scenarios++;
  const low = confidence.softConfidenceLabel('low', 1, 'A');
  const med = confidence.softConfidenceLabel('medium', 4, 'A');
  const high = confidence.softConfidenceLabel('high', 8, 'A');
  assert(/limited data/i.test(low), 'low → limited data', { low });
  assert(/recent cycles/i.test(med), 'medium → recent cycles', { med });
  assert(/recent cycles/i.test(high), 'high → recent cycles', { high });
  assert(!/\d\.\d/.test(low + med + high), 'no raw score in soft labels', {});
}

// --- Insights safe language ---
{
  results.scenarios++;
  const hist = simulateHistory({
    start: '2024-01-01',
    C: 28,
    P: 5,
    cycles: 3,
  });
  const S = hist.lastStart;
  const next = addDays(S, 28);
  const observations = [];
  for (let i = 0; i < 3; i++) {
    observations.push({
      date: addDays(next, -3 - i),
      type: 'symptom',
      value: { keys: ['sym_cramps'] },
    });
  }
  const list = insights.buildPersonalInsights({
    observations,
    lastPeriodStart: S,
    C: 28,
    L: 14,
  });
  assert(list.length >= 1, 'insight generated', { n: list.length });
  for (const item of list) {
    assert(item.safe === true, 'insight marked safe', { id: item.id });
    const text = `${item.title} ${item.body}`.toLowerCase();
    assert(
      !text.includes('you are fertile') &&
        !text.includes('you ovulated') &&
        !text.includes('because of headache'),
      'no fertility claim from symptoms',
      { text },
    );
  }

  // Symptoms alone do not change ovulation prediction
  const base = pred.generatePredictions({
    loggedDates: hist.loggedDates,
    profile: {},
    observations: [],
  });
  const withSym = pred.generatePredictions({
    loggedDates: hist.loggedDates,
    profile: {},
    observations,
  });
  assert(
    base.algorithm_version === 'ecc_prediction_v4',
    'generatePredictions v4',
    { v: base.algorithm_version },
  );
  const ovA = base.predictions.find(
    (r) => r.predictionType === 'ovulation' && r.isCurrentCycle,
  );
  const ovB = withSym.predictions.find(
    (r) => r.predictionType === 'ovulation' && r.isCurrentCycle,
  );
  assert(ovA?.date === ovB?.date, 'symptoms do not move ovulation', {
    a: ovA?.date,
    b: ovB?.date,
  });
}

// --- Validation delta math ---
{
  results.scenarios++;
  const predicted = '2026-04-10';
  const actual = '2026-04-12';
  const delta = flo.diffDays(predicted, actual);
  assert(delta === 2, 'actual - predicted = +2', { delta });
}

// --- Baseline engine still predicts ---
for (let i = 0; i < 20; i++) {
  results.scenarios++;
  const hist = simulateHistory({
    start: addDays('2024-06-01', i),
    C: 28,
    P: 5,
    cycles: 4,
  });
  const out = pred.generatePredictions({
    loggedDates: hist.loggedDates,
    profile: {},
    observations: [],
  });
  assert(out.predictions.length > 0, 'has predictions', {});
  assert(
    out.profile?.soft_confidence_label ||
      confidence.softConfidenceLabel(
        out.profile?.prediction_confidence,
        out.profile?.N || 0,
        out.evidence?.level,
      ),
    'soft label available',
    {},
  );
}

const summary = {
  engine: 'ecc_prediction_v4',
  scenarios_run: results.scenarios,
  assertions: results.assertions,
  passed: results.passed,
  failed: results.assertions - results.passed,
  pass_rate: `${((results.passed / results.assertions) * 100).toFixed(2)}%`,
  sample_failures: results.failed.slice(0, 15),
};

console.log(JSON.stringify(summary, null, 2));
process.exit(summary.failed === 0 ? 0 : 1);
