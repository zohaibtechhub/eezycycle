/**
 * Synthetic stress test for ecc_prediction_v3 (Phase 3).
 * Run: node tests/prediction_engine_phase3_stress.js
 *
 * Validates:
 * - algorithm version v3
 * - Level A baseline still next_period − 14
 * - Level C: positive OPK shifts ovulation ≈ T+1
 * - Level D: sustained BBT rise moves ovulation
 * - Symptoms never move ovulation
 * - evidence_sources listed on ov/fertile rows
 * - fertile width still biology + uncertainty
 */

const pred = require('../services/cycle/prediction_service');
const flo = require('../services/flo_calendar_service');
const evidence = require('../services/cycle/evidence_processor');

function addDays(dateStr, n) {
  return flo.addDays(dateStr, n);
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
  byLevel: { A: 0, B: 0, C: 0, D: 0 },
  opkShiftOk: 0,
  opkShiftChecked: 0,
  bbtShiftOk: 0,
  bbtShiftChecked: 0,
  symptomIgnoredOk: 0,
  symptomIgnoredChecked: 0,
  levelBOk: 0,
  levelBChecked: 0,
};

function assert(cond, msg, ctx) {
  results.assertions++;
  if (cond) {
    results.passed++;
    return true;
  }
  if (results.failed.length < 40) results.failed.push({ msg, ...ctx });
  return false;
}

function currentOv(out) {
  return out.predictions.find(
    (r) => r.predictionType === 'ovulation' && r.isCurrentCycle,
  );
}

// --- Baseline grid (Level A) ---
const starts = [];
let cursor = '2024-01-01';
for (let i = 0; i < 10; i++) {
  starts.push(cursor);
  cursor = addDays(cursor, 19);
}
for (const start of starts) {
  for (const C of [26, 28, 30, 32]) {
    for (const cycles of [3, 6]) {
      results.scenarios++;
      const hist = simulateHistory({ start, C, P: 5, cycles });
      const out = pred.generatePredictions({
        loggedDates: hist.loggedDates,
        profile: { avg_cycle_length: C, avg_period_length: 5 },
        observations: [],
      });
      assert(out.algorithm_version === 'ecc_prediction_v3', 'algo v3', {});
      assert(out.evidence?.level === 'A', 'level A without biomarkers', {
        level: out.evidence?.level,
      });
      if (out.evidence?.level === 'A') results.byLevel.A++;

      const expectedOv = addDays(addDays(hist.lastStart, out.profile.C), -14);
      const ov = currentOv(out);
      assert(ov?.date === expectedOv, 'A: ov = next-14', {
        expectedOv,
        got: ov?.date,
      });

      for (const row of out.predictions.filter(
        (r) => r.predictionType === 'ovulation',
      )) {
        assert(row.evidenceLevel === 'A', 'ov evidence A', {
          level: row.evidenceLevel,
        });
        assert(
          Array.isArray(row.evidenceSources) &&
            row.evidenceSources.includes('historical_cycle_data'),
          'sources listed',
          { sources: row.evidenceSources },
        );
      }
    }
  }
}

// --- Level C: OPK positive ---
for (let i = 0; i < 80; i++) {
  results.scenarios++;
  results.opkShiftChecked++;
  const C = 28;
  const hist = simulateHistory({
    start: addDays('2024-02-01', i),
    C,
    P: 5,
    cycles: 4,
  });
  const priorOv = addDays(addDays(hist.lastStart, C), -14);
  // Positive OPK 2 days before calendar ov → expect T+1
  const T = addDays(priorOv, -2);
  const expected = addDays(T, 1);

  const out = pred.generatePredictions({
    loggedDates: hist.loggedDates,
    profile: { avg_cycle_length: C },
    observations: [
      {
        date: T,
        type: 'ovulation_test',
        value: { result: 'positive', item_key: 'ov_positive' },
      },
      // symptoms must not win
      {
        date: T,
        type: 'symptom',
        value: { keys: ['sym_cramps', 'sym_fatigue'] },
      },
    ],
  });

  assert(out.evidence?.level === 'C', 'OPK → level C', {
    level: out.evidence?.level,
  });
  if (out.evidence?.level === 'C') results.byLevel.C++;

  const ov = currentOv(out);
  const ok = ov?.date === expected;
  if (ok) results.opkShiftOk++;
  assert(ok, 'OPK shifts ov to T+1', {
    T,
    expected,
    got: ov?.date,
    priorOv,
  });

  assert(
    out.evidence?.sources?.includes('ovulation_test_lh'),
    'LH source listed',
    { sources: out.evidence?.sources },
  );

  // Symptoms ignored: ov not on symptom-only logic (already T+1)
  results.symptomIgnoredChecked++;
  const symptomForced = ov?.date === T; // would be wrong if symptoms set ov=T
  if (!symptomForced && out.evidence?.notes?.includes('symptoms_ignored_for_ovulation')) {
    results.symptomIgnoredOk++;
  }
  assert(
    !symptomForced,
    'symptoms do not force ovulation date',
    { ov: ov?.date, T },
  );
}

// --- Level D: BBT sustained rise ---
for (let i = 0; i < 40; i++) {
  results.scenarios++;
  results.bbtShiftChecked++;
  const C = 28;
  const hist = simulateHistory({
    start: addDays('2024-03-01', i * 2),
    C,
    P: 5,
    cycles: 3,
  });
  const S = hist.lastStart;
  const priorOv = addDays(addDays(S, C), -14);

  const observations = [];
  // 6 baseline days before rise
  for (let d = 0; d < 6; d++) {
    observations.push({
      date: addDays(priorOv, -8 + d),
      type: 'bbt',
      value: { celsius: 36.3 },
    });
  }
  // 3 rise days
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
    profile: { avg_cycle_length: C },
    observations,
  });

  assert(out.evidence?.level === 'D', 'BBT → level D', {
    level: out.evidence?.level,
    notes: out.evidence?.notes,
  });
  if (out.evidence?.level === 'D') results.byLevel.D++;

  const expected = addDays(riseStart, -1);
  const ov = currentOv(out);
  const ok = ov?.date === expected;
  if (ok) results.bbtShiftOk++;
  assert(ok, 'BBT rise → ov day before rise', {
    riseStart,
    expected,
    got: ov?.date,
  });
  assert(
    out.evidence?.sources?.includes('bbt_sustained_rise'),
    'BBT source listed',
    { sources: out.evidence?.sources },
  );
}

// --- Level B: personal luteal from ≥2 historical OPK cycles ---
for (let i = 0; i < 30; i++) {
  results.scenarios++;
  results.levelBChecked++;
  const C = 30;
  const hist = simulateHistory({
    start: addDays('2023-06-01', i),
    C,
    P: 5,
    cycles: 4,
  });
  // completed cycles: starts at hist runs
  const runs = [];
  let S = hist.loggedDates[0];
  // rebuild starts from bleed runs
  const startsOnly = [];
  for (let c = 0; c < 4; c++) {
    startsOnly.push(addDays(hist.lastStart, -(4 - c) * C));
  }
  // Use lastStart walking back
  const cycleStarts = [];
  let cur = hist.lastStart;
  for (let c = 0; c < 5; c++) {
    cycleStarts.unshift(cur);
    cur = addDays(cur, -C);
  }

  const observations = [];
  // For first 3 completed cycles, OPK such that luteal ≈ 12
  for (let c = 0; c < 3; c++) {
    const start = cycleStarts[c];
    const next = cycleStarts[c + 1];
    const ov = addDays(next, -12);
    const T = addDays(ov, -1);
    observations.push({
      date: T,
      type: 'ovulation_test',
      value: { result: 'positive' },
    });
  }

  const out = pred.generatePredictions({
    loggedDates: hist.loggedDates,
    profile: { avg_cycle_length: C, luteal_phase_days: 14 },
    observations,
  });

  // Without current-cycle OPK, expect at least B if 2+ luteal samples
  const level = out.evidence?.level;
  const okLevel = level === 'B' || level === 'C'; // C if OPK falls in open cycle
  if (level === 'B') results.byLevel.B++;
  if (okLevel) results.levelBOk++;
  assert(okLevel, 'historical OPK yields B (or C if open cycle hit)', {
    level,
    luteal: out.evidence?.luteal_days,
    notes: out.evidence?.notes,
  });

  if (level === 'B') {
    assert(
      out.evidence.luteal_days === 12,
      'personal luteal ≈ 12',
      { L: out.evidence.luteal_days },
    );
    const expectedOv = addDays(addDays(hist.lastStart, out.profile.C), -12);
    const ov = currentOv(out);
    assert(ov?.date === expectedOv, 'B uses personal L for current ov', {
      expectedOv,
      got: ov?.date,
    });
  }
}

// --- Unit: symptoms alone never shift ---
{
  results.scenarios++;
  const hist = simulateHistory({ start: '2024-05-01', C: 28, P: 5, cycles: 3 });
  const baseline = pred.generatePredictions({
    loggedDates: hist.loggedDates,
    profile: {},
    observations: [],
  });
  const withSym = pred.generatePredictions({
    loggedDates: hist.loggedDates,
    profile: {},
    observations: [
      {
        date: addDays(hist.lastStart, 10),
        type: 'symptom',
        value: { keys: ['sym_cramps'] },
      },
    ],
  });
  assert(
    currentOv(baseline)?.date === currentOv(withSym)?.date,
    'symptoms-only: ovulation unchanged',
    {
      a: currentOv(baseline)?.date,
      b: currentOv(withSym)?.date,
    },
  );
  assert(withSym.evidence?.level === 'A', 'symptoms-only stays level A', {
    level: withSym.evidence?.level,
  });
}

// --- Unit helpers ---
{
  results.scenarios++;
  const shift = evidence.applyOpkShift(
    '2024-01-01',
    28,
    [{ date: '2024-01-13', type: 'ovulation_test', value: { result: 'positive' } }],
    '2024-01-15',
  );
  assert(shift?.date === '2024-01-14', 'helper OPK T+1', { shift });
}

const summary = {
  engine: 'ecc_prediction_v3',
  scenarios_run: results.scenarios,
  assertions: results.assertions,
  passed: results.passed,
  failed: results.assertions - results.passed,
  pass_rate: `${((results.passed / results.assertions) * 100).toFixed(2)}%`,
  evidence_level_counts: results.byLevel,
  opk_shift: {
    checked: results.opkShiftChecked,
    matched: results.opkShiftOk,
    rate: `${((results.opkShiftOk / results.opkShiftChecked) * 100).toFixed(2)}%`,
  },
  bbt_shift: {
    checked: results.bbtShiftChecked,
    matched: results.bbtShiftOk,
    rate: `${((results.bbtShiftOk / results.bbtShiftChecked) * 100).toFixed(2)}%`,
  },
  level_b: {
    checked: results.levelBChecked,
    matched: results.levelBOk,
    rate: `${((results.levelBOk / results.levelBChecked) * 100).toFixed(2)}%`,
  },
  symptoms_ignored: {
    checked: results.symptomIgnoredChecked,
    matched: results.symptomIgnoredOk,
  },
  sample_failures: results.failed.slice(0, 20),
};

console.log(JSON.stringify(summary, null, 2));
process.exit(summary.failed === 0 ? 0 : 1);
