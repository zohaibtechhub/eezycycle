-- Phase 4: dual pregnancy dating sources on user_profiles.
-- Import in phpMyAdmin against database `eezycycle`.
-- Safe to re-run: uses IF NOT EXISTS style checks via procedure-free ALTERs
-- (ignore duplicate-column errors if already applied).

ALTER TABLE user_profiles
  ADD COLUMN lmp_based_edd DATE NULL
    COMMENT 'LMP + 280 days snapshot'
    AFTER due_date;

ALTER TABLE user_profiles
  ADD COLUMN clinician_edd DATE NULL
    COMMENT 'Clinician or ultrasound EDD entered by user'
    AFTER lmp_based_edd;

ALTER TABLE user_profiles
  ADD COLUMN edd_source ENUM('lmp', 'clinician_ultrasound') NULL
    COMMENT 'Which source is active for due_date'
    AFTER clinician_edd;
