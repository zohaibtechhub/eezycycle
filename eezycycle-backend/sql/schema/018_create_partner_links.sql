-- Partner invite codes + couple linking (woman owner ↔ one or more male partners).
-- One reusable invite row (pending, partner_user_id NULL) + one active row per linked partner.
-- Share scope is an allow-list of high-level cycle phases only — never sex/symptoms/tests/notes.
CREATE TABLE IF NOT EXISTS partner_links (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code CHAR(6) NOT NULL,
  owner_user_id BIGINT UNSIGNED NOT NULL,
  partner_user_id BIGINT UNSIGNED NULL,
  status ENUM('pending', 'active', 'revoked') NOT NULL DEFAULT 'pending',
  share_scope JSON NOT NULL,
  owner_consented_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  linked_at DATETIME NULL,
  revoked_at DATETIME NULL,
  KEY idx_partner_links_code (code),
  KEY idx_partner_links_owner (owner_user_id),
  KEY idx_partner_links_partner (partner_user_id),
  KEY idx_partner_links_status (status),
  CONSTRAINT fk_partner_links_owner
    FOREIGN KEY (owner_user_id) REFERENCES users (id)
    ON DELETE CASCADE,
  CONSTRAINT fk_partner_links_partner
    FOREIGN KEY (partner_user_id) REFERENCES users (id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
