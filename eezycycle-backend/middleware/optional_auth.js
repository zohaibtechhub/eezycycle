const { verifyAccessToken } = require('../utils/token');
const userRepository = require('../repositories/user_repository');

/**
 * Soft auth: if Bearer token is valid, set req.userId / req.accountStatus.
 * Invalid/missing tokens are ignored (login can still proceed).
 */
async function optionalAuth(req, res, next) {
  try {
    const header = req.headers.authorization || '';
    const [scheme, token] = header.split(' ');
    if (scheme !== 'Bearer' || !token) {
      return next();
    }

    let payload;
    try {
      payload = verifyAccessToken(token);
    } catch {
      return next();
    }

    if (payload.typ && payload.typ !== 'access') {
      return next();
    }

    const userId = Number(payload.sub);
    if (!userId) return next();

    const user = await userRepository.findActiveById(userId);
    if (!user) return next();

    req.userId = user.id;
    req.accountStatus = user.account_status;
    req.deviceId = payload.device_id || null;
    req.user = user;
    next();
  } catch {
    next();
  }
}

module.exports = { optionalAuth };
