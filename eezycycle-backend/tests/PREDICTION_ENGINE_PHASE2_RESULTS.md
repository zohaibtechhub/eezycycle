# Prediction Engine Phase 2 — Stress Test Results

**Engine:** `ecc_prediction_v2`  
**Script:** `eezycycle-backend/tests/prediction_engine_phase2_stress.js`  
**Run:** `node tests/prediction_engine_phase2_stress.js`

## Summary

| Metric | Value |
|--------|------:|
| Scenarios | 4,271 |
| Prediction rows generated | 383,520 |
| Assertions | 1,314,261 |
| Passed | 1,314,261 |
| Failed | **0** |
| Pass rate | **100.00%** |

## What was validated

1. **Algorithm version** — all outputs tagged `ecc_prediction_v2`
2. **Recency weights** — for 6 cycles → `[1, 1, 2, 2, 3, 4]`
3. **Weighted profile** — `cycle_weighted_mean`, `period_uncertainty_days`, `ovulation_uncertainty_days` present
4. **Ranges** — period/ovulation `range_start`/`range_end` wider than the most-likely date when uncertainty &gt; 0 (151,200 / 151,200)
5. **Fertile window** — width = biological 7 days (`ov−5…ov+1`) + `2 × ovulation_uncertainty` (4,200 / 4,200)
6. **Level A ovulation** — still `next_period − 14` (4,200 / 4,200)
7. **Truth vs prediction** — zero overlaps with logged period dates
8. **Primary day type** — unique date after priority collapse

## Confidence distribution (scenario profiles)

| Label | Count |
|-------|------:|
| low | 1,400 |
| medium | 1,430 |
| high | 1,440 |

## Prediction type counts

| Type | Rows |
|------|-----:|
| period | 128,100 |
| ovulation | 25,620 |
| fertility | 229,800 |

## Phase 2 behavior notes

- Forecast **C** prefers **weighted mean** of usable cycles (21–45), not simple mean alone.
- Fertile width is no longer only `regular=7 / irregular=14`; irregularity still widens **uncertainty**, which expands the bio window.
- Rebuild modes: `FULL` (default `POST /cycle/predictions/rebuild`) and `TODAY` (`mode: "today"`).

## How to re-run

```bash
cd eezycycle-backend
node tests/prediction_engine_phase2_stress.js
```
