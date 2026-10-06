# Play Console Health & Sensitive Data Requirements

EezyCycle is a **period / ovulation / fertility / reproductive health** app. That data is among the most sensitive categories on Google Play. This doc covers:

1. What you must declare in **Play Console** (Health apps + Data safety) — this is what **users see** on the store listing  
2. What the **app and backend must actually do** so declarations are true  
3. How to keep intimate health data **readable by the user**, not casually by you / staff / partners  

Official references:

- [Health Content and Services](https://support.google.com/googleplay/android-developer/answer/16679511)  
- [Health apps declaration form](https://support.google.com/googleplay/android-developer/answer/14738291)  
- [Data safety section](https://support.google.com/googleplay/android-developer/answer/10787469)  
- [Publish a health app](https://developer.android.com/health-and-fitness/health-connect/publish)  

---

## Why this matters

| Audience | What they see |
|----------|----------------|
| **Users on Play Store** | Data safety labels (collected / shared / encrypted / deletable) |
| **Users in the app** | Privacy screen, consents, partner-sharing explanation, medical disclaimer |
| **Google review** | Health apps declaration must match real features |
| **You / ops / DB admins** | Must **not** browse intimate logs in plaintext; access must be rare, logged, and minimized |

If Play Console says “data is encrypted / not sold / deletable” but the server stores sex/pregnancy tests in open MySQL columns with open admin access, you risk **policy rejection, removal, and loss of trust**.

---

## 1. Health apps declaration (Play Console → App content)

**Path:** Play Console → *Policy* → *App content* → **Health apps**

Declare **all** health features the app actually offers. For EezyCycle (current design), select at least:

| Feature to declare | Why (maps to app) |
|--------------------|-------------------|
| **Period tracking** | Cycle calendar, period days, ovulation/fertility predictions |
| **Reproductive and sexual health** | Trying to conceive, pregnancy mode, sex logging, sexual-health articles |
| **Medical reference and education** | Articles, insights, tips, FAQ (non-diagnostic education) |
| **Nutrition and weight management** *(only if true)* | Height/weight + weight-related goals in onboarding — declare only if you keep this |
| **Human subjects research / patient communities** *(if secret chat is health community)* | Secret Chats / community posts about PCOS, TTC, pregnancy |

Do **not** declare clinical decision support, diagnosis, or treatment unless you truly offer that (you should **not**).

### Medical / wellness disclaimer (required mindset)

Play expects honesty about claims. In-app + store / privacy policy must make clear:

> EezyCycle is for **personal wellness tracking and education**. It is **not** a medical device, does **not** diagnose, treat, or prevent disease, and predictions (ovulation, fertile window, period) are **estimates**. Always consult a qualified healthcare professional for medical decisions.

Show this in:

- Privacy / onboarding consent flow  
- FAQ  
- Pregnancy / fertility prediction screens (short line)  
- Privacy policy URL (public, HTTPS, not PDF-only, not geofenced)

---

## 2. Data safety form — what **users** see on Play

**Path:** Play Console → *App content* → **Data safety**

This section is **user-facing**. Answers must match real collection/sharing.

### Security questions (answer honestly)

| Question | Recommended for EezyCycle | You must implement |
|----------|---------------------------|--------------------|
| Does the app collect / share required user data types? | **Yes** | Server sync of health + account data |
| Is all collected user data **encrypted in transit**? | **Yes** | HTTPS/TLS only; no cleartext APIs |
| Can users **request deletion** of their data? | **Yes** | In-app “Delete my data / account” + API that hard-deletes or anonymizes |

Optional later (if true): encryption at rest for all data; independent security review — only claim if true.

### Data types to declare (EezyCycle mapping)

| Play category | Data type | Collected? | Shared? | Collected from EezyCycle |
|---------------|-----------|------------|---------|---------------------------|
| Personal info | Email address | Yes (registered) | No* | Signup / upgrade |
| Personal info | Name | Yes (if collected) | No* | Profile |
| Personal info | User IDs | Yes | No* | `user_id`, account id |
| Personal info | Other info | Yes | No* | Birth year, height, weight |
| Health and fitness | **Health info** | **Yes** | **Yes*** | Periods, symptoms, tests, pregnancy, onboarding health answers, cycle predictions |
| Health and fitness | Fitness info | Yes (if activity logs kept) | No* | Yoga / walking / gym chips |
| App activity | Other user-generated content | Yes | Yes* | Notes, secret chat posts/comments |
| App activity | App interactions | Optional | No | Analytics — only if you add SDK |
| App info | Crash logs / Diagnostics | Optional | Maybe (Firebase etc.) | Only if crash SDK used |
| Device or other IDs | Device or other IDs | Yes | No* | `device_id`, push token |
| Messages | Other in-app messages | Yes (secret chat) | Yes* | Posts / comments visible to community |
| Photos and videos | Photos | Yes (if post images) | Yes* | Secret chat image uploads |

\* **Shared** on Play means data goes to a **third party** or to **other users** in a way that is not purely service-provider processing.

For EezyCycle:

| Sharing case | Declare as shared? | Notes |
|--------------|--------------------|--------|
| Your own MySQL / VPS / managed DB | Usually **Collected**, not “shared” if only you (the developer) process it as service provider | Still protect it |
| **Partner link** (cycle phase shown to partner) | **Yes — shared** (with another user) | User must **opt in**; disclose clearly |
| **Secret chat** (posts visible to community) | **Yes — shared** | User-generated; public within app |
| Google Sign-In | Follow Google’s SDK guidance; account data handled by Google | Declare per Google’s Data safety guidance |
| FCM / APNs push | Device token to Google/Apple | Often declared via SDK practice |
| Ads / trackers / sale of health data | **Do not** | Do **not** sell or use health data for advertising |

### Purposes (per data type)

For **Health info**, typical purposes:

- **App functionality** (cycle tracking, predictions, reminders) — required  
- **Personalization** (phase articles, Today insights) — if you do this  
- **Account management** — if tied to account backup  
- **Fraud prevention, security, and compliance** — limited, if needed  

Do **not** select **Advertising or marketing** for health info.

Mark health info as:

- Collected: **Yes**  
- Required for app / optional: core tracking is required for features; account email can be optional (guest)  
- Ephemeral: **No** (you store it)  
- Users can delete: **Yes**

---

## 3. Sensitive data tiers (design for “user can see it — staff should not”)

Not all columns are equal. Classify and protect accordingly.

### Tier 0 — Public CMS

Articles, insights, tips, FAQ — no user health.

### Tier 1 — Account / device

Email, password hash, device_id, tokens — standard auth security (hash passwords, TLS, lock down admin).

### Tier 2 — Health (sensitive)

Period days, cycle length, ovulation predictions, mood, symptoms, height/weight, experience mode, pregnancy due date, onboarding health answers (PCOS, birth control, etc.).

**Rules:**

- Encrypt in transit (TLS)  
- Encrypt at rest (disk / DB volume encryption minimum)  
- Access only via authenticated `user_id`  
- No unrestricted SQL admin browsing in production without break-glass + audit  
- Partner API returns **filtered** subset only  

### Tier 3 — Intimate / highly sensitive (strictest)

Sex activity, ovulation/pregnancy **test results**, free-text **notes**, detailed partner sexual answers, anything that could harm if leaked.

**Rules (recommended for Play + trust):**

1. **Field-level encryption** before insert (app or API encrypts with key not stored in the same DB row).  
2. Server decrypts **only** to return to the owning user (or never stores decryptable server-side — client-side key; harder for multi-device).  
3. **Never** include Tier 3 in partner APIs, analytics exports, support tickets, or logs.  
4. Support staff should see “user has data” counts, not plaintext symptoms/sex/tests.  
5. Do not put Tier 3 in email notifications or push payload bodies.

**Practical v1 (recommended):**

| Approach | Pros | Cons |
|----------|------|------|
| **A. Server-side field encryption** (KMS / app secret encrypts Tier 3 columns) | Multi-device works; staff can’t read DB dump easily | Your server *can* decrypt while handling the request |
| **B. Client-side E2E** (key only on device) | Closest to “only user can see”) | Hard merge/multi-device; password reset loses data |

Use **A** for v1 + strong access control + audit. Document honestly in privacy policy: *“We process your health data to provide the service; intimate fields are encrypted at rest; we do not sell your data.”*

Do **not** claim “we cannot read any of your data” unless you truly use E2E (B).

---

## 4. User-visible privacy UX (must exist in the app)

Play + health policy expect **prominent disclosure + affirmative consent** before collecting sensitive health data.

### Required screens / moments

| Moment | What user must see / do |
|--------|-------------------------|
| First launch / privacy | Terms + **health data processing** consent (you already have checkboxes) — must be explicit, not pre-ticked |
| Before partner link | Explain exactly what partner **can** and **cannot** see |
| Before secret chat post | Community is visible to others; don’t post identifiable health details |
| Predictions | Short “estimates, not medical advice” line |
| Settings | Link to Privacy Policy + Terms (public URL) |
| Settings | **Download / export my data** (FAQ claims this — implement) |
| Settings | **Delete my account & health data** |
| Store listing | Same Privacy Policy URL as in-app |

### Partner sharing disclosure (copy outline)

> When you connect a partner, they can see your **cycle phase and predicted fertile / period days**. They **cannot** see sex logs, symptoms, test results, or private notes. You can disconnect anytime.

This must match the API filter in the schema doc.

---

## 5. Backend / product rules that make Play answers true

| Rule | Implementation |
|------|----------------|
| Collect only what features need | No unused health permissions; no Health Connect perms until you integrate them |
| Consent before sync of health data | Guest JWT only after privacy acceptance; store `user_consents` |
| Encrypted in transit | TLS 1.2+ everywhere; HSTS on API domain |
| Encrypted at rest | Cloud disk encryption + field encryption for Tier 3 |
| Deletion | `DELETE /me` or `POST /me/delete` hard-deletes health rows; anonymize public posts or delete |
| No sale / no ads on health | No AdMob on health screens; no selling datasets |
| Minimize logs | Strip request bodies with health payloads from access logs |
| Age | Birth year gate ≥ 13 (you already warn &lt; 16); follow Play Families / age policies if targeting minors — prefer 16+ or 18+ for reproductive apps if possible |
| Admin access | Break-glass role; every read of Tier 2/3 logged in `privacy_access_audit` |
| Data retention | Define retention (e.g. delete guests inactive 24 months with no account); document in privacy policy |

---

## 6. Play Console checklist (copy into your launch task list)

### App content

- [ ] Health apps declaration completed (Period tracking + Reproductive/sexual health + education ± community)  
- [ ] Data safety form completed and **Store listing preview** reviewed as a user would see it  
- [ ] Privacy policy URL live, public, HTTPS, matches in-app  
- [ ] Data deletion method described in privacy policy and available in app  
- [ ] Target audience / age correctly set  

### Engineering

- [ ] HTTPS only  
- [ ] Passwords hashed (bcrypt/argon2)  
- [ ] Tier 3 fields encrypted at rest  
- [ ] Partner API excludes intimate data  
- [ ] Delete-account API wipes health data  
- [ ] No health data in analytics events / crash breadcrumbs  
- [ ] Medical disclaimer in app  

### Do not claim in Data safety unless true

- [ ] “Encrypted in transit” → only if all endpoints use TLS  
- [ ] “Users can request deletion” → only if button/API works  
- [ ] “Data is not shared” → false if partner sync or public secret chat exists — declare sharing  

---

## 7. Suggested privacy policy sections (user-facing URL)

Users (and Play) need a clear policy covering:

1. Who you are / contact for privacy requests  
2. What health data you collect (periods, symptoms, sex, tests, pregnancy, etc.)  
3. Why (app functionality, personalization, reminders)  
4. Guest vs account  
5. Partner sharing (opt-in, what is shared)  
6. Secret chat (public within community)  
7. Third parties (hosting, Google Sign-In, push)  
8. Encryption & security measures  
9. Retention  
10. How to export / delete data  
11. Children’s age limits  
12. “Not medical advice” disclaimer  
13. International users / GDPR-style rights if you serve EU (access, erasure, portability)

---

## 8. How this updates the other backend docs

| Doc | Privacy impact |
|-----|----------------|
| [01-guest-vs-account](./01-guest-vs-account-strategy.md) | Consent before guest health sync; deletion; no logging of health bodies |
| [02-mysql-table-structure](./02-mysql-table-structure.md) | Encryption flags, deletion requests, privacy audit, partner share scope |

**Bottom line:** Play Console is the **public promise to users**. Schema and APIs must enforce that intimate reproductive data is collected with consent, minimized, encrypted, deletable, and never exposed to partners or staff casually.
