-- Quiet hours + timezone for reminder delivery (optional columns).
ALTER TABLE reminder_preferences
  ADD COLUMN quiet_hours_start VARCHAR(5) NULL AFTER period_reminder_enabled,
  ADD COLUMN quiet_hours_end VARCHAR(5) NULL AFTER quiet_hours_start,
  ADD COLUMN timezone VARCHAR(64) NULL AFTER quiet_hours_end;
