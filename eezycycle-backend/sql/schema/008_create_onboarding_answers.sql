-- Dynamic onboarding Q&A [T2]. Never log answer_values plaintext in access logs.
CREATE TABLE IF NOT EXISTS onboarding_answers (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  flow_key VARCHAR(64) NOT NULL,
  step_id VARCHAR(64) NOT NULL,
  answer_values JSON NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_onboarding_answers_user_flow_step (user_id, flow_key, step_id),
  KEY idx_onboarding_answers_user_id (user_id),
  CONSTRAINT fk_onboarding_answers_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
