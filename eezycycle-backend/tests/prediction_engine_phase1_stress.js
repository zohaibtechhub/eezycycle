/**
 * Synthetic stress test for ecc_prediction_v1 (Phase 1).
 * Run: node tests/prediction_engine_phase1_stress.js
 *
 * Generates 4000+ user histories and validates:
 * - algorithm version
 * - envelope fields
 * - no prediction on logged period dates
 * - ovulation = next_period - 14 (Level A)
 * - fertile window neighbors
 * - primary day-type uniqueness
 */

const pred = require('../services/cycle/prediction_service');
const flo = require('../services/flo_calendar_service');

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
  predictionRows: 0,
  assertions: 0,
  passed: 0,
  failed: [],
  byConfidence: { low: 0, medium: 0, high: 0 },
  byType: { period: 0, ovulation: 0, fertility: 0 },
  ovulationMatchesLuteal: 0,
  ovulationChecked: 0,
  fertileIncludesNeighbors: 0,
  fertileChecked: 0,
  overlapLoggedBugs: 0,
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

const starts = [];
let cursor = '2024-01-01';
for (let i = 0; i < 20; i++) {
  starts.push(cursor);
  cursor = addDays(cursor, 17);
}

const cycleLens = [21, 24, 26, 28, 30, 32, 35];
const periodLens = [3, 4, 5, 6, 7];
const historyCounts = [1, 2, 3, 4, 6, 8];

for (const start of starts) {
  for (const C of cycleLens) {
    for (const P of periodLens) {
      for (const cycles of historyCounts) {
        results.scenarios++;
        const hist = simulateHistory({ start, C, P, cycles });
        const out = pred.generatePredictions({
          loggedDates: hist.loggedDates,
          profile: {
            avg_cycle_length: C,
            avg_period_length: P,
            luteal_phase_days: 14,
          },
        });

        assert(out.algorithm_version === 'ecc_prediction_v1', 'algo version', {
          start,
          C,
          P,
        });
        assert(!!out.profile, 'has profile', { start, C, P });
        assert(out.predictions.length > 0, 'has predictions', {
          start,
          C,
          P,
          n: out.predictions.length,
        });

        const conf = out.profile.prediction_confidence;
        if (results.byConfidence[conf] != null) results.byConfidence[conf]++;

        const loggedSet = new Set(hist.loggedDates);
        const byType = { period: [], ovulation: [], fertility: [] };
        for (const row of out.predictions) {
          results.predictionRows++;
          results.byType[row.predictionType] =
            (results.byType[row.predictionType] || 0) + 1;
          byType[row.predictionType]?.push(row);

          assert(!!row.rangeStart && !!row.rangeEnd, 'envelope ranges', {
            date: row.date,
          });
          assert(
            ['low', 'medium', 'high'].includes(row.confidence),
            'confidence label',
            { date: row.date, confidence: row.confidence },
          );
          assert(row.evidenceLevel === 'A', 'evidence A', { date: row.date });

          if (loggedSet.has(row.date)) {
            results.overlapLoggedBugs++;
            assert(false, 'prediction overlaps logged period', {
              date: row.date,
              type: row.predictionType,
            });
          }
        }

        const nextPeriod = addDays(hist.lastStart, out.profile.C);
        const expectedOv = addDays(nextPeriod, -14);
        results.ovulationChecked++;
        const hasOv = byType.ovulation.some((r) => r.date === expectedOv);
        if (hasOv) results.ovulationMatchesLuteal++;
        assert(hasOv, 'ovulation = next_period - 14', {
          expectedOv,
          nextPeriod,
          lastStart: hist.lastStart,
          C: out.profile.C,
        });

        results.fertileChecked++;
        const neighbor = addDays(expectedOv, -1);
        const okNeighbor =
          loggedSet.has(neighbor) ||
          byType.period.some((r) => r.date === neighbor) ||
          byType.fertility.some((r) => r.date === neighbor);
        if (okNeighbor) results.fertileIncludesNeighbors++;
        assert(
          okNeighbor,
          'fertile includes ov-1 (or skipped if period/logged)',
          { neighbor },
        );

        const primary = pred.primaryDayTypeByDate(out.predictions);
        const dates = primary.map((p) => p.date);
        assert(new Set(dates).size === dates.length, 'primary unique dates', {
          n: dates.length,
        });
      }
    }
  }
}

// Outlier histories (still observations; excluded from forecast averages)
for (let i = 0; i < 30; i++) {
  results.scenarios++;
  const lengths = [28, 50, 22, 41, 27, 19, 33];
  let S = addDays('2023-06-01', i * 3);
  const logged = [];
  for (const L of lengths) {
    logged.push(...bleedDays(S, 5));
    S = addDays(S, L);
  }
  logged.push(...bleedDays(S, 5));
  const out = pred.generatePredictions({ loggedDates: logged, profile: {} });
  results.predictionRows += out.predictions.length;
  assert(
    out.profile.forecast_cycle_count < lengths.length,
    'outliers excluded from forecast count',
    {
      forecast: out.profile.forecast_cycle_count,
      history: lengths.length,
    },
  );
  assert(out.predictions.length > 0, 'still predicts with outliers', {});
  for (const row of out.predictions) {
    results.byType[row.predictionType] =
      (results.byType[row.predictionType] || 0) + 1;
  }
  if (out.profile.prediction_confidence) {
    results.byConfidence[out.profile.prediction_confidence]++;
  }
}

const summary = {
  engine: 'ecc_prediction_v1',
  scenarios_run: results.scenarios,
  prediction_rows_generated: results.predictionRows,
  assertions: results.assertions,
  passed: results.passed,
  failed: results.assertions - results.passed,
  pass_rate: `${((results.passed / results.assertions) * 100).toFixed(2)}%`,
  confidence_distribution: results.byConfidence,
  prediction_type_counts: results.byType,
  ovulation_luteal_rule: {
    checked: results.ovulationChecked,
    matched: results.ovulationMatchesLuteal,
    rate: `${((results.ovulationMatchesLuteal / results.ovulationChecked) * 100).toFixed(2)}%`,
  },
  fertile_neighbor_ok: {
    checked: results.fertileChecked,
    matched: results.fertileIncludesNeighbors,
    rate: `${((results.fertileIncludesNeighbors / results.fertileChecked) * 100).toFixed(2)}%`,
  },
  overlap_bugs: results.overlapLoggedBugs,
  sample_failures: results.failed.slice(0, 15),
};

console.log(JSON.stringify(summary, null, 2));
process.exit(summary.failed === 0 ? 0 : 1);
