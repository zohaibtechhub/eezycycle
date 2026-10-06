-- Profile photo for the account (shown in app header, drawer, secret chat, partner view).
ALTER TABLE users
  ADD COLUMN avatar_url VARCHAR(512) NULL AFTER name;
