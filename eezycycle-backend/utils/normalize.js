/**
 * Normalize Flutter display strings / aliases to stable storage keys.
 */

const EXPERIENCE_MODE_MAP = {
  track_cycle: 'track_cycle',
  'track cycle': 'track_cycle',
  get_pregnant: 'get_pregnant',
  'get pregnant': 'get_pregnant',
  track_pregnancy: 'track_pregnancy',
  'track pregnancy': 'track_pregnancy',
  perimenopause: 'perimenopause',
  'track perimenopause': 'perimenopause',
  partner: 'partner',
};

const USAGE_PATH_MAP = {
  self: 'self',
  "yes, i'm using it for myself": 'self',
  'yes, im using it for myself': 'self',
  partner: 'partner',
  'no, i have a partner code': 'partner',
};

const GOAL_KEY_MAP = {
  get_pregnant: 'get_pregnant',
  'get pregnant': 'get_pregnant',
  track_pregnancy: 'track_pregnancy',
  'track my pregnancy': 'track_pregnancy',
  track_period: 'track_period',
  'track my period': 'track_period',
  well_being: 'well_being',
  'take charge of my well-being': 'well_being',
  manage_weight: 'manage_weight',
  'manage my weight': 'manage_weight',
  enhance_sex_life: 'enhance_sex_life',
  'enhance my sex life': 'enhance_sex_life',
  decode_discharge: 'decode_discharge',
  'decode my discharge': 'decode_discharge',
  explore_contraception: 'explore_contraception',
  'explore contraception': 'explore_contraception',
};

const FLOW_KEY_MAP = {
  normal: 'normal',
  pregnancy: 'normal',
  partner: 'partner',
  track_cycle: 'track_cycle',
  trackcycle: 'track_cycle',
  get_pregnant: 'get_pregnant',
  getpregnant: 'get_pregnant',
  perimenopause: 'perimenopause',
  trackperimenopause: 'perimenopause',
  track_perimenopause: 'perimenopause',
};

const CONSENT_TYPE_MAP = {
  terms: 'terms',
  terms_and_privacy: 'terms',
  termsandprivacy: 'terms',
  health_data: 'health_data',
  health_data_processing: 'health_data',
  healthdataprocessing: 'health_data',
  marketing: 'marketing',
  notifications: 'notifications',
};

/**
 * @param {unknown} value
 * @param {Record<string, string>} map
 * @returns {string|null}
 */
function mapKey(value, map) {
  if (value == null) return null;
  const key = String(value)
    .trim()
    .toLowerCase()
    .replace(/['’]/g, "'");
  const stripped = key.replace(/'/g, '');
  return map[key] || map[stripped] || null;
}

function normalizeExperienceMode(value) {
  return mapKey(value, EXPERIENCE_MODE_MAP);
}

function normalizeUsagePath(value) {
  return mapKey(value, USAGE_PATH_MAP);
}

function normalizeGoalKey(value) {
  const mapped = mapKey(value, GOAL_KEY_MAP);
  if (mapped) return mapped;
  if (typeof value !== 'string' || !value.trim()) return null;
  return value
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_|_$/g, '')
    .slice(0, 64);
}

function normalizeFlowKey(value) {
  if (value == null) return null;
  const lower = String(value).trim().toLowerCase();
  const compact = lower.replace(/[\s-]+/g, '');
  return FLOW_KEY_MAP[compact] || FLOW_KEY_MAP[lower] || lower;
}

function normalizeConsentType(value) {
  return mapKey(value, CONSENT_TYPE_MAP);
}

module.exports = {
  normalizeExperienceMode,
  normalizeUsagePath,
  normalizeGoalKey,
  normalizeFlowKey,
  normalizeConsentType,
};
