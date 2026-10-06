# Cycle / secret chat SQL migrations (phpMyAdmin)

Import into database **`eezycycle`** in order:

1. `014_create_cycle_observations.sql` — truth / observations table  
2. `015_alter_cycle_predictions_ecc_v1.sql` — prediction types + confidence envelope  
3. `016_alter_user_profiles_edd_sources.sql` — EDD sources (if not already applied)  
4. `017_create_prediction_validation_log.sql`  
5. `018` / `019` — partner links  
6. **`020_create_secret_profiles.sql`** — anonymous secret chat profile + tags  
7. **`021_create_posts.sql`** — posts, comments, likes  
8. **`025_create_pregnancy_weekly_insights.sql`** then **`../seeds/025_seed_pregnancy_weekly_insights.sql`** — Flo-style pregnancy daily insights (weeks 1–40)  

If an `ALTER ... ADD COLUMN` fails with “Duplicate column”, that column already exists — skip that statement and continue.

After import, restart the Node API.
