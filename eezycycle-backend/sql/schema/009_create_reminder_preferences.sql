-- Reminder opt-ins from onboarding + quiet hours / timezone for push delivery.
CREATE TABLE IF NOT EXISTS reminder_preferences (
  user_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
  fertile_days_enabled TINYINT(1) NOT NULL DEFAULT 0,
  pregnancy_test_enabled TINYINT(1) NOT NULL DEFAULT 0,
  daily_tips_enabled TINYINT(1) NOT NULL DEFAULT 1,
  period_reminder_enabled TINYINT(1) NOT NULL DEFAULT 0,
  quiet_hours_start VARCHAR(5) NULL,
  quiet_hours_end VARCHAR(5) NULL,
  timezone VARCHAR(64) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_reminder_preferences_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
