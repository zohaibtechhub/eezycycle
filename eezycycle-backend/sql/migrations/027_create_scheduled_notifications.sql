-- Tracks OneSignal notification ids per user + type so we can cancel/replace on rebuild.
-- Import in phpMyAdmin (database: eezycycle) after 026_create_push_devices.sql.
CREATE TABLE IF NOT EXISTS scheduled_notifications (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  notification_type VARCHAR(64) NOT NULL,
  onesignal_notification_id VARCHAR(64) NULL,
  fire_at_utc DATETIME NOT NULL,
  status ENUM('scheduled', 'sent', 'cancelled', 'failed') NOT NULL DEFAULT 'scheduled',
  payload_json JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_scheduled_notif_user_type (user_id, notification_type),
  KEY idx_scheduled_notif_status_fire (status, fire_at_utc),
  CONSTRAINT fk_scheduled_notif_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
