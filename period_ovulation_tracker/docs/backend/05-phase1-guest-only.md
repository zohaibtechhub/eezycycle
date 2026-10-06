# Phase 1 — Full App, Guest Only

**Goal:** Ship the **complete EezyCycle product experience** without email/password/Google login.  
Every user is a **guest** (`account_status = 'guest'`). Onboarding, periods, Flo formulas, Today messages, partner code, content, secret chat — all work.

**Phase 2 (later):** “Add email to finish account”, login, merge, multi-device restore.

Database: **`eezycycle`**  
Identity: [01-guest-vs-account-strategy.md](./01-guest-vs-account-strategy.md)  
Formulas: [04-cycle-formulas-flo.md](./04-cycle-formulas-flo.md)  
Privacy: [03-play-console-health-privacy.md](./03-play-console-health-privacy.md)

---

## Phase 1 principle

```
Install → create guest (device_id + JWT)
       → privacy consents
       → full onboarding (no signup wall)
       → main app (all tabs)
       → periods / logs / formulas / UI day messages
       → partner code generate OR enter
       → articles / insights / tips / FAQ / secret chat
```

Login / Signup screens can stay in the app as **stubs or hidden**, or show “Coming soon — you’re using as guest.”  
Drawer “Add your email…” → **defer to Phase 2** (hide or non-functional CTA).

Do **not** build a second local-only data model. Guest is already a real `users` row on the server.

---

## In scope (Phase 1)

### 1. Guest auth (only auth in P1)

| Item | Behavior |
|------|----------|
| `POST /auth/guest` | Create/reuse guest by `device_id` |
| `POST /auth/refresh` | Refresh tokens |
| `GET /me` | Profile + `account_status: guest` |
| Secure storage | Persist `device_id`, access + refresh tokens on device |

**Out of P1:** upgrade, login, signup, Google, merge, forgot password.

### 2. Privacy consents (required before health write)

- Terms + health-data processing (existing privacy screen)
- Store in `user_consents`
- Block period/log APIs until consents accepted

### 3. Complete onboarding (no login)

All current flows:

- Privacy → Usage (self / partner code) → Discovery → Birth year → Goals  
- Dynamic Q&A by mode (pregnant / track cycle / partner / perimenopause / …)  
- Last period calendar, height/weight, reminders opt-in  
- Progress → Comparison → Commit → Main tabs  

Persist:

- `user_profiles`, `user_goals`, `onboarding_answers`, `reminder_preferences`  
- Initial period days from onboarding calendar  
- Then run **Flo formulas** → seed `cycle_predictions`

If Usage = partner path: enter code during onboarding → same as partner link API.

### 4. Period saving + formulas + Today UI messages

| Feature | Behavior |
|---------|----------|
| Log / edit period days | Calendar taps → `period_days` |
| Daily symptom/mood/sex/tests sheet | `daily_logs` + `daily_log_items` |
| Rebuild predictions | On every period change → [04 formulas](./04-cycle-formulas-flo.md) |
| Home / Partner Today hero | Message from `day_type` + cycle day (period / fertile / ovulation / luteal / …) |
| Year calendar | Logged vs predicted period, fertile, ovulation |
| Cycle & ovulation graph | Avg C, avg P, history from `cycles` |

### 5. Partner code (guest ↔ guest OK in P1)

| Action | Behavior |
|--------|----------|
| Generate code | Owner guest gets 6-char code (`partner_links`) |
| Enter / accept code | Partner guest links; both stay guests |
| Share scope | Phases + predicted period/fertile only — **never** sex/symptoms/tests/notes |
| Partner Today / calendar | Read-only filtered predictions + partner copy |
| Disconnect | Revoke link |

Both devices need network + their own guest JWT.  
UI must show partner disclosure before link activates.

### 6. Rest of app (guest)

| Area | P1 |
|------|-----|
| Insights tab / articles / bookmarks | Yes (CMS can be seeded SQL or static JSON served by API) |
| Relationship tips | Yes |
| FAQ / legal docs | Yes |
| Secret chats (profile, posts, comments, likes) | Yes (optional: rate-limit guests) |
| Experience mode switch + mini onboarding | Yes |
| Pregnancy mode activation | Yes (disable cycle predictions while active) |
| Drawer settings (except account upgrade) | Yes |
| Delete my data | Yes (Play requirement even for guests) |

---

## Out of scope (Phase 2+)

| Deferred | Why |
|----------|-----|
| Email / password / Google signup & login | Explicit P2 |
| Account upgrade / merge | P2 |
| Multi-device restore via account | Guests are device-bound |
| Forgot password | N/A |
| Selling / ads on health data | Never |
| Full CMS admin UI | Seed data enough for P1 |
| Push notification *scheduling* workers | Optional; save prefs only in P1 |
| Real Health Connect permissions | Not required for P1 guest tracking |

---

## UI day messages (display layer)

Server (or client using prediction payload) returns enough for Flutter hero copy.

### Input

- `today`
- `cycle_day` (1-based from last period start)
- `day_type`: `period` | `ovulation` | `fertility` | `luteal`/`none` | `pregnancy`
- `period_day` (1..P) when bleeding
- `avg_cycle_length` C, `avg_period_length` P
- `days_until_next_period`, `days_until_ovulation` (computed)

### Message map (woman / self Today) — align with existing `DayCycleModel` style

| Condition | Example headline direction |
|-----------|----------------------------|
| `day_type = period` | “Period day {period_day}” / care & rest messaging |
| `day_type = fertility` (not ov day) | “Fertile window” / higher chance messaging |
| `day_type = ovulation` | “Predicted ovulation day” |
| Follicular (after period, before fertile) | Energy / follicular insights |
| Luteal (after ov, before next period) | PMS / wind-down messaging |
| `pregnancy_mode` | Week / countdown to due date |
| No period logged yet | Prompt: “Log your period to unlock predictions” |

### Partner Today

Same dates/phases, **partner headlines only** (supportive copy). No intimate details.

Keep copy templates in backend config or Flutter constants keyed by `day_type` + `experience_mode` — API returns structured flags; UI picks strings (easier to localize).

**Recommended API shape for Home:**

```json
{
  "date": "2026-03-15",
  "cycle_day": 15,
  "day_type": "ovulation",
  "period_day": null,
  "phase": "ovulation",
  "days_until_next_period": 14,
  "days_until_ovulation": 0,
  "fertile_window_mode": "standard",
  "algorithm_version": "flo_calendar_v1",
  "message_key": "today_ovulation",
  "partner_message_key": "partner_today_ovulation"
}
```

Flutter maps `message_key` → localized UI strings (matches your current design without hardcoding medical claims).

---

## Phase 1 API surface

### Auth
- `POST /auth/guest`
- `POST /auth/refresh`
- `POST /auth/logout` (revoke refresh; next open can recreate/reuse guest)

### Me / privacy
- `GET /me`
- `PATCH /me/profile`
- `POST /me/consents`
- `DELETE /me` (delete guest + health data)
- `GET /me/export` (optional but good for Play)

### Onboarding
- `PUT /onboarding/answers` (bulk upsert step answers)
- `PUT /onboarding/goals`
- `POST /onboarding/complete` (sets profile mode, initial periods, triggers prediction rebuild)

### Cycle
- `GET /cycle/summary` (C, P, next period, next ov, mode)
- `GET /cycle/today` (message keys + day_type — **Home**)
- `GET /cycle/calendar?from=&to=`
- `PUT /cycle/period-days` (replace/add/remove dates → rebuild predictions)
- `POST /cycle/predictions/rebuild` (admin/internal; usually auto)

### Daily logs
- `GET /logs?date=`
- `PUT /logs/{date}` (items + encrypted note)

### Partner
- `POST /partner/code` (generate)
- `POST /partner/link` (enter code + consent)
- `GET /partner/status`
- `DELETE /partner/link`
- `GET /partner/today` (filtered)
- `GET /partner/calendar?from=&to=` (filtered)

### Content (read + bookmark)
- `GET /articles`, `GET /articles/:id`
- `POST/DELETE /articles/:id/bookmark`
- `GET /insights`, `GET /tips`, `GET /faqs`

### Secret chat
- `PUT /secret/profile`
- `GET /posts`, `POST /posts`, comments/likes CRUD

---

## Tables needed in Phase 1

Implement from schema doc — **skip** only upgrade/merge-specific if you want leaner P1:

**Must have**

- `users`, `devices`, `refresh_tokens`
- `user_profiles` (incl. C, P, luteal, fertile_window_mode)
- `user_consents`, `user_goals`, `onboarding_answers`, `reminder_preferences`
- `cycles`, `period_days`, `cycle_predictions`
- `daily_logs`, `daily_log_items`
- `partner_links`
- CMS: `articles` (+ sections/takeaways), `insights`, `relationship_tips`, `faqs`, `legal_documents`
- `article_bookmarks`
- `secret_profiles`, tags, `posts`, comments, likes
- `data_deletion_requests` (for Delete)

**Can wait for Phase 2**

- `account_merge_events`
- Google/email columns heavily used (keep columns nullable now)
- Heavy `privacy_access_audit` tooling (table OK to create empty)

---

## Flutter Phase 1 checklist

1. On splash: ensure `device_id` → `POST /auth/guest` → save tokens.  
2. Wire onboarding to APIs (not in-memory only).  
3. After last-period step / commit: save periods → predictions → Home uses `GET /cycle/today`.  
4. Calendar + log sheet → API.  
5. Partner tab → generate/enter code → Partner Today from filtered API.  
6. Hide or disable Login/Signup upgrade until P2.  
7. Settings: privacy links + delete data.  
8. All screens work offline-fail gracefully (snackbar), but P1 is **online-first**.

---

## Partner linking — two guests (example)

```
User A (guest)  POST /partner/code     → code SYNC88
User B (guest)  POST /partner/link     → { code: "SYNC88", consented: true }
User B          GET  /partner/today    → A's phases only
User A          GET  /cycle/today      → full (own) data
```

If A or B deletes account → revoke link.

---

## Success criteria (Phase 1 done)

- [ ] Fresh install → guest created → onboarding finishes → Home shows Flo-based day message  
- [ ] Log period → next period / ovulation / fertile update on calendar  
- [ ] Daily log sheet persists and reloads  
- [ ] Two devices/guests can link via code; partner never sees sex/tests/notes  
- [ ] Articles / insights / tips / FAQ load  
- [ ] Secret chat works as guest  
- [ ] Delete my data wipes guest health rows  
- [ ] No login required anywhere in the happy path  
- [ ] Medical estimate disclaimer visible on prediction UI  

---

## Phase 2 teaser (do not build now)

- Upgrade guest → registered (same `user_id`)  
- Login + merge dialog  
- Show drawer “Add your email…” for real  
- Multi-device sync via account  

When P2 starts, **no schema rewrite** — only auth endpoints and UI unlock.
