# How the EezyCycle Algorithm Works Now

**Engine version:** `ecc_prediction_v4_1` (**frozen** conceptual architecture)  
**Status:** Production-oriented statistical / evidence system. Next milestone is **real-data validation**, not ML.

> **Disclaimer:** Everything below is a **timing estimate**. It is **not** contraception, **not** a medical diagnosis, **not** confirmed ovulation, and **not** a guarantee of fertility or due date. Calendar/app methods cannot precisely determine an individual’s ovulation day.

**Related docs**
- Longer reference: [06-how-predictions-work.md](./06-how-predictions-work.md)
- Flo formula background: [04-cycle-formulas-flo.md](./04-cycle-formulas-flo.md)
- Roadmap: [07-prediction-engine-phases.md](./07-prediction-engine-phases.md)

---

## 1. One-sentence summary

Logged periods (and optional LH / BBT / mucus) build a **robust personal cycle profile**, then a **baseline forecast** that evidence can **update** into a current **estimate** — with **timing uncertainty** kept separate from a **core / extended fertile window** — or a **pregnancy countdown** from LMP or a **user-entered** clinician/ultrasound date.

---

## 2. Truth vs forecast vs estimate

| Layer | Meaning |
|-------|---------|
| **Observation** | What the user logged (truth) |
| **Forecast** | What we thought would happen beforehand |
| **Estimate** | Best current timing guess — still not “confirmed” |
| **Prediction row** | Stored calendar row for UI |

Symptoms never set ovulation.

---

## 3. Pipeline

```text
PERIOD HISTORY
      ↓
ROBUST PERSONAL CYCLE PROFILE
  (mean · median · weighted_mean · stddev · range)
      ↓
BASELINE PERIOD + OVULATION FORECAST
      ↓
LH / BBT / MUCUS (layers to combine)
      ↓
UPDATED OVULATION ESTIMATE
      ↓
TIMING UNCERTAINTY  (range on ovulation — not equally “fertile” paint)
      ↓
CORE / EXTENDED FERTILE WINDOW
      ↓
SOFT TIMING CONFIDENCE
      ↓
UI
```

---

## 4. Choosing cycle length **C** (explicit thresholds)

Always stored: `mean`, `median`, `weighted_mean`, `stddev`, `range`, `recent_variability`.

| Condition | Threshold | Forecast C |
|-----------|-----------|------------|
| `cycle_stddev` high | **≥ 5** | **median** |
| `\|weighted − median\|` large | **≥ 3** days | **median** |
| cycle length range large | **≥ 10** days | **median** |
| otherwise | — | **weighted mean** |

Period length **P**: use median when `|weighted − median| ≥ 2`.

Outliers outside **21–45** stay in history but are excluded from forecast averages (`unusual ≠ invalid`).

Constants: `C_SELECTION_THRESHOLDS` in `services/cycle/constants.js`.

---

## 5. Ovulation

### Forecast (Layer A ± B)

```text
forecast_ovulation ≈ (S + C) − L
```

`L` defaults to 14; Layer B may personalize from historical OPK heuristics.

### OPK (Layer C) — update, don’t confirm

A positive test on day **T** does **not** mean `ovulation = T + 1`.

It means the estimate shifts toward the **expected post-LH-surge interval, approximately within the following 1–2 days** after a positive result — blended with the prior — while **uncertainty remains**.

```text
estimate_status = updated_estimate
```

### BBT (Layer D) — retrospective narrowing

Sustained rise → retrospectively narrows the timing estimate; still not an exact confirmed day.

```text
estimate_status = retrospective_estimate
```

### Stored for the open cycle

```text
forecast_ovulation_date
estimated_ovulation_date
ovulation_range_start / ovulation_range_end
estimate_status
evidence_layers   e.g. [A, C] or [A, B, D]
```

A/B/C/D are **layers to combine**, not a universal ranking.

---

## 6. Fertile window (core vs extended)

Timing uncertainty does **not** expand fertile calendar paint.

| Mode | Interval | Notes |
|------|----------|--------|
| **Core** | `ovulation − 5` → `ovulation` | 6 days ending on ovulation (counseling-style) |
| **Extended** | `ovulation − 5` → `ovulation + 1` | Optional product conservatism |

Default calendar mode today: **extended**.  
Both windows are stored on fertility rows (`coreFertile*` / `extendedFertile*`).

Ovulation day itself is labeled **ovulation**; neighbors are **fertility**.

UI intent: “Fertile window estimated around …” — not equal fertility probability on every day, not contraception.

---

## 7. Period forecast vs estimate

Same conceptual split as ovulation (for validation):

```text
forecast_period_start
estimated_period_start
period_range_start
period_range_end
```

Today, without period-moving biomarkers, forecast === estimated at generation time. Fields stay distinct so `prediction_validation_log` can compare original forecast vs later reality/estimates.

Returned on `generatePredictions()` as `period: { ... }`.

---

## 8. Confidence = timing / data confidence only

```text
confidence
  = confidence in the timing estimate / data quality

NOT = probability of conception
NOT = “you are fertile”
NOT = contraceptive safety
```

Soft labels always say **“Timing estimate …”**.

---

## 9. Pregnancy dating

| Source | Meaning | Priority |
|--------|---------|----------|
| LMP + 280 | From logged last period | Fallback / history |
| Clinician/ultrasound date **you entered** | User-provided | Wins when present |

Wording: “Based on clinician/ultrasound date you entered” — **not** “clinically verified.”

Pregnancy mode clears cycle fertility/ovulation predictions.

---

## 10. Rebuild & validation

| Mode | When |
|------|------|
| FULL | Period history, onboarding, leave pregnancy, manual |
| TODAY | Biomarker logs — near-term refresh |

`prediction_validation_log` records predicted vs actual period starts for future MAE / ±1–3 day metrics. **Performance must be measured on real data** — architecture alone does not imply accuracy.

---

## 11. What we deliberately do **not** do

- No neural net required for this architecture  
- No “safe day” claims  
- No ovulation from symptoms alone  
- No treating OPK/BBT as exact confirmed ovulation  
- No painting uncertainty days as equally fertile  
- No showing raw confidence as conception probability  
- No claiming a user-entered clinician date is medically verified by the app  

---

## 12. Code map

| Concern | Location |
|---------|----------|
| Version + thresholds + fertile modes | `constants.js` |
| Orchestrator | `prediction_service.js` |
| Stats / median protection | `cycle_statistics_service.js` |
| Evidence layers | `evidence_processor.js` |
| Core / extended fertile | `fertility_prediction_service.js` |
| Period forecast/estimate | `period_prediction_service.js` |
| Timing confidence copy | `confidence_service.js` |
| Pregnancy dating | `pregnancy_service.js` |
| Validation | `prediction_validation_service.js` |

---

## 13. Mental model (frozen)

```text
PERIOD HISTORY
      ↓
ROBUST PERSONAL CYCLE PROFILE
      ↓
BASELINE PERIOD + OVULATION FORECAST
      ↓
LH / BBT / MUCUS
      ↓
UPDATED OVULATION ESTIMATE
      ↓
TIMING UNCERTAINTY
      ↓
CORE FERTILE WINDOW  (+ optional EXTENDED)
      ↓
SOFT TIMING CONFIDENCE
      ↓
UI
```

**Next serious milestone:** real-world validation metrics — not adding AI.
