/**
 * Evidence processor (v4.1).
 *
 * Evidence layers (not a universal D > C > B > A ranking):
 *   A = baseline calendar prior (next_period − L)
 *   B = historical personal luteal evidence
 *   C = current-cycle LH / OPK evidence (shifts estimate; does NOT confirm exact day)
 *   D = current-cycle BBT pattern (retrospective narrowing; does NOT confirm exact day)
 *
 * Symptoms never set ovulation. Cervical mucus is supporting only.
 */

const flo = require('../flo_calendar_service');
const { ESTIMATE_STATUS } = require('./constants');

function parseObsValue(value) {
  if (value == null) return null;
  if (typeof value === 'object') return value;
  try {
    return JSON.parse(value);
  } catch (_) {
    return null;
  }
}

function obsOfType(observations, type) {
  return (observations || []).filter((o) => o.type === type);
}

function opkResult(obs) {
  const v = parseObsValue(obs.value);
  return String(v?.result || '').toLowerCase();
}

function bbtCelsius(obs) {
  const v = parseObsValue(obs.value);
  const n = Number(v?.celsius ?? v?.temp ?? v?.temperature);
  return Number.isFinite(n) ? n : null;
}

function mucusQuality(obs) {
  const v = parseObsValue(obs.value);
  return String(v?.quality || '').toLowerCase();
}

function clampInCycle(ov, lastPeriodStart, cycleEnd) {
  let d = ov;
  if (d <= lastPeriodStart) d = flo.addDays(lastPeriodStart, 1);
  if (d >= cycleEnd) d = flo.addDays(cycleEnd, -1);
  return d;
}

/**
 * Blend two dates toward a target (days).
 * @param {string} from
 * @param {string} toward
 * @param {number} weightToward 0..1
 */
function blendDates(from, toward, weightToward) {
  if (!from) return toward;
  if (!toward) return from;
  const delta = flo.diffDays(from, toward);
  const step = Math.round(delta * Math.min(1, Math.max(0, weightToward)));
  return flo.addDays(from, step);
}

/**
 * Level B: personal luteal from past positive OPK heuristics.
 * Uses T+1 only as a historical approximation for luteal length — not confirmed ovulation.
 */
function estimatePersonalLuteal(completed, observations) {
  const positives = obsOfType(observations, 'ovulation_test').filter(
    (o) => opkResult(o) === 'positive',
  );
  if (!completed?.length || !positives.length) {
    return { luteal_mean: null, samples: 0, sources: [] };
  }

  const luteals = [];
  for (let i = 0; i < completed.length; i++) {
    const start = completed[i].start;
    const nextStart = flo.addDays(start, completed[i].cycleLength);
    const inCycle = positives.filter(
      (o) => o.date > start && o.date < nextStart,
    );
    if (!inCycle.length) continue;
    inCycle.sort((a, b) => a.date.localeCompare(b.date));
    const T = inCycle[inCycle.length - 1].date;
    // Heuristic center of post-surge interval for historical L only
    const approxOv = flo.addDays(T, 1);
    const L = flo.diffDays(approxOv, nextStart);
    if (L >= 10 && L <= 16) luteals.push(L);
  }

  if (luteals.length < 2) {
    return {
      luteal_mean: luteals.length === 1 ? luteals[0] : null,
      samples: luteals.length,
      sources: luteals.length ? ['historical_opk_luteal'] : [],
    };
  }

  const mean = Math.round(
    luteals.reduce((s, n) => s + n, 0) / luteals.length,
  );
  return {
    luteal_mean: Math.min(16, Math.max(10, mean)),
    samples: luteals.length,
    sources: ['historical_opk_luteal'],
  };
}

/**
 * Level C: positive OPK shifts estimate toward the expected post-LH-surge
 * interval (approximately within the following 1–2 days after a positive test).
 * Does NOT set ovulation = T+1 as a confirmed fact, and does not imply
 * ovulation occurs on the same day as every positive OPK.
 *
 * Heuristic interval for updating: center near T+1, span about T … T+2,
 * blended with the prior estimate; uncertainty remains.
 */
function applyOpkUpdate(lastPeriodStart, C, observations, priorOvDate) {
  const cycleEnd = flo.addDays(lastPeriodStart, C);
  const positives = obsOfType(observations, 'ovulation_test').filter(
    (o) =>
      opkResult(o) === 'positive' &&
      o.date >= lastPeriodStart &&
      o.date < cycleEnd,
  );
  if (!positives.length) return null;

  positives.sort((a, b) => a.date.localeCompare(b.date));
  const T = positives[positives.length - 1].date;
  const surgeCenter = flo.addDays(T, 1);
  const surgeStart = T;
  const surgeEnd = flo.addDays(T, 2);

  // Pull prior toward surge center (~65%) — update, don't replace certainty
  let ov = blendDates(priorOvDate || surgeCenter, surgeCenter, 0.65);
  ov = clampInCycle(ov, lastPeriodStart, cycleEnd);

  // Soft clamp if wildly far from prior
  if (priorOvDate) {
    const delta = flo.diffDays(priorOvDate, ov);
    if (Math.abs(delta) > 7) {
      ov =
        delta > 0
          ? flo.addDays(priorOvDate, 7)
          : flo.addDays(priorOvDate, -7);
    }
  }

  return {
    date: ov,
    interval_start: surgeStart,
    interval_end: surgeEnd,
    layers: ['C'],
    sources: ['ovulation_test_lh'],
    opk_positive_date: T,
    estimate_status: ESTIMATE_STATUS.UPDATED,
    // Keep meaningful uncertainty — OPK is not exact ovulation
    min_uncertainty_days: 2,
  };
}

/**
 * Level D: sustained BBT rise → retrospective narrowing, not exact confirmation.
 */
function applyBbtUpdate(lastPeriodStart, C, observations, priorOvDate) {
  const cycleEnd = flo.addDays(lastPeriodStart, C);
  const readings = obsOfType(observations, 'bbt')
    .map((o) => ({ date: o.date, celsius: bbtCelsius(o) }))
    .filter(
      (r) =>
        r.celsius != null &&
        r.date >= lastPeriodStart &&
        r.date < cycleEnd,
    )
    .sort((a, b) => a.date.localeCompare(b.date));

  if (readings.length < 9) return null;

  for (let i = 6; i <= readings.length - 3; i++) {
    const baseline = readings.slice(i - 6, i);
    const mean =
      baseline.reduce((s, r) => s + r.celsius, 0) / baseline.length;
    const rise = readings.slice(i, i + 3);
    const sustained = rise.every((r) => r.celsius >= mean + 0.2);
    if (!sustained) continue;

    const riseStart = rise[0].date;
    const retrospectiveCenter = flo.addDays(riseStart, -1);
    // Blend prior with retrospective center — narrow, don't declare certainty
    let ov = blendDates(
      priorOvDate || retrospectiveCenter,
      retrospectiveCenter,
      0.7,
    );
    ov = clampInCycle(ov, lastPeriodStart, cycleEnd);

    if (priorOvDate) {
      const delta = flo.diffDays(priorOvDate, ov);
      if (Math.abs(delta) > 7) {
        ov =
          delta > 0
            ? flo.addDays(priorOvDate, 7)
            : flo.addDays(priorOvDate, -7);
      }
    }

    return {
      date: ov,
      interval_start: flo.addDays(retrospectiveCenter, -1),
      interval_end: flo.addDays(retrospectiveCenter, 1),
      layers: ['D'],
      sources: ['bbt_sustained_rise'],
      rise_start: riseStart,
      estimate_status: ESTIMATE_STATUS.RETROSPECTIVE,
      min_uncertainty_days: 1,
    };
  }

  return null;
}

function mucusSupport(observations, ovDate) {
  if (!ovDate) return { sources: [], near: false };
  const fertileQualities = new Set(['watery', 'egg_white']);
  const near = obsOfType(observations, 'cervical_mucus').some((o) => {
    const q = mucusQuality(o);
    if (!fertileQualities.has(q)) return false;
    const d = Math.abs(flo.diffDays(ovDate, o.date));
    return d <= 2;
  });
  return {
    sources: near ? ['cervical_mucus_support'] : [],
    near,
  };
}

/**
 * Process evidence against Level-A prior for the open cycle.
 */
function processEvidence(input) {
  const observations = input.observations || [];
  const sources = new Set(['historical_cycle_data', 'weighted_cycle_statistics']);
  const layers = new Set(['A']);
  let L = input.L;
  const forecastOv = input.priorCurrentOvulation;
  let currentOv = forecastOv;
  let uncertainty = Math.max(1, Number(input.ovulationUncertaintyDays) || 2);
  let estimateStatus = ESTIMATE_STATUS.FORECAST;
  let ovIntervalStart = null;
  let ovIntervalEnd = null;
  const notes = [];

  // Layer B — personal luteal (historical)
  const luteal = estimatePersonalLuteal(input.completedCycles, observations);
  if (luteal.luteal_mean != null && luteal.samples >= 2) {
    L = luteal.luteal_mean;
    layers.add('B');
    luteal.sources.forEach((s) => sources.add(s));
    notes.push(`personal_luteal=${L}`);
    if (input.lastPeriodStart && input.C) {
      const next = flo.addDays(input.lastPeriodStart, input.C);
      currentOv = flo.addDays(next, -L);
    }
  } else if (luteal.luteal_mean != null && luteal.samples === 1) {
    luteal.sources.forEach((s) => sources.add(s));
  }

  // Layer C — OPK (current cycle update; uncertainty remains)
  const opk = applyOpkUpdate(
    input.lastPeriodStart,
    input.C,
    observations,
    currentOv,
  );
  if (opk) {
    currentOv = opk.date;
    layers.add('C');
    opk.sources.forEach((s) => sources.add(s));
    estimateStatus = opk.estimate_status;
    ovIntervalStart = opk.interval_start;
    ovIntervalEnd = opk.interval_end;
    uncertainty = Math.max(opk.min_uncertainty_days, uncertainty - 0);
    // Slightly reduce only if was very wide; never collapse to zero
    uncertainty = Math.max(opk.min_uncertainty_days, Math.min(uncertainty, 3));
    notes.push(
      `opk_update=${opk.opk_positive_date}->estimate:${opk.date}(not_confirmed)`,
    );
  }

  // Layer D — BBT retrospective narrowing
  const bbt = applyBbtUpdate(
    input.lastPeriodStart,
    input.C,
    observations,
    currentOv,
  );
  if (bbt) {
    currentOv = bbt.date;
    layers.add('D');
    bbt.sources.forEach((s) => sources.add(s));
    estimateStatus = bbt.estimate_status;
    ovIntervalStart = bbt.interval_start;
    ovIntervalEnd = bbt.interval_end;
    uncertainty = Math.max(
      bbt.min_uncertainty_days,
      Math.min(uncertainty, 2),
    );
    notes.push(
      `bbt_retrospective=${bbt.rise_start}->estimate:${bbt.date}(not_confirmed)`,
    );
  }

  const mucus = mucusSupport(observations, currentOv);
  mucus.sources.forEach((s) => sources.add(s));

  if (obsOfType(observations, 'symptom').length > 0) {
    notes.push('symptoms_ignored_for_ovulation');
  }

  // Display "primary" layer = richest available for messaging (not absolute rank)
  const layerOrder = ['A', 'B', 'C', 'D'];
  let displayLevel = 'A';
  for (const Lyr of layerOrder) {
    if (layers.has(Lyr)) displayLevel = Lyr;
  }

  const half = uncertainty;
  const rangeStart = flo.addDays(currentOv, -half);
  const rangeEnd = flo.addDays(currentOv, half);

  return {
    evidence_level: displayLevel,
    evidence_layers: [...layers].sort(
      (a, b) => layerOrder.indexOf(a) - layerOrder.indexOf(b),
    ),
    evidence_sources: [...sources],
    luteal_days: L,
    /** Original calendar prior for the open cycle */
    forecast_ovulation_date: forecastOv,
    /** Best current estimate (still an estimate — not confirmed ovulation) */
    estimated_ovulation_date: currentOv,
    current_ovulation_date: currentOv,
    ovulation_range_start: rangeStart,
    ovulation_range_end: rangeEnd,
    ovulation_uncertainty_days: uncertainty,
    evidence_interval_start: ovIntervalStart,
    evidence_interval_end: ovIntervalEnd,
    estimate_status: estimateStatus,
    mucus_near: mucus.near,
    notes,
    level_b_samples: luteal.samples,
  };
}

module.exports = {
  processEvidence,
  estimatePersonalLuteal,
  applyOpkUpdate,
  applyBbtUpdate,
  /** @deprecated use applyOpkUpdate */
  applyOpkShift: applyOpkUpdate,
  /** @deprecated use applyBbtUpdate */
  applyBbtShift: applyBbtUpdate,
  mucusSupport,
  blendDates,
  ESTIMATE_STATUS,
};
