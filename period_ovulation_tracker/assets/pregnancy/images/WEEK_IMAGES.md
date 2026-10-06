# Pregnancy week images (baby + body)

## Layout

| Folder | Purpose |
|--------|---------|
| `images/baby/week_01.jpg` … `week_40.jpg` | Baby / fetus illustration per week |
| `images/body/week_01.jpg` … `week_40.jpg` | Maternal body / bump illustration per week |
| `images/body/labor_delivery.jpg` | Labor & delivery mom (extra) |
| `images/size/week_01.svg` … `week_41.svg` | Fruit/veg size comparisons (SVG pack) |

Catalog paths in `weekly_insights.json` already use these names — drop in files and **full restart**.

## What you currently have

**Baby (`fetaldev` pack):** real art for weeks **2–40**. Week **1** reuses week 2 until you add it.

**Body:** real art for weeks **1–40** (`pregnancy-week-N-wide` pack → `week_XX.jpg`). Extra: `labor_delivery.jpg`.

## Drop-in steps

1. Export / rename to exactly `week_07.jpg`, `week_22.jpg`, …
2. Put fetus art in `images/baby/`
3. Put bump / body art in `images/body/`
4. Full restart the app (hot reload may keep old bitmaps)

Suggested resolution: **800×800** or **1200×1200**, soft background, no watermarks.

## Important: third-party art

Do **not** ship proprietary fetal/body illustrations (BabyCenter, Flo, etc.) in a store build without a written commercial license. Prefer licensed packs, commissioned art, or stock with an **app** license.

## Attribution

- Size fruit SVGs: `assets/pregnancy/images/size/week_XX.svg`
- Baby/body: your pack as placed in `baby/` and `body/`
