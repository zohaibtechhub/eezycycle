# MySQL Table Structure

Schema for EezyCycle based on the current Flutter design (onboarding, cycle tracking, daily logs, articles, insights, tips, partner sync, secret chats, FAQ, auth).

**Database name:** `eezycycle`

```sql
CREATE DATABASE IF NOT EXISTS eezycycle
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE eezycycle;
```

**Prerequisites:**

- [01-guest-vs-account-strategy.md](./01-guest-vs-account-strategy.md) — guests and registered users share the same `users.id`
- [03-play-console-health-privacy.md](./03-play-console-health-privacy.md) — Play Console Health apps + Data safety; sensitive data tiers
- [04-cycle-formulas-flo.md](./04-cycle-formulas-flo.md) — Flo-aligned period / ovulation / fertile-window formulas

Conventions:

- Engine: InnoDB, charset `utf8mb4`
- PKs: `BIGINT UNSIGNED AUTO_INCREMENT` unless noted
- Timestamps: `created_at`, `updated_at` on mutable rows
- Soft delete where useful: `deleted_at DATETIME NULL`
- Money/commerce: not in UI yet — omit
- Enums shown as `ENUM(...)`; you may use lookup tables instead

### Sensitivity & encryption conventions

| Tier | Examples | Storage rule |
|------|----------|--------------|
| 0 Public CMS | articles, faqs | Normal |
| 1 Account | email, device_id | Hash passwords; TLS |
| 2 Health | period_days, predictions, symptoms, height/weight | Disk encryption + strict ACL; no partner leak of intimate subsets |
| 3 Intimate | sex logs, pregnancy/ovulation tests, `note` text | **Field-level encryption** (`*_encrypted` BLOB or ciphertext VARCHAR); never in logs; never in partner API |

Mark columns below with **[T2]** / **[T3]** where relevant. Decrypt Tier 3 only in the API response path for the owning `user_id`.

Production DB: enable volume/at-rest encryption (RDS/Cloud SQL). Restrict `SELECT` on health tables to the app role only.
---

## 1. Auth & identity

### `users`

Core identity for **guest and registered**.

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| account_status | ENUM('guest','registered') | default `guest` |
| email | VARCHAR(255) NULL | unique when not null |
| password_hash | VARCHAR(255) NULL | null for guest / Google-only |
| name | VARCHAR(120) NULL | |
| google_sub | VARCHAR(255) NULL | unique when not null |
| email_verified_at | DATETIME NULL | |
| registered_at | DATETIME NULL | set on upgrade |
| last_login_at | DATETIME NULL | |
| is_active | TINYINT(1) | default 1 |
| created_at | DATETIME | |
| updated_at | DATETIME | |
| deleted_at | DATETIME NULL | |

Indexes: `UNIQUE(email)`, `UNIQUE(google_sub)`, `INDEX(account_status)`.

### `devices`

Links device installs to a user (guest reclaim + multi-device).

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| user_id | BIGINT FK → users | |
| device_id | VARCHAR(64) | app-generated UUID |
| platform | ENUM('ios','android','other') | |
| push_token | VARCHAR(512) NULL | FCM/APNs |
| app_version | VARCHAR(32) NULL | |
| last_seen_at | DATETIME | |
| created_at | DATETIME | |
| updated_at | DATETIME | |

Indexes: `UNIQUE(device_id)`, `INDEX(user_id)`.

### `refresh_tokens`

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| user_id | BIGINT FK → users | |
| token_hash | VARCHAR(255) | store hash only |
| device_id | VARCHAR(64) NULL | |
| expires_at | DATETIME | |
| revoked_at | DATETIME NULL | |
| created_at | DATETIME | |

### `account_merge_events` (audit)

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| from_user_id | BIGINT | guest being merged |
| to_user_id | BIGINT | surviving account |
| choice | ENUM('keep_account','keep_device','merge_both') | |
| summary_json | JSON | counts moved |
| created_at | DATETIME | |

---

## 2. Profile, consents, onboarding

### `user_profiles`

| Column | Type | Notes |
|--------|------|--------|
| user_id | BIGINT PK FK → users | 1:1 |
| birth_year | SMALLINT NULL | age gate ≥ 13 |
| height_cm | DECIMAL(5,2) NULL | |
| weight_kg | DECIMAL(5,2) NULL | |
| is_metric | TINYINT(1) | default 1 |
| experience_mode | ENUM('track_cycle','get_pregnant','track_pregnancy','perimenopause','partner') | |
| pregnancy_mode_active | TINYINT(1) | default 0 |
| due_date | DATE NULL | track pregnancy |
| discovery_source | VARCHAR(64) NULL | from discovery screen |
| usage_path | ENUM('self','partner') NULL | usage screen |
| partner_code_entered | VARCHAR(16) NULL | if joined via code |
| avg_cycle_length | TINYINT NULL | cached **C** from Flo formulas (default 28) |
| avg_period_length | TINYINT NULL | cached **P** (default 5) |
| luteal_phase_days | TINYINT | default **14** (Flo calendar rule) |
| fertile_window_mode | ENUM('standard','wide') | standard = 7 days; wide ≈ up to 14 if &lt;3 cycles / irregular |
| timezone | VARCHAR(64) NULL | |
| created_at | DATETIME | |
| updated_at | DATETIME | |

### `user_consents`

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| user_id | BIGINT FK → users | |
| consent_type | ENUM('terms','health_data','marketing','notifications') | |
| accepted | TINYINT(1) | |
| accepted_at | DATETIME | |
| document_version | VARCHAR(32) NULL | |

Index: `UNIQUE(user_id, consent_type)`.

### `user_goals`

Multi-select from “What would you like to focus on?”

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| user_id | BIGINT FK → users | |
| goal_key | VARCHAR(64) | e.g. `get_pregnant`, `track_period`, `well_being`, … |
| created_at | DATETIME | |

Index: `UNIQUE(user_id, goal_key)`.

### `onboarding_answers`

Flexible store for dynamic Q&A (`Map<stepId, List<option>>`).

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| user_id | BIGINT FK → users | |
| flow_key | VARCHAR(64) | e.g. `pregnancy`, `partner`, `track_cycle`, `get_pregnant`, `perimenopause` |
| step_id | VARCHAR(64) | e.g. `feeling`, `last_period`, `health_conditions` |
| answer_values | JSON | array of option ids / strings |
| created_at | DATETIME | |
| updated_at | DATETIME | |

Index: `UNIQUE(user_id, flow_key, step_id)`.

### `reminder_preferences`

| Column | Type | Notes |
|--------|------|--------|
| user_id | BIGINT PK FK → users | |
| fertile_days_enabled | TINYINT(1) | default 0 |
| pregnancy_test_enabled | TINYINT(1) | default 0 |
| daily_tips_enabled | TINYINT(1) | default 1 |
| period_reminder_enabled | TINYINT(1) | default 0 |
| created_at | DATETIME | |
| updated_at | DATETIME | |

---

## 3. Cycle, periods, daily logs

### `cycles`

Optional cycle header for stats / history graph.

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| user_id | BIGINT FK → users | |
| start_date | DATE | first period day of cycle |
| end_date | DATE NULL | day before next period |
| period_length_days | TINYINT NULL | logged bleed length |
| cycle_length_days | TINYINT NULL | computed when next starts |
| is_predicted | TINYINT(1) | 0 = logged-based |
| source | ENUM('logged','predicted','imported') | |
| created_at | DATETIME | |
| updated_at | DATETIME | |

Index: `INDEX(user_id, start_date)`.

### `period_days`

Day-level period marks (calendar taps + onboarding last period).

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| user_id | BIGINT FK → users | |
| log_date | DATE | |
| flow_intensity | ENUM('none','spotting','light','medium','heavy') NULL | FAQ mentions; UI may add later |
| is_predicted | TINYINT(1) | default 0 |
| cycle_id | BIGINT NULL FK → cycles | |
| created_at | DATETIME | |
| updated_at | DATETIME | |

Index: `UNIQUE(user_id, log_date)`.

### `cycle_predictions`

Server-computed fertile / ovulation / next period (home + partner calendar).  
Generated by [04-cycle-formulas-flo.md](./04-cycle-formulas-flo.md) (`flo_calendar_v1`).

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| user_id | BIGINT FK → users | |
| pred_date | DATE | |
| day_type | ENUM('period','ovulation','fertility','pregnancy','none') | |
| period_day | TINYINT NULL | 1–P when applicable |
| headline | VARCHAR(255) NULL | optional cached copy |
| partner_headline | VARCHAR(255) NULL | |
| algorithm_version | VARCHAR(32) | e.g. `flo_calendar_v1` |
| generated_at | DATETIME | |

Index: `UNIQUE(user_id, pred_date)`.
### `daily_logs`

One row per user per calendar day (bottom sheet “Done”).

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| user_id | BIGINT FK → users | |
| log_date | DATE | |
| note_encrypted | BLOB NULL | **[T3]** free-text notes — ciphertext only; never plaintext column |
| created_at | DATETIME | |
| updated_at | DATETIME | |

Index: `UNIQUE(user_id, log_date)`.

### `daily_log_items`

Selected chips from `LogTrackingController`.

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| daily_log_id | BIGINT FK → daily_logs | |
| category | VARCHAR(64) | `sex`, `mood`, `symptoms`, `ovulation_test`, `pregnancy_test`, `digestion`, `activity`, `other` |
| item_key | VARCHAR(64) | e.g. `sex_protected`, `sym_cramps`, `mood_happy` |
| sensitivity | ENUM('standard','intimate') | `intimate` = sex + tests → treat as **[T3]** (encrypt `item_key` or store in encrypted JSON blob per day) |

Index: `UNIQUE(daily_log_id, item_key)` if keys stored plaintext for non-intimate; for Tier 3 prefer encrypted payload per day instead of readable keys.

**Partner / analytics rule:** categories `sex`, `ovulation_test`, `pregnancy_test` and any `note` are **never** returned to partner or exported to support tools.

**Seed / catalog of `item_key` values (from UI):**

| Category | Keys | Tier |
|----------|------|------|
| sex | `sex_protected`, `sex_unprotected`, `sex_high_drive`, `sex_low_drive`, `sex_masturbation` | T3 |
| mood | `mood_happy`, `mood_calm`, `mood_anxious`, `mood_sad`, `mood_irritated`, `mood_energetic` | T2 |
| symptoms | `sym_cramps`, `sym_headache`, `sym_bloating`, `sym_tender_breasts`, `sym_acne`, `sym_fatigue` | T2 |
| ovulation_test | `ov_positive`, `ov_negative`, `ov_faint` | T3 |
| pregnancy_test | `preg_positive`, `preg_negative`, `preg_faint` | T3 |
| digestion | `dig_constipated`, `dig_loose`, `dig_nausea`, `dig_healthy` | T2 |
| activity | `act_yoga`, `act_walking`, `act_gym`, `act_rest` | T2 |
| other | `oth_alcohol`, `oth_medication`, `oth_travel` | T2 |

### `bbt_readings` (optional / FAQ future)

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| user_id | BIGINT FK → users | |
| log_date | DATE | |
| temperature_c | DECIMAL(4,2) | |
| created_at | DATETIME | |

Index: `UNIQUE(user_id, log_date)`.

---

## 4. Partner sync

Privacy rule: partner sees **phases / predictions / high-level mood only** — not symptoms, tests, notes, sex details.

### `partner_links`

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| code | CHAR(6) | unique, e.g. `SYNC88` |
| owner_user_id | BIGINT FK → users | person sharing cycle |
| partner_user_id | BIGINT NULL FK → users | linked partner |
| status | ENUM('pending','active','revoked') | |
| share_scope | JSON | explicit allow-list, e.g. `["cycle_phase","predicted_period","predicted_fertile"]` — **never** include sex/symptoms/tests/notes |
| owner_consented_at | DATETIME NULL | when owner accepted sharing disclosure |
| created_at | DATETIME | |
| linked_at | DATETIME NULL | |
| revoked_at | DATETIME NULL | |

Indexes: `UNIQUE(code)`, `INDEX(owner_user_id)`, `INDEX(partner_user_id)`.

**Play Data safety:** active partner link = **sharing Health info** with another user. Must be opt-in with clear UI copy.

---

## 5. Content CMS — articles, insights, tips, FAQ

### `articles`

List cards + detail (`CycleArticleModel` + `ArticleView`).

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| slug | VARCHAR(160) | unique |
| title | VARCHAR(255) | |
| description | TEXT | list subtitle |
| category | VARCHAR(64) | Energy & Hormones, Fitness, … |
| phase | ENUM('menstrual','follicular','ovulation','luteal','general') | |
| read_time_minutes | TINYINT | |
| image_url | VARCHAR(512) | |
| theme_color_hex | CHAR(7) NULL | e.g. `#E85078` |
| author | VARCHAR(120) NULL | detail screen |
| published_at | DATETIME NULL | |
| hero_summary | TEXT NULL | detail intro |
| is_published | TINYINT(1) | default 0 |
| sort_order | INT | default 0 |
| created_at | DATETIME | |
| updated_at | DATETIME | |

Indexes: `UNIQUE(slug)`, `INDEX(phase)`, `INDEX(category)`, `INDEX(is_published, published_at)`.

### `article_sections`

Detail body blocks.

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| article_id | BIGINT FK → articles | |
| heading | VARCHAR(255) | |
| body | TEXT | |
| sort_order | INT | |

### `article_takeaways`

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| article_id | BIGINT FK → articles | |
| body | VARCHAR(500) | |
| sort_order | INT | |

### `article_bookmarks`

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| user_id | BIGINT FK → users | |
| article_id | BIGINT FK → articles | |
| created_at | DATETIME | |

Index: `UNIQUE(user_id, article_id)`.

### `insights`

Home / insight cards (`InsightModel`).

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| tag | VARCHAR(64) | |
| title | VARCHAR(255) | |
| category | VARCHAR(64) | default Hormonal Health |
| read_time_minutes | TINYINT | default 2 |
| summary | TEXT | |
| action_tip | TEXT | |
| accent_color_hex | CHAR(7) NULL | |
| phase | ENUM('menstrual','follicular','ovulation','luteal','general') NULL | for Today targeting |
| is_published | TINYINT(1) | |
| published_at | DATETIME NULL | |
| created_at | DATETIME | |
| updated_at | DATETIME | |

### `insight_bullets`

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| insight_id | BIGINT FK → insights | |
| body | VARCHAR(500) | |
| sort_order | INT | |

### `relationship_tips`

Partner “Daily Relationship Tips”.

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| title | VARCHAR(255) | |
| description | TEXT | |
| category | VARCHAR(64) | Cycle Support, Communication, Quality Time |
| icon_key | VARCHAR(64) NULL | client asset key |
| time_to_read_minutes | TINYINT | |
| is_featured | TINYINT(1) | default 0 |
| is_published | TINYINT(1) | |
| published_at | DATETIME NULL | |
| created_at | DATETIME | |
| updated_at | DATETIME | |

### `faqs`

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| category | VARCHAR(64) | |
| question | VARCHAR(500) | |
| answer | TEXT | |
| sort_order | INT | |
| is_published | TINYINT(1) | |

### `legal_documents`

Privacy / Terms versions for consent tracking.

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| doc_type | ENUM('privacy_policy','terms_of_use') | |
| version | VARCHAR(32) | |
| title | VARCHAR(255) | |
| body_markdown | MEDIUMTEXT | |
| effective_at | DATETIME | |
| created_at | DATETIME | |

Index: `UNIQUE(doc_type, version)`.

---

## 6. Secret chats (community)

### `secret_profiles`

Anonymous community identity (separate from real name/email).

| Column | Type | Notes |
|--------|------|--------|
| user_id | BIGINT PK FK → users | |
| username | VARCHAR(40) | unique |
| avatar_url | VARCHAR(512) NULL | |
| created_at | DATETIME | |
| updated_at | DATETIME | |

### `secret_profile_tags`

Interest tags (TTC, PCOS, period pain, pregnancy, …).

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| user_id | BIGINT FK → secret_profiles.user_id | |
| tag_key | VARCHAR(64) | |

Index: `UNIQUE(user_id, tag_key)`.

### `posts`

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| user_id | BIGINT FK → users | |
| content | TEXT | |
| image_url | VARCHAR(512) NULL | |
| likes_count | INT | default 0 (denormalized) |
| comments_count | INT | default 0 |
| is_hidden | TINYINT(1) | moderation |
| created_at | DATETIME | |
| updated_at | DATETIME | |
| deleted_at | DATETIME NULL | |

Index: `INDEX(created_at)`, `INDEX(user_id)`.

### `post_comments`

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| post_id | BIGINT FK → posts | |
| user_id | BIGINT FK → users | |
| body | TEXT | |
| likes_count | INT | default 0 |
| created_at | DATETIME | |
| deleted_at | DATETIME NULL | |

### `post_likes`

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| post_id | BIGINT FK → posts | |
| user_id | BIGINT FK → users | |
| created_at | DATETIME | |

Index: `UNIQUE(post_id, user_id)`.

### `comment_likes`

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| comment_id | BIGINT FK → post_comments | |
| user_id | BIGINT FK → users | |
| created_at | DATETIME | |

Index: `UNIQUE(comment_id, user_id)`.

---

## 7. Privacy, deletion & access control (Play requirement)

These tables make Data safety promises (**users can delete data**, consents, audit) enforceable.

### `data_deletion_requests`

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| user_id | BIGINT FK → users | |
| requested_at | DATETIME | |
| status | ENUM('pending','processing','completed','failed') | |
| completed_at | DATETIME NULL | |
| source | ENUM('in_app','email','play_policy') | |
| notes | VARCHAR(255) NULL | internal only — no health content |

### `data_export_requests`

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| user_id | BIGINT FK → users | |
| requested_at | DATETIME | |
| status | ENUM('pending','ready','downloaded','expired','failed') | |
| file_url | VARCHAR(512) NULL | short-lived signed URL |
| expires_at | DATETIME NULL | |

### `privacy_access_audit`

Log rare human/admin or break-glass access to health rows (empty in normal ops).

| Column | Type | Notes |
|--------|------|--------|
| id | BIGINT PK | |
| actor | VARCHAR(120) | admin user / system job |
| action | VARCHAR(64) | e.g. `support_view_counts`, `break_glass_decrypt` |
| target_user_id | BIGINT NULL | |
| reason | VARCHAR(255) | required for break-glass |
| created_at | DATETIME | |

**Policy:** no tooling that dumps plaintext Tier 3 for “curiosity.” Export/delete is user-initiated only.

### Hard-delete order on `DELETE /me`

1. Revoke partner links; delete devices, tokens  
2. Delete daily_log_items → daily_logs, period_days, cycles, predictions, onboarding_answers, goals, bookmarks, reminder prefs, secret profile/tags  
3. Delete or anonymize posts/comments (prefer delete for health community)  
4. Delete profile, consents; mark user `deleted_at` or hard-delete users row  
5. Mark `data_deletion_requests.status = completed`

---

## 8. Entity relationship (high level)

```
users ──┬── devices
        ├── refresh_tokens
        ├── user_profiles                    [T2]
        ├── user_consents
        ├── user_goals
        ├── onboarding_answers               [T2]
        ├── reminder_preferences
        ├── cycles ── period_days            [T2]
        ├── cycle_predictions                [T2]
        ├── daily_logs (note_encrypted)      [T3]
        │      └── daily_log_items           [T2/T3]
        ├── article_bookmarks ── articles
        ├── partner_links (+ share_scope)
        ├── data_deletion_requests
        ├── data_export_requests
        └── secret_profiles ── tags
                └── posts ── comments / likes

CMS (no user FK): articles, insights, relationship_tips, faqs, legal_documents
Ops: privacy_access_audit
```

---

## 9. Mapping: design screens → tables

| App area | Tables |
|----------|--------|
| Privacy / Terms | `user_consents`, `legal_documents` |
| Usage / Discovery / Birth year / Goals | `user_profiles`, `user_goals` |
| Dynamic onboarding Q&A | `onboarding_answers` |
| Height / weight / mode / pregnancy | `user_profiles` |
| Reminders opt-in | `reminder_preferences` |
| Calendar period days | `period_days`, `cycles` |
| Predictions / Today hero | `cycle_predictions` |
| Log symptoms sheet | `daily_logs`, `daily_log_items` |
| Cycle & ovulation graph | `cycles`, `period_days` |
| Insights tab / home cards | `insights`, `insight_bullets` |
| Articles list + detail + bookmark | `articles`, `article_sections`, `article_takeaways`, `article_bookmarks` |
| Daily relationship tips | `relationship_tips` |
| Partner code / Partner Today | `partner_links` (+ filtered predictions only) |
| Secret chats | `secret_profiles`, tags, `posts`, comments, likes |
| FAQ | `faqs` |
| Login / Signup / Google / guest | `users`, `devices`, `refresh_tokens` |
| Drawer “finish account” | upgrade on `users` |
| Delete / export my data (Play) | `data_deletion_requests`, `data_export_requests` |

---

## 10. Suggested build order

1. `users`, `devices`, `refresh_tokens` + guest/upgrade/login  
2. `user_consents`, `legal_documents` (block health write without consent)  
3. `user_profiles`, goals, `onboarding_answers`  
4. `period_days`, `cycles`, `cycle_predictions`  
5. `daily_logs` / items with Tier 3 encryption  
6. CMS: articles, insights, tips, faqs  
7. Bookmarks, reminders  
8. `partner_links` + partner-safe read APIs + consent UI  
9. Secret chat  
10. Export + delete account APIs + audit table  

---

## 11. Partner API filter (Play + product)

When `partner_user_id` reads owner data, allow only what `share_scope` lists, typically:

- `cycle_predictions` phase types / dates / partner headlines  
- Connection status  

Never return: sex/symptoms/tests items, `note_encrypted`, BBT, onboarding health answers, secret chat identity, email/name of owner beyond what UI needs.

This filter must match the in-app partner disclosure and the Data safety “shared” declaration.