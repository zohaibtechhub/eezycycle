# Articles (frontend-only)

All articles live in `assets/articles/articles.json`. No backend CMS required.

## Structure of every article

| Field | Purpose | Example |
|-------|---------|---------|
| `id` | Unique key | `sex_desire_cycle_01` |
| `title` | Card + reader headline | How desire shifts across your cycle |
| `description` | Short card blurb | … |
| `category` | Chip label | `Sex & Intimacy` |
| `category_type` | Filter / theme | `sex_intimacy` |
| `read_time` | Meta | `4 min read` |
| `image` | Cover (URL or `assets/articles/images/...`) | Unsplash / local |
| `phase` | Primary cycle stage | `ovulation` |
| `phases` | Extra stages article can appear in | `["follicular","ovulation"]` |
| `hero_summary` | Intro under image | … |
| `sections[]` | `{ heading, body }` body blocks | … |
| `takeaways[]` | Bullet tips at end | … |

### Categories you can use
- Sex & Intimacy (`sex_intimacy`) — desire, consent, protection, period sex, low drive
- Energy & Hormones, Fitness, Fertility, PMS & Care, Rest & Flow, Sleep, Nutrition, Pregnancy, Wellness

### Phases
`menstrual` · `follicular` · `ovulation` · `luteal` · `pregnancy` · `general`

## Images (Unsplash — curated for you)

Article covers are **Unsplash** URLs chosen to match each topic (tasteful lifestyle for Sex & Intimacy — no explicit imagery).

- Field: `"image": "https://images.unsplash.com/photo-..."`
- Optional: `"image_alt": "short description"`
- When you add a new article, ask the agent to pick a matching Unsplash cover (verified HTTP 200).

Local files are also supported later: `assets/articles/images/your_file.jpg`.

## Adding toward 50 articles
Copy one object in `articles.json`, change `id`, fill title/copy, and attach a unique Unsplash `image`. Or regenerate with:

`python3 tool/gen_articles.py`

Library tab **Sex & Intimacy** lists all sex articles automatically.

## Home placement
- **Discover Insights** — up to **6** articles matched to the current cycle phase.
- **For you** — **5** more recommended articles from the same ranking, **never overlapping** Discover. **See all** opens the full library.

