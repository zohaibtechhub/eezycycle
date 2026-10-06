-- Phase 1: Prediction envelope + allow multiple prediction types per date.
-- Import AFTER 014. Database `eezycycle`.
-- Safe to re-run pieces carefully; if columns already exist, skip those ALTERs.

-- 1) New columns (ignore error if already added)
ALTER TABLE cycle_predictions
  ADD COLUMN prediction_type ENUM('period', 'ovulation', 'fertility', 'pregnancy', 'none') NULL AFTER pred_date;

ALTER TABLE cycle_predictions
  ADD COLUMN range_start DATE NULL AFTER period_day;

ALTER TABLE cycle_predictions
  ADD COLUMN range_end DATE NULL AFTER range_start;

ALTER TABLE cycle_predictions
  ADD COLUMN confidence ENUM('low', 'medium', 'high') NOT NULL DEFAULT 'low' AFTER range_end;

ALTER TABLE cycle_predictions
  ADD COLUMN confidence_score DECIMAL(4,3) NULL AFTER confidence;

ALTER TABLE cycle_predictions
  ADD COLUMN evidence_level CHAR(1) NOT NULL DEFAULT 'A' AFTER confidence_score;

ALTER TABLE cycle_predictions
  ADD COLUMN evidence_sources JSON NULL AFTER evidence_level;

ALTER TABLE cycle_predictions
  ADD COLUMN predicted_value VARCHAR(64) NULL AFTER evidence_sources;

ALTER TABLE cycle_predictions
  ADD COLUMN updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER generated_at;

-- 2) Backfill prediction_type from day_type
UPDATE cycle_predictions
SET prediction_type = day_type
WHERE prediction_type IS NULL;

UPDATE cycle_predictions
SET range_start = pred_date
WHERE range_start IS NULL;

UPDATE cycle_predictions
SET range_end = pred_date
WHERE range_end IS NULL;

UPDATE cycle_predictions
SET predicted_value = day_type
WHERE predicted_value IS NULL;

UPDATE cycle_predictions
SET algorithm_version = 'ecc_prediction_v1'
WHERE algorithm_version = 'flo_calendar_v1' OR algorithm_version IS NULL OR algorithm_version = '';

-- 3) Enforce NOT NULL on prediction_type
ALTER TABLE cycle_predictions
  MODIFY prediction_type ENUM('period', 'ovulation', 'fertility', 'pregnancy', 'none') NOT NULL;

-- 4) Replace unique key: one row per (user, date, type)
ALTER TABLE cycle_predictions
  DROP INDEX uq_cycle_predictions_user_date;

ALTER TABLE cycle_predictions
  ADD UNIQUE KEY uq_cycle_predictions_user_date_type (user_id, pred_date, prediction_type);
