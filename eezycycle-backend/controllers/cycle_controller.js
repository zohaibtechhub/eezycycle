const cycleService = require('../services/cycle_service');
const observationService = require('../services/cycle/observation_service');
const { asyncHandler } = require('../utils/async_handler');

const putPeriodDays = asyncHandler(async (req, res) => {
  const data = await cycleService.putPeriodDays(req.userId, req.body);
  res.json({ success: true, message: 'Period days saved', data });
});

const getPeriodDays = asyncHandler(async (req, res) => {
  const data = await cycleService.getPeriodDays(req.userId, req.query);
  res.json({ success: true, data });
});

const getToday = asyncHandler(async (req, res) => {
  const data = await cycleService.getToday(req.userId, req.query);
  res.json({ success: true, data });
});

const getCalendar = asyncHandler(async (req, res) => {
  const data = await cycleService.getCalendar(req.userId, req.query);
  res.json({ success: true, data });
});

const rebuildPredictions = asyncHandler(async (req, res) => {
  const data = await cycleService.rebuildPredictions(req.userId, {
    mode: req.body?.mode || req.query?.mode || 'full',
    date: req.body?.date || req.query?.date,
    horizonDays: req.body?.horizon_days || req.body?.horizonDays,
  });
  const mode = data?.rebuild_mode || 'full';
  res.json({
    success: true,
    message:
      mode === 'today'
        ? 'Predictions updated (today)'
        : 'Predictions rebuilt',
    data,
  });
});

/**
 * PUT /cycle/observations
 * Body: { date, observations: [{ type, value }], bbt_celsius? }
 * Also accepts single { date, type, value }.
 */
const putObservations = asyncHandler(async (req, res) => {
  const body = { ...req.body };
  if (body.bbt_celsius != null || body.bbtCelsius != null) {
    const celsius = Number(body.bbt_celsius ?? body.bbtCelsius);
    const list = Array.isArray(body.observations) ? [...body.observations] : [];
    list.push({ type: 'bbt', value: { celsius } });
    body.observations = list;
  }

  const data = await observationService.upsertObservations(req.userId, body);

  let rebuild = null;
  const biomarker = (data.observations || []).some((o) =>
    ['ovulation_test', 'bbt', 'cervical_mucus'].includes(o.type),
  );
  if (biomarker) {
    rebuild = await cycleService.todayUpdate(req.userId, { date: data.date });
  }

  res.json({
    success: true,
    message: 'Observations saved',
    data: { ...data, rebuild },
  });
});

/**
 * GET /cycle/observations?from=&to=&type=
 */
const getObservations = asyncHandler(async (req, res) => {
  const observations = await observationService.collectObservations(
    req.userId,
    {
      from: req.query.from,
      to: req.query.to,
    },
  );
  const type = req.query.type;
  const filtered = type
    ? observations.filter((o) => o.type === type)
    : observations;
  res.json({ success: true, data: { observations: filtered } });
});

/**
 * DELETE /cycle/observations?date=&type=
 */
const deleteObservation = asyncHandler(async (req, res) => {
  const data = await observationService.deleteObservation(
    req.userId,
    req.query.date || req.body?.date,
    req.query.type || req.body?.type,
  );
  const biomarker = ['ovulation_test', 'bbt', 'cervical_mucus'].includes(
    data.type,
  );
  let rebuild = null;
  if (biomarker) {
    rebuild = await cycleService.todayUpdate(req.userId, { date: data.date });
  }
  res.json({
    success: true,
    message: 'Observation deleted',
    data: { ...data, rebuild },
  });
});

const getInsights = asyncHandler(async (req, res) => {
  const data = await cycleService.getInsights(req.userId);
  res.json({ success: true, data });
});

module.exports = {
  putPeriodDays,
  getPeriodDays,
  getToday,
  getCalendar,
  rebuildPredictions,
  putObservations,
  getObservations,
  deleteObservation,
  getInsights,
};
