-- Schema: article bookmarks (guest + registered)
-- Articles are still served from the app catalog; we store slug/id strings.

CREATE TABLE IF NOT EXISTS article_bookmarks (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  article_id VARCHAR(64) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_article_bookmarks_user_article (user_id, article_id),
  KEY idx_article_bookmarks_user (user_id),
  CONSTRAINT fk_article_bookmarks_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
