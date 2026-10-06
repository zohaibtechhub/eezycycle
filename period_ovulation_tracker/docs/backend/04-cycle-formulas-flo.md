# Cycle & Ovulation Formulas (Flo-aligned)

EezyCycle predictions follow the **same publicly documented calendar rules Flo uses** for period / ovulation / fertile-window estimates.

Flo’s full production model also uses proprietary AI and optional BBT/wearables. That black-box part is **not** copyable. What we implement (and document here) is Flo’s **published** methodology:

Sources: [Flo menstrual cycle calculator](https://flo.health/tools/menstrual-cycle-calculator), [Flo ovulation calculator](https://flo.health/tools/ovulation-calculator), [Flo fertile window help](https://help.flo.health/hc/en-us/articles/360015313531-Why-is-my-fertile-window-so-short-long), [Flo accuracy](https://flo.health/flo-accuracy).

**Disclaimer (same as Flo):** predictions are educational estimates only — **not** contraception and **not** a guarantee for conception.

---

## Database

| Setting | Value |
|---------|--------|
| MySQL database name | `eezycycle` |
| Charset / collation | `utf8mb4` / `utf8mb4_unicode_ci` |

```sql
CREATE DATABASE IF NOT EXISTS eezycycle
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

All tables from [02-mysql-table-structure.md](./02-mysql-table-structure.md) live in `eezycycle`.

---

## Defaults (when user has little history)

Same textbook defaults Flo’s public tools use:

| Symbol | Meaning | Default |
|--------|---------|---------|
| `C` | Predicted / average cycle length (days) | **28** |
| `P` | Average period (bleed) length (days) | **5** |
| `L` | Assumed luteal phase length (days) | **14** |
| Valid cycle range | “Typical” adult cycle | **21–35** |

---

## Core definitions

### Cycle start

```
cycle_start = first day of menstrual bleeding (day 1)
```

Spotting before flow does **not** start a new cycle unless the product later treats it as period (v1: logged period days only).

### Cycle length (completed cycle)

```
cycle_length = (next_cycle_start - this_cycle_start)   // in whole days
```

Example: period starts Mar 1, next period starts Mar 29 → `cycle_length = 28`.

### Period length (bleed length)

```
period_length = count of consecutive logged period days in that cycle
                (or last_period_day - first_period_day + 1)
```

Default fill when user taps one day in onboarding: **5 days** (matches current Flutter UX and Flo’s average).

---

## Averaging (personalization — Flo-style)

Use completed cycles only (both start dates known).

### Average cycle length

```
N = number of completed cycles in history (prefer last 6, max 12)

avg_cycle_length C =
  round( mean( cycle_length_i for i in last N cycles ) )

If N = 0:
  C = user-declared cycle length from onboarding, else 28
```

Clamp for prediction stability (optional but recommended):

```
C = clamp(C, 21, 45)   // still predict outside “typical”; widen fertile window if irregular
```

### Average period length

```
avg_period_length P =
  round( mean( period_length_i for i in last N cycles ) )

If N = 0:
  P = 5

P = clamp(P, 2, 10)
```

### Cycle regularity (for fertile-window width)

```
variation = standard_deviation(cycle_length_i)   // or max - min over last N

is_irregular =
  (N < 3)
  OR (variation >= 7)      // Flo: “vary in length a lot”
  OR (any cycle_length outside 21–35 when N >= 3)
```

---

## Next period prediction

Given last logged cycle start `S` (most recent period start):

```
predicted_next_period_start = S + C days
```

Predicted period days:

```
for d in 0 .. (P - 1):
  mark date (predicted_next_period_start + d) as predicted period
```

Also project further cycles the same way for calendar year view:

```
period_start_k = S + (k * C)    // k = 1, 2, 3, ...
```

When the user logs a new real period start `S'`, recalculate:

```
completed_cycle_length = S' - S
append to history → recompute C, P → regenerate predictions from S'
```

---

## Ovulation prediction (Flo calendar rule)

Flo’s published rule: ovulation ≈ **14 days before the next period** (luteal phase ≈ 14–16 days; calculators use **14**).

```
L = 14   // luteal_phase_days

predicted_ovulation_date = predicted_next_period_start - L

// Equivalent cycle-day form:
ovulation_cycle_day = C - L
// For C = 28 → day 14
// For C = 21 → day 7
// For C = 35 → day 21
```

Absolute date form from last period start:

```
predicted_ovulation_date = S + (C - L)
                         = S + C - 14
```

**Do not** use “always day 14 of cycle” — that only matches 28-day cycles. Flo explicitly shifts ovulation with cycle length via the luteal assumption.

### LH test refinement (optional, later)

If user logs LH positive on date `T`:

```
ovulation_estimate ≈ T + 1 day   // LH surge ~24–36h before ovulation (Flo: ~36h)
```

Prefer this for the **current** cycle over the calendar formula when present; still show uncertainty.

---

## Fertile window (Flo help-center rule)

Biology Flo cites:

- Sperm can live up to **~5 days**
- Egg viable up to **~24 hours**

### Standard window (enough / regular history)

Flo: combine **4–5 days before ovulation + ovulation day + 1–2 days after**, **minimum 7 days**.

Implement the common 7-day window Flo describes as minimum:

```
ov = predicted_ovulation_date

fertile_start = ov - 5      // 5 days before (sperm lifespan)
fertile_end   = ov + 1      // ovulation + 1 day after

// Inclusive day count = 7
// Days: ov-5, ov-4, ov-3, ov-2, ov-1, ov, ov+1
```

Mark:

| Date | `day_type` |
|------|------------|
| `ov` | `ovulation` |
| other dates in `[fertile_start, fertile_end]` | `fertility` |

(If UI wants ovulation highlighted inside the fertile set, keep both: primary type `ovulation`, still “in fertile window”.)

### Wide window (Flo: little data or irregular)

If `N < 3` **OR** `is_irregular`:

```
// Widen up to ~14 days (Flo accuracy / help articles)
fertile_start = ov - 9
fertile_end   = ov + 4
// clamp width to max 14 inclusive days
width = (fertile_end - fertile_start) + 1
if width > 14:
  // center on ovulation
  fertile_start = ov - 6
  fertile_end   = ov + 7   // 14 days
```

When history becomes ≥ 3 cycles and variation drops, shrink back to the **7-day** standard window.

---

## Phase labels (for Today / articles)

Using cycle day `d` where `d = (today - S) + 1` (day 1 = period start), and `ov_day = C - 14`:

| Phase | Cycle days (approx) |
|-------|---------------------|
| Menstrual | `1 .. P` |
| Follicular | `(P + 1) .. (ov_day - 1)` |
| Ovulation | `ov_day` (and optionally fertile peak days) |
| Luteal | `(ov_day + 1) .. C` |

These phases drive article/`phase` filtering — same four buckets as the app’s `CyclePhaseType`.

---

## Worked examples (must match Flo public calculators)

### Example A — classic 28-day

```
S = 2026-03-01
C = 28, P = 5, L = 14

next_period = 2026-03-29
ovulation   = 2026-03-15          // 29 - 14
fertile     = 2026-03-10 .. 2026-03-16   // ov-5 .. ov+1
period days = 2026-03-01 .. 2026-03-05 (logged or predicted next: 03-29 .. 04-02)
```

### Example B — 35-day cycle

```
S = 2026-03-01
C = 35, L = 14

next_period = 2026-04-05
ovulation   = 2026-03-22          // 04-05 - 14 = day 22 of cycle
fertile     = 2026-03-17 .. 2026-03-23
```

### Example C — 21-day cycle

```
S = 2026-03-01
C = 21, L = 14

next_period = 2026-03-22
ovulation   = 2026-03-08          // day 7
fertile     = 2026-03-03 .. 2026-03-09
```

### Example D — new user (widen window)

```
N = 0, C = 28, ov = S + 14
fertile ≈ 14-day wide window centered on ov (see wide-window formula)
```

---

## Pregnancy mode

When `pregnancy_mode_active` and `due_date` set:

- **Stop** cycle/ovulation/fertile predictions for the owner calendar (or hide them).
- Show countdown / pregnancy week instead (UI already sketches this).
- Do not use Flo fertile-window math while pregnancy mode is on.

---

## What we store vs recompute

| Persist | Recompute often |
|---------|-----------------|
| Logged `period_days`, completed `cycles` | `avg_cycle_length`, `avg_period_length` |
| User overrides (optional) | `cycle_predictions` rows for next 2–3 cycles |
| LH / BBT logs (optional) | Fertile window width (`standard` vs `wide`) |

Suggested profile fields (already partly in schema):

```
user_profiles.avg_cycle_length   -- cached C
user_profiles.avg_period_length  -- cached P
user_profiles.luteal_phase_days  -- default 14 (Flo)
user_profiles.fertile_window_mode -- 'standard' | 'wide'
```

Algorithm version string on each prediction batch:

```
cycle_predictions.algorithm_version = 'flo_calendar_v1'
```

So you can migrate later without mixing old rows.

---

## Pseudocode (server)

```text
function rebuildPredictions(userId):
  cycles = lastCompletedCycles(userId, limit=12)
  N = cycles.length
  C = N > 0 ? round(mean(cycles.lengths)) : (profile.declared_C or 28)
  P = N > 0 ? round(mean(cycles.periodLengths)) : (profile.declared_P or 5)
  L = profile.luteal_phase_days or 14
  irregular = N < 3 or stddev(cycles.lengths) >= 7

  S = lastPeriodStart(userId)
  if S is null: return

  clearFuturePredictions(userId)

  for k in 1..3:
    nextStart = S + k * C
    ov = nextStart - L
    if irregular:
      (fStart, fEnd) = wideWindow(ov)      // up to 14 days
    else:
      (fStart, fEnd) = (ov - 5, ov + 1)    // 7 days

    for d in 0..P-1:
      upsert(nextStart + d, type=period, predicted=true)

    for day in fStart..fEnd:
      type = (day == ov) ? ovulation : fertility
      upsert(day, type=type, predicted=true)

  save profile caches: C, P, fertile_window_mode
```

---

## QA checklist (formulas match Flo public behavior)

- [ ] 28-day cycle → ovulation on day 14  
- [ ] Ovulation always `next_period - 14`, not fixed day 14  
- [ ] Standard fertile window = 7 days (`ov-5` … `ov+1`)  
- [ ] &lt; 3 cycles or high variation → fertile window widens toward 14 days  
- [ ] New period log recalculates averages and regenerates predictions  
- [ ] Pregnancy mode disables ovulation/fertile predictions  
- [ ] UI copy: estimates only, not birth control  

---

## Relation to other docs

| Doc | Role |
|-----|------|
| [02-mysql-table-structure.md](./02-mysql-table-structure.md) | Tables that store inputs/outputs of these formulas |
| [03-play-console-health-privacy.md](./03-play-console-health-privacy.md) | Predictions are health estimates — disclose + disclaimer |
