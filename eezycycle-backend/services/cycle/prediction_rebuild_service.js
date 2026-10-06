const profileRepository = require('../../repositories/profile_repository');
const periodRepository = require('../../repositories/period_repository');
const predictionRepository = require('../../repositories/prediction_repository');
const { toDateString, addDays } = require('../../utils/date');
const { ALGORITHM_VERSION } = require('./constants');
const observationService = require('./observation_service');
const pregnancyService = require('./pregnancy_service');
const predictionService = require('./prediction_service');
const flo = require('../flo_calendar_service');

/** In-flight rebuilds — home fires getToday + getCalendar in parallel. */
const rebuildInFlight = new Map();

/**
 * FULL REBUILD — period history / onboarding / pregnancy toggle / manual.
 * @param {number} userId
 */
async function fullRebuild(userId) {
  return _withLock(userId, () => _rebuildPredictions(userId, { mode: 'full' }));
}

/**
 * TODAY UPDATE — lightweight path for biomarker day updates (Phase 3).
 * Phase 2: regenerates with the same engine but only replaces a near-term
 * prediction window so far-future rows from a prior FULL rebuild can remain.
 *
 * @param {number} userId
 * @param {{ date?: string, horizonDays?: number }} [opts]
 */
async function todayUpdate(userId, opts = {}) {
  return _withLock(userId, () =>
    _rebuildPredictions(userId, {
      mode: 'today',
      date: opts.date,
      horizonDays: opts.horizonDays ?? 60,
    }),
  );
}

/**
 * Backward-compatible alias → FULL REBUILD.
 * @param {number} userId
 */
async function rebuildPredictions(userId) {
  return fullRebuild(userId);
}

function _withLock(userId, fn) {
  const key = String(userId);
  const existing = rebuildInFlight.get(key);
  if (existing) return existing;

  const promise = fn().finally(() => {
    if (rebuildInFlight.get(key) === promise) {
      rebuildInFlight.delete(key);
    }
  });
  rebuildInFlight.set(key, promise);
  return promise;
}

/**
 * @param {number} userId
 * @param {{ mode: 'full'|'today', date?: string, horizonDays?: number }} opts
 */
async function _rebuildPredictions(userId, opts) {
  const mode = opts.mode || 'full';
  await profileRepository.ensureExists(userId);
  const profile = await profileRepository.findByUserId(userId);
  const periodRows = await periodRepository.listByUserId(userId);
  const loggedDates = periodRows
    .filter((r) => !r.is_predicted)
    .map((r) => toDateString(r.log_date))
    .filter(Boolean)
    .sort();

  try {
    await observationService.syncPeriodObservations(userId, loggedDates);
  } catch (_) {
    // Table may not exist until migration 014 is imported — period_days still works
  }

  if (pregnancyService.isPregnancyActive(profile)) {
    await predictionRepository.deletePredictedForUser(userId);
    await profileRepository.update(userId, {
      fertile_window_mode: profile.fertile_window_mode || 'standard',
    });
    const runs = flo.groupBleedRuns(logged);
    const lastStart = runs.length ? runs[runs.length - 1].start : null;
    const datingFull = pregnancyService.resolveDating(profile, lastStart);

    return {
      rebuilt: true,
      rebuild_mode: mode,
      pregnancy_mode: true,
      predictions: 0,
      algorithm_version: ALGORITHM_VERSION,
      avg_cycle_length: profile.avg_cycle_length || 28,
      avg_period_length: profile.avg_period_length || 5,
      personal_cycle_profile: null,
      due_date: datingFull.due_date,
      edd_source: datingFull.edd_source,
      edd_source_label: pregnancyService.eddSourceLabel(datingFull.edd_source),
      lmp_based_edd: datingFull.lmp_based_edd,
      clinician_edd: datingFull.clinician_edd,
    };
  }

  if (loggedDates.length === 0) {
    await predictionRepository.deletePredictedForUser(userId);
    return {
      rebuilt: true,
      rebuild_mode: mode,
      pregnancy_mode: false,
      predictions: 0,
      algorithm_version: ALGORITHM_VERSION,
      avg_cycle_length: profile?.avg_cycle_length || 28,
      avg_period_length: profile?.avg_period_length || 5,
      personal_cycle_profile: null,
    };
  }

  let observations = [];
  try {
    observations = await observationService.collectObservations(userId);
  } catch (_) {
    observations = [];
  }

  const generated = predictionService.generatePredictions({
    loggedDates,
    profile,
    observations,
  });

  if (mode === 'today') {
    const anchor =
      toDateString(opts.date) || new Date().toISOString().slice(0, 10);
    const horizon = Math.max(14, Number(opts.horizonDays) || 60);
    const from = addDays(anchor, -7);
    const to = addDays(anchor, horizon);
    const windowRows = generated.predictions.filter(
      (r) => r.date >= from && r.date <= to,
    );
    await predictionRepository.replaceInRange(
      userId,
      from,
      to,
      windowRows,
      ALGORITHM_VERSION,
    );
  } else {
    await predictionRepository.replaceAll(
      userId,
      generated.predictions,
      ALGORITHM_VERSION,
    );
  }

  const personal = generated.profile;
  if (personal) {
    const patch = {
      avg_cycle_length: personal.C,
      avg_period_length: personal.P,
      fertile_window_mode: personal.fertile_window_mode,
    };
    if (
      personal.luteal_mean != null &&
      personal.luteal_mean >= 10 &&
      personal.luteal_mean <= 16
    ) {
      patch.luteal_phase_days = personal.luteal_mean;
    }
    await profileRepository.update(userId, patch);
  }

  return {
    rebuilt: true,
    rebuild_mode: mode,
    pregnancy_mode: false,
    predictions: generated.predictions.length,
    last_period_start: generated.last_period_start,
    avg_cycle_length: personal?.C,
    avg_period_length: personal?.P,
    fertile_window_mode: personal?.fertile_window_mode,
    algorithm_version: ALGORITHM_VERSION,
    evidence: generated.evidence,
    personal_cycle_profile: personal
      ? {
          cycle_mean: personal.cycle_mean,
          cycle_median: personal.cycle_median,
          cycle_weighted_mean: personal.cycle_weighted_mean,
          cycle_stddev: personal.cycle_stddev,
          cycle_range: personal.cycle_range,
          recent_cycle_mean: personal.recent_cycle_mean,
          recent_cycle_stddev: personal.recent_cycle_stddev,
          period_mean: personal.period_mean,
          period_median: personal.period_median,
          period_weighted_mean: personal.period_weighted_mean,
          luteal_mean: personal.luteal_mean,
          regularity_score: personal.regularity_score,
          data_quality: personal.data_quality,
          prediction_confidence: personal.prediction_confidence,
          prediction_confidence_score: personal.prediction_confidence_score,
          period_uncertainty_days: personal.period_uncertainty_days,
          ovulation_uncertainty_days: personal.ovulation_uncertainty_days,
          forecast_cycle_count: personal.forecast_cycle_count,
          evidence_level: personal.evidence_level,
          evidence_sources: personal.evidence_sources,
        }
      : null,
  };
}

module.exports = {
  rebuildPredictions,
  fullRebuild,
  todayUpdate,
};
