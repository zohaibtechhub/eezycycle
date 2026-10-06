-- Profile + cycle defaults [T2 health fields: birth_year, height, weight, mode].
CREATE TABLE IF NOT EXISTS user_profiles (
  user_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
  birth_year SMALLINT NULL,
  height_cm DECIMAL(5, 2) NULL,
  weight_kg DECIMAL(5, 2) NULL,
  is_metric TINYINT(1) NOT NULL DEFAULT 1,
  experience_mode ENUM(
    'track_cycle',
    'get_pregnant',
    'track_pregnancy',
    'perimenopause',
    'partner'
  ) NULL,
  pregnancy_mode_active TINYINT(1) NOT NULL DEFAULT 0,
  due_date DATE NULL,
  discovery_source VARCHAR(64) NULL,
  usage_path ENUM('self', 'partner') NULL,
  partner_code_entered VARCHAR(16) NULL,
  avg_cycle_length TINYINT NULL DEFAULT 28,
  avg_period_length TINYINT NULL DEFAULT 5,
  luteal_phase_days TINYINT NOT NULL DEFAULT 14,
  fertile_window_mode ENUM('standard', 'wide') NOT NULL DEFAULT 'standard',
  timezone VARCHAR(64) NULL,
  onboarding_completed_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_user_profiles_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
