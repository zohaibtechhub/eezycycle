# Frontend audit — hardcoded UI, missing buttons, DB gaps

**App:** `period_ovulation_tracker`  
**Last updated:** 2026-09-25  
**Scope:** Hardcoded content, dead/missing buttons, and data that should come from MySQL/API but does not yet.

---

## Severity legend

| Level | Meaning |
|-------|---------|
| **High** | Broken UX, empty screens, or live API data ignored |
| **Med** | Planned CMS/API not wired; incomplete actions |
| **Low** | Intentional local catalog / decorative / scaffolding |

---

## Recently fixed (2026-09-25)

| Area | Change |
|------|--------|
| Personal cycle insights | Surfaced on Home as **Your patterns** from `/cycle/today` + `/cycle/insights`. |
| Woman **Recommended Actions** | Local phase catalog (`recommended_actions_catalog.dart`) opens a full detail reader (no empty article shells). Still not API `insights[]`. |
| Article **Bookmark** | Wired to `BookmarkController` + `GET/POST articles/bookmarks` when `articleId` is present. Hidden for coach tips / bare shells without id. |
| Bookmarks screen | Drawer → `BookmarksView` uses API bookmarks. |
| Calendar period edits | Day taps are **local only**; top-right **Log** does one `PUT cycle/period-days`. Back with unsaved changes shows Discard / Log dialog. |
| Experience mode defaults | Drawer + mapper + onboarding multi-goal fallbacks prefer **`track_cycle` / Track cycle** (Get pregnant no longer wins when “Track my period” is also selected). |
| Secret chat **Delete** | Confirm dialog + `AppLoading` (“Deleting post…”) then `DELETE`. |
| Partner home content | Discover / For you use partner-safe articles; Recommended Actions use relationship tips (real detail screens). |
| **InsightDetailView** | Removed unused Placeholder screen + route. |
| **Forgot Password** | Email → OTP → new password; SMTP via cPanel; API `auth/forgot-password`, `verify-reset-otp`, `reset-password`. |
| **Profile photo** | Guests + registered: `POST /me/avatar`. Syncs secret chat; partner sees woman’s photo (read-only). |

---

## 1. Missing or dead buttons

| # | Where | Issue | Severity |
|---|--------|--------|----------|
| 1 | `lib/views/drawer/drawer_view.dart` | **Rate the App**: `onTap: () {}` | Med |
| 2 | `lib/widgets/container/quick_step_container.dart` | Stub `Placeholder()` widget (unused) | Low |
| 3 | `lib/views/insight/insight_view.dart` | Bookmark action commented out | Low |

~~InsightDetailView Placeholder~~ — **removed**.  
~~Forgot Password TODO~~ — **fixed** (email → OTP → reset).  
~~Partner home dead taps / empty shells~~ — **fixed** (articles + relationship tips).  
~~Woman Recommended Actions → empty `ArticleView`~~ — **fixed** (local catalog + detail).  
~~Article Bookmark `onPressed: () {}`~~ — **fixed** (API when `articleId` set).

---

## 2. Hardcoded content that **should** come from DB / API

These are either documented as CMS tables or already returned by the backend but unused in Flutter.

| # | Area | Current source | Should be | Severity |
|---|------|----------------|-----------|----------|
| 1 | **Personal cycle insights** | Home **Your patterns** (`today.insights` + `GET /cycle/insights`) | — | Done |
| 2 | Woman **Recommended Actions** | Local `RecommendedActionsCatalog` (phase-aware, filled reader) | Phase-aware insights / tips from API (or CMS) | Med *(was High; UX filled, still not API)* |
| 3 | Partner **Discover Insights** | Partner-safe phase articles (`ArticleRepository`, `partnerSafe: true`) | Still assets until CMS | Low *(was High)* |
| 4 | Partner **Recommended Actions** | Daily relationship tips → tip detail | Still assets until CMS | Low *(was High)* |
| 5 | **Articles** | `assets/articles/articles.json` | Docs/schema: `articles`, bookmarks — **CMS body API not built yet** (bookmark IDs are wired) | Med |
| 6 | **Relationship tips** | `assets/relationship_tips/tips.json` | Docs/schema: `relationship_tips` — **CMS API not built yet** | Med |
| 7 | **FAQs** | Hardcoded in `faq_controller.dart` | Docs/schema: `faqs` | Med |
| 8 | **Privacy / Terms** | Hardcoded in `legal_document_view.dart` | Docs/schema: `legal_documents` | Med |
| 9 | Classic **Insight** pages | Default copy in `insight_view.dart` | Docs/schema: `insights` / bullets — **CMS API not built yet** | Med |

---

## 3. Hardcoded but **OK for now** (intentional frontend catalogs)

Keep these local unless/until CMS is implemented.

| Area | Location | Notes |
|------|----------|--------|
| Article library (50) | `assets/articles/` + `ArticleRepository` | README: frontend-only by design; bookmarks use API ids |
| Daily relationship tips (50) | `assets/relationship_tips/` | Day-seeded ≤10; frontend-only by design |
| Recommended Actions (woman) | `recommended_actions_catalog.dart` | Local phase catalog until API insights |
| Symptom log catalog | `log_tracking_controller.dart` | UI options; **values** sync via `GET/PUT /logs` |
| Onboarding copy & options | `onboarding_goal.dart` / controller | Answers/goals posted to API; mode resolves to `track_cycle` by default |
| Experience mode labels | `drawer_controller.dart` | Mode change patches `me/profile`; default **Track cycle** |
| Secret chat tags | `secret_profile_controller.dart` | Local chip list; selected tags saved to API |
| Category filter chips | Articles / tips controllers | Filters over local JSON |
| Partner hero tip strings | `home_cycle_hero.dart` | Presentation copy over live phase |
| Pregnancy promo marketing | `pregnancy_mode.dart` | Activation still patches API |

---

## 4. API endpoints declared but unused in Flutter

| Endpoint (`ApiEndPoints`) | Backend | Flutter |
|---------------------------|---------|---------|
| `cycle/insights` | Yes | **Called** from `HomeHeroController.loadCycleData` |
| `cycle/observations` | Yes | **Not called** |
| `cycle/predictions/rebuild` | Yes | **Not called** |

**Already wired well:** auth, me/profile, onboarding, cycle today/calendar/period-days, daily logs, partner link/today/calendar, secret profile/posts, article bookmarks.

---

## 5. Home content map (what is real vs mock)

| Section | Woman home | Partner home |
|---------|------------|--------------|
| Cycle hero / date strip | API (`/cycle/today` + calendar) | API (`/partner/today` + calendar) |
| Discover Insights | Assets articles (6, phase-matched) — labeled **Discover articles** | Partner-safe assets articles (6, phase-matched) |
| For you | Assets articles (5, non-overlapping) | Partner-safe assets articles (5) |
| Your patterns | **API** personal insights (hidden if empty) | — (backend strips for partner) |
| Recommended Actions | **Local catalog** (filled detail) | **Relationship tips** (filled tip detail) |
| Personal `insights[]` from today API | **Shown** in Your patterns | N/A (backend strips for partner) |

---

## 6. Suggested fix order

1. Implement or hide: Rate App.
2. Later CMS: articles, tips, FAQs, legal → MySQL + API (schema already sketched in `docs/backend/`).
3. Optional: migrate woman Recommended Actions from local catalog to API insights when ready.

---

## 7. Quick file checklist

```
[x] partner_home_view.dart      — Discover/For you articles; Recommended = relationship tips
[x] insight_detail_view.dart    — Removed (unused)
[ ] drawer_view.dart            — Rate App no-op
[x] login_view.dart             — Forgot Password → email / OTP / reset
[x] home_hero_controller.dart   — personalInsights from today + cycle/insights
[ ] api_service.dart            — observations / rebuild unused (cycleInsights wired)
[ ] faq_controller.dart         — FAQs hardcoded
[ ] legal_document_view.dart    — Legal copy hardcoded
[~] home_view.dart              — Recommended Actions: local catalog OK UX; not API yet
[x] article_view.dart           — Bookmark wired (needs articleId)
[x] bookmarks / BookmarkController — API
[x] articles.json               — OK as asset until CMS
[x] tips.json                   — OK as asset until CMS
[x] cycle today/calendar/logs   — Wired to DB
[x] calender_view / cycle_calender_controller — Local taps + explicit Log PUT
[x] experience mode defaults    — track_cycle preferred
[x] secret chat delete          — Confirm dialog + loading
[x] auth forgot-password        — SMTP + OTP reset API + Flutter flow
```

---

## 8. Optional Low scaffolding (not user-facing bugs)

| Item | Location | Notes |
|------|----------|--------|
| `ProductController` mock products | `lib/controllers/product_controller.dart` | Bound but unused as a real feature |
| Insight bookmark commented | `insight_view.dart` | Intentional; not a live broken control |

---

*Re-audited 2026-09-25 against live `ApiEndPoints` usage, home/drawer/onboarding/calendar/secret-chat controllers, and `docs/backend/` CMS notes.*
