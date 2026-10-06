const { createError, ErrorCodes } = require('../utils/error');
const { verifyAccessToken } = require('../utils/token');
const userRepository = require('../repositories/user_repository');

/**
 * Resolves Authorization Bearer → req.userId / req.accountStatus / req.deviceId.
 * Clients never send userId in the body — identity comes from the token only.
 */
async function requireAuth(req, res, next) {
  try {
    const header = req.headers.authorization || '';
    const [scheme, token] = header.split(' ');

    if (scheme !== 'Bearer' || !token) {
      throw createError(
        'Authentication required. Please sign in again.',
        401,
        ErrorCodes.UNAUTHORIZED,
      );
    }

    let payload;
    try {
      payload = verifyAccessToken(token);
    } catch {
      throw createError(
        'Session expired. Please sign in again.',
        401,
        ErrorCodes.UNAUTHORIZED,
      );
    }

    if (payload.typ && payload.typ !== 'access') {
      throw createError(
        'Invalid access token.',
        401,
        ErrorCodes.UNAUTHORIZED,
      );
    }

    const userId = Number(payload.sub);
    if (!userId) {
      throw createError(
        'Invalid access token.',
        401,
        ErrorCodes.UNAUTHORIZED,
      );
    }

    const user = await userRepository.findActiveById(userId);
    if (!user) {
      throw createError(
        'Account not found or inactive.',
        401,
        ErrorCodes.UNAUTHORIZED,
      );
    }

    req.userId = user.id;
    req.accountStatus = user.account_status;
    req.deviceId = payload.device_id || null;
    req.user = user;
    next();
  } catch (err) {
    next(err);
  }
}

module.exports = { requireAuth };
