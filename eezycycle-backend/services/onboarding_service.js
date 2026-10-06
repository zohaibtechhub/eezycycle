const { createError, ErrorCodes } = require('../utils/error');
const {
  normalizeFlowKey,
  normalizeGoalKey,
  normalizeExperienceMode,
  normalizeUsagePath,
} = require('../utils/normalize');
const profileRepository = require('../repositories/profile_repository');
const goalRepository = require('../repositories/goal_repository');
const onboardingAnswerRepository = require('../repositories/onboarding_answer_repository');
const reminderRepository = require('../repositories/reminder_repository');
const cycleService = require('./cycle_service');
const { serializeProfile } = require('./me_service');

function parseAnswerValues(raw) {
  if (Array.isArray(raw)) return raw.map(String);
  if (typeof raw === 'string') {
    try {
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed.map(String) : [String(raw)];
    } catch {
      return [raw];
    }
  }
  return [];
}

/**
 * PUT /onboarding/answers — bulk upsert step answers.
 * Body: { flow_key, answers: { stepId: [optionIds] } } or answers: [{ step_id, values }]
 * @param {number} userId
 * @param {Record<string, unknown>} body
 */
async function upsertAnswers(userId, body) {
  const flowKey = normalizeFlowKey(body.flow_key || body.flowKey || body.flow);
  if (!flowKey) {
    throw createError('flow_key is required.', 400, ErrorCodes.VALIDATION);
  }

  let answers = [];

  if (body.answers && !Array.isArray(body.answers) && typeof body.answers === 'object') {
    answers = Object.entries(body.answers).map(([stepId, values]) => ({
      stepId: String(stepId).slice(0, 64),
      answerValues: Array.isArray(values) ? values.map(String) : [String(values)],
    }));
  } else if (Array.isArray(body.answers)) {
    answers = body.answers.map((item) => ({
      stepId: String(item.step_id || item.stepId || '').slice(0, 64),
      answerValues: Array.isArray(item.values || item.answer_values || item.answerValues)
        ? (item.values || item.answer_values || item.answerValues).map(String)
        : [],
    }));
  }

  answers = answers.filter((a) => a.stepId && a.answerValues.length > 0);

  if (answers.length === 0) {
    throw createError('At least one answer is required.', 400, ErrorCodes.VALIDATION);
  }

  await onboardingAnswerRepository.upsertMany(userId, flowKey, answers);

  const rows = await onboardingAnswerRepository.listByUserId(userId, flowKey);
  return {
    flow_key: flowKey,
    answers: rows.map((r) => ({
      step_id: r.step_id,
      values: parseAnswerValues(r.answer_values),
    })),
  };
}

/**
 * PUT /onboarding/goals — replace goal set.
 * @param {number} userId
 * @param {Record<string, unknown>} body
 */
async function replaceGoals(userId, body) {
  const rawGoals = body.goals || body.goal_keys || body.goalKeys;
  if (!Array.isArray(rawGoals) || rawGoals.length === 0) {
    throw createError('goals array is required.', 400, ErrorCodes.VALIDATION);
  }

  const goalKeys = [
    ...new Set(
      rawGoals
        .map((g) => normalizeGoalKey(g))
        .filter(Boolean),
    ),
  ];

  if (goalKeys.length === 0) {
    throw createError('No valid goals provided.', 400, ErrorCodes.VALIDATION);
  }

  await goalRepository.replaceAll(userId, goalKeys);
  const goals = await goalRepository.listByUserId(userId);
  return { goals: goals.map((g) => g.goal_key) };
}

/**
 * POST /onboarding/complete — finalize onboarding profile + reminders.
 * Period days / Flo predictions are intentionally out of scope for this slice.
 * @param {number} userId
 * @param {Record<string, unknown>} body
 */
async function completeOnboarding(userId, body) {
  await profileRepository.ensureExists(userId);

  const fields = {
    onboarding_completed_at: new Date(),
  };

  if (body.experience_mode !== undefined || body.experienceMode !== undefined) {
    const mode = normalizeExperienceMode(body.experience_mode || body.experienceMode);
    if (!mode) {
      throw createError('Invalid experience_mode.', 400, ErrorCodes.VALIDATION);
    }
    fields.experience_mode = mode;
    // Completing onboarding into cycle / conceive / peri must leave pregnancy mode
    if (mode !== 'track_pregnancy') {
      fields.pregnancy_mode_active = 0;
    }
  }

  if (body.usage_path !== undefined || body.usagePath !== undefined || body.usage !== undefined) {
    const path = normalizeUsagePath(body.usage_path || body.usagePath || body.usage);
    if (!path) {
      throw createError('Invalid usage_path.', 400, ErrorCodes.VALIDATION);
    }
    fields.usage_path = path;
  }

  if (body.discovery_source !== undefined || body.discoverySource !== undefined) {
    const source = body.discovery_source || body.discoverySource;
    fields.discovery_source = source ? String(source).slice(0, 64) : null;
  }

  if (body.birth_year !== undefined || body.birthYear !== undefined) {
    const year = Number(body.birth_year ?? body.birthYear);
    const currentYear = new Date().getFullYear();
    if (!Number.isInteger(year) || year < currentYear - 90 || year > currentYear - 13) {
      throw createError('Birth year must be for ages 13–90.', 400, ErrorCodes.VALIDATION);
    }
    fields.birth_year = year;
  }

  if (body.height_cm !== undefined || body.heightCm !== undefined) {
    fields.height_cm = Number(body.height_cm ?? body.heightCm);
  }

  if (body.weight_kg !== undefined || body.weightKg !== undefined) {
    fields.weight_kg = Number(body.weight_kg ?? body.weightKg);
  }

  if (body.is_metric !== undefined || body.isMetric !== undefined) {
    fields.is_metric = (body.is_metric ?? body.isMetric) ? 1 : 0;
  }

  if (body.partner_code_entered !== undefined || body.partnerCode !== undefined) {
    const code = body.partner_code_entered || body.partnerCode;
    fields.partner_code_entered = code ? String(code).slice(0, 16) : null;
  }

  if (body.timezone !== undefined) {
    fields.timezone = body.timezone ? String(body.timezone).slice(0, 64) : null;
  }

  // Optional: persist Q&A in the same request
  if (body.flow_key || body.flowKey || body.flow) {
    if (body.answers) {
      await upsertAnswers(userId, body);
    }
  }

  // Optional: goals in the same request
  if (Array.isArray(body.goals) && body.goals.length > 0) {
    await replaceGoals(userId, body);
  }

  const profile = await profileRepository.update(userId, fields);

  let reminders = null;
  if (body.reminders && typeof body.reminders === 'object') {
    reminders = await reminderRepository.upsert(userId, {
      fertileDaysEnabled: Boolean(
        body.reminders.fertile_days_enabled ?? body.reminders.fertileDaysEnabled,
      ),
      pregnancyTestEnabled: Boolean(
        body.reminders.pregnancy_test_enabled ?? body.reminders.pregnancyTestEnabled,
      ),
      dailyTipsEnabled:
        body.reminders.daily_tips_enabled ?? body.reminders.dailyTipsEnabled ?? true,
      periodReminderEnabled: Boolean(
        body.reminders.period_reminder_enabled ?? body.reminders.periodReminderEnabled,
      ),
    });
  }

  const periodInput =
    body.last_period_dates ||
    body.lastPeriodDates ||
    body.period_dates ||
    body.periodDates ||
    body.dates;

  let periods = null;
  if (Array.isArray(periodInput) && periodInput.length > 0) {
    periods = await cycleService.putPeriodDays(userId, { dates: periodInput });
  } else {
    // Periods may already be saved step-by-step — still rebuild Flo predictions
    await cycleService.rebuildPredictions(userId);
  }

  const goals = await goalRepository.listByUserId(userId);

  // Event-driven push replan after onboarding + prediction rebuild
  try {
    const notificationPlanner = require('./notification_planner_service');
    notificationPlanner.rebuildSafe(userId, { reason: 'onboarding_complete' });
  } catch (_) {
    /* non-fatal */
  }

  return {
    profile: serializeProfile(profile),
    goals: goals.map((g) => g.goal_key),
    reminders: reminders
      ? {
          fertile_days_enabled: Boolean(reminders.fertile_days_enabled),
          pregnancy_test_enabled: Boolean(reminders.pregnancy_test_enabled),
          daily_tips_enabled: Boolean(reminders.daily_tips_enabled),
          period_reminder_enabled: Boolean(reminders.period_reminder_enabled),
          quiet_hours_start: reminders.quiet_hours_start || null,
          quiet_hours_end: reminders.quiet_hours_end || null,
          timezone: reminders.timezone || null,
        }
      : null,
    periods_seeded: Boolean(periods),
    periods,
  };
}

/**
 * @param {number} userId
 * @param {string} [flowKey]
 */
async function getOnboardingState(userId, flowKey) {
  const normalized = flowKey ? normalizeFlowKey(flowKey) : null;
  const [profile, goals, answers, reminders] = await Promise.all([
    profileRepository.findByUserId(userId),
    goalRepository.listByUserId(userId),
    onboardingAnswerRepository.listByUserId(userId, normalized || undefined),
    reminderRepository.findByUserId(userId),
  ]);

  return {
    profile: serializeProfile(profile),
    goals: goals.map((g) => g.goal_key),
    answers: answers.map((r) => ({
      flow_key: r.flow_key,
      step_id: r.step_id,
      values: parseAnswerValues(r.answer_values),
    })),
    reminders: reminders
      ? {
          fertile_days_enabled: Boolean(reminders.fertile_days_enabled),
          pregnancy_test_enabled: Boolean(reminders.pregnancy_test_enabled),
          daily_tips_enabled: Boolean(reminders.daily_tips_enabled),
          period_reminder_enabled: Boolean(reminders.period_reminder_enabled),
        }
      : null,
  };
}

module.exports = {
  upsertAnswers,
  replaceGoals,
  completeOnboarding,
  getOnboardingState,
};
