const flo = require('../flo_calendar_service');

/**
 * Luteal estimate — Level A default, or personal mean from evidence (Level B).
 * @param {{ luteal_mean?: number|null }} [profile]
 * @param {{ luteal_days?: number|null }} [evidence]
 */
function estimatedLutealDays(profile, evidence) {
  const fromEvidence = Number(evidence?.luteal_days);
  if (Number.isFinite(fromEvidence) && fromEvidence >= 10 && fromEvidence <= 16) {
    return Math.round(fromEvidence);
  }
  const L = Number(profile?.luteal_mean);
  if (Number.isFinite(L) && L >= 10 && L <= 16) return Math.round(L);
  return flo.DEFAULT_L;
}

module.exports = {
  estimatedLutealDays,
  DEFAULT_L: flo.DEFAULT_L,
};
