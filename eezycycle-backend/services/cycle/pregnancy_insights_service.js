const pregnancyInsightsRepository = require('../../repositories/pregnancy_insights_repository');
const dailyLogRepository = require('../../repositories/daily_log_repository');
const { toDateString } = require('../../utils/date');

/**
 * Build Flo-style daily_insights payload for pregnancy Home.
 *
 * @param {{
 *   userId: number,
 *   date: string,
 *   pregnancyWeeks: number|null,
 *   pregnancyDays: number|null,
 * }} input
 */
async function buildDailyInsights(input) {
  const date = toDateString(input.date) || new Date().toISOString().slice(0, 10);
  const weeks = Math.max(0, Number(input.pregnancyWeeks) || 0);
  // Content catalog is keyed 1–40; treat week 0 as week 1 for early pregnancy.
  const contentWeek = Math.max(1, Math.min(40, weeks || 1));
  const dayInWeek =
    input.pregnancyDays == null ? null : Number(input.pregnancyDays);

  const entry = await pregnancyInsightsRepository.findForWeek(
    contentWeek,
    dayInWeek,
  );
  if (!entry) return null;

  let loggedKeys = [];
  try {
    const log = await dailyLogRepository.findLogByUserAndDate(
      input.userId,
      date,
    );
    if (log) {
      const items = await dailyLogRepository.listItems(log.id);
      loggedKeys = items
        .filter((i) => i.category === 'symptoms' || i.category === 'Symptoms')
        .map((i) => i.item_key)
        .filter(Boolean);
    }
  } catch (_) {
    loggedKeys = [];
  }

  const common = entry.symptoms?.common_keys || [];
  const cards = [
    {
      type: 'baby',
      week: entry.week,
      title: entry.baby.title,
      short_summary: entry.baby.short_summary,
      size_label: entry.baby.size_label,
      size_asset: entry.baby.size_asset,
      illustration_asset: entry.baby.illustration_asset,
      detail_available: true,
    },
    {
      type: 'body',
      week: entry.week,
      title: entry.body.title,
      short_summary: entry.body.short_summary,
      illustration_asset: entry.body.illustration_asset,
      detail_available: true,
    },
    {
      type: 'symptoms',
      week: entry.week,
      title: entry.symptoms.title || 'Symptoms',
      common_keys: common,
      logged_keys: loggedKeys.filter((k) => k.startsWith('sym_')),
      tip: entry.symptoms.tip,
    },
  ];

  const expect = entry.what_to_expect || {
    week: entry.week,
    title: `What to expect at ${entry.week} weeks`,
    items: [],
  };

  return {
    date,
    section_title: 'My daily insights',
    week: entry.week,
    day_in_week: dayInWeek,
    cards,
    stories: entry.stories || [],
    what_to_expect: expect,
    baby_detail: entry.baby,
    body_detail: entry.body,
    disclaimer:
      'Educational only — not a diagnosis or ultrasound substitute.',
  };
}

module.exports = {
  buildDailyInsights,
};
