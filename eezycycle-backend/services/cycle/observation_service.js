const observationRepository = require('../../repositories/observation_repository');
const { toDateString } = require('../../utils/date');
const { OBSERVATION_TYPES } = require('./constants');
const { createError, ErrorCodes } = require('../../utils/error');

const OPK_KEY_MAP = {
  ov_positive: 'positive',
  ov_negative: 'negative',
  ov_faint: 'faint',
};

const PREG_KEY_MAP = {
  preg_positive: 'positive',
  preg_negative: 'negative',
  preg_faint: 'faint',
};

const MUCUS_KEY_MAP = {
  mucus_dry: 'dry',
  mucus_sticky: 'sticky',
  mucus_creamy: 'creamy',
  mucus_watery: 'watery',
  mucus_egg_white: 'egg_white',
};

function parseValueJson(raw) {
  if (raw == null) return null;
  if (typeof raw === 'object') return raw;
  try {
    return JSON.parse(raw);
  } catch (_) {
    return { raw };
  }
}

/**
 * Sync logged period dates into the observation truth table.
 * @param {number} userId
 * @param {string[]} dates
 */
async function syncPeriodObservations(userId, dates) {
  const cleaned = [
    ...new Set((dates || []).map((d) => toDateString(d)).filter(Boolean)),
  ].sort();
  await observationRepository.replacePeriodObservations(userId, cleaned);
  return cleaned;
}

/**
 * @param {number} userId
 */
async function listPeriodObservationDates(userId) {
  const rows = await observationRepository.listByUserId(userId, 'period');
  return rows.map((r) => toDateString(r.obs_date)).filter(Boolean);
}

/**
 * Collect all observations for the engine.
 * @param {number} userId
 * @param {{ from?: string, to?: string }} [range]
 */
async function collectObservations(userId, range = {}) {
  const rows = await observationRepository.listByUserId(userId, null, range);
  return rows.map((r) => ({
    date: toDateString(r.obs_date),
    type: r.observation_type,
    value: parseValueJson(r.value_json),
    source: r.source,
  }));
}

/**
 * Upsert one or more observations for a date.
 * @param {number} userId
 * @param {{
 *   date: string,
 *   observations?: Array<{ type: string, value?: object, source?: string }>,
 *   type?: string,
 *   value?: object,
 *   source?: string,
 * }} body
 */
async function upsertObservations(userId, body = {}) {
  const date = toDateString(body.date);
  if (!date) {
    throw createError('date (YYYY-MM-DD) is required.', 400, ErrorCodes.VALIDATION);
  }

  let list = Array.isArray(body.observations) ? body.observations : null;
  if (!list && body.type) {
    list = [{ type: body.type, value: body.value, source: body.source }];
  }
  if (!list || list.length === 0) {
    throw createError(
      'observations array or type is required.',
      400,
      ErrorCodes.VALIDATION,
    );
  }

  const saved = [];
  for (const item of list) {
    const type = String(item.type || '').trim();
    if (!OBSERVATION_TYPES.includes(type)) {
      throw createError(
        `Invalid observation type: ${type}`,
        400,
        ErrorCodes.VALIDATION,
      );
    }
    if (type === 'period') {
      throw createError(
        'Use period-days API for period observations.',
        400,
        ErrorCodes.VALIDATION,
      );
    }
    await observationRepository.upsert(userId, {
      date,
      type,
      value: item.value ?? null,
      source: item.source || 'user',
    });
    saved.push({ date, type, value: item.value ?? null });
  }

  return { date, observations: saved };
}

/**
 * Delete one observation.
 * @param {number} userId
 * @param {string} date
 * @param {string} type
 */
async function deleteObservation(userId, date, type) {
  const d = toDateString(date);
  if (!d || !OBSERVATION_TYPES.includes(type) || type === 'period') {
    throw createError('Valid date and non-period type required.', 400, ErrorCodes.VALIDATION);
  }
  await observationRepository.deleteOne(userId, d, type);
  return { deleted: true, date: d, type };
}

/**
 * Mirror daily-log item keys (+ optional BBT) into cycle_observations for one date.
 * Symptoms are stored for insights only — never used to set ovulation.
 *
 * @param {number} userId
 * @param {string} date
 * @param {string[]} itemKeys
 * @param {{ bbtCelsius?: number|null }} [extras]
 * @returns {{ biomarkerChanged: boolean, types: string[] }}
 */
async function syncFromDailyLogKeys(userId, date, itemKeys, extras = {}) {
  const d = toDateString(date);
  if (!d) return { biomarkerChanged: false, types: [] };

  const keys = Array.isArray(itemKeys) ? itemKeys : [];
  const changedTypes = [];

  // --- OPK / LH ---
  const opkKey = keys.find((k) => OPK_KEY_MAP[k]);
  if (opkKey) {
    await observationRepository.upsert(userId, {
      date: d,
      type: 'ovulation_test',
      value: { result: OPK_KEY_MAP[opkKey], item_key: opkKey },
      source: 'daily_log',
    });
    changedTypes.push('ovulation_test');
  } else {
    await observationRepository.deleteOne(userId, d, 'ovulation_test');
  }

  // --- Pregnancy test (stored; Phase 4 may use) ---
  const pregKey = keys.find((k) => PREG_KEY_MAP[k]);
  if (pregKey) {
    await observationRepository.upsert(userId, {
      date: d,
      type: 'pregnancy_test',
      value: { result: PREG_KEY_MAP[pregKey], item_key: pregKey },
      source: 'daily_log',
    });
    changedTypes.push('pregnancy_test');
  } else {
    await observationRepository.deleteOne(userId, d, 'pregnancy_test');
  }

  // --- Cervical mucus ---
  const mucusKey = keys.find((k) => MUCUS_KEY_MAP[k]);
  if (mucusKey) {
    await observationRepository.upsert(userId, {
      date: d,
      type: 'cervical_mucus',
      value: { quality: MUCUS_KEY_MAP[mucusKey], item_key: mucusKey },
      source: 'daily_log',
    });
    changedTypes.push('cervical_mucus');
  } else {
    await observationRepository.deleteOne(userId, d, 'cervical_mucus');
  }

  // --- Symptoms (insights only) ---
  const symptomKeys = keys.filter((k) => k.startsWith('sym_'));
  if (symptomKeys.length > 0) {
    await observationRepository.upsert(userId, {
      date: d,
      type: 'symptom',
      value: { keys: symptomKeys },
      source: 'daily_log',
    });
    // Not a biomarker for ovulation shift
  } else {
    await observationRepository.deleteOne(userId, d, 'symptom');
  }

  // --- BBT ---
  const bbt =
    extras.bbtCelsius != null
      ? Number(extras.bbtCelsius)
      : extras.bbt != null
        ? Number(extras.bbt)
        : null;
  if (bbt != null && Number.isFinite(bbt) && bbt >= 34 && bbt <= 42) {
    await observationRepository.upsert(userId, {
      date: d,
      type: 'bbt',
      value: { celsius: Math.round(bbt * 100) / 100 },
      source: extras.bbtSource || 'daily_log',
    });
    changedTypes.push('bbt');
  }

  const biomarkerChanged = changedTypes.some((t) =>
    ['ovulation_test', 'bbt', 'cervical_mucus'].includes(t),
  );

  return { biomarkerChanged, types: changedTypes };
}

module.exports = {
  syncPeriodObservations,
  listPeriodObservationDates,
  collectObservations,
  upsertObservations,
  deleteObservation,
  syncFromDailyLogKeys,
  OPK_KEY_MAP,
  MUCUS_KEY_MAP,
  PREG_KEY_MAP,
};
