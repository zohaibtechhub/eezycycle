/**
 * Confidence = confidence in the *timing estimate* / data quality (v4.1).
 *
 * NOT:
 * - probability of conception
 * - probability the user is fertile
 * - contraceptive safety
 *
 * Evidence layers bump timing confidence when available — ordered rules, not weight mixes.
 */

function assessConfidence(profile, evidence = {}) {
  const N = profile.N || 0;
  const sd = Number(profile.cycle_stddev) || 0;
  const recentSd = Number(profile.recent_cycle_stddev) || 0;
  let label = 'low';
  let score = 0.35;

  if (N >= 6 && !profile.irregular && sd < 4) {
    label = 'high';
    score = 0.85;
  } else if (N >= 6 && sd < 6) {
    label = 'medium';
    score = 0.7;
  } else if (N >= 3 && !profile.irregular && sd < 5) {
    label = 'medium';
    score = 0.68;
  } else if (N >= 3) {
    label = 'medium';
    score = profile.irregular ? 0.52 : 0.6;
  } else if (N >= 1) {
    label = 'low';
    score = 0.4;
  }

  if (recentSd >= 6) {
    score -= 0.08;
    if (label === 'high') label = 'medium';
  }

  if (profile.regularity_score != null) {
    score = Math.min(
      0.95,
      Math.max(0.2, (score + profile.regularity_score) / 2),
    );
  }

  const level = evidence.evidence_level || 'A';
  if (level === 'B') score = Math.min(0.95, score + 0.04);
  if (level === 'C') {
    score = Math.min(0.95, score + 0.06);
    if (label === 'low') label = 'medium';
  }
  if (level === 'D') {
    score = Math.min(0.95, score + 0.08);
    if (label === 'low') label = 'medium';
  }
  if (evidence.mucus_near) {
    score = Math.min(0.95, score + 0.02);
  }

  score = Math.min(0.95, Math.max(0.2, score));

  const sources = Array.isArray(evidence.evidence_sources)
    ? evidence.evidence_sources
    : ['historical_cycle_data', 'weighted_cycle_statistics'];

  return {
    prediction_confidence: label,
    prediction_confidence_score: Math.round(score * 1000) / 1000,
    confidence_means: 'timing_estimate',
    evidence_level: level,
    evidence_layers: evidence.evidence_layers || [level],
    evidence_sources: sources,
    soft_confidence_label: softConfidenceLabel(label, N, level),
  };
}

/**
 * Soft UI copy — timing/data confidence only; never fertility probability.
 */
function softConfidenceLabel(label, N, evidenceLevel) {
  if (label === 'low' || N < 3) {
    return 'Timing estimate based on limited data';
  }
  if (evidenceLevel === 'C' || evidenceLevel === 'D') {
    return 'Timing estimate updated from your recent logs';
  }
  if (label === 'high' && N >= 6) {
    return 'Timing estimate based on your recent cycles';
  }
  if (label === 'medium') {
    return 'Timing estimate based on your recent cycles';
  }
  return 'Timing estimate';
}

module.exports = {
  assessConfidence,
  softConfidenceLabel,
};
