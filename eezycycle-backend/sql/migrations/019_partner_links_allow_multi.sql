-- Allow multiple partners on the same invite code (drop code uniqueness).
-- Import in phpMyAdmin on database `eezycycle` if 018 already ran.
ALTER TABLE partner_links
  DROP INDEX uq_partner_links_code;

ALTER TABLE partner_links
  ADD KEY idx_partner_links_code (code);
