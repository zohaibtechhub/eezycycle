-- Optional cycle headers for stats / history (seeded when periods are logged).
CREATE TABLE IF NOT EXISTS cycles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NULL,
  period_length_days TINYINT NULL,
  cycle_length_days TINYINT NULL,
  is_predicted TINYINT(1) NOT NULL DEFAULT 0,
  source ENUM('logged', 'predicted', 'imported') NOT NULL DEFAULT 'logged',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_cycles_user_start (user_id, start_date),
  CONSTRAINT fk_cycles_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
