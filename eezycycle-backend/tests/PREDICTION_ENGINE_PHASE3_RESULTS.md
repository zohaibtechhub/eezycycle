# Prediction Engine Phase 3 — Stress Test Results

**Engine:** `ecc_prediction_v3`  
**Script:** `eezycycle-backend/tests/prediction_engine_phase3_stress.js`  
**Run:** `node tests/prediction_engine_phase3_stress.js`

## Summary

| Metric | Value |
|--------|------:|
| Scenarios | 232 |
| Assertions | 1,733 |
| Passed | 1,733 |
| Failed | **0** |
| Pass rate | **100.00%** |

## Evidence levels exercised

| Level | Count | Meaning |
|-------|------:|---------|
| A | 80 | Calendar prior only (`next_period − L`) |
| B | 30 | Personal luteal from historical OPK |
| C | 80 | Positive OPK → ovulation ≈ `T+1` |
| D | 40 | Sustained BBT rise confirms / shifts |

## Key checks

| Check | Result |
|-------|--------|
| OPK shift to T+1 | 80 / 80 (100%) |
| BBT rise → day before rise | 40 / 40 (100%) |
| Level B personal luteal | 30 / 30 (100%) |
| Symptoms never force ovulation | 80 / 80 |
| `evidence_sources` on ov rows | pass |

## How biomarkers reach the engine

1. Flutter daily log (`ov_*`, `mucus_*`) or `PUT /cycle/observations` / optional `bbt_celsius` on `PUT /logs/:date`
2. Rows stored in `cycle_observations`
3. `todayUpdate` rebuilds the near-term prediction window

## How to re-run

```bash
cd eezycycle-backend
node tests/prediction_engine_phase3_stress.js
```
