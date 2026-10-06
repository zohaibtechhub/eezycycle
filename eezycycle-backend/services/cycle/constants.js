/** Shared engine version — Flo-aligned calendar math, EezyCycle packaging. */
const ALGORITHM_VERSION = 'ecc_prediction_v4_1';
/** Prior Phase 4 packaging. */
const LEGACY_ALGORITHM_VERSION = 'ecc_prediction_v4';
const ECC_V3_ALGORITHM_VERSION = 'ecc_prediction_v3';
const ECC_V2_ALGORITHM_VERSION = 'ecc_prediction_v2';
const ECC_V1_ALGORITHM_VERSION = 'ecc_prediction_v1';
const FLO_LEGACY_ALGORITHM_VERSION = 'flo_calendar_v1';

const OBSERVATION_TYPES = [
  'period',
  'bbt',
  'ovulation_test',
  'cervical_mucus',
  'symptom',
  'pregnancy_test',
];

const EDD_SOURCES = {
  LMP: 'lmp',
  CLINICIAN: 'clinician_ultrasound',
};

/** Estimate status — forecast vs updated/retrospective (not “confirmed ovulation”). */
const ESTIMATE_STATUS = {
  FORECAST: 'forecast',
  UPDATED: 'updated_estimate',
  RETROSPECTIVE: 'retrospective_estimate',
};

/**
 * Explicit thresholds for choosing median vs weighted mean for forecast C.
 * Prefer weighted mean when recent pattern is stable; median when noisy.
 */
const C_SELECTION_THRESHOLDS = {
  /** Use median if cycle_stddev >= this */
  HIGH_STDDEV: 5,
  /** Use median if |weighted_mean − median| >= this (days) */
  WEIGHTED_MEDIAN_PULL: 3,
  /** Use median if max−min usable cycle lengths >= this */
  LARGE_RANGE: 10,
  /** Period length: use median if |weighted − median| >= this */
  PERIOD_WEIGHTED_MEDIAN_PULL: 2,
};

/**
 * Fertile window modes (ASRM-aligned core + optional product extension).
 * Timing uncertainty is NEVER used to auto-expand these intervals.
 */
const FERTILE_WINDOW = {
  /** Core counseling window: ovulation−5 through ovulation (6 days ending on ov) */
  CORE: 'core',
  /** Extended conservative app window: ovulation−5 through ovulation+1 */
  EXTENDED: 'extended',
  /** Default calendar paint mode */
  DEFAULT_MODE: 'extended',
};

module.exports = {
  ALGORITHM_VERSION,
  LEGACY_ALGORITHM_VERSION,
  ECC_V3_ALGORITHM_VERSION,
  ECC_V2_ALGORITHM_VERSION,
  ECC_V1_ALGORITHM_VERSION,
  FLO_LEGACY_ALGORITHM_VERSION,
  OBSERVATION_TYPES,
  EDD_SOURCES,
  ESTIMATE_STATUS,
  C_SELECTION_THRESHOLDS,
  FERTILE_WINDOW,
};
