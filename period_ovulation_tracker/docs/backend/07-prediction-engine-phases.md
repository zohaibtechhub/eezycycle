# EezyCycle Prediction Engine — 4-Phase Roadmap

> **How to use this file with the AI agent**  
> Say exactly one of: **`phase 1`**, **`phase 2`**, **`phase 3`**, or **`phase 4`**.  
> That command means: implement **only that phase** from this document (backend + Flutter as listed). Do not start later phases until commanded.

**Product rule (all phases):** UI language stays **estimated / predicted**. Never claim a day is “safe,” never present confidence as fertility certainty. Keep the existing health disclaimer.

**Algorithm naming**
- Keep current logic as the base; rename conceptually to **`ecc_prediction_v1`** (today’s `flo_calendar_v1` continues until Phase 1 ships the rename).
- Later evidence upgrades bump to `ecc_prediction_v2`, etc.

**Related docs**
- Current live math: [06-how-predictions-work.md](./06-how-predictions-work.md)
- Flo formulas: [04-cycle-formulas-flo.md](./04-cycle-formulas-flo.md)

---

## Target architecture (build now, activate layers as data appears)

```text
                    USER DATA
                       │
       ┌───────────────┼────────────────┐
       ↓               ↓                ↓
   Periods          Symptoms        Biomarkers
                                      │
                              ┌───────┼───────┐
                              ↓       ↓       ↓
                             BBT   OPK/LH   Cervical
                                           mucus
       │               │                │
       └───────────────┼────────────────┘
                       ↓
             PERSONAL CYCLE PROFILE
                       │
          ┌────────────┼────────────┐
          ↓            ↓            ↓
      Cycle length  Period length  Luteal phase
          │            │            │
          └────────────┼────────────┘
                       ↓
              STATISTICAL ENGINE
                       │
          ┌────────────┼────────────┐
          ↓            ↓            ↓
       Period       Ovulation     Fertility
     prediction     estimate       window
          │            │            │
          └────────────┼────────────┘
                       ↓
               CONFIDENCE ENGINE
                       ↓
             FINAL USER PREDICTION
```

No neural network. Intelligence = **data model + statistics + biology + personalization + uncertainty**.

Layers that need more user data (BBT, OPK, mucus) are **wired in the architecture from Phase 1**, but only become active when enough evidence exists.

---

## Core principles (locked for all phases)

### 1. Separate TRUTH from PREDICTION

| Observations (user reported) | Predictions (EezyCycle estimates) |
|------------------------------|-----------------------------------|
| `period` / period day / period ended | `predicted_period` |
| `symptom` | `predicted_ovulation` |
| `bbt` | `predicted_fertility` |
| `ovulation_test` (OPK/LH) | `predicted_cycle_length` |
| `cervical_mucus` | `predicted_luteal_phase` |
| `pregnancy_test` | ranges + confidence |

**Actual observation always wins** over a prediction on the same date.

Example:

```text
Mar 29 → predicted_period = true, actual_period = false
User logs Mar 30 as period
→ Mar 29 stays prediction; Mar 30 is observation
```

### 2. Evidence hierarchy for ovulation (fallback → stronger)

| Level | Evidence | Behavior |
|-------|----------|----------|
| **A** | No ovulation evidence | `next_period − luteal` (default L=14) |
| **B** | Historical ovulation logs | Personal luteal estimate |
| **C** | OPK/LH positive | Shift/update ovulation probability |
| **D** | Sustained BBT shift | Confirm / tighten around probable ovulation |

Symptoms are **supporting insights only** — never “you ovulated because of cramps.”

### 3. Do **not** invent unvalidated confidence weights

Avoid fixed recipes like `40% history + 30% symptoms + …` unless validated later. Prefer ordered evidence rules.

---

## Phase overview

| Phase | Name | Goal | Command |
|-------|------|------|---------|
| **1** | Foundation & schema | Truth vs prediction, service split, profile skeleton, prediction envelope | `phase 1` |
| **2** | Statistical engine | Weighted means, regularity, ranges, uncertainty-based fertile window, smart rebuild | `phase 2` |
| **3** | Evidence layers | OPK / BBT / mucus / historical luteal update ovulation; symptoms as support | `phase 3` |
| **4** | Pregnancy, insights & polish | Clinician EDD, personal insights, validation hooks, UI confidence (soft) | `phase 4` |

```text
Phase 1 ──► Phase 2 ──► Phase 3 ──► Phase 4
 (structure)  (stats)     (biomarkers) (product polish)
```

---

# Phase 1 — Foundation & schema

**Command:** `phase 1`

### Intent
Keep `flo_calendar_v1` behavior working, but **restructure** so later layers plug in without rewriting Home/calendar again.

### What will be done

1. **Rename / version**
   - Treat engine as `ecc_prediction_v1` (keep Flo math as default Level A).
   - Central pipeline sketch:

```text
generatePredictions(user)
  → collect observations
  → build cycle history (bleed runs)
  → personal statistics (basic)
  → predict period / ovulation / fertility
  → attach confidence skeleton
  → persist predictions
```

2. **Service split** under `eezycycle-backend/services/cycle/` (or equivalent):

```text
observation_service
bleed_run_service
cycle_statistics_service
regularity_service          # stub OK in Phase 1
luteal_phase_service        # default L=14
period_prediction_service
ovulation_prediction_service
fertility_prediction_service
pregnancy_service           # existing LMP+280
confidence_service          # stub: high/medium/low from data volume
prediction_service          # orchestrator
prediction_rebuild_service
```

3. **Schema direction** (migrations under `eezycycle-backend/sql/`)

**Observations** (actual user data) — unify or bridge toward:

```text
cycle_observations
  id, user_id, date, observation_type, value, source, created_at
```

Types: `period`, `bbt`, `ovulation_test`, `cervical_mucus`, `symptom`, `pregnancy_test`

**Predictions** — evolve `cycle_predictions`:

```text
(user_id, pred_date, prediction_type)   -- NOT only (user_id, pred_date)

+ predicted_value / day label
+ range_start, range_end
+ confidence          -- internal 0–1 or enum
+ evidence_level      -- A/B/C/D or sources list
+ algorithm_version
+ created_at, updated_at
```

So one date can hold:

```text
user 1 | Mar 15 | ovulation
user 1 | Mar 15 | fertility
user 1 | Mar 29 | period
```

UI picks the **primary** label (same priority as today: ovulation > period > fertility).

4. **Personal Cycle Profile (compute now; cache optional)**

```text
cycle_mean, cycle_median, cycle_weighted_mean (simple equal weights OK in P1)
cycle_stddev
period_mean / period_median
luteal_mean (default 14 until evidence)
regularity_score / data_quality / prediction_confidence (basic)
```

Outliers: **exclude from prediction averages** when &lt;21 or &gt;45 for *forecasting*, but **keep as observations** in history.

5. **Prediction envelope on every prediction**

```text
predicted_date
earliest_date / latest_date   -- can equal predicted_date in Phase 1
confidence                    -- low/medium/high from N cycles
evidence_sources              -- e.g. ["historical_cycle_data"]
algorithm_version
```

6. **Flutter**
   - Keep current Home/calendar UX.
   - Consume new prediction shape if API changes (mapper updates).
   - Still show single primary day type; ranges can stay internal if UI not ready.

7. **Pregnancy**
   - Keep LMP + 280.
   - Keep “pregnancy mode off → no fertile/ovulation predictions.”
   - Leave room for clinician EDD later (Phase 4).

### Done when
- [ ] Observations vs predictions clearly separated in code/DB
- [ ] Unique key allows multiple prediction types per date
- [ ] Rebuild still works; Home still shows period / ovulation / fertility
- [ ] Profile + confidence fields exist (even if simple)
- [ ] `ecc_prediction_v1` version string used on new rows

### Out of scope for Phase 1
Weighted recent-cycle emphasis (beyond stub), OPK/BBT logic, Bayesian updates, clinician EDD, FULL vs TODAY rebuild split.

---

# Phase 2 — Statistical engine & uncertainty

**Command:** `phase 2`

### Intent
Make predictions a **distribution**, not a single hard date; widen fertile window from **ovulation uncertainty**, not a forever hard-coded 7 vs 14.

### What will be done

1. **Weighted cycle averages** (recent cycles weigh more), e.g. for 6 cycles weights `1,1,2,2,3,4`.

2. **Full stats pack**
   - mean, median, weighted mean, stddev, range, recent variability
   - internal `prediction_confidence` = high / medium / low (and optional 0–1)

3. **Period prediction as range**

```text
Most likely = Mar 29
Expected range = Mar 27–Apr 1
Confidence = medium/high
```

UI can still say “Period expected Mar 29”; engine stores the range.

4. **Fertile window from uncertainty**

```text
biological window (ov−5 … ov+1)
  + ovulation uncertainty
  → final fertile window
```

High confidence → tighter window; low confidence → wider (replaces forever `regular=7 / irregular=14` as the only rule).

5. **Smarter rebuild**
   - `FULL REBUILD` — period history / onboarding / pregnancy toggle / manual
   - `TODAY UPDATE` — lightweight path reserved for biomarker day updates (Phase 3 will use this)

6. **Flutter**
   - Optional soft copy: “around Mar 29” when confidence low
   - Calendar can show range hints without claiming certainty

### Done when
- [x] Weighted + multi-stat profile used for next period / ovulation
- [x] Predictions persist `range_start` / `range_end` / confidence
- [x] Fertile width depends on uncertainty + biology
- [x] FULL vs TODAY rebuild entry points exist

### Out of scope for Phase 2
OPK/BBT/mucus Bayesian updates; symptom→ovulation claims; clinician EDD.

### Phase 2 shipped (code)
- `ecc_prediction_v2` + weighted recency stats + uncertainty service
- Period/ovulation ranges; fertile = `(ov−5…ov+1) ± ovulation_uncertainty`
- `fullRebuild` / `todayUpdate` (`POST /cycle/predictions/rebuild` with `mode: "today"`)
- Flutter soft copy when `confidence` is low (“Period around…”)
- Stress: `tests/prediction_engine_phase2_stress.js` → `PREDICTION_ENGINE_PHASE2_RESULTS.md`

---

# Phase 3 — Evidence layers (biomarkers)

**Command:** `phase 3`

### Intent
Activate Level B–D ovulation evidence. Same engine; richer inputs.

### What will be done

1. **Observation ingestion** for:
   - OPK / LH (`ovulation_test`)
   - BBT (`bbt`)
   - Cervical mucus (`cervical_mucus`)
   - Keep symptoms as observations for insights only

2. **Evidence processor**
   - Level B: historical luteal from past confirmed/estimated ovulations
   - Level C: positive OPK shifts prior ovulation estimate
   - Level D: sustained BBT rise increases confidence / tightens window
   - Conceptual flow: prior → new evidence → updated prediction (simple Bayesian *mindset*, not a research paper)

3. **Symptoms**
   - Never set ovulation from symptoms alone
   - Aggregate for personal patterns (“you often log X before period”) — may land UI in Phase 4 if needed

4. **TODAY UPDATE**
   - Logging today’s BBT/OPK updates the relevant horizon without full-year wipe when possible

5. **Flutter**
   - Wire logging UIs (where missing) to observation APIs
   - Home can show “based on your LH test” style evidence only if carefully worded as estimate

### Done when
- [x] OPK/BBT/mucus stored as observations
- [x] Ovulation prediction moves when LH/BBT evidence arrives
- [x] Evidence sources listed on prediction rows
- [x] Symptoms do not force ovulation day_type

### Out of scope for Phase 3
Clinician ultrasound EDD; ML models; arbitrary % confidence recipes.

### Phase 3 shipped (code)
- `ecc_prediction_v3` + `evidence_processor.js` (Levels B–D)
- Observation upsert API: `GET/PUT/DELETE /cycle/observations`
- Daily logs sync OPK / mucus / symptoms / optional `bbt_celsius` → observations + `todayUpdate`
- Flutter: cervical mucus log items + Home evidence soft copy
- Stress: `tests/prediction_engine_phase3_stress.js` → `PREDICTION_ENGINE_PHASE3_RESULTS.md`

---

# Phase 4 — Pregnancy upgrade, insights & polish

**Command:** `phase 4`

### Intent
Product-grade pregnancy dating sources, safer insights, and soft confidence UX — still no neural net.

### What will be done

1. **Pregnancy dating sources (distinct)**
   - `LMP-based EDD` (existing LMP + 280)
   - `clinician_or_ultrasound_EDD` when user enters it
   - Prefer clinician dating when present; keep LMP as fallback/history

2. **Pregnancy mode**
   - Confirmed pregnancy → cycle fertility/ovulation predictions stay off
   - Clear audit of which EDD source is active

3. **Personal insights (safe language)**
   - Symptom timing patterns relative to period/ovulation estimates
   - Never “you are fertile because of headache”

4. **UI confidence (soft)**
   - Do **not** show raw `0.74` unless product decides later
   - Prefer “Estimate”, “Based on limited data”, “Based on your recent cycles”

5. **Validation hooks**
   - Log predicted vs actual period starts for future tuning
   - No fake weight formulas without data

6. **Docs & QA**
   - Update [06-how-predictions-work.md](./06-how-predictions-work.md) to match shipped engine
   - Expand QA checklist for evidence levels + pregnancy sources

### Done when
- [x] Dual EDD sources supported
- [x] Insights are pattern-based, not ovulation claims from noise
- [x] Soft confidence copy on Home when useful
- [x] Prediction-vs-actual logging path exists for later validation

### Phase 4 shipped (code)
- `ecc_prediction_v4` + dual EDD (`lmp` / `clinician_ultrasound`)
- SQL: `016` EDD columns, `017` `prediction_validation_log`
- `GET /cycle/insights` + insights on `GET /cycle/today`
- Soft `soft_confidence_label` (never show raw scores in UI)
- Validation hook on new period starts (`PUT /cycle/period-days`)
- Flutter: clinician EDD on pregnancy activation + EDD audit / soft copy on Home
- Stress: `tests/prediction_engine_phase4_stress.js` → `PREDICTION_ENGINE_PHASE4_RESULTS.md`

---

## Target service layout (end state)

```text
cycle/
├── observation_service
├── bleed_run_service
├── cycle_statistics_service
├── regularity_service
├── luteal_phase_service
├── period_prediction_service
├── ovulation_prediction_service
├── fertility_prediction_service
├── pregnancy_service
├── confidence_service
├── evidence_processor          # Phase 3+
├── prediction_service
└── prediction_rebuild_service
```

Final pipeline:

```text
USER INPUT
  → OBSERVATION LAYER
  → CYCLE PROCESSOR (bleed runs, lengths)
  → PERSONAL STATISTICS
  → EVIDENCE PROCESSOR
  → PREDICTION ENGINE (period / ovulation / fertility / pregnancy)
  → UNCERTAINTY ENGINE (range, confidence, data quality)
  → CALENDAR / HOME / INSIGHTS
```

---

## Agent execution contract

When the user says **`phase N`**:

1. Read **this file** and implement **only Phase N** checklist items.
2. Prefer migrations in `eezycycle-backend/sql/` for phpMyAdmin (project rule).
3. Do not throw away current `flo_calendar_v1` math — wrap and extend it.
4. Keep Flutter working after each phase (Home + calendar).
5. Update [06-how-predictions-work.md](./06-how-predictions-work.md) if behavior users see changes.
6. Summarize what shipped vs deferred when done.

---

## Status

| Phase | Status |
|-------|--------|
| Phase 1 — Foundation & schema | **Done (code)** — import SQL `014` + `015` in phpMyAdmin |
| Phase 2 — Statistical engine | **Done (code)** — `ecc_prediction_v2` |
| Phase 3 — Evidence layers | **Done (code)** — `ecc_prediction_v3` |
| Phase 4 — Pregnancy & polish | **Done (code)** — `ecc_prediction_v4`; import SQL `016` + `017`, restart API |

### Phase 1 shipped checklist

- [x] Observations vs predictions separated (`cycle_observations` + `cycle_predictions`)
- [x] Unique key `(user_id, pred_date, prediction_type)`
- [x] Service split under `services/cycle/`
- [x] Personal cycle profile + confidence skeleton (Level A)
- [x] Prediction envelope fields (range/confidence/evidence)
- [x] `ecc_prediction_v1` version string
- [x] Home/calendar still use primary `day_type` (Flutter compatible)
- [ ] **You:** run migrations `014` + `015` in phpMyAdmin

### Phase 2 shipped checklist

- [x] Weighted cycle averages (e.g. 6 cycles → `1,1,2,2,3,4`)
- [x] Full stats pack + confidence high/medium/low
- [x] Period/ovulation as ranges (`range_start` / `range_end`)
- [x] Fertile window from biology + ovulation uncertainty
- [x] FULL vs TODAY rebuild entry points
- [x] Flutter soft copy for low confidence
- [x] Stress test 100% pass (`PREDICTION_ENGINE_PHASE2_RESULTS.md`)
### Phase 3 shipped checklist

- [x] OPK / BBT / mucus / symptoms stored in `cycle_observations`
- [x] `evidence_processor` Levels B–D (luteal / OPK / BBT)
- [x] Ovulation moves on LH / BBT evidence; sources on prediction rows
- [x] Symptoms never force ovulation `day_type`
- [x] TODAY UPDATE on biomarker logs
- [x] Flutter mucus items + soft evidence Home copy
- [x] Stress test 100
### Phase 3 shipped checklist

- [x] OPK / BBT / mucus / symptoms stored in `cycle_observations`
- [x] `evidence_processor` Levels B–D (luteal / OPK / BBT)
- [x] Ovulation moves on LH / BBT evidence; sources on prediction rows
- [x] Symptoms never force ovulation `day_type`
- [x] TODAY UPDATE on biomarker logs
- [x] Flutter mucus items + soft evidence Home copy
- [x] Stress test 100% pass (`PREDICTION_ENGINE_PHASE3_RESULTS.md`)
- [ ] **You:** ensure SQL `014` + `015` imported (observations table required)

### Phase 4 shipped checklist

- [x] Dual EDD sources (LMP + clinician/ultrasound); clinician preferred
- [x] Pregnancy mode keeps fertility/ovulation predictions off + EDD audit fields
- [x] Safe personal insights (symptom timing; never fertility claims)
- [x] Soft confidence labels on Home / today payload
- [x] Predicted vs actual period-start logging (`prediction_validation_log`)
- [x] Docs + stress test 100% pass (`PREDICTION_ENGINE_PHASE4_RESULTS.md`)
- [ ] **You:** import SQL `016` + `017` in phpMyAdmin (and `014`/`015` if missing)

### v4.1 corrections (post Phase 4)

Engine tag: `ecc_prediction_v4_1`

- [x] OPK updates estimate toward post-surge interval (uncertainty remains; not exact T+1 confirmation)
- [x] BBT retrospectively narrows estimate (not exact confirmation)
- [x] Biological fertile window separated from timing uncertainty
- [x] Confidence defined as timing/data confidence only
- [x] A/B/C/D treated as evidence layers to combine
- [x] Forecast vs updated/retrospective estimate distinguished
- [x] Median-protected cycle length when outliers pull weighted mean
- [x] Clinician EDD wording = user-entered (not “verified”)
- [x] Stress: `tests/prediction_engine_phase4_1_stress.js` → `PREDICTION_ENGINE_PHASE4_1_RESULTS.md`

### v4.1 freeze (final conceptual adjustments)

- [x] Core fertile window (`ov−5→ov`) vs optional extended (`ov−5→ov+1`)
- [x] Explicit `C_SELECTION_THRESHOLDS` in `constants.js`
- [x] Period `forecast_*` / `estimated_*` / range fields (parity with ovulation)
- [x] OPK wording: expected post-surge interval ~1–2 days after positive test
- [x] Docs `08` marked frozen; next milestone = real-data validation (not ML)
