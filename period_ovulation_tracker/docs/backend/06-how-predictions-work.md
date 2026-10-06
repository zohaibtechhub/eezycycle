# How EezyCycle Calculates Periods, Ovulation & Pregnancy

This document explains **how the app predicts** period days, ovulation (best day), fertile window (best days), and pregnancy timeline — based on the live backend engine **`ecc_prediction_v4`** (Flo-aligned math + statistics + evidence + pregnancy polish).

> **Disclaimer:** These are **educational estimates only**. They are **not** contraception and **not** a medical guarantee for conception or due dates.

**Related docs**
- **Current engine overview:** [08-how-the-algorithm-works-now.md](./08-how-the-algorithm-works-now.md)
- Deeper Flo-alignment math: [04-cycle-formulas-flo.md](./04-cycle-formulas-flo.md)
- **4-phase roadmap:** [07-prediction-engine-phases.md](./07-prediction-engine-phases.md)
- Implementation: `eezycycle-backend/services/cycle/` + `flo_calendar_service.js`
- Rebuild / API: `eezycycle-backend/services/cycle_service.js`

**Algorithm version:** `ecc_prediction_v4_1` (v4 + biological/semantic corrections)

### v4.1 corrections (applied)

- OPK **updates** ovulation timing toward the expected post-LH-surge interval (~1–2 days after a positive test); does **not** hard-set `T+1` as confirmed ovulation  
- BBT **retrospectively narrows** the estimate; does not declare an exact confirmed day  
- **Core** fertile window `ov−5→ov` vs optional **extended** `ov−5→ov+1`; uncertainty does not expand fertile paint  
- Confidence = **timing/data** confidence only (not conception probability)  
- Evidence A/B/C/D are **layers to combine**, not a universal ranking  
- Forecast vs updated/retrospective estimate for ovulation **and** period starts  
- Explicit median thresholds: stddev ≥ 5, \|weighted−median\| ≥ 3, range ≥ 10  
- Clinician EDD copy = “date you entered” (not “clinically verified”)  

### Phase 2 additions (what users may notice)

- Forecast cycle length **C** uses a **recency-weighted** mean (newer cycles count more).
- Period and ovulation predictions store an **expected range** (`range_start` / `range_end`), not only a single date.
- Fertile window = biology (`ovulation − 5` … `ovulation + 1`) **expanded by ovulation uncertainty** (high confidence → tighter; low → wider).
- Home soft copy: when confidence is **low**, period countdown may say **“Period around…”** instead of a hard “Period in…”.
- Rebuild: full wipe/replace by default; `POST /cycle/predictions/rebuild` with `{ "mode": "today" }` for a near-term update path.

### Phase 3 additions (biomarker evidence)

- **Level A** — calendar prior (`next period − luteal`)
- **Level B** — personal luteal from past positive OPK cycles (≥2 samples)
- **Level C** — positive LH/OPK shifts current ovulation ≈ **test day + 1**
- **Level D** — sustained BBT rise confirms / tightens ovulation estimate
- Cervical mucus is **supporting only**; **symptoms never set ovulation**
- Logging OPK/mucus (or `bbt_celsius` on daily logs / `PUT /cycle/observations`) triggers a **TODAY UPDATE**
- Home may say estimates are “informed by your LH test” / temperature pattern — still not certainty

### Phase 4 additions (pregnancy + polish)

- **Dual due dates:** LMP + 280 days **and** optional clinician/ultrasound EDD — **clinician wins** when present; LMP kept as history (`lmp_based_edd`, `edd_source`)
- Pregnancy mode still **turns off** cycle fertility/ovulation predictions
- Home shows soft confidence (“Based on limited data” / “Based on your recent cycles”) — **never** raw scores
- Personal insights from symptom **timing patterns** only (`GET /cycle/insights`) — never “you are fertile because of X”
- Logging a new period start records predicted vs actual for future tuning (`prediction_validation_log`)

---

## 1. Big picture

```text
User logs period days
        ↓
Group into bleed runs → find last period start (LMP / S)
        ↓
Compute averages: cycle length C, period length P
        ↓
Predict:
  • next periods
  • ovulation (best day)
  • fertile window (best days)
        ↓
Store rows in cycle_predictions
        ↓
Home / calendar read GET /cycle/today + GET /cycle/calendar
```

If **pregnancy mode** is on, cycle/fertile predictions stop and the home hero shows pregnancy week + due date instead.

---

## 2. Defaults (when history is thin)

| Symbol | Meaning | Default |
|--------|---------|---------|
| **C** | Average / predicted cycle length (days) | **28** |
| **P** | Average bleed (period) length (days) | **5** |
| **L** | Assumed luteal phase (days before next period → ovulation) | **14** |
| Pregnancy | Days from LMP to due date | **280** (40 weeks) |

---

## 3. Periods — what we store vs what we predict

### 3.1 Logged periods (truth)

- User taps days in onboarding calendar or tracker calendar.
- Saved via **`PUT /api/cycle/period-days`** as real bleed days (not predicted).
- These are the **source of truth**.

### 3.2 Bleed runs

Consecutive logged days become one **bleed run**:

```text
Example logged: Mar 1, 2, 3, 4, 5
→ run: start=Mar 1, end=Mar 5, length=5
```

A gap of 1+ days starts a new run.

### 3.3 Last period start `S`

```text
S = start date of the most recent bleed run
```

All predictions are anchored from **S**.

### 3.4 Completed cycles (for averages)

Between two period starts:

```text
cycle_length = days between run[i].start and run[i+1].start
```

Example: Mar 1 → Mar 29 → cycle length **28**.

---

## 4. How we personalize C and P

From completed cycles (prefer last **12**):

### Cycle length `C`

1. Keep cycles with length **21–45** (ignore crazy gaps / mistaps).
2. Average those lengths and **round**.
3. If none usable → onboarding/declared value or **28**.
4. Clamp: **`C = clamp(C, 21, 45)`**.

### Period length `P`

1. Flo-style default stays **5** until history is solid.
2. Only personalize when we have **≥ 3** good bleed lengths (3–7 days) **and** ≥ 3 usable cycles.
3. Clamp: **`P = clamp(P, 3, 7)`**.

### Irregular?

Marked irregular (wider fertile window) when:

- fewer than **3** usable cycles, or
- cycle-length **stddev ≥ 7**, or
- any usable cycle outside **21–35** (with enough history).

Stored as `fertile_window_mode`: `standard` | `wide`.

---

## 5. Predicting the next periods

Given last start **S** and average **C**:

```text
predicted_period_start_k = S + (k × C)     for k = 1, 2, 3, …
```

For each predicted start, mark **P** days as predicted period:

```text
for d in 0 .. (P - 1):
  mark (predicted_period_start + d) as day_type = "period"
```

We generate about **6 cycles ahead** for the year calendar.

Logged period days always win: if a date is already logged as period, we **do not** store a prediction on that date.

---

## 6. Ovulation — the “best day”

Flo’s published calendar rule: ovulation ≈ **14 days before the next period** (luteal phase **L = 14**).

```text
next_period = S + C
ovulation   = next_period - L
            = S + C - 14
```

| Cycle length C | Ovulation cycle day |
|----------------|---------------------|
| 28 | Day **14** |
| 21 | Day **7** |
| 35 | Day **21** |

Important: we do **not** always use “day 14 of the cycle”. That only matches 28-day cycles.

On that date we store:

```text
day_type = "ovulation"
```

This is the **best day** highlighted on home / calendar (highest chance estimate).

---

## 7. Fertile window — “best days”

Biology used (Flo-style):

- Sperm can live up to ~**5 days**
- Egg viable ~**24 hours**

### Biological base window

```text
ov = ovulation date (most likely)

bio_start = ov - 5
bio_end   = ov + 1
```

Inclusive biology = **7 days** (`ov-5` … `ov+1`). The `ov` day is stored as `ovulation`; neighbors as `fertility`.

### Phase 2: expand by ovulation uncertainty

```text
U = ovulation_uncertainty_days   (from variability + confidence)

fertile_start = bio_start - U
fertile_end   = bio_end + U
```

| Confidence | Typical effect |
|------------|----------------|
| high | smaller `U` → tighter window |
| medium | moderate `U` |
| low / irregular / thin history | larger `U` → wider window |

This **replaces** using only the old forever rule `regular=7 / irregular≈14` as the sole width control (those Flo helpers remain for legacy reference; the live engine uses uncertainty).

| Date | `day_type` |
|------|------------|
| `ov` | `ovulation` (best day) |
| other days in fertile window | `fertility` (best days) |

Period and ovulation rows also store `range_start` / `range_end` around the most-likely date (UI can still highlight the point estimate).

---

## 8. Day priority when labels overlap

One calendar day can only have one primary type. Priority:

```text
ovulation > period > fertility > none
```

So if fertile window overlaps a predicted period day, **period** (or **ovulation**) wins as configured by that priority.

---

## 9. Pregnancy mode

When `pregnancy_mode_active = true`:

1. **Delete / stop** cycle predictions (no fertile / ovulation / predicted period rows for the owner calendar).
2. Due date (Flo rule):

```text
due_date = first day of last period (LMP / S) + 280 days
```

3. Gestational age on a given date:

```text
days_pregnant = max(0, date - LMP)
weeks         = floor(days_pregnant / 7)
days          = days_pregnant % 7
days_until_due = due_date - date
```

4. Home hero shows copy like: *“You're X weeks Y days pregnant”* plus days until due.

Turning pregnancy mode **off** (e.g. switch to Track cycle) clears the flag and **rebuilds** cycle predictions again.

---

## 10. What the Home screen shows for a date

`GET /api/cycle/today?date=YYYY-MM-DD` builds a day summary:

| Situation | Result |
|-----------|--------|
| Pregnancy mode on | `day_type=pregnancy`, week/days/due fields |
| No period history | Prompt to log period |
| Date is logged period | `day_type=period`, period day number |
| Date in predictions | `ovulation` / `fertility` / predicted `period` |
| Otherwise | Follicular / luteal style messaging from cycle day |

Also returns:

- `days_until_next_period`
- `days_until_ovulation`
- `phase` (`menstrual`, `follicular`, `ovulation`, `fertility`, `luteal`, `pregnancy`)

Flutter maps this in `CycleDisplayMapper` for hero headlines.

---

## 11. When predictions rebuild

`rebuildPredictions(userId)` runs when:

| Trigger | Why |
|---------|-----|
| `PUT /cycle/period-days` | User changed logged periods |
| `GET /cycle/today` | No predictions yet, but periods exist |
| `GET /cycle/calendar` | Missing fertile/ovulation rows |
| `POST /cycle/predictions/rebuild` | Manual rebuild |
| Profile leaves pregnancy mode | Need cycle calendar again |
| Onboarding complete (with periods) | Seed first predictions |

Concurrent rebuilds for the same user are **locked** so parallel home API calls don’t hit MySQL duplicate-key errors.

Predictions are stored in **`cycle_predictions`** with unique `(user_id, pred_date)`.

---

## 12. Worked example (classic 28-day)

```text
S = 2026-03-01
C = 28, P = 5, L = 14

next_period = 2026-03-29
ovulation   = 2026-03-15          ← best day
fertile     = 2026-03-10 .. 2026-03-16   ← best days
next bleed  = 2026-03-29 .. 2026-04-02   (predicted period)
```

### 35-day cycle

```text
S = 2026-03-01, C = 35

next_period = 2026-04-05
ovulation   = 2026-03-22          ← day 22 of cycle (not day 14)
fertile     = 2026-03-17 .. 2026-03-23
```

---

## 13. Code map (for developers)

| Concern | File / function |
|---------|-----------------|
| Bleed runs | `groupBleedRuns()` |
| Averages C / P (legacy helpers) | `flo_calendar_service.computeAverages()` |
| Weighted profile + uncertainty | `services/cycle/cycle_statistics_service.js`, `uncertainty_service.js` |
| Fertile window (live) | `fertility_prediction_service.computeFertileWindowFromUncertainty()` |
| Build prediction rows | `services/cycle/prediction_service.generatePredictions()` |
| Today / pregnancy summary | `buildDaySummary()` |
| Due date / gestational age | `pregnancy_service.resolveDating()`, `dueDateFromLmp()`, `gestationalAgeFromDue()` |
| Evidence B–D | `evidence_processor.processEvidence()` |
| Insights (safe) | `insight_service.buildPersonalInsights()` |
| Predicted vs actual | `prediction_validation_service.logNewPeriodStarts()` |
| Persist + rebuild | `fullRebuild` / `todayUpdate` via `cycle_service.rebuildPredictions()` |
| DB tables | `cycle_predictions`, `cycle_observations`, `prediction_validation_log` |
| Flutter UI copy | `lib/core/services/cycle_display_mapper.dart` |

---

## 14. QA checklist

- [ ] 28-day cycle → ovulation on day 14  
- [ ] Ovulation = `next_period - 14`, not always cycle day 14  
- [ ] Fertile base = 7 days (`ov-5` … `ov+1`), then ± ovulation uncertainty  
- [ ] Low confidence / thin history → wider ranges and fertile window  
- [ ] Positive OPK → ovulation ≈ T+1 (Level C); BBT rise can confirm (Level D)  
- [ ] Symptoms never set ovulation day  
- [ ] New period log recalculates C/P and regenerates predictions  
- [ ] Pregnancy mode hides ovulation/fertile predictions  
- [ ] Clinician EDD overrides LMP due date; LMP kept as history  
- [ ] Leaving pregnancy mode rebuilds the cycle calendar  
- [ ] UI copy says estimates only (soft confidence / “around” when useful)  
- [ ] Insights never claim fertility from symptoms  

---

## 15. Simple glossary

| Term | Meaning in EezyCycle |
|------|----------------------|
| **Period / bleed** | Days the user logged (or we predicted) as menstrual flow |
| **Cycle length (C)** | Days from one period start to the next |
| **Ovulation (best day)** | Estimated egg-release day = next period − 14 |
| **Fertile / best days** | Window around ovulation when conception chance is higher |
| **LMP (S)** | First day of the last menstrual period |
| **Due date** | LMP + 280 days in pregnancy mode |
