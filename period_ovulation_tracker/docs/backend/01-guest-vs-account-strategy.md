# Guest vs Account Strategy

## Phase 1 decision (current build)

**Ship the full app as guest-only first.** See [05-phase1-guest-only.md](./05-phase1-guest-only.md).

- Onboarding, periods, Flo formulas, Today UI messages, partner code, content, secret chat — all with `account_status = 'guest'`.
- No email/Google login in Phase 1.
- Phase 2 upgrades the same `user_id` — do not invent a separate guest schema.

---

## The problem

The app is **guest-first**:

1. User completes onboarding **without** signup.
2. They track periods, symptoms, bookmarks, partner code, secret chat, etc.
3. Later, drawer CTA: *“Add your email to finish creating your account”* → Login / Signup.
4. Onboarding “Skip” is labeled **Login** (existing users can jump in).

If guest data lives only on the device, and account data lives only on the server, you get:

- Lost data after reinstall / new phone
- Duplicate users when they finally sign up
- Painful “which data wins?” merges
- Partner sync and secret chat that only work for logged-in users inconsistently

You need **one identity model** that works for both paths.

---



## Recommended approach (use this)



### One user row for everyone


| Concept             | Meaning                                                                                                             |
| ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **Guest user**      | Real `users` row with `account_status = 'guest'`. No email/password yet. Identified by `device_id` + anonymous JWT. |
| **Registered user** | Same `users` row upgraded with email / Google. `account_status = 'registered'`.                                     |


**All app data** (onboarding, periods, daily logs, bookmarks, partner links, secret profile) is always keyed by `user_id` — never by “guest vs account”.

```
Install app
    → POST /auth/guest  (device_id)
    → get user_id + guest JWT
    → onboarding + tracking all use that user_id

Later: “Add email”
    → POST /auth/upgrade   (attach email/password or Google to THIS user_id)
    → same user_id, now registered
    → no data move needed
```

This matches the product copy: they are **finishing** an account, not creating a second one.

---



## What NOT to do


| Bad pattern                                                    | Why it fails                                         |
| -------------------------------------------------------------- | ---------------------------------------------------- |
| Guest = local only; account = server only                      | Reinstall loses everything; merge is nightmare       |
| Separate `guests` and `users` tables with different FK targets | Every feature needs dual foreign keys / dual queries |
| Force signup before onboarding                                 | Breaks current UX and conversion                     |
| Allow unlimited anonymous server users with no device bind     | Abuse / spam; hard to reclaim data                   |


---



## Identity rules



### 1. First open → create guest

- App generates / reads a stable `device_id` (e.g. `uuid` stored in secure storage / Keychain).
- Call `POST /auth/guest` with `{ device_id, platform, app_version }`.
- Server creates `users` + `devices` (or upserts device → existing guest).
- Return `{ access_token, refresh_token, user: { id, account_status: "guest" } }`.



### 2. Guest can use almost everything

Allowed while guest:

- Onboarding answers, goals, consents  
- Period / cycle / daily logs  
- Experience mode, pregnancy mode  
- Read articles / insights / tips / FAQ  
- Bookmarks (tied to `user_id`)  
- Reminder preferences + push token  
- Generate / enter partner code (optional: require register before *accepting* link — product choice)  
- Secret chat profile + posts (optional: require register to post publicly — product choice)

Suggested product defaults:


| Feature            | Guest         | Registered |
| ------------------ | ------------- | ---------- |
| Track cycle / logs | Yes           | Yes        |
| Read CMS content   | Yes           | Yes        |
| Bookmarks          | Yes           | Yes        |
| Partner link       | Yes (soft)    | Yes        |
| Secret chat post   | Optional gate | Yes        |
| Multi-device sync  | No (1 device) | Yes        |
| Password recovery  | No            | Yes        |




### 3. Upgrade guest → registered (happy path)

When drawer says “Add your email”:

```
POST /auth/upgrade
Authorization: Bearer <guest_jwt>
Body: { email, password }  OR  { google_id_token }
```

Server:

1. Verify guest JWT → `user_id`.
2. Ensure email / Google not already used by another user.
3. Set email, password_hash / oauth, `account_status = 'registered'`, `registered_at = now()`.
4. Keep **same** `user_id`. All rows already point at it → **zero merge**.
5. Issue new tokens (registered claims).

This is the path you optimize for.

### 4. Login on a guest device (harder path)

User already has account A on another phone, and this phone has guest B with local/server data.

```
POST /auth/login
Authorization: Bearer <guest_jwt>   // optional but recommended
Body: { email, password } or Google
```

Server must choose a **merge policy**:

#### Policy A — Prefer (recommended for v1)

**Ask the user** if guest has meaningful data:

- If guest has **no** periods / logs / onboarding → attach device to account A; delete empty guest B.
- If guest **has** data → return `409 MERGE_REQUIRED` with summary counts; client shows:
  > “This device has cycle data. Keep device data, keep account data, or merge both?”

Actions:


| Choice       | Behavior                                                           |
| ------------ | ------------------------------------------------------------------ |
| Keep account | Discard guest B data; device now uses A                            |
| Keep device  | Move B’s health data onto A (or swap — rare); then delete B        |
| Merge both   | Copy B’s periods/logs/answers into A with conflict rules; delete B |


**Conflict rules for merge (simple v1):**

- Period days: union of dates (unique per day).  
- Daily logs: union of item keys per date.  
- Onboarding answers: account A wins if both set; else take non-empty.  
- Experience mode / pregnancy: account A wins.  
- Bookmarks: union.  
- Partner link: keep A’s active link; deactivate B’s.  
- Secret profile: keep A’s username if set; else take B’s if unique.



#### Policy B — Simpler v1 (if you want less UI)

Always: **account wins**. Guest health data is abandoned (warn once in UI). Faster to ship; worse UX.

**Recommendation:** Policy A with auto-discard when guest is empty; dialog only when guest has data.

### 5. Google sign-in

Same rules as email:

- Upgrade attached guest if Google email unused.  
- Else login existing Google user + merge flow if guest has data.



### 6. Logout

- Clear tokens on device.  
- Optionally create a **new** guest user on next open (fresh), or require login.  
- Do **not** delete server data of the registered user.



### 7. Multi-device

Only for `account_status = 'registered'`:

- Same tokens / refresh on multiple devices.  
- Guests stay single-device via `devices.device_id` uniqueness for guest users.

---



## Privacy & Play Console (guest path included)

Guest users still create **Health info** on your servers. That must appear in Play **Data safety**, and users must consent **before** health sync.

1. Do **not** call health APIs until Terms + health-data consents are accepted (`user_consents`).
2. Guest JWT is still a real account for privacy purposes — deletion must wipe guest health data too.
3. Partner link and secret chat = **data sharing** with other people — disclose in-app and in Data safety.
4. Intimate Tier 3 fields (sex, tests, notes) — encrypt at rest; never log plaintext; never send to partner. See [03-play-console-health-privacy.md](./03-play-console-health-privacy.md).
5. Settings must offer **Delete my data / account** for both guest and registered.

---

## Client responsibilities (Flutter)

1. Persist `device_id` + tokens securely (Keychain / EncryptedSharedPreferences).
2. Block health sync until privacy consents are stored.
3. Send `Authorization` on every API call.
4. After upgrade, keep using same local DB / cache keyed by `user_id` (id unchanged).
5. On `MERGE_REQUIRED`, show dialog → call `POST /auth/merge` with choice.
6. Drawer CTA: show “Add email…” only when `account_status == guest`.
7. Settings: Privacy Policy link, export, **delete account/data**, partner sharing explanation.
8. Never put sex/test/notes content in analytics or crash breadcrumbs.
9. Optional offline queue: write locally, sync when online (later phase). For v1, online-first with guest JWT is enough.

---

## Server responsibilities (Node.js)

1. Middleware: resolve JWT → `req.userId` + `req.accountStatus`.
2. Never branch schema by guest vs registered — only gate features.
3. Rate-limit `POST /auth/guest` by IP + device_id.
4. Soft-delete / purge guests unused for N days with **no** health data (cleanup job); document retention.
5. Never expose intimate logs to partner APIs (filter on read).
6. Audit log for merge / upgrade / delete / admin access events.
7. TLS only; field-level encryption for Tier 3 columns.
8. `DELETE /me` (or equivalent) hard-deletes health data for that `user_id`.
9. Strip sensitive bodies from HTTP access logs.

---



## Auth API sketch


| Method | Path            | Who                                | Purpose                            |
| ------ | --------------- | ---------------------------------- | ---------------------------------- |
| POST   | `/auth/guest`   | App                                | Create/reuse guest for `device_id` |
| POST   | `/auth/upgrade` | Guest JWT                          | Attach email/password or Google    |
| POST   | `/auth/login`   | Public (+ optional guest JWT)      | Login; may return merge required   |
| POST   | `/auth/merge`   | Guest JWT + registered credentials | Resolve conflict                   |
| POST   | `/auth/refresh` | Refresh token                      | New access token                   |
| POST   | `/auth/logout`  | Auth                               | Invalidate refresh                 |
| GET    | `/me`           | Auth                               | Profile + `account_status`         |
| GET    | `/me/export`    | Auth                               | Portable copy of user health data  |
| DELETE | `/me`           | Auth                               | Delete account + health data       |


---



## Decision summary


| Decision                      | Choice                                         |
| ----------------------------- | ---------------------------------------------- |
| Guest storage                 | Server `users` row (`guest`) + JWT             |
| Data ownership                | Always `user_id`                               |
| Signup from guest             | **Upgrade in place** (same id)                 |
| Login while guest has data    | Merge dialog (or account-wins if you simplify) |
| Separate guest tables         | **No**                                         |
| Force account before tracking | **No** (but **force consent** before health sync) |
| Intimate health visibility    | User via app; staff must not casually read DB  |
| Play Data safety              | Declare Health info; partner/chat as shared    |


Once this is agreed, implement tables from [02-mysql-table-structure.md](./02-mysql-table-structure.md) and privacy rules in [03-play-console-health-privacy.md](./03-play-console-health-privacy.md).