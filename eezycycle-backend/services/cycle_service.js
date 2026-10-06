const { createError, ErrorCodes } = require('../utils/error');
const { toDateString } = require('../utils/date');
const periodRepository = require('../repositories/period_repository');
const predictionRepository = require('../repositories/prediction_repository');
const profileRepository = require('../repositories/profile_repository');
const flo = require('./flo_calendar_service');
const {
  ALGORITHM_VERSION,
  observationService,
  pregnancyService,
  predictionService,
  predictionRebuildService,
} = require('./cycle');
const insightService = require('./cycle/insight_service');
const pregnancyInsightsService = require('./cycle/pregnancy_insights_service');
const predictionValidationService = require('./cycle/prediction_validation_service');
const confidenceService = require('./cycle/confidence_service');

/**
 * @param {unknown} input
 * @returns {string[]}
 */
function normalizePeriodDates(input) {
  const list = Array.isArray(input) ? input : [];
  const set = new Set();
  for (const item of list) {
    const date = toDateString(item);
    if (!date) {
      throw createError(`Invalid period date: ${item}`, 400, ErrorCodes.VALIDATION);
    }
    const today = new Date();
    const max = new Date(
      Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), today.getUTCDate() + 1),
    );
    const maxDate = max.toISOString().slice(0, 10);
    if (date > maxDate) {
      throw createError('Period dates cannot be in the future.', 400, ErrorCodes.VALIDATION);
    }
    set.add(date);
  }
  return [...set].sort();
}

function serializeDay(row) {
  return {
    date: toDateString(row.log_date),
    flow_intensity: row.flow_intensity,
    is_predicted: Boolean(row.is_predicted),
    day_type: 'period',
    is_observation: true,
  };
}

function serializePredictionRow(row) {
  let sources = row.evidence_sources;
  if (typeof sources === 'string') {
    try {
      sources = JSON.parse(sources);
    } catch (_) {
      sources = [sources];
    }
  }
  return {
    date: toDateString(row.pred_date),
    prediction_type: row.prediction_type || row.day_type,
    day_type: row.day_type || row.prediction_type,
    period_day: row.period_day,
    is_predicted: true,
    is_observation: false,
    range_start: row.range_start ? toDateString(row.range_start) : toDateString(row.pred_date),
    range_end: row.range_end ? toDateString(row.range_end) : toDateString(row.pred_date),
    confidence: row.confidence || null,
    confidence_score: row.confidence_score != null ? Number(row.confidence_score) : null,
    evidence_level: row.evidence_level || 'A',
    evidence_sources: sources || ['historical_cycle_data'],
    predicted_value: row.predicted_value || row.day_type,
    algorithm_version: row.algorithm_version || ALGORITHM_VERSION,
  };
}

function rebuildPredictions(userId, opts = {}) {
  const mode = String(opts.mode || opts.rebuild_mode || 'full').toLowerCase();
  if (mode === 'today') {
    return predictionRebuildService.todayUpdate(userId, {
      date: opts.date,
      horizonDays: opts.horizonDays ?? opts.horizon_days,
    });
  }
  return predictionRebuildService.fullRebuild(userId);
}

function fullRebuild(userId) {
  return predictionRebuildService.fullRebuild(userId);
}

function todayUpdate(userId, opts = {}) {
  return predictionRebuildService.todayUpdate(userId, opts);
}

/**
 * PUT /cycle/period-days
 */
async function putPeriodDays(userId, body) {
  const raw =
    body.dates ||
    body.period_dates ||
    body.periodDates ||
    body.last_period_dates ||
    body.lastPeriodDates;

  if (!Array.isArray(raw)) {
    throw createError('dates array is required.', 400, ErrorCodes.VALIDATION);
  }

  const dates = normalizePeriodDates(raw);

  const previousRows = await periodRepository.listByUserId(userId);
  const previousDates = previousRows
    .filter((r) => !r.is_predicted)
    .map((r) => toDateString(r.log_date))
    .filter(Boolean);

  await periodRepository.replaceLoggedDates(userId, dates);
  try {
    await observationService.syncPeriodObservations(userId, dates);
  } catch (_) {
    /* migration 014 optional until imported */
  }

  let validation = [];
  try {
    validation = await predictionValidationService.logNewPeriodStarts(
      userId,
      previousDates,
      dates,
    );
  } catch (_) {
    /* migration 017 optional */
  }

  const rebuild = await rebuildPredictions(userId);

  // Event-driven push replan (OneSignal holds the send queue)
  try {
    const notificationPlanner = require('./notification_planner_service');
    notificationPlanner.rebuildSafe(userId, { reason: 'period_days' });
  } catch (_) {
    /* non-fatal */
  }

  const rows = await periodRepository.listByUserId(userId);
  return {
    dates: rows.filter((r) => !r.is_predicted).map((r) => serializeDay(r).date),
    days: rows.map(serializeDay),
    rebuild,
    validation,
  };
}

async function getPeriodDays(userId, query = {}) {
  const from = query.from ? toDateString(query.from) : null;
  const to = query.to ? toDateString(query.to) : null;
  if ((query.from && !from) || (query.to && !to)) {
    throw createError('Invalid from/to date.', 400, ErrorCodes.VALIDATION);
  }

  const rows = await periodRepository.listByUserId(
    userId,
    from || undefined,
    to || undefined,
  );
  return { days: rows.map(serializeDay) };
}

function profilePayload(profile, lastPeriodStart, extras = {}) {
  const pregnancyOn = pregnancyService.isPregnancyActive(profile);
  const dating = pregnancyOn
    ? pregnancyService.resolveDating(profile, lastPeriodStart)
    : {
        due_date: profile?.due_date ? toDateString(profile.due_date) : null,
        edd_source: profile?.edd_source || null,
        lmp_based_edd: profile?.lmp_based_edd
          ? toDateString(profile.lmp_based_edd)
          : null,
        clinician_edd: profile?.clinician_edd
          ? toDateString(profile.clinician_edd)
          : null,
      };

  return {
    experience_mode: profile?.experience_mode || null,
    pregnancy_mode_active: pregnancyOn,
    due_date: dating.due_date,
    lmp_based_edd: dating.lmp_based_edd,
    clinician_edd: dating.clinician_edd,
    edd_source: dating.edd_source,
    edd_source_label: pregnancyService.eddSourceLabel(dating.edd_source),
    last_period_start: lastPeriodStart,
    avg_cycle_length: profile?.avg_cycle_length || flo.DEFAULT_C,
    avg_period_length: profile?.avg_period_length || flo.DEFAULT_P,
    fertile_window_mode: profile?.fertile_window_mode || 'standard',
    ...extras,
  };
}

/**
 * GET /cycle/today
 */
async function getToday(userId, query = {}) {
  await profileRepository.ensureExists(userId);
  let profile = await profileRepository.findByUserId(userId);

  const periodRows = await periodRepository.listByUserId(userId);
  const loggedDates = periodRows
    .filter((r) => !r.is_predicted)
    .map((r) => toDateString(r.log_date))
    .filter(Boolean);

  let predictions = await predictionRepository.listByUserId(userId);
  if (
    loggedDates.length > 0 &&
    predictions.length === 0 &&
    !pregnancyService.isPregnancyActive(profile)
  ) {
    await rebuildPredictions(userId);
    profile = await profileRepository.findByUserId(userId);
    predictions = await predictionRepository.listByUserId(userId);
  }

  const runs = flo.groupBleedRuns(loggedDates);
  const lastPeriodStart = runs.length ? runs[runs.length - 1].start : null;
  const date = toDateString(query.date) || new Date().toISOString().slice(0, 10);

  const primaryPredicted = predictionService.primaryDayTypeByDate(
    predictions.map((p) => ({
      date: toDateString(p.pred_date),
      predictionType: p.prediction_type || p.day_type,
      dayType: p.day_type || p.prediction_type,
      periodDay: p.period_day,
      rangeStart: p.range_start,
      rangeEnd: p.range_end,
      confidence: p.confidence,
      evidenceLevel: p.evidence_level,
      algorithm_version: p.algorithm_version,
    })),
  );

  const dating = pregnancyService.resolveDating(profile, lastPeriodStart);

  const summary = flo.buildDaySummary({
    date,
    lastPeriodStart,
    C: profile?.avg_cycle_length || flo.DEFAULT_C,
    P: profile?.avg_period_length || flo.DEFAULT_P,
    L: profile?.luteal_phase_days || flo.DEFAULT_L,
    loggedDates,
    predicted: primaryPredicted.map((p) => ({
      date: p.date,
      dayType: p.day_type,
      periodDay: p.period_day,
    })),
    pregnancyModeActive: pregnancyService.isPregnancyActive(profile),
    dueDate: dating.due_date,
    clinicianEdd: dating.clinician_edd,
    eddSource: dating.edd_source,
    experienceMode: profile?.experience_mode || null,
    irregular: profile?.fertile_window_mode === 'wide',
  });

  const dayPredictions = predictions
    .filter((p) => toDateString(p.pred_date) === date)
    .map(serializePredictionRow);

  const ovPred =
    dayPredictions.find((p) => p.prediction_type === 'ovulation') ||
    predictions
      .filter((p) => (p.prediction_type || p.day_type) === 'ovulation')
      .map(serializePredictionRow)
      .sort((a, b) => a.date.localeCompare(b.date))[0];

  const confRow =
    dayPredictions.find((p) => p.prediction_type === 'ovulation') ||
    dayPredictions[0] ||
    primaryPredicted.find((p) => p.date === date);
  const nextPeriodPred = predictions
    .filter(
      (p) =>
        (p.prediction_type || p.day_type) === 'period' &&
        (p.period_day == null || Number(p.period_day) === 1) &&
        toDateString(p.pred_date) >= date,
    )
    .sort((a, b) =>
      toDateString(a.pred_date).localeCompare(toDateString(b.pred_date)),
    )[0];

  const confidenceLabel =
    confRow?.confidence || nextPeriodPred?.confidence || null;
  const softLabel = confidenceLabel
    ? confidenceService.softConfidenceLabel(
        confidenceLabel,
        predictions.length > 0 ? 3 : loggedDates.length > 0 ? 1 : 0,
        ovPred?.evidence_level || confRow?.evidence_level,
      )
    : null;

  let insights = [];
  let observations = [];
  if (!pregnancyService.isPregnancyActive(profile)) {
    try {
      observations = await observationService.collectObservations(userId);
    } catch (_) {
      observations = [];
    }
    const ovDate = ovPred?.date || null;
    insights = insightService.buildPersonalInsights({
      observations,
      lastPeriodStart,
      C: profile?.avg_cycle_length || flo.DEFAULT_C,
      L: profile?.luteal_phase_days || flo.DEFAULT_L,
      ovulationDate: ovDate,
    });
  }

  const ovRaw = predictions.find(
    (p) =>
      (p.prediction_type || p.day_type) === 'ovulation' &&
      toDateString(p.pred_date) === (ovPred?.date || ''),
  );
  const evidenceLevelForStatus =
    ovPred?.evidence_level || ovRaw?.evidence_level || null;
  const estimateStatus =
    ovRaw?.estimate_status ||
    (evidenceLevelForStatus === 'D'
      ? 'retrospective_estimate'
      : evidenceLevelForStatus === 'C'
        ? 'updated_estimate'
        : evidenceLevelForStatus
          ? 'forecast'
          : null);

  let dailyInsights = null;
  if (pregnancyService.isPregnancyActive(profile)) {
    try {
      dailyInsights = await pregnancyInsightsService.buildDailyInsights({
        userId,
        date,
        pregnancyWeeks: summary.pregnancy_weeks,
        pregnancyDays: summary.pregnancy_days,
      });
    } catch (_) {
      dailyInsights = null;
    }
  }

  return {
    ...summary,
    algorithm_version: ALGORITHM_VERSION,
    confidence: confidenceLabel,
    soft_confidence_label: softLabel,
    confidence_means: 'timing_estimate',
    estimate_status: estimateStatus,
    evidence_level:
      ovPred?.evidence_level ||
      confRow?.evidence_level ||
      nextPeriodPred?.evidence_level ||
      (loggedDates.length ? 'A' : null),
    evidence_sources:
      ovPred?.evidence_sources ||
      confRow?.evidence_sources ||
      null,
    range_start: confRow?.range_start
      ? toDateString(confRow.range_start)
      : nextPeriodPred?.range_start
        ? toDateString(nextPeriodPred.range_start)
        : null,
    range_end: confRow?.range_end
      ? toDateString(confRow.range_end)
      : nextPeriodPred?.range_end
        ? toDateString(nextPeriodPred.range_end)
        : null,
    insights,
    daily_insights: dailyInsights,
    edd_source: dating.edd_source,
    edd_source_label: pregnancyService.eddSourceLabel(dating.edd_source),
    predictions_for_date: dayPredictions,
    profile: profilePayload(profile, lastPeriodStart),
  };
}

/**
 * GET /cycle/calendar?from=&to=
 * Merges logged periods (observations) + predictions for the range.
 */
async function getCalendar(userId, query = {}) {
  const from =
    toDateString(query.from) ||
    `${new Date().getUTCFullYear()}-01-01`;
  const to =
    toDateString(query.to) ||
    `${new Date().getUTCFullYear()}-12-31`;

  await profileRepository.ensureExists(userId);
  let profile = await profileRepository.findByUserId(userId);

  const periodRows = await periodRepository.listByUserId(userId, from, to);
  let predictions = await predictionRepository.listByUserId(userId, from, to);

  const allLogged = await periodRepository.listByUserId(userId);
  const loggedAllDates = allLogged
    .filter((r) => !r.is_predicted)
    .map((r) => toDateString(r.log_date))
    .filter(Boolean);

  if (loggedAllDates.length > 0 && !pregnancyService.isPregnancyActive(profile)) {
    const hasFertileOrOv = predictions.some(
      (r) =>
        r.day_type === 'fertility' ||
        r.day_type === 'ovulation' ||
        r.prediction_type === 'fertility' ||
        r.prediction_type === 'ovulation',
    );
    if (predictions.length === 0 || !hasFertileOrOv) {
      await rebuildPredictions(userId);
      profile = await profileRepository.findByUserId(userId);
      predictions = await predictionRepository.listByUserId(userId, from, to);
    }
  }

  const loggedSet = new Set(
    periodRows
      .filter((r) => !r.is_predicted)
      .map((r) => toDateString(r.log_date)),
  );

  const days = [];

  // Truth: observations win
  for (const row of periodRows.filter((r) => !r.is_predicted)) {
    const date = toDateString(row.log_date);
    days.push({
      date,
      day_type: 'period',
      is_predicted: false,
      is_observation: true,
      period_day: null,
    });
  }

  if (!pregnancyService.isPregnancyActive(profile)) {
    const primary = predictionService.primaryDayTypeByDate(
      predictions.map((p) => ({
        date: toDateString(p.pred_date),
        predictionType: p.prediction_type || p.day_type,
        dayType: p.day_type || p.prediction_type,
        periodDay: p.period_day,
        rangeStart: p.range_start,
        rangeEnd: p.range_end,
        confidence: p.confidence,
        evidenceLevel: p.evidence_level,
        algorithm_version: p.algorithm_version,
      })),
    );

    for (const p of primary) {
      if (loggedSet.has(p.date)) continue;
      days.push({
        date: p.date,
        day_type: p.day_type,
        prediction_type: p.prediction_type,
        is_predicted: true,
        is_observation: false,
        period_day: p.period_day,
        range_start: p.range_start,
        range_end: p.range_end,
        confidence: p.confidence,
        evidence_level: p.evidence_level,
      });
    }
  }

  days.sort((a, b) => a.date.localeCompare(b.date));

  const runs = flo.groupBleedRuns(loggedAllDates);

  return {
    from,
    to,
    days,
    last_period_start: runs.length ? runs[runs.length - 1].start : null,
    profile: profilePayload(
      profile,
      runs.length ? runs[runs.length - 1].start : null,
    ),
    algorithm_version: ALGORITHM_VERSION,
    // Full typed rows for clients that want envelopes (Flutter can ignore)
    prediction_rows: predictions.map(serializePredictionRow),
  };
}

/**
 * GET /cycle/insights — safe personal symptom-timing patterns (Phase 4).
 */
async function getInsights(userId) {
  await profileRepository.ensureExists(userId);
  const profile = await profileRepository.findByUserId(userId);

  if (pregnancyService.isPregnancyActive(profile)) {
    return {
      insights: [],
      pregnancy_mode: true,
      note: 'Cycle insights pause while pregnancy mode is on.',
    };
  }

  const periodRows = await periodRepository.listByUserId(userId);
  const loggedDates = periodRows
    .filter((r) => !r.is_predicted)
    .map((r) => toDateString(r.log_date))
    .filter(Boolean)
    .sort();
  const runs = flo.groupBleedRuns(loggedDates);
  const lastPeriodStart = runs.length ? runs[runs.length - 1].start : null;

  let observations = [];
  try {
    observations = await observationService.collectObservations(userId);
  } catch (_) {
    observations = [];
  }

  const insights = insightService.buildPersonalInsights({
    observations,
    lastPeriodStart,
    C: profile?.avg_cycle_length || flo.DEFAULT_C,
    L: profile?.luteal_phase_days || flo.DEFAULT_L,
  });

  return {
    insights,
    pregnancy_mode: false,
    algorithm_version: ALGORITHM_VERSION,
  };
}

module.exports = {
  putPeriodDays,
  getPeriodDays,
  rebuildPredictions,
  fullRebuild,
  todayUpdate,
  getToday,
  getCalendar,
  getInsights,
  normalizePeriodDates,
  ALGORITHM_VERSION,
};
