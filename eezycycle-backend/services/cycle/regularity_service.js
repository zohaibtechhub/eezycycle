/**
 * Phase 2 regularity — uses stddev, range, and recent variability.
 *
 * @param {{
 *   N: number,
 *   cycle_stddev: number,
 *   cycle_range?: number,
 *   recent_cycle_stddev?: number,
 *   irregular: boolean,
 * }} profile
 */
function assessRegularity(profile) {
  const N = profile.N || 0;
  const sd = profile.cycle_stddev || 0;
  const recentSd = profile.recent_cycle_stddev || 0;
  const range = profile.cycle_range || 0;

  let regularity_score = 0.3;
  if (N >= 6 && sd < 3 && recentSd < 3) regularity_score = 0.92;
  else if (N >= 6 && sd < 5) regularity_score = 0.8;
  else if (N >= 3 && sd < 5 && recentSd < 4) regularity_score = 0.72;
  else if (N >= 3 && sd < 7) regularity_score = 0.55;
  else if (N >= 1) regularity_score = 0.4;

  if (range >= 12) regularity_score = Math.min(regularity_score, 0.5);
  if (profile.irregular) regularity_score = Math.min(regularity_score, 0.45);

  let data_quality = 'low';
  if (N >= 6) data_quality = 'high';
  else if (N >= 3) data_quality = 'medium';

  return {
    regularity_score: Math.round(regularity_score * 100) / 100,
    data_quality,
  };
}

module.exports = {
  assessRegularity,
};
