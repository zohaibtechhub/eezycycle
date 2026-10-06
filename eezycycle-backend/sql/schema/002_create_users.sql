-- Auth identity: guest and registered share the same users row.
CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  account_status ENUM('guest', 'registered') NOT NULL DEFAULT 'guest',
  email VARCHAR(255) NULL,
  password_hash VARCHAR(255) NULL,
  name VARCHAR(120) NULL,
  google_sub VARCHAR(255) NULL,
  email_verified_at DATETIME NULL,
  registered_at DATETIME NULL,
  last_login_at DATETIME NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  UNIQUE KEY uq_users_email (email),
  UNIQUE KEY uq_users_google_sub (google_sub),
  KEY idx_users_account_status (account_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
