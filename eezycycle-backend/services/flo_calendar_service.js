/**
 * Flo-aligned calendar formulas (flo_calendar_v1).
 * Pure functions only — no DB. Keep all prediction math here (DRY).
 *
 * @see period_ovulation_tracker/docs/backend/04-cycle-formulas-flo.md
 */

const {
  toDateString,
  addDays,
  diffDays,
} = require('../utils/date');

const ALGORITHM_VERSION = 'ecc_prediction_v1';
/** @deprecated Prefer ALGORITHM_VERSION; kept for reading old prediction rows. */
const LEGACY_ALGORITHM_VERSION = 'flo_calendar_v1';
const DEFAULT_C = 28;
const DEFAULT_P = 5;
const DEFAULT_L = 14;
/** Flo due-date rule: first day of LMP + 280 days (40 weeks; timeline through week 41). */
const PREGNANCY_LENGTH_DAYS = 280;

/**
 * @param {string|Date} value
 * @returns {string} YYYY-MM-DD
 */
function toDateOnly(value) {
  return toDateString(value) || String(value).slice(0, 10);
}

function clamp(n, min, max) {
  return Math.min(max, Math.max(min, n));
}

/**
 * Group sorted YYYY-MM-DD period days into bleed runs.
 * @param {string[]} sortedDates
 * @returns {{ start: string, end: string, length: number }[]}
 */
function groupBleedRuns(sortedDates) {
  const dates = [...new Set(sortedDates.map(toDateOnly))].sort();
  if (dates.length === 0) return [];

  const runs = [];
  let start = dates[0];
  let prev = dates[0];

  for (let i = 1; i < dates.length; i++) {
    if (diffDays(prev, dates[i]) === 1) {
      prev = dates[i];
      continue;
    }
    runs.push({
      start,
      end: prev,
      length: diffDays(start, prev) + 1,
    });
    start = dates[i];
    prev = dates[i];
  }
  runs.push({
    start,
    end: prev,
    length: diffDays(start, prev) + 1,
  });
  return runs;
}

/**
 * Completed cycles from bleed run starts.
 * @param {{ start: string, length: number }[]} runs
 * @returns {{ start: string, cycleLength: number, periodLength: number }[]}
 */
function completedCyclesFromRuns(runs) {
  const completed = [];
  for (let i = 0; i < runs.length - 1; i++) {
    completed.push({
      start: runs[i].start,
      cycleLength: diffDays(runs[i].start, runs[i + 1].start),
      periodLength: runs[i].length,
    });
  }
  return completed;
}

/**
 * @param {{ cycleLength: number, periodLength: number }[]} cycles
 * @param {{ declaredC?: number|null, declaredP?: number|null }} [opts]
 */
function computeAverages(cycles, opts = {}) {
  const recent = cycles.slice(-12);
  // Ignore mistap / gap outliers for cycle length
  const usable = recent.filter(
    (c) => c.cycleLength >= 21 && c.cycleLength <= 45,
  );
  const forAvg = usable.length > 0 ? usable : [];
  const N = recent.length;
  const nAvg = forAvg.length;

  let C =
    nAvg > 0
      ? Math.round(forAvg.reduce((s, c) => s + c.cycleLength, 0) / nAvg)
      : Number(opts.declaredC) || DEFAULT_C;

  // Period length: Flo default is 5 days (typical 3–5).
  // Only personalize once cycle history is solid; thin data stays at 5.
  const bleedLengths = Array.isArray(opts.bleedLengths)
    ? opts.bleedLengths
    : recent.map((c) => c.periodLength);
  const goodBleeds = bleedLengths.filter((len) => len >= 3 && len <= 7);
  let P = DEFAULT_P;
  if (goodBleeds.length >= 3 && nAvg >= 3) {
    P = Math.round(goodBleeds.reduce((s, n) => s + n, 0) / goodBleeds.length);
  }

  C = clamp(C, 21, 45);
  P = clamp(P, 3, 7);

  let irregular = nAvg < 3;
  if (nAvg >= 2) {
    const lengths = forAvg.map((c) => c.cycleLength);
    const mean = lengths.reduce((s, n) => s + n, 0) / lengths.length;
    const variance =
      lengths.reduce((s, n) => s + (n - mean) ** 2, 0) / lengths.length;
    const stddev = Math.sqrt(variance);
    if (stddev >= 7) irregular = true;
  }
  if (nAvg >= 3 && forAvg.some((c) => c.cycleLength < 21 || c.cycleLength > 35)) {
    irregular = true;
  }
  if (N > 0 && nAvg < 2) irregular = true;

  return {
    C,
    P,
    N: nAvg,
    irregular,
    fertileWindowMode: irregular ? 'wide' : 'standard',
  };
}

/**
 * @param {string} ov YYYY-MM-DD ovulation
 * @param {boolean} irregular
 * @returns {{ fertileStart: string, fertileEnd: string }}
 */
function computeFertileWindow(ov, irregular) {
  if (irregular) {
    let fertileStart = addDays(ov, -9);
    let fertileEnd = addDays(ov, 4);
    let width = diffDays(fertileStart, fertileEnd) + 1;
    if (width > 14) {
      fertileStart = addDays(ov, -6);
      fertileEnd = addDays(ov, 7);
    }
    return { fertileStart, fertileEnd };
  }
  return {
    fertileStart: addDays(ov, -5),
    fertileEnd: addDays(ov, 1),
  };
}

/**
 * Build predicted day rows for the next `cyclesAhead` cycles after last start S.
 * Does not include the current logged bleed (caller merges logged days).
 *
 * @param {{
 *   lastPeriodStart: string,
 *   C: number,
 *   P: number,
 *   L?: number,
 *   irregular: boolean,
 *   cyclesAhead?: number,
 * }} input
 * @returns {{ date: string, dayType: string, periodDay: number|null, isPredicted: boolean }[]}
 */
function buildPredictionDays(input) {
  const S = toDateOnly(input.lastPeriodStart);
  const C = input.C || DEFAULT_C;
  const P = input.P || DEFAULT_P;
  const L = input.L || DEFAULT_L;
  const irregular = Boolean(input.irregular);
  const cyclesAhead = input.cyclesAhead ?? 6;

  /** @type {Map<string, { date: string, dayType: string, periodDay: number|null, isPredicted: boolean }>} */
  const byDate = new Map();

  function upsert(date, dayType, periodDay = null) {
    const existing = byDate.get(date);
    // Priority: ovulation > period > fertility > none
    const rank = { ovulation: 3, period: 2, fertility: 1, none: 0 };
    if (existing && (rank[existing.dayType] || 0) >= (rank[dayType] || 0)) {
      return;
    }
    byDate.set(date, {
      date,
      dayType,
      periodDay,
      isPredicted: true,
    });
  }

  for (let k = 1; k <= cyclesAhead; k++) {
    const nextStart = addDays(S, k * C);
    const ov = addDays(nextStart, -L);
    const { fertileStart, fertileEnd } = computeFertileWindow(ov, irregular);

    for (let d = 0; d < P; d++) {
      upsert(addDays(nextStart, d), 'period', d + 1);
    }

    let cursor = fertileStart;
    while (cursor <= fertileEnd) {
      upsert(cursor, cursor === ov ? 'ovulation' : 'fertility', null);
      cursor = addDays(cursor, 1);
    }
  }

  // Also mark fertile/ovulation for the *current* open cycle (from S)
  const currentNext = addDays(S, C);
  const currentOv = addDays(currentNext, -L);
  const currentWindow = computeFertileWindow(currentOv, irregular);
  let cursor = currentWindow.fertileStart;
  while (cursor <= currentWindow.fertileEnd) {
    // Don't overwrite logged period days later — predictions only for future/non-logged
    upsert(cursor, cursor === currentOv ? 'ovulation' : 'fertility', null);
    cursor = addDays(cursor, 1);
  }

  return [...byDate.values()].sort((a, b) => a.date.localeCompare(b.date));
}

/**
 * Flo due date from LMP: first day of last menstrual period + 280 days.
 * @param {string|Date} lmp
 * @returns {string} YYYY-MM-DD
 */
function dueDateFromLmp(lmp) {
  return addDays(toDateOnly(lmp), PREGNANCY_LENGTH_DAYS);
}

/**
 * Gestational age from LMP (Flo calendar).
 * @param {string|Date} lmp
 * @param {string|Date} date
 */
function gestationalAgeFromLmp(lmp, date) {
  const lmpDay = toDateOnly(lmp);
  const onDay = toDateOnly(date);
  const due = dueDateFromLmp(lmpDay);
  const daysPregnant = Math.max(0, diffDays(lmpDay, onDay));
  const weeks = Math.floor(daysPregnant / 7);
  const days = daysPregnant % 7;
  return {
    daysPregnant,
    weeks,
    days,
    pregnancyWeek: Math.max(1, Math.min(42, weeks + 1)),
    dueDate: due,
    daysUntilDue: diffDays(onDay, due),
  };
}

/**
 * Fallback when only a stored due date exists (no LMP).
 * @param {string|Date} due
 * @param {string|Date} date
 */
function gestationalAgeFromDue(due, date) {
  const dueDay = toDateOnly(due);
  const onDay = toDateOnly(date);
  const daysUntilDue = diffDays(onDay, dueDay);
  const daysPregnant = Math.max(0, PREGNANCY_LENGTH_DAYS - daysUntilDue);
  const weeks = Math.floor(daysPregnant / 7);
  const days = daysPregnant % 7;
  return {
    daysPregnant,
    weeks,
    days,
    pregnancyWeek: Math.max(1, Math.min(42, weeks + 1)),
    dueDate: dueDay,
    daysUntilDue,
  };
}

/**
 * Classify today / a date for Home hero.
 * @param {{
 *   date: string,
 *   lastPeriodStart: string|null,
 *   C: number,
 *   P: number,
 *   L?: number,
 *   loggedDates: Set<string>|string[],
 *   predicted: { date: string, dayType: string, periodDay?: number|null }[],
 *   pregnancyModeActive?: boolean,
 *   dueDate?: string|null,
 *   experienceMode?: string|null,
 * }} input
 */
function buildDaySummary(input) {
  const date = toDateOnly(input.date);
  const L = input.L || DEFAULT_L;
  const C = input.C || DEFAULT_C;
  const P = input.P || DEFAULT_P;

  if (input.pregnancyModeActive) {
    const lmp = input.lastPeriodStart ? toDateOnly(input.lastPeriodStart) : null;
    const storedDue = input.dueDate ? toDateOnly(input.dueDate) : null;
    const clinicianDue = input.clinicianEdd
      ? toDateOnly(input.clinicianEdd)
      : null;
    const preferClinician =
      input.eddSource === 'clinician_ultrasound' || !!clinicianDue;

    // Phase 4: prefer clinician/ultrasound EDD when present
    const lmpDue = lmp ? dueDateFromLmp(lmp) : null;
    const due = preferClinician
      ? clinicianDue || storedDue || lmpDue
      : lmpDue || storedDue;

    let age;
    if (preferClinician && due) {
      age = gestationalAgeFromDue(due, date);
    } else if (lmp) {
      age = gestationalAgeFromLmp(lmp, date);
    } else if (due) {
      age = gestationalAgeFromDue(due, date);
    } else {
      age = {
        daysPregnant: 0,
        weeks: 0,
        days: 0,
        pregnancyWeek: 1,
        daysUntilDue: null,
        dueDate: null,
      };
    }

    return {
      date,
      cycle_day: null,
      day_type: 'pregnancy',
      period_day: null,
      phase: 'pregnancy',
      days_until_next_period: null,
      days_until_ovulation: null,
      pregnancy_week: age.pregnancyWeek,
      pregnancy_weeks: age.weeks,
      pregnancy_days: age.days,
      days_pregnant: age.daysPregnant,
      days_until_due: age.daysUntilDue,
      last_period_start: lmp,
      due_date: due || age.dueDate || null,
      edd_source: preferClinician
        ? 'clinician_ultrasound'
        : due
          ? 'lmp'
          : null,
      message_key: null,
      avg_cycle_length: C,
      avg_period_length: P,
      fertile_window_mode: 'standard',
      algorithm_version: ALGORITHM_VERSION,
      partner_message_key: 'partner_today_pregnancy',
      experience_mode: input.experienceMode || 'track_pregnancy',
    };
  }

  const logged = input.loggedDates instanceof Set
    ? input.loggedDates
    : new Set([...(input.loggedDates || [])].map(toDateOnly));

  const predMap = new Map(
    (input.predicted || []).map((p) => [toDateOnly(p.date), p]),
  );

  const S = input.lastPeriodStart ? toDateOnly(input.lastPeriodStart) : null;

  if (!S) {
    return {
      date,
      cycle_day: null,
      day_type: 'none',
      period_day: null,
      phase: 'unknown',
      days_until_next_period: null,
      days_until_ovulation: null,
      avg_cycle_length: C,
      avg_period_length: P,
      fertile_window_mode: 'wide',
      algorithm_version: ALGORITHM_VERSION,
      message_key: 'today_log_period',
      partner_message_key: 'partner_today_log_period',
      experience_mode: input.experienceMode || null,
    };
  }

  const cycleDay = diffDays(S, date) + 1;
  const nextPeriod = addDays(S, C);
  const ovulation = addDays(nextPeriod, -L);
  const daysUntilNextPeriod = diffDays(date, nextPeriod);
  const daysUntilOvulation = diffDays(date, ovulation);

  let dayType = 'none';
  let periodDay = null;

  if (logged.has(date)) {
    dayType = 'period';
    // Day N of this bleed = offset from last period start (logged only).
    periodDay = cycleDay >= 1 ? cycleDay : 1;
  } else if (predMap.has(date)) {
    const p = predMap.get(date);
    dayType = p.dayType || 'none';
    periodDay = p.periodDay ?? null;
  }
  // else: leave day_type none. Do NOT invent period / fertility / ovulation from
  // cycle math — /cycle/calendar already has logged + predicted marks. Inventing
  // here made Home paint empty strip days purple/yellow when tapping them.

  const ovDay = C - L;
  let phase = 'luteal';
  // Menstrual phase only when this date is actually period (logged or predicted).
  if (dayType === 'period') phase = 'menstrual';
  else if (cycleDay < ovDay) phase = 'follicular';
  else if (cycleDay === ovDay || dayType === 'ovulation') phase = 'ovulation';
  else if (dayType === 'fertility') phase = 'fertility';
  else phase = 'luteal';

  let messageKey = 'today_luteal';
  let partnerKey = 'partner_today_luteal';
  if (dayType === 'period') {
    messageKey = 'today_period';
    partnerKey = 'partner_today_period';
  } else if (dayType === 'ovulation') {
    messageKey = 'today_ovulation';
    partnerKey = 'partner_today_ovulation';
  } else if (dayType === 'fertility') {
    messageKey = 'today_fertility';
    partnerKey = 'partner_today_fertility';
  } else if (phase === 'follicular') {
    messageKey = 'today_follicular';
    partnerKey = 'partner_today_follicular';
  }

  return {
    date,
    cycle_day: cycleDay > 0 ? cycleDay : null,
    day_type: dayType,
    period_day: periodDay,
    phase,
    days_until_next_period: daysUntilNextPeriod,
    days_until_ovulation: daysUntilOvulation,
    avg_cycle_length: C,
    avg_period_length: P,
    luteal_phase_days: L,
    fertile_window_mode: input.irregular ? 'wide' : 'standard',
    algorithm_version: ALGORITHM_VERSION,
    message_key: messageKey,
    partner_message_key: partnerKey,
    experience_mode: input.experienceMode || null,
    last_period_start: S,
    next_period_start: nextPeriod,
    ovulation_date: ovulation,
  };
}

module.exports = {
  ALGORITHM_VERSION,
  LEGACY_ALGORITHM_VERSION,
  DEFAULT_C,
  DEFAULT_P,
  DEFAULT_L,
  PREGNANCY_LENGTH_DAYS,
  toDateOnly,
  addDays,
  diffDays,
  groupBleedRuns,
  completedCyclesFromRuns,
  computeAverages,
  computeFertileWindow,
  buildPredictionDays,
  buildDaySummary,
  dueDateFromLmp,
  gestationalAgeFromLmp,
  gestationalAgeFromDue,
};
