/**
 * Phase 4 — personal insights from symptom timing patterns.
 * Safe language only: never claim fertility/ovulation from symptoms.
 */

const flo = require('../flo_calendar_service');

const SYMPTOM_LABELS = {
  sym_cramps: 'cramps',
  sym_headache: 'headaches',
  sym_bloating: 'bloating',
  sym_breast: 'breast tenderness',
  sym_backache: 'backache',
  sym_acne: 'acne',
  sym_fatigue: 'fatigue',
  sym_nausea: 'nausea',
  sym_mood: 'mood changes',
};

function parseKeys(value) {
  if (!value) return [];
  const v = typeof value === 'string' ? JSON.parse(value) : value;
  if (Array.isArray(v?.keys)) return v.keys.map(String);
  if (Array.isArray(v)) return v.map(String);
  return [];
}

function labelFor(key) {
  return SYMPTOM_LABELS[key] || key.replace(/^sym_/, '').replace(/_/g, ' ');
}

/**
 * @param {{
 *   observations?: Array<{ date: string, type: string, value?: object }>,
 *   lastPeriodStart?: string|null,
 *   C?: number,
 *   L?: number,
 *   ovulationDate?: string|null,
 * }} input
 * @returns {Array<{
 *   id: string,
 *   kind: string,
 *   title: string,
 *   body: string,
 *   safe: true,
 * }>}
 */
function buildPersonalInsights(input) {
  const observations = input.observations || [];
  const S = input.lastPeriodStart || null;
  const C = input.C || 28;
  const L = input.L || 14;
  const ov =
    input.ovulationDate ||
    (S ? flo.addDays(flo.addDays(S, C), -L) : null);

  const symptomObs = observations.filter((o) => o.type === 'symptom');
  if (!S || symptomObs.length < 2) {
    return [];
  }

  /** @type {Map<string, { beforePeriod: number, nearOv: number, total: number }>} */
  const counts = new Map();

  for (const obs of symptomObs) {
    const keys = parseKeys(obs.value);
    for (const key of keys) {
      if (!key.startsWith('sym_')) continue;
      if (!counts.has(key)) {
        counts.set(key, { beforePeriod: 0, nearOv: 0, total: 0 });
      }
      const row = counts.get(key);
      row.total++;

      // Days until next period estimate from this obs date
      const nextPeriod = flo.addDays(S, C);
      const daysToPeriod = flo.diffDays(obs.date, nextPeriod);
      if (daysToPeriod >= 0 && daysToPeriod <= 5) {
        row.beforePeriod++;
      }

      if (ov) {
        const dOv = Math.abs(flo.diffDays(ov, obs.date));
        if (dOv <= 2) row.nearOv++;
      }
    }
  }

  const insights = [];

  for (const [key, stats] of counts.entries()) {
    if (stats.total < 2) continue;
    const name = labelFor(key);

    if (stats.beforePeriod >= 2 && stats.beforePeriod >= stats.nearOv) {
      insights.push({
        id: `symptom_pre_period_${key}`,
        kind: 'symptom_timing',
        title: `You often log ${name} before your period`,
        body:
          'This is a personal pattern from your logs — an estimate of timing only, not a diagnosis or fertility signal.',
        safe: true,
      });
    } else if (stats.nearOv >= 2) {
      // Near estimated ovulation window — still NOT a fertility claim
      insights.push({
        id: `symptom_midcycle_${key}`,
        kind: 'symptom_timing',
        title: `You sometimes log ${name} mid-cycle`,
        body:
          'Based on when you logged this relative to your cycle estimates. Symptoms alone do not confirm ovulation.',
        safe: true,
      });
    }
  }

  // Cap to keep Home/API light
  return insights.slice(0, 5);
}

module.exports = {
  buildPersonalInsights,
  SYMPTOM_LABELS,
};
