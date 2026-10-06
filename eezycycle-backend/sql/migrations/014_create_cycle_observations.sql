-- Phase 1: Truth layer — user-reported observations (never mix with predictions).
-- Import in phpMyAdmin → database `eezycycle` → Import / SQL tab.

CREATE TABLE IF NOT EXISTS cycle_observations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  obs_date DATE NOT NULL,
  observation_type ENUM(
    'period',
    'bbt',
    'ovulation_test',
    'cervical_mucus',
    'symptom',
    'pregnancy_test'
  ) NOT NULL,
  value_json JSON NULL,
  source VARCHAR(64) NOT NULL DEFAULT 'user',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_cycle_obs_user_date_type (user_id, obs_date, observation_type),
  KEY idx_cycle_obs_user_date (user_id, obs_date),
  KEY idx_cycle_obs_user_type (user_id, observation_type),
  CONSTRAINT fk_cycle_observations_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
