const { ALGORITHM_VERSION, FERTILE_WINDOW } = require('./constants');
const bleedRunService = require('./bleed_run_service');
const cycleStatisticsService = require('./cycle_statistics_service');
const regularityService = require('./regularity_service');
const lutealPhaseService = require('./luteal_phase_service');
const uncertaintyService = require('./uncertainty_service');
const evidenceProcessor = require('./evidence_processor');
const periodPredictionService = require('./period_prediction_service');
const ovulationPredictionService = require('./ovulation_prediction_service');
const fertilityPredictionService = require('./fertility_prediction_service');
const confidenceService = require('./confidence_service');
const flo = require('../flo_calendar_service');

/**
 * Core Phase-3 pipeline (no DB writes).
 *
 * @param {{
 *   loggedDates: string[],
 *   profile?: object,
 *   observations?: Array<{ date: string, type: string, value?: object }>,
 * }} input
 */
function generatePredictions(input) {
  const loggedDates = [...new Set(input.loggedDates || [])].sort();
  const loggedSet = new Set(loggedDates);
  const observations = input.observations || [];

  const runs = bleedRunService.buildBleedRuns(loggedDates);
  const completed = bleedRunService.completedCycles(runs);
  const lastStart = bleedRunService.lastPeriodStart(loggedDates);

  if (!lastStart) {
    return {
      profile: null,
      predictions: [],
      last_period_start: null,
      algorithm_version: ALGORITHM_VERSION,
      evidence: null,
    };
  }

  let personal = cycleStatisticsService.buildPersonalCycleProfile(
    completed,
    runs,
    {
      declaredC: input.profile?.avg_cycle_length,
      declaredP: input.profile?.avg_period_length,
      lutealDays: input.profile?.luteal_phase_days,
    },
  );

  const regularity = regularityService.assessRegularity(personal);
  personal = { ...personal, ...regularity };

  // Level A prior ovulation (for evidence processor)
  const L0 = lutealPhaseService.estimatedLutealDays(personal);
  const priorCurrentOv = flo.addDays(flo.addDays(lastStart, personal.C), -L0);

  const evidence = evidenceProcessor.processEvidence({
    observations,
    completedCycles: completed,
    lastPeriodStart: lastStart,
    C: personal.C,
    L: L0,
    priorCurrentOvulation: priorCurrentOv,
    ovulationUncertaintyDays: null,
  });

  // Apply Level B luteal into profile before uncertainty
  if (evidence.luteal_days != null) {
    personal = { ...personal, luteal_mean: evidence.luteal_days, L: evidence.luteal_days };
  }

  let confidence = confidenceService.assessConfidence(personal, evidence);
  personal = { ...personal, ...confidence };

  let uncertainty = uncertaintyService.computeUncertainty(personal);
  // Evidence may set a floor/ceiling on ovulation timing uncertainty (never zero)
  if (evidence.ovulation_uncertainty_days != null) {
    const fromEvidence = evidence.ovulation_uncertainty_days;
    const layers = evidence.evidence_layers || [];
    if (layers.includes('C') || layers.includes('D')) {
      uncertainty = {
        ...uncertainty,
        ovulation_uncertainty_days: Math.max(
          1,
          Math.min(uncertainty.ovulation_uncertainty_days, fromEvidence),
        ),
      };
    }
  }
  personal = { ...personal, ...uncertainty };

  const L = lutealPhaseService.estimatedLutealDays(personal, evidence);

  const forecastPeriodStart = flo.addDays(lastStart, personal.C);
  const estimatedPeriodStart = forecastPeriodStart; // no period-moving biomarkers yet

  const periodRows = periodPredictionService.predictPeriodDays(
    {
      lastPeriodStart: lastStart,
      C: personal.C,
      P: personal.P,
      cyclesAhead: 6,
      periodUncertaintyDays: personal.period_uncertainty_days,
      forecastPeriodStart,
      estimatedPeriodStart,
    },
    loggedSet,
  );

  const periodSummary = periodPredictionService.summarizeNextPeriod({
    lastPeriodStart: lastStart,
    C: personal.C,
    periodUncertaintyDays: personal.period_uncertainty_days,
    forecastPeriodStart,
    estimatedPeriodStart,
  });

  const hasCurrentEvidence =
    (evidence.evidence_layers || []).some((l) => l === 'C' || l === 'D') ||
    (evidence.estimate_status &&
      evidence.estimate_status !== 'forecast');

  const ovulationRows = ovulationPredictionService.predictOvulationDays(
    {
      lastPeriodStart: lastStart,
      C: personal.C,
      L,
      cyclesAhead: 6,
      ovulationUncertaintyDays: personal.ovulation_uncertainty_days,
      currentOvulationOverride: hasCurrentEvidence
        ? evidence.estimated_ovulation_date || evidence.current_ovulation_date
        : evidence.evidence_layers?.includes('B')
          ? evidence.current_ovulation_date
          : null,
      estimateStatus: evidence.estimate_status,
      ovulationRangeStart: evidence.ovulation_range_start,
      ovulationRangeEnd: evidence.ovulation_range_end,
      forecastOvulationDate: evidence.forecast_ovulation_date || priorCurrentOv,
    },
    loggedSet,
  );

  const periodDateSet = new Set(periodRows.map((r) => r.date));
  const fertilityRows = fertilityPredictionService.predictFertilityDays(
    ovulationRows,
    { mode: FERTILE_WINDOW.DEFAULT_MODE },
    loggedSet,
    periodDateSet,
  );

  confidence = confidenceService.assessConfidence(personal, evidence);

  const envelope = {
    confidence: confidence.prediction_confidence,
    confidenceScore: confidence.prediction_confidence_score,
    evidenceLevel: confidence.evidence_level,
    evidenceSources: confidence.evidence_sources,
    evidenceLayers: confidence.evidence_layers,
    confidenceMeans: 'timing_estimate',
  };

  const predictions = [...periodRows, ...ovulationRows, ...fertilityRows].map(
    (row) => {
      const isOvRelated =
        row.predictionType === 'ovulation' ||
        row.predictionType === 'fertility';
      return {
        ...row,
        ...envelope,
        evidenceLevel: isOvRelated
          ? evidence.evidence_level
          : row.predictionType === 'period'
            ? 'A'
            : evidence.evidence_level,
        evidenceSources: isOvRelated
          ? evidence.evidence_sources
          : ['historical_cycle_data', 'weighted_cycle_statistics'],
        evidenceLayers: isOvRelated
          ? evidence.evidence_layers
          : ['A'],
        estimateStatus:
          row.estimateStatus ||
          (isOvRelated ? evidence.estimate_status : null),
        rangeStart: row.rangeStart || row.date,
        rangeEnd: row.rangeEnd || row.date,
      };
    },
  );

  personal = {
    ...personal,
    ...confidence,
    evidence_level: evidence.evidence_level,
    evidence_layers: evidence.evidence_layers,
    evidence_sources: evidence.evidence_sources,
    soft_confidence_label: confidence.soft_confidence_label,
    estimate_status: evidence.estimate_status,
  };

  return {
    profile: personal,
    predictions,
    last_period_start: lastStart,
    algorithm_version: ALGORITHM_VERSION,
    period: periodSummary,
    evidence: {
      level: evidence.evidence_level,
      layers: evidence.evidence_layers,
      sources: evidence.evidence_sources,
      notes: evidence.notes,
      forecast_ovulation_date: evidence.forecast_ovulation_date,
      estimated_ovulation_date: evidence.estimated_ovulation_date,
      current_ovulation_date: evidence.current_ovulation_date,
      ovulation_range_start: evidence.ovulation_range_start,
      ovulation_range_end: evidence.ovulation_range_end,
      ovulation_uncertainty_days: evidence.ovulation_uncertainty_days,
      estimate_status: evidence.estimate_status,
      luteal_days: evidence.luteal_days,
    },
  };
}

/**
 * Collapse multi-type prediction rows to one primary day_type per date
 * for Flutter calendar compatibility.
 * Priority: ovulation > period > fertility > none
 *
 * Symptoms never appear as day_type here.
 */
function primaryDayTypeByDate(predictionRows) {
  const rank = { ovulation: 3, period: 2, fertility: 1, none: 0, pregnancy: 4 };
  const byDate = new Map();

  for (const row of predictionRows || []) {
    const date = row.date || row.pred_date;
    const type =
      row.predictionType || row.prediction_type || row.dayType || row.day_type;
    if (!date || !type) continue;
    // Guard: never promote symptom / mucus as calendar day_type
    if (type === 'symptom' || type === 'cervical_mucus' || type === 'bbt') {
      continue;
    }
    const existing = byDate.get(date);
    if (!existing || (rank[type] || 0) > (rank[existing.day_type] || 0)) {
      byDate.set(date, {
        date,
        day_type: type,
        prediction_type: type,
        period_day: row.periodDay ?? row.period_day ?? null,
        is_predicted: true,
        range_start: row.rangeStart || row.range_start || date,
        range_end: row.rangeEnd || row.range_end || date,
        confidence: row.confidence || null,
        evidence_level: row.evidenceLevel || row.evidence_level || 'A',
        evidence_sources: row.evidenceSources || row.evidence_sources || null,
        algorithm_version: row.algorithm_version || ALGORITHM_VERSION,
      });
    }
  }

  return [...byDate.values()].sort((a, b) => a.date.localeCompare(b.date));
}

module.exports = {
  generatePredictions,
  primaryDayTypeByDate,
  ALGORITHM_VERSION,
};
