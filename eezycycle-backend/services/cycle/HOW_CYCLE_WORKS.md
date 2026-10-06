# How EezyCycle Predictions Work

A simple guide to what the app does with your cycle logs — no tech jargon required.

---

## The big idea

EezyCycle looks at what you log (especially period days), learns **your** usual pattern, then paints the calendar with:

- **When your next period might start**
- **When ovulation is most likely**
- **Which days are in your fertile window**

These are **estimates**, not medical facts. The more you log, and the more steady your cycles are, the more useful those estimates tend to be.

---

## What you give the app

You can log things like:

| What you log | What it helps with |
|---|---|
| **Period days** | The main foundation — cycle length, period length, next period |
| **Ovulation test (OPK)** | Can gently shift the ovulation estimate for the current cycle |
| **Basal body temperature (BBT)** | Can refine the ovulation estimate after the fact |
| **Cervical mucus** | Supporting clue only — never decides ovulation alone |
| **Symptoms** | Personal insights (e.g. “cramps often show up before your period”) — **not** used to set fertile or ovulation days |
| **Pregnancy test / pregnancy mode** | Switches the app into pregnancy dating (due date), not normal cycle forecasts |

**Period days are the truth the calendar is built on.** Everything else either improves the estimate or adds helpful context.

---

## Step by step: what happens behind the scenes

Think of it like a short checklist the app runs whenever predictions need updating.

### 1. Group your period days into “bleeding stretches”

If you log period on Mon–Wed, the app treats that as one period start (Monday), not three separate cycles.

### 2. Learn your personal pattern

From completed cycles it figures out things like:

- **Typical cycle length** (how many days from one period start to the next)
- **Typical period length** (how many days bleeding usually lasts)
- Whether your cycles are **fairly regular** or **more variable**

Recent cycles matter more than old ones. Extremely short or long cycles are kept in history but don’t pull averages in a misleading way.

If you’re new and don’t have much history yet, the app leans on what you entered during setup (like “my cycle is usually 28 days”).

### 3. Estimate ovulation from that pattern

A simple way to think about it:

> **Next period start, minus the “second half” of the cycle (luteal phase) ≈ ovulation day**

By default that “second half” is about **14 days**, unless your own history (especially past ovulation tests) suggests a more personal number.

### 4. Use extra clues carefully (evidence layers)

The app stacks clues in layers. Higher layers can **update** the estimate — they do **not** claim “ovulation is confirmed on this exact day.”

| Layer | Meaning in plain English |
|---|---|
| **A** | Calendar guess from your usual cycle length |
| **B** | Your personal luteal length from past OPK history |
| **C** | A positive ovulation test this cycle nudges the estimate |
| **D** | A BBT shift pattern can narrow the estimate after ovulation likely happened |

**Symptoms never set ovulation.** Mucus can support a guess; it doesn’t override the calendar alone.

### 5. Draw a fertile window around ovulation

Around the estimated ovulation day, the app marks a **fertile window**:

- Roughly the **5 days before ovulation**, plus ovulation itself  
- By default the app also includes **one day after** (a slightly more cautious window)

Important: if the app is less sure *when* ovulation is, it shows a **range of possible days** for the estimate — it does **not** paint a huge extra fertile zone just because timing is uncertain.

### 6. Predict the next periods (and a few ahead)

Using your typical cycle length, it projects:

- Next period start (and how many days it might last)
- Often several cycles ahead for calendar planning

Each prediction can include an **earliest–latest range** when your cycles vary a lot or you don’t have much data yet.

### 7. Attach a “how sure are we?” label

Confidence here means:

> **How solid is this timing estimate given your data?**

It does **not** mean:

- Chance of getting pregnant  
- Chance you are fertile today  
- Birth-control safety  

More logged cycles + steadier lengths + useful tests → higher timing confidence. New users or irregular cycles → lower confidence and wider ranges.

### 8. Refresh the calendar

When you change period history, finish onboarding, toggle pregnancy mode, or update today’s biomarkers, the app **rebuilds** predictions so Home and the calendar stay in sync.

---

## What you see on the calendar

For each day, the app picks one main label when several ideas overlap. Priority is roughly:

1. **Pregnancy** (if that mode is on)  
2. **Ovulation**  
3. **Period**  
4. **Fertility**  

So ovulation day stays marked as ovulation, not just “fertile.”

---

## Pregnancy mode (separate from cycle forecasts)

If pregnancy mode is active:

- The app focuses on a **due date**
- Prefer a **clinician / ultrasound** due date when you have one  
- Otherwise it can estimate from the **last menstrual period (LMP)**

Normal period / ovulation / fertile forecasts take a back seat while pregnancy mode is on.

---

## Insights (symptoms)

If you often log the same symptoms near certain parts of the cycle, the app may show gentle notes like:

- “You often log cramps in the days before your period.”

These are **personal patterns**, written carefully so they never claim “symptoms prove you’re ovulating.”

---

## What this system is *not*

- Not a doctor or diagnostic tool  
- Not a guarantee of ovulation on a single day  
- Not a contraceptive method  
- Not “confirmed pregnant / not pregnant” from calendar math alone  

OPK and BBT **improve estimates**; they do not turn the app into a lab confirmation.

---

## Everyday takeaways

1. **Log period days consistently** — that’s the backbone.  
2. **A few full cycles** make predictions more personal than setup averages alone.  
3. **OPK / BBT** can fine-tune the current cycle’s ovulation estimate.  
4. **Ranges and confidence** are honesty about uncertainty — not a bug.  
5. **Fertile days** follow the ovulation estimate; they don’t grow endlessly when the app is unsure.  
6. **Symptoms** help you understand yourself; they don’t drive fertility math.

---

## One-sentence summary

**EezyCycle learns your cycle from period history, estimates ovulation and fertility around that pattern, gently updates those estimates when you log tests or temperature, and always treats the result as a timing estimate — not a medical confirmation.**
