/**
 * EezyCycle prediction engine — `ecc_prediction_v4_1`
 * Dual EDD, safe insights, soft timing-confidence, validation hooks,
 * plus v4.1: OPK/BBT as estimate updates, bio fertile ≠ uncertainty expansion.
 */

const { ALGORITHM_VERSION } = require('./constants');

module.exports = {
  ALGORITHM_VERSION,
  observationService: require('./observation_service'),
  bleedRunService: require('./bleed_run_service'),
  cycleStatisticsService: require('./cycle_statistics_service'),
  regularityService: require('./regularity_service'),
  uncertaintyService: require('./uncertainty_service'),
  evidenceProcessor: require('./evidence_processor'),
  lutealPhaseService: require('./luteal_phase_service'),
  periodPredictionService: require('./period_prediction_service'),
  ovulationPredictionService: require('./ovulation_prediction_service'),
  fertilityPredictionService: require('./fertility_prediction_service'),
  pregnancyService: require('./pregnancy_service'),
  pregnancyInsightsService: require('./pregnancy_insights_service'),
  confidenceService: require('./confidence_service'),
  insightService: require('./insight_service'),
  predictionValidationService: require('./prediction_validation_service'),
  predictionService: require('./prediction_service'),
  predictionRebuildService: require('./prediction_rebuild_service'),
};
