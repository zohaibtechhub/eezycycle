const { createError, ErrorCodes } = require('../utils/error');
const { toDateString } = require('../utils/date');
const dailyLogRepository = require('../repositories/daily_log_repository');
const observationService = require('./cycle/observation_service');
const predictionRebuildService = require('./cycle/prediction_rebuild_service');

const INTIMATE_PREFIXES = ['sex_', 'ov_', 'preg_'];

function categoryFromItemKey(key) {
  if (key.startsWith('sex_')) return 'sex';
  if (key.startsWith('mood_')) return 'mood';
  if (key.startsWith('sym_')) return 'symptoms';
  if (key.startsWith('ov_')) return 'ovulation_test';
  if (key.startsWith('preg_')) return 'pregnancy_test';
  if (key.startsWith('mucus_')) return 'cervical_mucus';
  if (key.startsWith('bbt_')) return 'bbt';
  if (key.startsWith('dig_')) return 'digestion';
  if (key.startsWith('act_')) return 'activity';
  if (key.startsWith('oth_')) return 'other';
  return 'other';
}

function sensitivityForKey(key) {
  return INTIMATE_PREFIXES.some((p) => key.startsWith(p))
    ? 'intimate'
    : 'standard';
}

function normalizeItemKeys(raw) {
  const list = Array.isArray(raw)
    ? raw
    : Array.isArray(raw?.item_keys)
      ? raw.item_keys
      : Array.isArray(raw?.itemKeys)
        ? raw.itemKeys
        : [];

  const set = new Set();
  for (const item of list) {
    const key =
      typeof item === 'string'
        ? item.trim()
        : String(item?.item_key || item?.itemKey || item?.id || '').trim();
    if (!key || key.length > 64) continue;
    set.add(key);
  }
  return [...set];
}

function parseBbtCelsius(body) {
  const raw =
    body?.bbt_celsius ?? body?.bbtCelsius ?? body?.bbt ?? body?.temperature;
  if (raw == null || raw === '') return null;
  const n = Number(raw);
  if (!Number.isFinite(n) || n < 34 || n > 42) return null;
  return n;
}

/**
 * GET /logs?date=
 */
async function getLogs(userId, query = {}) {
  const date = toDateString(query.date);
  if (!date) {
    throw createError('date (YYYY-MM-DD) is required.', 400, ErrorCodes.VALIDATION);
  }

  const log = await dailyLogRepository.findLogByUserAndDate(userId, date);
  if (!log) {
    return { date, item_keys: [], items: [] };
  }

  const rows = await dailyLogRepository.listItems(log.id);
  return {
    date,
    item_keys: rows.map((r) => r.item_key),
    items: rows.map((r) => ({
      item_key: r.item_key,
      category: r.category,
      sensitivity: r.sensitivity,
    })),
  };
}

/**
 * PUT /logs/:date
 * Body: { item_keys: string[], bbt_celsius?: number }
 *
 * Mirrors OPK / mucus / symptoms / BBT into cycle_observations and runs
 * TODAY UPDATE when biomarkers change (Phase 3).
 */
async function putLogs(userId, dateParam, body = {}) {
  const date = toDateString(dateParam) || toDateString(body.date);
  if (!date) {
    throw createError('date (YYYY-MM-DD) is required.', 400, ErrorCodes.VALIDATION);
  }

  const today = toDateString(new Date());
  if (today && date > today) {
    throw createError(
      'You can only log for today or past days.',
      400,
      ErrorCodes.VALIDATION,
    );
  }

  const keys = normalizeItemKeys(body);
  const items = keys.map((itemKey) => ({
    itemKey,
    category: categoryFromItemKey(itemKey),
    sensitivity: sensitivityForKey(itemKey),
  }));

  const log = await dailyLogRepository.ensureLog(userId, date);
  await dailyLogRepository.replaceItems(log.id, items);

  const bbtCelsius = parseBbtCelsius(body);
  let sync = { biomarkerChanged: false, types: [] };
  try {
    sync = await observationService.syncFromDailyLogKeys(userId, date, keys, {
      bbtCelsius,
    });
  } catch (_) {
    // cycle_observations may not exist until migration 014
  }

  let rebuild = null;
  if (sync.biomarkerChanged || bbtCelsius != null) {
    try {
      rebuild = await predictionRebuildService.todayUpdate(userId, { date });
    } catch (_) {
      /* predictions optional if schema not migrated */
    }
  }

  const payload = await getLogs(userId, { date });
  return {
    ...payload,
    bbt_celsius: bbtCelsius,
    observation_sync: sync,
    rebuild,
  };
}

module.exports = {
  getLogs,
  putLogs,
};
