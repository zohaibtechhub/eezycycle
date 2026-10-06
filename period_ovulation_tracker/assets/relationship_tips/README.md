# Daily relationship tips (frontend-only)

Catalog: `assets/relationship_tips/tips.json` — **50 tips**.

## Daily selection
- Each calendar day shows a **stable random set of up to 10** tips (seeded by date).
- Same day → same 10; next day → a new shuffle.
- First tip of the day is the featured “empathy nugget.”

## Tip fields
| Field | Purpose |
|-------|---------|
| `id` | Unique key (`tip_01` … `tip_50`) |
| `title` | Card + detail headline |
| `description` | Short blurb |
| `body` | Longer detail copy |
| `category` | Filter chip |
| `icon` | Icon key (`chat`, `favorite`, …) |
| `time_to_read` | Meta |
| `try_this` | Action box on detail |
| `takeaways` | Bullet list on detail |

### Categories
Cycle Support · Communication · Quality Time · Care & Comfort · Appreciation
