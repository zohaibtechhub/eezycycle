-- Canonical create for new installs (Phase 1 prediction shape).
-- Prefer migrations/014 + 015 on existing DBs that already ran 012.

CREATE TABLE IF NOT EXISTS cycle_predictions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  pred_date DATE NOT NULL,
  prediction_type ENUM('period', 'ovulation', 'fertility', 'pregnancy', 'none') NOT NULL DEFAULT 'none',
  day_type ENUM('period', 'ovulation', 'fertility', 'pregnancy', 'none') NOT NULL DEFAULT 'none',
  period_day TINYINT NULL,
  range_start DATE NULL,
  range_end DATE NULL,
  confidence ENUM('low', 'medium', 'high') NOT NULL DEFAULT 'low',
  confidence_score DECIMAL(4,3) NULL,
  evidence_level CHAR(1) NOT NULL DEFAULT 'A',
  evidence_sources JSON NULL,
  predicted_value VARCHAR(64) NULL,
  headline VARCHAR(255) NULL,
  partner_headline VARCHAR(255) NULL,
  algorithm_version VARCHAR(32) NOT NULL DEFAULT 'ecc_prediction_v1',
  generated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_cycle_predictions_user_date_type (user_id, pred_date, prediction_type),
  KEY idx_cycle_predictions_user_date (user_id, pred_date),
  CONSTRAINT fk_cycle_predictions_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
