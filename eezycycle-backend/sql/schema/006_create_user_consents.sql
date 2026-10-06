-- Privacy consents — required before health data writes (Play / Data safety).
CREATE TABLE IF NOT EXISTS user_consents (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  consent_type ENUM('terms', 'health_data', 'marketing', 'notifications') NOT NULL,
  accepted TINYINT(1) NOT NULL,
  accepted_at DATETIME NOT NULL,
  document_version VARCHAR(32) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_user_consents_user_type (user_id, consent_type),
  CONSTRAINT fk_user_consents_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
