# EezyCycle Prediction Engine — Phase 1 Stress Test Results

**Engine:** `ecc_prediction_v1`  
**Test script:** `eezycycle-backend/tests/prediction_engine_phase1_stress.js`  
**Run command:**

```bash
cd eezycycle-backend && node tests/prediction_engine_phase1_stress.js
```

**Date of run:** 2026-09-16  
**Verdict:** **PASS (100%)**

---

## Summary

| Metric | Result |
|--------|--------|
| Synthetic scenarios (user histories) | **4,230** |
| Prediction rows generated | **342,660** |
| Assertions evaluated | **1,042,980** |
| Passed | **1,042,980** |
| Failed | **0** |
| Pass rate | **100.00%** |
| Predictions overlapping logged periods | **0** |

This validates **engine rules and invariants** on synthetic cycle histories. It is **not** a clinical accuracy study against real-world outcomes.

---

## What was tested

### Scenario matrix (Batch A)

| Dimension | Values |
|-----------|--------|
| Period start anchors | 20 staggered starts from `2024-01-01` |
| Cycle lengths (C) | 21, 24, 26, 28, 30, 32, 35 |
| Period lengths (P) | 3, 4, 5, 6, 7 |
| Completed-cycle history depth | 1, 2, 3, 4, 6, 8 |

Combinations: `20 × 7 × 5 × 6 = 4,200` regular histories.

### Outlier histories (Batch B)

| Item | Detail |
|------|--------|
| Count | 30 histories |
| Cycle lengths mixed in | 28, 50, 22, 41, 27, 19, 33 (includes &lt;21 and &gt;45) |
| Expectation | Outliers remain as **observations**; excluded from **forecast** averages; engine still emits predictions |

---

## Rule checks

| Rule | Checked | Matched | Rate |
|------|---------|---------|------|
| Algorithm version is `ecc_prediction_v1` | (per scenario) | all | 100% |
| Personal cycle profile present | (per scenario) | all | 100% |
| Predictions non-empty when periods exist | (per scenario) | all | 100% |
| Envelope: `range_start` / `range_end` set | (per row) | all | 100% |
| Confidence ∈ `{low, medium, high}` | (per row) | all | 100% |
| Evidence level = `A` (Phase 1) | (per row) | all | 100% |
| **No prediction on logged period dates** | all rows | 0 bugs | 100% |
| **Ovulation = next_period − 14** (Level A) | 4,200 | 4,200 | **100%** |
| Fertile window includes `ov−1` (or skipped if period/logged) | 4,200 | 4,200 | **100%** |
| Primary day-type collapse → unique dates | (per scenario) | all | 100% |

---

## Prediction type mix (generated rows)

| `prediction_type` | Count |
|-------------------|------:|
| period | 126,900 |
| ovulation | 25,380 |
| fertility | 190,380 |
| **Total** | **342,660** |

Multiple types per calendar date are allowed by schema; UI still collapses to a **primary** label (`ovulation > period > fertility`).

---

## Confidence distribution

From scenario profiles (regular matrix + outlier batch):

| Confidence | Count |
|------------|------:|
| low | 1,400 |
| medium | 1,430 |
| high | 1,400 |

Roughly aligned with history depth:

- **low** — thin history (e.g. 1–2 cycles)
- **medium** — moderate history (e.g. ~3–4+)
- **high** — deeper history and more regular patterns (e.g. 6–8 cycles)

Exact buckets follow Phase 1 `confidence_service` rules (data volume + irregularity), not biomarker weights.

---

## Outlier handling (Batch B)

| Check | Result |
|-------|--------|
| Unusual cycle lengths kept as history | Yes |
| Forecast averages exclude &lt;21 / &gt;45 lengths | Yes (`forecast_cycle_count` &lt; raw history count) |
| Engine still produces predictions | Yes |

This matches Phase 1 principle: **data validity ≠ biological normality** — outliers stay as truth observations but do not distort forecasting averages.

---

## Sample expected behavior (classic 28-day)

For last period start `S`, `C = 28`, `L = 14`:

```text
next_period = S + 28
ovulation   = next_period - 14 = S + 14
```

Stress test confirmed this Level A luteal rule across **4,200** regular scenarios.

---

## Failures

**None.** `sample_failures: []`

---

## How to re-run

```bash
cd eezycycle-backend
node tests/prediction_engine_phase1_stress.js
```

Exit code `0` = all assertions passed; non-zero = failures printed in `sample_failures`.

---

## Limits of this test

| Covered | Not covered |
|---------|-------------|
| Synthetic period histories | Real user DB rows |
| Level A calendar rules | OPK / BBT / mucus (Phase 3) |
| Envelope + confidence skeleton | Weighted recent-cycle stats (Phase 2) |
| Truth vs prediction separation in logic | phpMyAdmin migration application |
| Primary label collapse | Clinical accuracy / pregnancy outcomes |

---

## Related docs

- Roadmap: [07-prediction-engine-phases.md](../../period_ovulation_tracker/docs/backend/07-prediction-engine-phases.md)
- How predictions work: [06-how-predictions-work.md](../../period_ovulation_tracker/docs/backend/06-how-predictions-work.md)
- Flo formulas: [04-cycle-formulas-flo.md](../../period_ovulation_tracker/docs/backend/04-cycle-formulas-flo.md)

---

## Next

After importing SQL migrations `014` + `015` and restarting the API, optional follow-up: a **DB-backed** sample test against live `period_days` / `cycle_predictions`.  
Say **`phase 2`** when ready for the statistical-engine upgrades.
