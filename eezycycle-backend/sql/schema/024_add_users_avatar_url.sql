-- Profile photo column on users (canonical avatar for the account).
-- Prefer migrations/024_add_users_avatar_url.sql for existing DBs.
ALTER TABLE users
  ADD COLUMN avatar_url VARCHAR(512) NULL AFTER name;
