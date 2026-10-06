-- Day-level period marks (onboarding calendar + later calendar taps) [T2].
CREATE TABLE IF NOT EXISTS period_days (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  log_date DATE NOT NULL,
  flow_intensity ENUM('none', 'spotting', 'light', 'medium', 'heavy') NULL,
  is_predicted TINYINT(1) NOT NULL DEFAULT 0,
  cycle_id BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_period_days_user_date (user_id, log_date),
  KEY idx_period_days_cycle_id (cycle_id),
  CONSTRAINT fk_period_days_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_period_days_cycle
    FOREIGN KEY (cycle_id) REFERENCES cycles (id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
