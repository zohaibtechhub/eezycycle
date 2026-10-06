-- Phase 4: predicted vs actual period starts (schema mirror).
CREATE TABLE IF NOT EXISTS prediction_validation_log (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  event_type ENUM('period_start') NOT NULL DEFAULT 'period_start',
  actual_date DATE NOT NULL,
  predicted_date DATE NULL,
  delta_days INT NULL COMMENT 'actual - predicted (days); NULL if no prediction',
  algorithm_version VARCHAR(32) NULL,
  meta_json JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_pvl_user_date (user_id, actual_date),
  KEY idx_pvl_event (event_type, created_at),
  CONSTRAINT fk_pvl_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
