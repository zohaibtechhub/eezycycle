-- Daily symptom / mood / sex / test logs (Flo-style daily tracking) [T2/T3].
CREATE TABLE IF NOT EXISTS daily_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  log_date DATE NOT NULL,
  note_encrypted BLOB NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_daily_logs_user_date (user_id, log_date),
  KEY idx_daily_logs_user_date (user_id, log_date),
  CONSTRAINT fk_daily_logs_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS daily_log_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  daily_log_id BIGINT UNSIGNED NOT NULL,
  category VARCHAR(64) NOT NULL,
  item_key VARCHAR(64) NOT NULL,
  sensitivity ENUM('standard', 'intimate') NOT NULL DEFAULT 'standard',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_daily_log_items_log_key (daily_log_id, item_key),
  KEY idx_daily_log_items_log (daily_log_id),
  CONSTRAINT fk_daily_log_items_log
    FOREIGN KEY (daily_log_id) REFERENCES daily_logs (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
