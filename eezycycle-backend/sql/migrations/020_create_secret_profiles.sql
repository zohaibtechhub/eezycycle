-- Migration 020: secret chat anonymous profiles + tags
-- phpMyAdmin → database `eezycycle` → Import / SQL tab

CREATE TABLE IF NOT EXISTS secret_profiles (
  user_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
  username VARCHAR(40) NOT NULL,
  avatar_url VARCHAR(512) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_secret_profiles_username (username),
  CONSTRAINT fk_secret_profiles_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS secret_profile_tags (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  tag_key VARCHAR(64) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_secret_profile_tags_user_tag (user_id, tag_key),
  KEY idx_secret_profile_tags_user (user_id),
  CONSTRAINT fk_secret_profile_tags_profile
    FOREIGN KEY (user_id) REFERENCES secret_profiles (user_id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
