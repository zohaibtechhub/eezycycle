# Prediction Engine v4.1 — Stress Test Results

**Engine:** `ecc_prediction_v4_1` (frozen conceptual architecture)  
**Script:** `eezycycle-backend/tests/prediction_engine_phase4_1_stress.js`

## Summary

| Metric | Value |
|--------|------:|
| Assertions | 30 |
| Passed | 30 |
| Failed | **0** |
| Pass rate | **100%** |

## Freeze checklist validated

1. Core fertile window `ov−5→ov` (6 days) vs extended `ov−5→ov+1` (7 days)  
2. Uncertainty does not expand fertile paint  
3. OPK → `updated_estimate` with remaining uncertainty; forecast preserved  
4. BBT → `retrospective_estimate`  
5. Explicit `C_SELECTION_THRESHOLDS` (stddev≥5, pull≥3, range≥10)  
6. Period `forecast_period_start` / `estimated_period_start` / range fields  
7. Timing-only confidence copy; clinician EDD = “you entered”  

```bash
cd eezycycle-backend
node tests/prediction_engine_phase4_1_stress.js
```
