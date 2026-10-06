# Pregnancy Daily Insights (Flo-style) — Structure & Process

**Goal:** In pregnancy mode, show a **My daily insights** row (horizontal cards) driven by gestational age — same idea as Flo:


| Card          | What it shows                                                | Changes when                                    |
| ------------- | ------------------------------------------------------------ | ----------------------------------------------- |
| **Your baby** | Size comparison (e.g. corn) + short development copy         | Usually **per week**; optional day-level tweaks |
| **Your body** | Body-change illustration + short maternal copy               | Usually **per week**; optional day-level tweaks |
| **Symptoms**  | Common symptoms for this stage + icons from **today’s logs** | **Week catalog** + **day logs**                 |


Below that, a **What to expect at N weeks** section (Baby’s growth / Body changes / Baby inside you) opens deeper content for the same week.

This doc is the **process + data shape** to implement. Do not invent a second gestational-age calculator — reuse what `/cycle/today` already returns.

---

## 1. Mental model (read this first)

```
User date (e.g. 31 Jan)
        │
        ▼
Gestational age from engine
  pregnancy_weeks = 22
  pregnancy_days  = 6     // day within the week (0–6)
  pregnancy_week  = 23    // Flo-style "week number" (1–42) — already on today payload
  days_pregnant   = 160   // absolute day from LMP (optional key)
        │
        ▼
Content lookup (CMS / local JSON)
  baby[week]  (+ optional day override)
  body[week]  (+ optional day override)
  symptoms_common[week]
        │
        ▼
Merge with user daily_logs for that date (symptoms category only)
        │
        ▼
API / Flutter: daily_insights[] cards + what_to_expect block
```

**Rules:**

1. **Baby / Body content is editorial** (CMS or seeded JSON) — not computed from the user’s body.
2. **Symptoms card is hybrid** — editorial “common this week” + **user logs** for that calendar date.
3. **Lookup key = gestational week** (primary). Use day only when you truly have day-specific copy.
4. Partner APIs must **never** receive symptom log detail (Tier 2/3 privacy — see `docs/backend/02-mysql-table-structure.md`).

---

## 2. How gestational keys work in EezyCycle

Already produced when `pregnancy_mode_active` (see `flo_calendar_service.buildDaySummary`):


| Field                         | Meaning                                         | Use for insights                                                                              |
| ----------------------------- | ----------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `pregnancy_weeks`             | Completed weeks (e.g. 22)                       | Titles: “Your baby at **22** weeks”                                                           |
| `pregnancy_days`              | Extra days in current week (0–6)                | Hero: “22 weeks, **6** days”                                                                  |
| `pregnancy_week`              | Display week number 1–42 (`weeks + 1`, clamped) | Prefer as **primary content key** (`week = 22` or `23` — pick one convention and stick to it) |
| `days_pregnant`               | Days since LMP                                  | Optional: day-level content / milestones                                                      |
| `due_date` / `days_until_due` | Dating                                          | Hero / Details only                                                                           |


### Recommended content key convention

Use **one** integer for catalog rows:

```text
content_week = pregnancy_weeks   // 0–40+
// OR
content_week = pregnancy_week    // 1–42 Flo display week
```

**Recommendation for EezyCycle:** key catalogs by `pregnancy_weeks` (0–40), and show UI title as:

- If `pregnancy_days == 0` → “Your baby at {weeks} weeks”
- Else → still “Your baby at {weeks} weeks” (Flo keeps week in the card title; day only in the hero)

Optional day override key:

```text
content_day_key = "{pregnancy_weeks}-{pregnancy_days}"   // e.g. "22-6"
// or absolute:
days_pregnant = 160
```

**Fallback chain when resolving a card:**

1. Exact day override (`week` + `day_in_week` or `days_pregnant`)
2. Week row (`week`)
3. Nearest previous week with content
4. Soft empty state (“Content for this week is coming soon”)

---

## 3. UI structure (matches Flo Today)

### 3.1 Home hero (already partly there)

- Date + profile + calendar
- Pregnancy illustration
- **“{pregnancy_weeks} weeks, {pregnancy_days} days”** + info
- **Details** → gestational summary / EDD source / disclaimer

### 3.2 My daily insights · {date}

Horizontal `ListView` of cards (same row):

1. **Baby card** → opens baby detail for this week
2. **Body card** → opens body detail for this week
3. **Symptoms card** → opens symptom log / common-symptoms sheet for this week

Card chrome: soft bordered tile, short title, illustration or icon row.

### 3.3 What to expect at {N} weeks

Three entry points (not the carousel):


| Key            | Label           | Opens                                          |
| -------------- | --------------- | ---------------------------------------------- |
| `baby_growth`  | Baby’s growth   | Long-form baby development for week N          |
| `body_changes` | Body changes    | Long-form maternal changes for week N          |
| `baby_inside`  | Baby inside you | Visual / womb position / size story for week N |


`N` = same `content_week` as the carousel.

---

## 3.4 Flo “story view” — it looks hard, it is not

Flo’s full-screen daily insight feels like Instagram Stories. In code it is **one screen + a list of pages**. The hard part is **images and copy**, not Flutter.

### What the user sees

```
Home (pregnancy)
  ├─ Hero: baby 3D/illustration + "22 weeks, 6 days"
  ├─ My daily insights  →  [Baby card] [Body card] [Symptoms card]   ← horizontal scroll
  └─ What to expect     →  [Baby's growth] [Body changes] [Baby inside you]

Tap Baby card ──► Full-screen STORY viewer
                    ┌─────────────────────────────┐
                    │  ▬▬▬  ▬▬▬  ▬▬▬   progress   │  ← one segment per story page
                    │                      ✕ close │
                    │                             │
                    │     [ big baby / size img ] │
                    │                             │
                    │  Your baby at 22 weeks      │
                    │  Size of a corn…            │
                    │                             │
                    │  Tap left = prev page       │
                    │  Tap right / wait = next    │
                    └─────────────────────────────┘
```

Swipe between **stories** (Baby → Body → Symptoms). Inside one story, advance **pages** (image → fact → tip).

### Break it into 4 small UI pieces (build one at a time)


| #   | Piece          | What it is in Flutter                             | Difficulty     |
| --- | -------------- | ------------------------------------------------- | -------------- |
| 1   | Home cards row | `ListView` horizontal — 3 cards                   | Easy           |
| 2   | Story shell    | `story_view` full-screen + close                  | Easy (package) |
| 3   | Story pages    | `StoryItem.pageProviderImage` / `.text` from JSON | Easy           |
| 4   | What to expect | 3 `InkWell` icons → existing article-style detail | Easy           |


You do **not** need to invent story math yourself. **Use `story_view: ^0.16.6`** (see below). Pattern:

1. Build `List<PregnancyStory>` for today (usually 3: baby, body, symptoms).
2. Each story has `List<PregnancyStoryPage>` (2–5 pages).
3. Open `PregnancyStoryViewer(stories, initialStoryIndex)`.
4. `Timer` (~5s) or tap-right → next page; end of pages → next story; end of stories → `Get.back()`.
5. Top: `Row` of `LinearProgressIndicator`s (one per page in current story), same as Instagram.

### Story data shape (add to weekly JSON)

```json
{
  "week": 22,
  "stories": [
    {
      "id": "baby",
      "card_title": "Your baby at 22 weeks",
      "card_image_key": "size_corn",
      "pages": [
        {
          "background": "#FFE8E0",
          "image_key": "baby_week_22_hero",
          "title": "Your baby at 22 weeks",
          "body": "About the size of an ear of corn.",
          "duration_ms": 5000
        },
        {
          "background": "#FFE8E0",
          "image_key": "size_corn",
          "title": "Size now",
          "body": "Around 28 cm and 430 g — still growing fast.",
          "duration_ms": 5000
        },
        {
          "background": "#FFE8E0",
          "image_key": null,
          "title": "This week",
          "body": "Hearing is developing. You may feel stronger movements.",
          "duration_ms": 6000
        }
      ]
    },
    {
      "id": "body",
      "card_title": "Your body at 22 weeks",
      "card_image_key": "body_week_22",
      "pages": [ "...same idea..." ]
    },
    {
      "id": "symptoms",
      "card_title": "Symptoms",
      "card_image_key": null,
      "pages": [
        {
          "title": "Common this week",
          "body": "Fatigue, back strain, and feeling good can all show up.",
          "common_keys": ["sym_fatigue", "sym_back_pain", "sym_feeling_good"],
          "cta": "log_symptoms"
        }
      ]
    }
  ],
  "what_to_expect": {
    "week": 22,
    "items": [
      { "key": "baby_growth", "label": "Baby's growth", "image_key": "expect_growth", "article_id": "preg_w22_growth" },
      { "key": "body_changes", "label": "Body changes", "image_key": "expect_body", "article_id": "preg_w22_body" },
      { "key": "baby_inside", "label": "Baby inside you", "image_key": "expect_inside", "article_id": "preg_w22_inside" }
    ]
  }
}
```

Home cards = preview of each `stories[]` item. Tap = open viewer at that story index. What to expect = **not** stories; opens a normal scroll detail (like your article reader).

### Baby image — how Flo does it (and how you can)

Flo uses **pre-made art per week** (3D / illustration). The app does **not** generate a baby from the user’s photo.


| Approach                                                           | When to use                | Effort                                               |
| ------------------------------------------------------------------ | -------------------------- | ---------------------------------------------------- |
| **A. One hero image + size fruit/veg per week**                    | MVP — looks like Flo cards | Low: 40 week assets over time; start with 5–10 weeks |
| **B. Same placeholder art for all weeks + change text/size label** | Ship UI tomorrow           | Lowest                                               |
| **C. Licensed 3D pack / designer**                                 | Polish later               | High cost, not required for v1                       |
| **D. AI-generated per week**                                       | Optional later             | Legal/medical review; not needed to match UX         |


**Practical path:**

1. Folder: `assets/pregnancy/images/`
2. Keys in JSON: `baby_week_22_hero`, `size_corn`, `body_week_22`
3. Flutter: `Image.asset('assets/pregnancy/images/$key.png')` with a fallback image if missing
4. Hero on Home can reuse `baby_week_{N}_hero` or one shared pregnancy hero until you have all weeks

You can look “like Flo” with **good layout + progress bars + 1 strong image**, even before you have 40 unique babies.

### What to expect — separate from stories

Do **not** force these into the story viewer.

```
Tap "Baby's growth"
  → PregnancyExpectDetailView(
      title: "Baby's growth · week 22",
      image: ...,
      sections: markdown / bullets   // reuse ArticleView pattern
    )
```

Same pattern you already use for articles / recommended actions. Three icons on Home; three detail routes (or one route + `key`).

### Suggested build order (so it never feels huge)

```
Week 1 of work
  ☐ Home: age text (you mostly have this)
  ☐ Home: 3 insight cards (static mock for week 22)
  ☐ Home: 3 what-to-expect icons (open Placeholder or ArticleView)

Week 2
  ☐ StoryViewer shell (progress + tap next/prev + close)
  ☐ Feed it 1 story × 3 pages from hardcoded list
  ☐ Wire card tap → StoryViewer(initialIndex)

Week 3
  ☐ weekly_insights.json for weeks you care about
  ☐ Load by pregnancy_weeks from /cycle/today
  ☐ Symptoms page CTA → existing log sheet
  ☐ Swap placeholder baby image for real assets gradually
```

If something feels “too difficult,” you are probably trying to do **assets + CMS + stories + logs** in one jump. Ship the **shell with fake week-22 content** first; content fill-in is a checklist, not a new architecture.

### Flutter viewer sketch (conceptual)

```dart
// PregnancyStoryViewer
// - stories: List<PregnancyStory>
// - indexStory, indexPage
// - top: progress segments for current story.pages.length
// - body: pages[indexPage] → image + title + body
// - GestureDetector: left third = prev, right third = next
// - Timer.periodic / Future.delayed(page.duration) → next
```

That is the entire “Flo story” mechanic.

### Package choice: `story_view: ^0.16.6` (confirmed)

Use this instead of a hand-rolled `PageView` timer. It already gives Instagram/WhatsApp-style:

- Top progress segments  
- Tap left / right  
- Pause on hold  
- Image + caption pages

Add to `pubspec.yaml`:

```yaml
dependencies:
  story_view: ^0.16.6
```

Map our content → package:


| Our JSON                   | `story_view`                                                                              |
| -------------------------- | ----------------------------------------------------------------------------------------- |
| One story page with asset  | `StoryItem.pageProviderImage(AssetImage(...), caption: '...', controller: c)`             |
| Soft color + text page     | `StoryItem.text(title, backgroundColor: ...)` or custom `StoryItem(child, duration: ...)` |
| Network CMS image later    | `StoryItem.pageImage(url: ..., controller: c, caption: ...)`                              |
| Whole Baby story (3 pages) | One `StoryView(storyItems: [...])` **or** chain Baby then Body then Symptoms in one list  |
| Close / finished           | `onComplete: () => Get.back()`                                                            |


**Flo UX tip:** opening from the Baby card should start at the Baby pages; from Body card, jump to Body pages (build one combined `storyItems` list and skip already-`shown` items, or open three separate viewers). Simplest v1: **three separate StoryViews** (one per card) — less Flo-swipe-across-cards, still feels like Flo stories.

Folder when you implement:

```
lib/views/pregnancy/pregnancy_story_view.dart   # wraps StoryView
lib/controllers/pregnancy/pregnancy_insights_controller.dart
assets/pregnancy/weekly_insights.json
assets/pregnancy/images/
```

---

### Baby / body images — where to get them

Flo’s look is **custom 3D + illustration**. You will not get Flo’s exact files (copyright). You *can* get the same **product pattern**: week hero + size fruit/veg + body sketch.

#### What images you need per week (minimum)


| Asset key pattern     | Purpose                                  | Example week 22                                            |
| --------------------- | ---------------------------------------- | ---------------------------------------------------------- |
| `baby_week_{N}`       | Story + card — fetus / baby illustration | Soft illustrated fetus                                     |
| `size_{label}`        | Size comparison (corn, avocado…)         | Corn cob next to scale cue                                 |
| `body_week_{N}`       | Maternal body change                     | Torso / bump / stretch marks style (tasteful, non-graphic) |
| `expect_*` (optional) | What-to-expect icons                     | Growth / body / inside                                     |


MVP shortcut: **1 shared baby hero** + **unique fruit/veg size image per week** + **1–3 shared body illustrations**. Flo-like cards work even before you have 40 unique fetuses.

#### Where to get them (legal / practical)


| Source                                                   | Good for                           | App OK?                                   | Notes                                                                                                                                      |
| -------------------------------------------------------- | ---------------------------------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| **Hire illustrator / 3D artist** (Fiverr, Upwork, local) | Closest to Flo                     | Best long-term                            | Brief: “week-by-week fetus + fruit size, soft pastel, medical-educational, commercial app license, exclusive”                              |
| **Stock — Shutterstock / iStock / Adobe Stock**          | Single weeks, fruit+embryo vectors | Yes if **commercial / app** license       | Search: `pregnancy baby size fruit week`, `fetus week illustration`. Prefer “Illustration” not photo of real fetus if you want Flo warmth. |
| **Creative Market / Envato / Etsy packs**                | Week 4–40 fruit size sets          | **Only if license says commercial / app** | Many Etsy packs are **personal use only** — read the license. Reject “personal use” for Play Store.                                        |
| **unDraw / Storyset / Open Peeps style**                 | Body / lifestyle                   | Often yes (check license)                 | Not week-accurate babies; fine for body/symptoms chrome                                                                                    |
| **AI image tools** (with commercial rights)              | Fast prototypes                    | Prototype only at first                   | Inconsistent week-to-week; review medical accuracy; keep a human edit pass before shipping                                                 |
| **Lottie** (`lottie` already in app)                     | Soft motion on hero                | Yes                                       | One pregnancy Lottie for Home hero while still images load in stories                                                                      |
| **Your designer exports PNG/WebP**                       | Final brand set                    | Best                                      | Put under `assets/pregnancy/images/`                                                                                                       |


**Do not:** scrape Flo, Glow, BabyCenter, or Google Images. **Do not** use “editorial only” stock in the app.

#### Recommended buy / make order

1. **Now (ship UI):** 1 baby placeholder + 5 size fruits (weeks you demo: 4, 12, 20, 22, 28) + 1 body placeholder.
2. **Next:** Buy or commission a **week 4–40 fruit/veg size pack** with **commercial license**.
3. **Polish:** Commission matching soft fetus illustrations (or one growing series) so Home hero + story feel premium like Flo.
4. **Never block coding on assets** — use colored placeholders + `size_label` text (“Corn”) until PNGs arrive.

#### How files live in the project

```
assets/pregnancy/images/
  baby_week_22.webp
  size_corn.webp
  body_week_22.webp
  placeholder_baby.webp
  placeholder_body.webp
```

JSON:

```json
"image_key": "size_corn"
```

Flutter:

```dart
Image.asset(
  'assets/pregnancy/images/$imageKey.webp',
  errorBuilder: (…) => Image.asset('assets/pregnancy/images/placeholder_baby.webp'),
)
```

Register in `pubspec.yaml`:

```yaml
assets:
  - assets/pregnancy/
  - assets/pregnancy/images/
```

#### Medical / store note

Label art as **illustrative / educational**, not ultrasound. Prefer stylized illustration over graphic clinical photos for a Flo-like soft brand and Play policy comfort.

---

### Will it look like Flo?

**Honest answer:**


| Layer                                               | Can match Flo?                                                                     |
| --------------------------------------------------- | ---------------------------------------------------------------------------------- |
| Home: week text + insight cards + what-to-expect    | **Yes** — layout & information architecture                                        |
| Full-screen story with progress bars (`story_view`) | **Yes** — same interaction pattern                                                 |
| Soft peach/pink pregnancy Home                      | **Yes** — theme/colors (keep your brand, don’t copy Flo pixels)                    |
| Exact 3D baby renders Flo uses                      | **No** — proprietary. Yours will look Flo-*like* only as good as **your** art pack |
| Size-of-fruit comparisons                           | **Yes** — very Flo, easy with stock/commissioned set                               |
| Symptoms card + log                                 | **Yes** — same idea; your log sheet already exists                                 |


So: **UX = Flo-like. Brand art = depends on images you license/commission.**  
With `story_view` + fruit size set + clean cards, users will recognize the *pattern* immediately. Without custom baby art, it still works — it just won’t look as premium as Flo’s 3D hero.

**Closest cheap path to “feels like Flo”:**

1. `story_view` for the viewer
2. Commercial fruit/veg week pack for size cards
3. One strong shared illustrated fetus for hero + baby story
4. Soft pastel backgrounds (not copying Flo’s exact assets)

---

## 4. Content data model

### 4.1 Catalog entry (one week — or one day override)

```json
{
  "id": "preg_insight_w22",
  "week": 22,
  "day_in_week": null,
  "days_pregnant": null,
  "locale": "en",
  "is_published": true,

  "baby": {
    "title": "Your baby at 22 weeks",
    "short_summary": "About the size of an ear of corn.",
    "size_label": "Corn",
    "size_asset_key": "size_corn",
    "illustration_asset_key": "baby_week_22",
    "body_markdown": "Longer development copy…",
    "length_cm": 27.8,
    "weight_g": 430,
    "milestones": ["Hearing is developing", "Movements feel stronger"]
  },

  "body": {
    "title": "Your body at 22 weeks",
    "short_summary": "Stretch marks and a growing bump are common.",
    "illustration_asset_key": "body_week_22",
    "body_markdown": "Longer maternal copy…",
    "highlights": ["Stretch marks", "Back strain", "Appetite changes"]
  },

  "symptoms": {
    "title": "Symptoms",
    "common_keys": ["sym_fatigue", "sym_back_pain", "sym_feeling_good"],
    "tip": "Logging helps you spot patterns week to week."
  },

  "what_to_expect": {
    "baby_growth_id": "preg_expect_baby_22",
    "body_changes_id": "preg_expect_body_22",
    "baby_inside_id": "preg_expect_inside_22"
  }
}
```

### 4.2 Day-level override (optional, rare)

Only add when copy truly differs by day (e.g. milestone day):

```json
{
  "id": "preg_insight_w22_d6",
  "week": 22,
  "day_in_week": 6,
  "days_pregnant": null,
  "baby": { "...": "override fields only; merge over week row" },
  "body": null,
  "symptoms": null
}
```

Merge rule: non-null fields on the day row override the week row.

### 4.3 Symptom keys

Reuse existing log catalog keys from the app (`sym_*` in daily logs). Pregnancy-common lists should only reference keys the log sheet already understands (or extend the log catalog in the same PR).

Examples:

- `sym_fatigue`
- `sym_cramps` / `sym_back_pain`
- `sym_nausea`
- `sym_feeling_good` (thumbs-up style)

### 4.4 What-to-expect long articles

Either:

- Link to `articles` with `phase = pregnancy` + `pregnancy_week = 22`, **or**
- Dedicated `pregnancy_expect_articles` rows referenced by `what_to_expect.*_id`

Prefer **reusing articles** if the CMS path is already planned; otherwise keep a small dedicated table so pregnancy week targeting stays clean.

---

## 5. MySQL shape (phpMyAdmin import later)

Deliver as `eezycycle-backend/sql/schema/` + `sql/seeds/` when you implement. Suggested tables:

### `pregnancy_weekly_insights` (CMS)


| Column                         | Type                   | Notes                                 |
| ------------------------------ | ---------------------- | ------------------------------------- |
| id                             | BIGINT PK              |                                       |
| week                           | TINYINT UNSIGNED       | 0–42; **unique with day_in_week**     |
| day_in_week                    | TINYINT UNSIGNED NULL  | `NULL` = whole week; `0–6` = override |
| days_pregnant                  | SMALLINT UNSIGNED NULL | optional absolute key                 |
| locale                         | VARCHAR(8)             | default `en`                          |
| baby_title                     | VARCHAR(255)           |                                       |
| baby_short_summary             | TEXT                   |                                       |
| baby_size_label                | VARCHAR(64) NULL       | “Corn”                                |
| baby_size_asset_key            | VARCHAR(64) NULL       |                                       |
| baby_illustration_asset_key    | VARCHAR(64) NULL       |                                       |
| baby_body_markdown             | MEDIUMTEXT             |                                       |
| baby_length_cm                 | DECIMAL(5,1) NULL      |                                       |
| baby_weight_g                  | INT NULL               |                                       |
| baby_milestones_json           | JSON NULL              | string array                          |
| body_title                     | VARCHAR(255)           |                                       |
| body_short_summary             | TEXT                   |                                       |
| body_illustration_asset_key    | VARCHAR(64) NULL       |                                       |
| body_body_markdown             | MEDIUMTEXT             |                                       |
| body_highlights_json           | JSON NULL              |                                       |
| symptoms_title                 | VARCHAR(255)           | default Symptoms                      |
| symptoms_common_keys_json      | JSON                   | `["sym_fatigue", …]`                  |
| symptoms_tip                   | TEXT NULL              |                                       |
| expect_baby_growth_article_id  | BIGINT NULL            | FK articles or expect table           |
| expect_body_changes_article_id | BIGINT NULL            |                                       |
| expect_baby_inside_article_id  | BIGINT NULL            |                                       |
| is_published                   | TINYINT(1)             |                                       |
| published_at                   | DATETIME NULL          |                                       |
| created_at / updated_at        | DATETIME               |                                       |


Index: `UNIQUE(week, day_in_week, locale)` (use a sentinel or generated column if MySQL unique-null quirks bite you — e.g. `day_in_week` default `-1` for “week row”).

**Do not** store user symptom logs here — those stay in `daily_logs` / `daily_log_items`.

---

## 6. API contract

### Option A (recommended): nest under existing today

`GET /cycle/today` when pregnancy mode is on already returns age fields. Extend `data` with:

```json
{
  "pregnancy_weeks": 22,
  "pregnancy_days": 6,
  "pregnancy_week": 23,
  "days_pregnant": 160,
  "daily_insights": {
    "date": "2027-01-31",
    "section_title": "My daily insights",
    "cards": [
      {
        "type": "baby",
        "week": 22,
        "title": "Your baby at 22 weeks",
        "short_summary": "About the size of an ear of corn.",
        "size_label": "Corn",
        "size_asset_key": "size_corn",
        "illustration_asset_key": "baby_week_22",
        "detail_available": true
      },
      {
        "type": "body",
        "week": 22,
        "title": "Your body at 22 weeks",
        "short_summary": "Stretch marks and a growing bump are common.",
        "illustration_asset_key": "body_week_22",
        "detail_available": true
      },
      {
        "type": "symptoms",
        "week": 22,
        "title": "Symptoms",
        "common_keys": ["sym_fatigue", "sym_back_pain", "sym_feeling_good"],
        "logged_keys": ["sym_fatigue"],
        "tip": "Logging helps you spot patterns week to week."
      }
    ],
    "what_to_expect": {
      "week": 22,
      "title": "What to expect at 22 weeks",
      "items": [
        { "key": "baby_growth", "label": "Baby's growth", "article_id": "…" },
        { "key": "body_changes", "label": "Body changes", "article_id": "…" },
        { "key": "baby_inside", "label": "Baby inside you", "article_id": "…" }
      ]
    }
  }
}
```

`logged_keys` = intersection of that date’s `daily_log_items` (category `symptoms`) with keys you care about for the card icons.

### Option B: dedicated endpoint

`GET /cycle/pregnancy/daily-insights?date=YYYY-MM-DD`

Same payload as `daily_insights` above. Use if today payload must stay small.

### Detail endpoints

- `GET /cycle/pregnancy/insights/:week/baby`
- `GET /cycle/pregnancy/insights/:week/body`
- or single `GET /cycle/pregnancy/insights/:week` returning full markdown + milestones

Partner variant: return **baby/body titles only** (or nothing). Never `logged_keys`.

---

## 7. Flutter processing steps

When `HomeHeroController` (or pregnancy home) loads and `pregnancyModeActive == true`:

1. Read age from today: `pregnancy_weeks`, `pregnancy_days`.
2. Read `daily_insights` from API **or** resolve from local catalog (Phase 1 below).
3. Build section header: `My daily insights · {formatted date}`.
4. Render horizontal cards from `cards[]` by `type`.
5. On baby/body tap → detail screen with markdown + assets.
6. On symptoms tap → existing log sheet pre-filtered to pregnancy-relevant symptoms; show `common_keys` as suggestions.
7. Render **What to expect** from `what_to_expect.items`.
8. On date change (calendar), re-fetch today/insights for that date so week/day and logs stay in sync.

### Local models (suggested)

```dart
enum PregnancyInsightCardType { baby, body, symptoms }

class PregnancyDailyInsights {
  final DateTime date;
  final int week;
  final int dayInWeek;
  final List<PregnancyInsightCard> cards;
  final PregnancyWhatToExpect whatToExpect;
}

class PregnancyInsightCard {
  final PregnancyInsightCardType type;
  final String title;
  final String? shortSummary;
  final String? sizeLabel;
  final String? sizeAssetKey;
  final String? illustrationAssetKey;
  final List<String> commonKeys;   // symptoms only
  final List<String> loggedKeys;   // symptoms only
}
```

Map asset keys → `assets/pregnancy/...` (or network CDN later).

---

## 8. Implementation phases (do in order)

### Phase 1 — Local catalog (ship UI fast)

Mirror articles pattern:

```
period_ovulation_tracker/assets/pregnancy/
  weekly_insights.json      # weeks 1–40 (start with 4–8 weeks of seed content)
  images/                   # size_*, baby_week_*, body_week_*
  README.md                 # how to add a week
```

- Resolver in Flutter: `week` → entry; merge day override if present.
- Symptoms `logged_keys` from existing `GET /logs?date=`.
- No new MySQL yet.

### Phase 2 — Backend CMS + seed SQL

- Tables + phpMyAdmin import under `eezycycle-backend/sql/`.
- Seed weeks 1–40 (copy from JSON).
- Service: `pregnancy_insights_service.js` resolves week/day + merges logs.
- Attach to `/cycle/today` or dedicated route.

### Phase 3 — Polish

- Prefetch adjacent weeks.
- Bookmark / share week article.
- Push: `pregnancy_week` notification already sketched in `onesignal-notification-plan.md`.
- Analytics: card opens by type/week (no intimate symptom payloads).

---

## 9. Content authoring checklist (per week)

For each `week` N:

- [ ] Baby size label + comparison asset
- [ ] Baby short summary (1–2 lines for card)
- [ ] Baby long markdown + 2–5 milestones
- [ ] Body illustration + short summary + long markdown
- [ ] 3–6 `symptoms.common_keys` that exist in the log catalog
- [ ] Three What-to-expect targets (or one shared article with sections)
- [ ] Medical disclaimer footer on detail screens (educational, not diagnosis)
- [ ] `is_published` only when copy + assets ready

Start content for the weeks you demo most (e.g. 4, 12, 20, 22, 28, 36); fill gaps with fallback chain.

---

## 10. Privacy & product rules


| Data                        | Woman app | Partner API                 |
| --------------------------- | --------- | --------------------------- |
| Baby / body weekly copy     | Yes       | Optional high-level only    |
| Common symptom suggestions  | Yes       | No                          |
| Logged symptom keys / notes | Yes       | **Never**                   |
| Due date / week number      | Yes       | Yes (if share_scope allows) |


Copy must stay educational. No diagnosis language. Align with Play health disclosures in `docs/backend/03-play-console-health-privacy.md`.

---

## 11. What you should do next (practical order)

### Applied in app (2026-09-28)

- Flutter: pregnancy Home section + `story_view` stories + what-to-expect detail  
- Assets: `assets/pregnancy/weekly_insights.json` (weeks 1–40) + Unsplash images  
- SQL: `025_create_pregnancy_weekly_insights.sql` + seed  
- API: `daily_insights` nested on `GET /cycle/today` when pregnancy mode is on  

### phpMyAdmin

1. Import `eezycycle-backend/sql/schema/025_create_pregnancy_weekly_insights.sql`  
2. Import `eezycycle-backend/sql/seeds/025_seed_pregnancy_weekly_insights.sql`  

Local JSON still powers the UI if SQL is not imported yet.

1. **Agree content key:** use `pregnancy_weeks` everywhere in catalogs.  
2. **Story UI:** `story_view: ^0.16.6` — see §3.4.  
3. Replace Unsplash produce photos with commissioned fetus art when budget allows.  
4. Optional: polish symptom CTA + partner-safe baby/body only.

---

## 12. Related code / docs


| Piece                   | Location                                                |
| ----------------------- | ------------------------------------------------------- |
| Gestational age         | `eezycycle-backend/services/flo_calendar_service.js`    |
| Pregnancy dating        | `eezycycle-backend/services/cycle/pregnancy_service.js` |
| Today payload           | `eezycycle-backend/services/cycle_service.js`           |
| Pregnancy mode UI flags | `HomeHeroController.pregnancyModeActive`                |
| Daily symptom logs      | `daily_logs` / log tracking controller                  |
| Schema / privacy tiers  | `docs/backend/02-mysql-table-structure.md`              |
| Articles local pattern  | `assets/articles/README.md`                             |


