const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const { env } = require('../config/env');

/**
 * Guest Phase 1: tokens are permanent (no JWT exp claim).
 * @param {{ userId: number, accountStatus: string, deviceId?: string }} payload
 * @returns {string}
 */
function signAccessToken(payload) {
  return jwt.sign(
    {
      sub: payload.userId,
      account_status: payload.accountStatus,
      device_id: payload.deviceId || null,
      typ: 'access',
    },
    env.jwt.accessSecret,
  );
}

/**
 * @param {{ userId: number, accountStatus: string, deviceId?: string }} payload
 * @returns {string}
 */
function signRefreshToken(payload) {
  return jwt.sign(
    {
      sub: payload.userId,
      account_status: payload.accountStatus,
      device_id: payload.deviceId || null,
      typ: 'refresh',
    },
    env.jwt.refreshSecret,
  );
}

/**
 * @param {string} token
 * @returns {object}
 */
function verifyAccessToken(token) {
  return jwt.verify(token, env.jwt.accessSecret);
}

/**
 * @param {string} token
 * @returns {object}
 */
function verifyRefreshToken(token) {
  return jwt.verify(token, env.jwt.refreshSecret);
}

/**
 * @param {string} token
 * @returns {string}
 */
function hashToken(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

/**
 * DB column still needs a date — store a far-future sentinel for permanent tokens.
 * @returns {Date}
 */
function refreshExpiresAt() {
  return new Date('9999-12-31T23:59:59.000Z');
}

module.exports = {
  signAccessToken,
  signRefreshToken,
  verifyAccessToken,
  verifyRefreshToken,
  hashToken,
  refreshExpiresAt,
};
