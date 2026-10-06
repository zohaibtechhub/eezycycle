# EezyCycle Backend Docs

Planning docs for the **Node.js + MySQL** API that will back the Flutter app.

**MySQL database name:** `eezycycle`

| Doc | Purpose |
|-----|---------|
| [01-guest-vs-account-strategy.md](./01-guest-vs-account-strategy.md) | Guest vs registered account, merge rules, auth flow (+ consent / deletion) |
| [02-mysql-table-structure.md](./02-mysql-table-structure.md) | Full MySQL schema (cycle, logs, articles, partner, secret chat, privacy tables) |
| [03-play-console-health-privacy.md](./03-play-console-health-privacy.md) | Play Console Health apps + Data safety — user-visible disclosures, encryption, deletion |
| [PRIVACY_POLICY.md](../PRIVACY_POLICY.md) | **User-facing Privacy Policy** (host as public HTTPS URL for Play + in-app) |
| [04-cycle-formulas-flo.md](./04-cycle-formulas-flo.md) | Period / ovulation / fertile-window formulas aligned with Flo’s published rules |
| [05-phase1-guest-only.md](./05-phase1-guest-only.md) | **Phase 1 scope** — full app as guest only (onboarding, periods, formulas, UI messages, partner code) |
| [06-how-predictions-work.md](./06-how-predictions-work.md) | **How we calculate** periods, ovulation (best day), fertile window, pregnancy — implementation guide |
| [07-prediction-engine-phases.md](./07-prediction-engine-phases.md) | **4-phase roadmap** for the full prediction engine — command `phase 1`…`phase 4` |
| [08-how-the-algorithm-works-now.md](./08-how-the-algorithm-works-now.md) | **Current engine (`ecc_prediction_v4_1`)** — plain-language how it works (incl. forecast vs estimate) |
| [Pregnancy daily insights (Flo-style)](../pregnancy-daily-insights-structure.md) | Baby / body / symptoms cards by week+day — content model, API, Flutter process |
| [Phase 1–4 stress results](../../../eezycycle-backend/tests/) | `PREDICTION_ENGINE_PHASE*_RESULTS.md` under `eezycycle-backend/tests/` |

**Build order now:** Prediction engine Phases 1–4 are implemented (`ecc_prediction_v4`). Guest-only product Phase 1 remains the app auth posture.

**Recommended read order (predictions):** [08 how it works now](./08-how-the-algorithm-works-now.md) → [06 reference](./06-how-predictions-work.md) → [04 Flo formulas](./04-cycle-formulas-flo.md) → [07 phases](./07-prediction-engine-phases.md).

Reproductive health data is highly sensitive. Intimate fields must not be casually readable by staff or partners. Cycle math must follow [04-cycle-formulas-flo.md](./04-cycle-formulas-flo.md).
