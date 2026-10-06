const { createError, ErrorCodes } = require('../utils/error');
const consentRepository = require('../repositories/consent_repository');

/**
 * Blocks health-data writes until required consents are accepted (Play / privacy).
 * @param {string[]} requiredTypes  e.g. ['terms', 'health_data']
 */
function requireConsents(requiredTypes = ['terms', 'health_data']) {
  return async function consentGuard(req, res, next) {
    try {
      const missing = await consentRepository.findMissingAccepted(
        req.userId,
        requiredTypes,
      );

      if (missing.length > 0) {
        throw createError(
          'Please accept Terms and health-data processing before continuing.',
          403,
          ErrorCodes.CONSENT_REQUIRED,
        );
      }

      next();
    } catch (err) {
      next(err);
    }
  };
}

module.exports = { requireConsents };
