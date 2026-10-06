-- Push device registry: maps users.id ↔ OneSignal subscription (player) id.
CREATE TABLE IF NOT EXISTS push_devices (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  onesignal_subscription_id VARCHAR(64) NOT NULL,
  platform ENUM('ios', 'android', 'other') NOT NULL DEFAULT 'other',
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  last_seen_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_push_devices_subscription (onesignal_subscription_id),
  KEY idx_push_devices_user_id (user_id),
  KEY idx_push_devices_user_enabled (user_id, enabled),
  CONSTRAINT fk_push_devices_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
