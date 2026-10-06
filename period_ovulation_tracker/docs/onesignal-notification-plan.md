# EezyCycle notification plan — Flo-style + OneSignal

**Status:** Plan only (not implemented)  
**App:** `period_ovulation_tracker`  
**Backend:** `eezycycle-backend` (Node + MySQL / phpMyAdmin)  
**Date:** 2026-09-26  

This document describes how to ship **Flo-like** cycle reminders and **rich push** using **OneSignal**, with scheduling that **does not depend on a traditional server cron** (and treats GitHub Actions scheduled workflows as an optional last resort only).

---

## 1. Goals (Flo-like UX)

| Goal | Flo-like behavior | EezyCycle mapping |
|------|-------------------|-------------------|
| Period coming | “Period may start in 1–2 days” | `reminder_preferences.period_reminder_enabled` |
| Fertile window | “Higher chance of pregnancy today / soon” | `fertile_days_enabled` |
| Log nudge | Soft “Log spotting / symptoms?” | After predicted period start if no new log |
| Daily tip | Short educational / wellness tip | `daily_tips_enabled` |
| Pregnancy test | Optional TTC timing tip | `pregnancy_test_enabled` |
| Partner support | Partner gets phase-aware tip (never intimate logs) | Partner linked users only |
| Quiet hours | Respect local evening / morning | OneSignal timezone delivery + local prefs |
| Rich push | Image + action buttons | OneSignal rich media + `buttons` / deep links |

**Non-goals (v1):** SMS, email marketing blasts, medical diagnosis claims, partner seeing symptoms/sex/tests.

---

## 2. Architecture (preferred — no cron)

```
┌─────────────────────┐     register playerId      ┌──────────────────┐
│  Flutter app        │ ─────────────────────────► │  OneSignal       │
│  onesignal_flutter  │ ◄──── rich push / IAM ──── │  (delivery)      │
└─────────┬───────────┘                            └────────▲─────────┘
          │ PATCH /me/push + tags                            │
          ▼                                                  │
┌─────────────────────┐   on cycle events / prefs   ┌────────┴─────────┐
│  eezycycle-backend  │ ── Create Notification ───► │  OneSignal REST  │
│  + MySQL predictions│    send_after / timezone    │  API             │
└─────────────────────┘                            └──────────────────┘
```

**Who schedules what**

| Layer | Responsibility | Cron needed? |
|-------|----------------|--------------|
| **OneSignal** | Queue sends (`send_after`), local-time delivery (`delayed_option: timezone`), Journeys | **No** |
| **Backend (event-driven)** | When user logs period / completes onboarding / toggles prefs → compute next dates → **create or cancel** OneSignal notifications | **No** |
| **Flutter local** (optional) | Same-day / tomorrow soft alarms via `flutter_local_notifications` when app opens | **No** |
| **GitHub Actions** | Optional batch safety net only | Avoid if possible (see §7) |

**Principle:** Predictions already live in MySQL (`predictions`, period logs, `reminder_preferences`). Treat **user events** as the scheduler trigger — not a nightly cron scraping all users.

---

## 3. Flo-style notification catalog

Use stable `notification_type` codes for tags, analytics, and cancel/replace.

### 3.1 Woman (cycle owner)

| Code | When to schedule | Title (example) | Body (example) | Deep link |
|------|------------------|-----------------|----------------|-----------|
| `period_soon` | 1–2 days before predicted period | Period may be close | Want to review your calendar? | `eezycycle://calendar` |
| `period_expected` | Predicted period start day (local morning) | Period day may start today | Log flow when you’re ready | `eezycycle://calendar` |
| `log_period_nudge` | Expected day +1 if no new period log | Still quiet on logging? | A quick log keeps predictions sharp | `eezycycle://calendar` |
| `fertile_start` | First fertile day | Fertile window | Higher chance days are starting (estimate) | `eezycycle://home` |
| `ovulation_day` | Predicted ovulation day | Around ovulation | Timing estimate only — not contraception | `eezycycle://home` |
| `daily_tip` | Local 9:00–10:00 if enabled | Today’s tip | Short wellness / phase tip | `eezycycle://articles` |
| `symptom_nudge` | Optional, mid-luteal or user opt-in | How are you feeling? | Log symptoms in a few taps | `eezycycle://log?cat=symptoms` |
| `pregnancy_week` | Pregnancy mode only, weekly | You’re around week N | Gentle check-in & tips | `eezycycle://home` |
| `ttc_test_window` | If `pregnancy_test_enabled` | Test window tip | Educational — follow product / clinician guidance | `eezycycle://home` |

### 3.2 Partner (read-only)

| Code | When | Title | Body | Notes |
|------|------|-------|------|-------|
| `partner_phase_tip` | Phase change / morning of fertile or period | Support tip | High-level only (“she may need extra care”) | **Never** symptoms, sex, tests |
| `partner_period_soon` | 1 day before her predicted period | Heads-up | Soft support reminder | Same privacy rules |

### 3.3 Account / product

| Code | Trigger | Example |
|------|---------|---------|
| `welcome` | After onboarding complete | Welcome to EezyCycle |
| `secret_chat_reply` | Someone comments on your post (transactional) | New comment on your post |
| `password_security` | Prefer email OTP (already shipped); push optional | Rare |

---

## 4. OneSignal setup

### 4.1 Dashboard

1. Create OneSignal app (iOS + Android).
2. Upload iOS APNs key / Android FCM (Firebase) credentials.
3. Enable **Additional Data** + deep links.
4. Plan **Segments** (optional): `period_reminder_on`, `fertile_on`, `daily_tips_on`, `is_partner`, `experience_track_cycle`, etc. — better driven by **Data Tags** than static lists.

### 4.2 Flutter (`onesignal_flutter`)

- Init OneSignal early (after privacy consent if required by policy).
- Request permission (iOS) / POST_NOTIFICATIONS (Android 13+).
- On login / guest session: send **External User Id** = backend `users.id` (string).
- On logout / end guest: `OneSignal.logout()` / clear external id.
- Handle:
  - Foreground display
  - Tap → parse `additional_data` → `Get.toNamed(...)`
- Store `onesignal_subscription_id` / player id via `PATCH /me/push` (new endpoint).

**Suggested packages**

- `onesignal_flutter` (remote + rich)
- Optional: `flutter_local_notifications` for same-device near-term backup

### 4.3 Backend

Env (never commit secrets):

```env
ONESIGNAL_APP_ID=...
ONESIGNAL_REST_API_KEY=...
ONESIGNAL_API_URL=https://api.onesignal.com
```

New modules (suggested):

| File | Role |
|------|------|
| `services/onesignal_service.js` | Create / cancel notification wrappers |
| `services/notification_planner_service.js` | Given userId → compute next sends from predictions + prefs |
| `controllers/me_controller.js` | `PATCH /me/push`, `PATCH /me/reminders` |
| SQL `025_create_push_devices.sql` | Map `user_id` ↔ OneSignal subscription id |
| SQL `026_create_scheduled_notifications.sql` | Track OneSignal `notification_id` per type for cancel/replace |

---

## 5. Scheduling **without** server cron (recommended)

### Strategy A — Event-driven plan + OneSignal `send_after` (primary)

Whenever any of these happen, call `notification_planner_service.rebuild(userId)`:

- `PUT /cycle/period-days` (period logged)
- Onboarding complete
- Reminder prefs changed
- Experience / pregnancy mode change
- Partner linked / unlinked
- App open → `GET /me` (optional light rebuild if plan stale > 24h)

**Planner algorithm (per user):**

1. Load `reminder_preferences`, profile, predictions, last period.
2. For each enabled type, compute next local fire datetime (cap horizon e.g. **14–30 days**).
3. Cancel previous OneSignal messages for that `user_id` + `notification_type` (see cancel below).
4. Create new OneSignal notifications with:
   - `include_aliases` / external_id targeting that user
   - `send_after`: ISO-8601 UTC
   - **or** `delayed_option: "timezone"` + `delivery_time_of_day: "9:00AM"` for “local morning” tips
5. Persist returned OneSignal `id` in `scheduled_notifications` for later cancel.

**Why this replaces cron:** OneSignal holds the queue; your server only **replans** when data changes.

### Strategy B — OneSignal Journeys + Tags (marketing / soft lifecycle)

Keep transactional cycle math on your server. Use Journeys for:

- Welcome series
- “Haven’t opened in 7 days” re-engagement
- Tip content that doesn’t need precise ovulation math

Update **Data Tags** from backend when prefs change:

```json
{
  "period_reminder": "1",
  "fertile_reminders": "1",
  "daily_tips": "1",
  "experience_mode": "track_cycle",
  "is_partner": "0"
}
```

### Strategy C — Local notifications (device) as Flo polish

On each successful `loadCycleData` / calendar load:

- Schedule **at most** the next 1–3 local notifications (period tomorrow, fertile start).
- Cancel & reschedule when predictions change.
- Complements OneSignal when the phone is offline from your API but OS still fires locals.

**Do not** rely on locals alone for multi-device / partner.

### Cancel / replace pattern

OneSignal: cancel scheduled notification by id (REST cancel endpoint) when rebuilding.

DB row example:

```text
scheduled_notifications
  id, user_id, notification_type, onesignal_notification_id,
  fire_at_utc, status (scheduled|sent|cancelled), payload_json
```

Unique key: `(user_id, notification_type)` → one active schedule per type.

---

## 6. Rich notifications (Flo-like)

### 6.1 Payload shape (OneSignal)

```json
{
  "app_id": "YOUR_APP_ID",
  "include_aliases": { "external_id": ["42"] },
  "headings": { "en": "Period may be close" },
  "contents": { "en": "Predictions suggest your period could start in 2 days." },
  "big_picture": "https://cdn.eezycycle.app/push/period_soft.jpg",
  "ios_attachments": { "id": "https://cdn.eezycycle.app/push/period_soft.jpg" },
  "huawei_big_picture": "https://cdn.eezycycle.app/push/period_soft.jpg",
  "buttons": [
    { "id": "open_calendar", "text": "Open calendar" },
    { "id": "snooze", "text": "Remind later" }
  ],
  "data": {
    "notification_type": "period_soon",
    "deep_link": "eezycycle://calendar",
    "user_role": "owner"
  },
  "send_after": "2026-10-02T04:00:00Z",
  "existing_android_channel_id": "cycle_reminders",
  "priority": 5,
  "ios_sound": "default",
  "android_accent_color": "FFE85078"
}
```

### 6.2 Rich assets

| Asset | Use |
|-------|-----|
| Soft rose / cycle illustrations (brand-safe, not clinical gore) | `big_picture` / iOS attachment |
| App logo small icon | Android large icon |
| Phase-colored accent | `#E85078` brand rose |

Host images on your CDN or `/uploads/push/` (public HTTPS). Avoid personal photos in push images.

### 6.3 Android channels (create in app)

| Channel id | Name | Importance |
|------------|------|------------|
| `cycle_reminders` | Cycle reminders | High |
| `daily_tips` | Daily tips | Default |
| `partner_tips` | Partner tips | Default |
| `community` | Secret chat | High |

### 6.4 Deep links / actions

Flutter: parse `notification.additionalData`:

- `open_calendar` → calendar route  
- `open_home` → main bottom nav  
- `open_log` → log bottomsheet with category  
- `snooze` → call `POST /me/notifications/snooze` → planner reschedules +6h / next evening  

---

## 7. GitHub CLI / Actions — optional, **not preferred**

You asked for OneSignal **+** GitHub CLI in the plan. Use GitHub **only as a safety net**, because scheduled workflows are still cron under the hood (`on: schedule`).

### When it might be OK

- Catch users who never reopened the app after predictions changed (missed event-driven rebuild).
- Ops: dry-run report of “users with prefs on but no `scheduled_notifications` row”.

### When to avoid

- Primary delivery path for period/fertile timing (racey, coarse, secret-prone if misconfigured).
- Per-minute or heavy MySQL scans from Actions against production without IP allowlists.

### If you still add a weekly safety net

**Repo:** e.g. `.github/workflows/notification-replan-safety.yml`

```yaml
name: Notification replan safety net
on:
  workflow_dispatch: {}   # preferred: run via GitHub CLI when needed
  # schedule:
  #   - cron: '0 6 * * 0'  # OPTIONAL weekly — avoid if event-driven is healthy
jobs:
  replan:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger backend replan
        run: |
          curl -X POST "$BACKEND_URL/internal/notifications/replan-stale" \
            -H "Authorization: Bearer $INTERNAL_JOB_TOKEN" \
            -H "Content-Type: application/json" \
            -d '{"stale_hours": 168, "limit": 500}'
```

**GitHub CLI (manual, no cron):**

```bash
# one-off safety pass when you want it
gh workflow run notification-replan-safety.yml

# or call backend directly from laptop with secrets in env
gh secret list   # ensure INTERNAL_JOB_TOKEN / BACKEND_URL exist
```

**Backend internal route** (protected by shared secret, not public):

- Select users where `reminder_*_enabled` and no scheduled row / `updated_at` old.
- Call same `notification_planner_service.rebuild(userId)` as event path.
- Rate-limit; never put OneSignal REST key in the workflow — only call **your** backend.

---

## 8. Privacy & compliance (must)

- Ask for notification permission **after** value is clear (post onboarding / first period log) — Flo-style, not on first frame.
- Honor `reminder_preferences` and marketing/notification consents already in DB (`consent_type` includes `notifications`).
- Partner pushes: **phase-level language only**.
- No fertility certainty wording; always “estimate”.
- Do not put PHI (symptom lists, sex logs) in push title/body.
- Document retention of `scheduled_notifications` and device ids in Privacy Policy.

---

## 9. Implementation phases

### Phase 0 — Foundations (1–2 days)

- [ ] OneSignal apps + FCM/APNs  
- [ ] Flutter SDK init, permission, external user id  
- [ ] SQL: `push_devices`, `scheduled_notifications` (phpMyAdmin import under `eezycycle-backend/sql/`)  
- [ ] `PATCH /me/push`, wire reminder prefs to UI settings screen  

### Phase 1 — Event-driven cycle pushes (core Flo)

- [ ] `onesignal_service` + planner on period save / onboarding / prefs  
- [ ] Types: `period_soon`, `period_expected`, `fertile_start`, `ovulation_day`  
- [ ] Cancel/replace on rebuild  
- [ ] Deep links to calendar / home  

### Phase 2 — Rich + tips

- [ ] Images + action buttons  
- [ ] Android channels  
- [ ] `daily_tip` with timezone delivery  
- [ ] Partner tip types  

### Phase 3 — Polish

- [ ] Local notification complement  
- [ ] Snooze API  
- [ ] Secret chat comment push  
- [ ] Optional `gh workflow run` safety net (no standing cron)  

---

## 10. API sketch

### `PATCH /me/push`

```json
{
  "onesignal_subscription_id": "…",
  "platform": "ios" | "android",
  "enabled": true
}
```

### `PATCH /me/reminders`

```json
{
  "fertile_days_enabled": true,
  "pregnancy_test_enabled": false,
  "daily_tips_enabled": true,
  "period_reminder_enabled": true,
  "quiet_hours_start": "22:00",
  "quiet_hours_end": "07:00",
  "timezone": "Asia/Karachi"
}
```

(Extend `reminder_preferences` columns when implementing quiet hours / timezone.)

### Internal (optional)

`POST /internal/notifications/replan-stale` — GitHub CLI / Actions only, secret header.

---

## 11. Decision summary

| Question | Answer |
|----------|--------|
| Prefer server cron? | **No** |
| Prefer GitHub Actions cron? | **No** as primary; optional `gh workflow run` safety net |
| Who holds the send queue? | **OneSignal** (`send_after` / timezone / Journeys) |
| Who decides *what* to send? | **Eezycycle backend** from MySQL predictions + prefs |
| When to replan? | On **user/data events** (period log, prefs, mode, partner link) |
| Rich notifications? | Yes — image + buttons + deep links + channels |
| Flo parity focus | Period soon, fertile/ovulation, log nudge, tips, partner soft tips |

---

## 12. Out of scope for this plan file

- Exact marketing copy finalization  
- OneSignal pricing tier limits  
- Full IAM (in-app messages) design — can reuse Journeys later  

When ready to implement, start with **Phase 0 + Phase 1**; keep GitHub CLI as a manual ops tool, not the heartbeat of cycle reminders.
