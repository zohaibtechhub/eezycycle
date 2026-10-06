const flo = require('../flo_calendar_service');
const { toDateString } = require('../../utils/date');
const { EDD_SOURCES } = require('./constants');

function isPregnancyActive(profile) {
  return (
    profile?.pregnancy_mode_active === true ||
    profile?.pregnancy_mode_active === 1 ||
    profile?.pregnancy_mode_active === '1'
  );
}

/**
 * Resolve active due date with dual sources (Phase 4).
 * Prefer clinician/ultrasound EDD when present; keep LMP as fallback/history.
 *
 * @param {{
 *   due_date?: string|null,
 *   clinician_edd?: string|null,
 *   lmp_based_edd?: string|null,
 *   edd_source?: string|null,
 * }} profile
 * @param {string|null} lastPeriodStart
 * @returns {{
 *   due_date: string|null,
 *   edd_source: 'lmp'|'clinician_ultrasound'|null,
 *   lmp_based_edd: string|null,
 *   clinician_edd: string|null,
 * }}
 */
function resolveDating(profile, lastPeriodStart) {
  const lmpBased =
    lastPeriodStart
      ? flo.dueDateFromLmp(lastPeriodStart)
      : profile?.lmp_based_edd
        ? toDateString(profile.lmp_based_edd)
        : null;

  const clinician = profile?.clinician_edd
    ? toDateString(profile.clinician_edd)
    : null;

  if (clinician) {
    return {
      due_date: clinician,
      edd_source: EDD_SOURCES.CLINICIAN,
      lmp_based_edd: lmpBased,
      clinician_edd: clinician,
    };
  }

  if (lmpBased) {
    return {
      due_date: lmpBased,
      edd_source: EDD_SOURCES.LMP,
      lmp_based_edd: lmpBased,
      clinician_edd: null,
    };
  }

  const stored = profile?.due_date ? toDateString(profile.due_date) : null;
  return {
    due_date: stored,
    edd_source: stored
      ? profile?.edd_source === EDD_SOURCES.CLINICIAN
        ? EDD_SOURCES.CLINICIAN
        : EDD_SOURCES.LMP
      : null,
    lmp_based_edd: profile?.lmp_based_edd
      ? toDateString(profile.lmp_based_edd)
      : null,
    clinician_edd: null,
  };
}

/**
 * @deprecated Prefer resolveDating — kept for callers that only need a date string.
 * @param {string|null} lastPeriodStart
 * @param {string|null} [storedDue]
 * @param {{ clinician_edd?: string|null }} [profile]
 */
function resolveDueDate(lastPeriodStart, storedDue, profile) {
  const dating = resolveDating(
    {
      due_date: storedDue,
      clinician_edd: profile?.clinician_edd,
      lmp_based_edd: profile?.lmp_based_edd,
      edd_source: profile?.edd_source,
    },
    lastPeriodStart,
  );
  return dating.due_date;
}

/**
 * Human-readable EDD source audit label (API / UI).
 * @param {string|null} source
 */
function eddSourceLabel(source) {
  if (source === EDD_SOURCES.CLINICIAN) {
    return 'Based on clinician/ultrasound date you entered';
  }
  if (source === EDD_SOURCES.LMP) {
    return 'Estimated from last period you logged (LMP + 280 days)';
  }
  return null;
}

module.exports = {
  isPregnancyActive,
  resolveDating,
  resolveDueDate,
  eddSourceLabel,
  EDD_SOURCES,
  dueDateFromLmp: flo.dueDateFromLmp,
  gestationalAgeFromLmp: flo.gestationalAgeFromLmp,
  gestationalAgeFromDue: flo.gestationalAgeFromDue,
  PREGNANCY_LENGTH_DAYS: flo.PREGNANCY_LENGTH_DAYS,
};
