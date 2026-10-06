# Prediction Engine Phase 4 — Stress Test Results

**Engine:** `ecc_prediction_v4`  
**Script:** `eezycycle-backend/tests/prediction_engine_phase4_stress.js`  
**Run:** `node tests/prediction_engine_phase4_stress.js`

## Summary

| Metric | Value |
|--------|------:|
| Scenarios | 25 |
| Assertions | 60 |
| Passed | 60 |
| Failed | **0** |
| Pass rate | **100.00%** |

## What was validated

1. **Dual EDD** — clinician/ultrasound preferred; LMP+280 kept as history  
2. **`buildDaySummary`** — pregnancy countdown uses clinician due when present  
3. **Soft confidence** — labels like “Based on limited data” / “Based on your recent cycles” (no raw `0.xx`)  
4. **Insights** — symptom timing patterns marked `safe`; no fertility claims from symptoms  
5. **Symptoms** — still do not move ovulation date  
6. **Validation delta** — `actual − predicted` day math for period-start hooks  

## SQL to import (phpMyAdmin → `eezycycle`)

1. `sql/migrations/016_alter_user_profiles_edd_sources.sql`  
2. `sql/migrations/017_create_prediction_validation_log.sql`  

(Plus Phase 1 `014` + `015` if not already imported.)

## How to re-run

```bash
cd eezycycle-backend
node tests/prediction_engine_phase4_stress.js
```
