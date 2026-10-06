/**
 * Synthetic stress test for ecc_prediction_v2 (Phase 2).
 * Run: node tests/prediction_engine_phase2_stress.js
 *
 * Validates:
 * - algorithm version v2
 * - weighted stats + uncertainty on profile
 * - period/ovulation ranges wider than a point when uncertainty > 0
 * - fertile window = bio(ov−5…ov+1) ± ovulation uncertainty
 * - no prediction on logged period dates
 * - ovulation = next_period − 14 (Level A)
 * - primary day-type uniqueness
 */

const pred = require('../services/cycle/prediction_service');
const flo = require('../services/flo_calendar_service');
const { recencyWeights } = require('../services/cycle/cycle_statistics_service');
const {
  computeFertileWindowFromUncertainty,
} = require('../services/cycle/fertility_prediction_service');
const { diffDays } = require('../utils/date');

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
  rangeWiderThanPoint: 0,
  rangeChecked: 0,
  fertileWidthOk: 0,
  fertileWidthChecked: 0,
  ovulationMatchesLuteal: 0,
  ovulationChecked: 0,
  overlapLoggedBugs: 0,
  weightedProfileOk: 0,
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

// Unit: recency weights for n=6 → [1,1,2,2,3,4]
{
  results.scenarios++;
  const w = recencyWeights(6);
  assert(
    JSON.stringify(w) === JSON.stringify([1, 1, 2, 2, 3, 4]),
    'recency weights n=6',
    { w },
  );
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

        assert(out.algorithm_version === 'ecc_prediction_v2', 'algo version', {
          start,
          C,
          P,
          got: out.algorithm_version,
        });
        assert(!!out.profile, 'has profile', { start, C, P });
        assert(out.predictions.length > 0, 'has predictions', {
          start,
          C,
          P,
          n: out.predictions.length,
        });

        const profile = out.profile;
        assert(
          profile.cycle_weighted_mean != null &&
            profile.period_uncertainty_days != null &&
            profile.ovulation_uncertainty_days != null,
          'weighted + uncertainty profile',
          {
            wm: profile.cycle_weighted_mean,
            pu: profile.period_uncertainty_days,
            ou: profile.ovulation_uncertainty_days,
          },
        );
        if (
          profile.cycle_weighted_mean != null &&
          profile.period_uncertainty_days != null
        ) {
          results.weightedProfileOk++;
        }

        const conf = profile.prediction_confidence;
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

          if (
            row.predictionType === 'period' ||
            row.predictionType === 'ovulation'
          ) {
            results.rangeChecked++;
            const wider =
              row.rangeStart < row.date || row.rangeEnd > row.date;
            if (wider) results.rangeWiderThanPoint++;
            if (
              (row.predictionType === 'period' &&
                profile.period_uncertainty_days > 0) ||
              (row.predictionType === 'ovulation' &&
                profile.ovulation_uncertainty_days > 0)
            ) {
              assert(wider, 'range wider than point date', {
                date: row.date,
                type: row.predictionType,
                rangeStart: row.rangeStart,
                rangeEnd: row.rangeEnd,
              });
            }
          }

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

        const ovRow = byType.ovulation.find((r) => r.date === expectedOv);
        if (ovRow) {
          results.fertileWidthChecked++;
          const expected = computeFertileWindowFromUncertainty(
            expectedOv,
            profile.ovulation_uncertainty_days,
          );
          const fert = byType.fertility.filter(
            (r) =>
              r.rangeStart === expected.fertileStart &&
              r.rangeEnd === expected.fertileEnd,
          );
          const width =
            diffDays(expected.fertileStart, expected.fertileEnd) + 1;
          const expectedWidth = 7 + 2 * profile.ovulation_uncertainty_days;
          const widthOk = width === expectedWidth;
          if (widthOk) results.fertileWidthOk++;
          assert(widthOk, 'fertile width = bio7 + 2*uncertainty', {
            width,
            expectedWidth,
            half: profile.ovulation_uncertainty_days,
          });
          // At least one fertile day in window (unless all skipped)
          const anyInWindow = byType.fertility.some(
            (r) =>
              r.date >= expected.fertileStart && r.date <= expected.fertileEnd,
          );
          const windowAllSkipped =
            !anyInWindow &&
            [...Array(width)].every((_, i) => {
              const d = addDays(expected.fertileStart, i);
              return (
                d === expectedOv ||
                loggedSet.has(d) ||
                byType.period.some((p) => p.date === d)
              );
            });
          assert(
            fert.length > 0 || anyInWindow || windowAllSkipped,
            'fertile rows use uncertainty window',
            {
              fertileStart: expected.fertileStart,
              fertileEnd: expected.fertileEnd,
              fertCount: fert.length,
            },
          );
        }

        const primary = pred.primaryDayTypeByDate(out.predictions);
        const dates = primary.map((p) => p.date);
        assert(new Set(dates).size === dates.length, 'primary unique dates', {
          n: dates.length,
        });
      }
    }
  }
}

// Variable-length histories — weighted mean should adapt toward recent C
for (let i = 0; i < 40; i++) {
  results.scenarios++;
  const lengths = [35, 34, 33, 28, 27, 26];
  let S = addDays('2023-03-01', i * 2);
  const logged = [];
  for (const L of lengths) {
    logged.push(...bleedDays(S, 5));
    S = addDays(S, L);
  }
  logged.push(...bleedDays(S, 5));
  const out = pred.generatePredictions({ loggedDates: logged, profile: {} });
  results.predictionRows += out.predictions.length;
  assert(!!out.profile.cycle_weighted_mean, 'variable hist has weighted mean', {
    wm: out.profile?.cycle_weighted_mean,
  });
  // Recent cycles shorter → weighted mean should be ≤ unweighted mean
  assert(
    out.profile.cycle_weighted_mean <= out.profile.cycle_mean + 1,
    'weighted leans recent (not far above mean)',
    {
      weighted: out.profile.cycle_weighted_mean,
      mean: out.profile.cycle_mean,
    },
  );
  if (out.profile.prediction_confidence) {
    results.byConfidence[out.profile.prediction_confidence]++;
  }
  for (const row of out.predictions) {
    results.byType[row.predictionType] =
      (results.byType[row.predictionType] || 0) + 1;
  }
}

// Outlier histories
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
  engine: 'ecc_prediction_v2',
  scenarios_run: results.scenarios,
  prediction_rows_generated: results.predictionRows,
  assertions: results.assertions,
  passed: results.passed,
  failed: results.assertions - results.passed,
  pass_rate: `${((results.passed / results.assertions) * 100).toFixed(2)}%`,
  confidence_distribution: results.byConfidence,
  prediction_type_counts: results.byType,
  weighted_profile_ok: results.weightedProfileOk,
  range_wider_than_point: {
    checked: results.rangeChecked,
    wider: results.rangeWiderThanPoint,
  },
  fertile_width_ok: {
    checked: results.fertileWidthChecked,
    matched: results.fertileWidthOk,
    rate: results.fertileWidthChecked
      ? `${((results.fertileWidthOk / results.fertileWidthChecked) * 100).toFixed(2)}%`
      : 'n/a',
  },
  ovulation_luteal_rule: {
    checked: results.ovulationChecked,
    matched: results.ovulationMatchesLuteal,
    rate: `${((results.ovulationMatchesLuteal / results.ovulationChecked) * 100).toFixed(2)}%`,
  },
  overlap_bugs: results.overlapLoggedBugs,
  sample_failures: results.failed.slice(0, 15),
};

console.log(JSON.stringify(summary, null, 2));
process.exit(summary.failed === 0 ? 0 : 1);
