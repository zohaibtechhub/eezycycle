const bcrypt = require('bcryptjs');
const { pool } = require('../config/db');
const { createError, ErrorCodes } = require('../utils/error');
const {
  signAccessToken,
  signRefreshToken,
  hashToken,
  refreshExpiresAt,
  verifyRefreshToken,
} = require('../utils/token');
const { verifyGoogleIdToken } = require('../utils/google_auth');
const userRepository = require('../repositories/user_repository');
const deviceRepository = require('../repositories/device_repository');
const refreshTokenRepository = require('../repositories/refresh_token_repository');
const profileRepository = require('../repositories/profile_repository');
const passwordResetRepository = require('../repositories/password_reset_repository');
const mailUtil = require('../utils/mail');

const PLATFORMS = new Set(['ios', 'android', 'other']);
const BCRYPT_ROUNDS = 10;
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function issueTokenPair({ userId, accountStatus, deviceId }) {
  const accessToken = signAccessToken({ userId, accountStatus, deviceId });
  const refreshToken = signRefreshToken({ userId, accountStatus, deviceId });
  return { accessToken, refreshToken };
}

function publicUser(user) {
  return {
    id: user.id,
    account_status: user.account_status,
    email: user.email || null,
    name: user.name || null,
  };
}

async function persistRefresh({ userId, refreshToken, deviceId, connection }) {
  await refreshTokenRepository.create(connection || null, {
    userId,
    tokenHash: hashToken(refreshToken),
    deviceId: deviceId || null,
    expiresAt: refreshExpiresAt(),
  });
}

async function issueSession(user, deviceId, connection) {
  const tokens = issueTokenPair({
    userId: user.id,
    accountStatus: user.account_status,
    deviceId: deviceId || null,
  });
  await persistRefresh({
    userId: user.id,
    refreshToken: tokens.refreshToken,
    deviceId,
    connection,
  });
  await userRepository.touchLastLogin(user.id, connection);
  return {
    access_token: tokens.accessToken,
    refresh_token: tokens.refreshToken,
    user: publicUser(user),
  };
}

function normalizeEmail(email) {
  return String(email || '')
    .trim()
    .toLowerCase();
}

function assertValidEmailPassword(email, password) {
  if (!EMAIL_RE.test(email)) {
    throw createError('Enter a valid email address.', 400, ErrorCodes.VALIDATION);
  }
  if (!password || String(password).length < 6) {
    throw createError(
      'Password must be at least 6 characters.',
      400,
      ErrorCodes.VALIDATION,
    );
  }
}

/**
 * Create or reuse guest by device_id.
 * @param {{ deviceId: string, platform?: string, appVersion?: string }} input
 */
async function createOrReuseGuest(input) {
  const deviceId = String(input.deviceId || '').trim();
  if (!deviceId || deviceId.length > 64) {
    throw createError('Valid device_id is required.', 400, ErrorCodes.VALIDATION);
  }

  let platform = String(input.platform || 'other').toLowerCase();
  if (!PLATFORMS.has(platform)) platform = 'other';
  const appVersion = input.appVersion ? String(input.appVersion).slice(0, 32) : null;

  const existing = await deviceRepository.findByDeviceId(deviceId);

  if (existing && !existing.deleted_at && existing.is_active) {
    await deviceRepository.touch(deviceId, { platform, appVersion });
    await userRepository.touchLastLogin(existing.user_id);

    const tokens = issueTokenPair({
      userId: existing.user_id,
      accountStatus: existing.account_status,
      deviceId,
    });

    await refreshTokenRepository.create(null, {
      userId: existing.user_id,
      tokenHash: hashToken(tokens.refreshToken),
      deviceId,
      expiresAt: refreshExpiresAt(),
    });

    return {
      access_token: tokens.accessToken,
      refresh_token: tokens.refreshToken,
      user: {
        id: existing.user_id,
        account_status: existing.account_status,
      },
    };
  }

  if (existing && (existing.deleted_at || !existing.is_active)) {
    throw createError(
      'This device was linked to a deleted account. Contact support or reinstall.',
      409,
      ErrorCodes.CONFLICT,
    );
  }

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const userId = await userRepository.createGuest(connection);
    await deviceRepository.create(connection, {
      userId,
      deviceId,
      platform,
      appVersion,
    });
    await profileRepository.ensureExists(userId, connection);
    await userRepository.touchLastLogin(userId, connection);

    const tokens = issueTokenPair({
      userId,
      accountStatus: 'guest',
      deviceId,
    });

    await refreshTokenRepository.create(connection, {
      userId,
      tokenHash: hashToken(tokens.refreshToken),
      deviceId,
      expiresAt: refreshExpiresAt(),
    });

    await connection.commit();

    return {
      access_token: tokens.accessToken,
      refresh_token: tokens.refreshToken,
      user: { id: userId, account_status: 'guest' },
    };
  } catch (err) {
    await connection.rollback();
    throw err;
  } finally {
    connection.release();
  }
}

/**
 * Attach email/password or Google to the current guest — same user_id.
 * @param {{ userId: number, accountStatus: string, deviceId?: string|null, email?: string, password?: string, googleIdToken?: string }} input
 */
async function upgradeGuest(input) {
  if (input.accountStatus !== 'guest') {
    throw createError(
      'This account is already registered. Please sign in instead.',
      409,
      ErrorCodes.CONFLICT,
    );
  }

  const deviceId = input.deviceId || null;
  const googleIdToken = input.googleIdToken
    ? String(input.googleIdToken).trim()
    : '';

  if (googleIdToken) {
    const google = await verifyGoogleIdToken(googleIdToken);

    const bySub = await userRepository.findActiveByGoogleSub(google.sub);
    if (bySub && bySub.id !== input.userId) {
      throw createError(
        'This Google account is already linked to another EezyCycle user. Sign in instead.',
        409,
        ErrorCodes.CONFLICT,
      );
    }

    if (google.email) {
      const byEmail = await userRepository.findActiveByEmail(google.email);
      if (byEmail && byEmail.id !== input.userId) {
        throw createError(
          'This email is already registered. Sign in instead.',
          409,
          ErrorCodes.CONFLICT,
        );
      }
    }

    await userRepository.upgradeGuestToRegistered(input.userId, {
      email: google.email,
      googleSub: google.sub,
      name: google.name,
      emailVerified: google.emailVerified,
    });

    const user = await userRepository.findActiveById(input.userId);
    return issueSession(user, deviceId);
  }

  const email = normalizeEmail(input.email);
  const password = String(input.password || '');
  assertValidEmailPassword(email, password);

  const existing = await userRepository.findActiveByEmail(email);
  if (existing && existing.id !== input.userId) {
    throw createError(
      'This email is already registered. Sign in instead.',
      409,
      ErrorCodes.CONFLICT,
    );
  }

  const passwordHash = await bcrypt.hash(password, BCRYPT_ROUNDS);
  await userRepository.upgradeGuestToRegistered(input.userId, {
    email,
    passwordHash,
    emailVerified: false,
  });

  const user = await userRepository.findActiveById(input.userId);
  return issueSession(user, deviceId);
}

/**
 * When a guest device logs into an existing registered account:
 * - empty guest → reattach device, soft-delete guest (data stays on account)
 * - guest with data → Policy B for v1: account wins (guest abandoned)
 */
async function attachDeviceToAccount({
  guestUserId,
  accountUser,
  deviceId,
}) {
  if (!guestUserId || guestUserId === accountUser.id) {
    return issueSession(accountUser, deviceId);
  }

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    if (deviceId) {
      await deviceRepository.reassignUser(deviceId, accountUser.id, connection);
      await refreshTokenRepository.revokeAllForUserDevice(guestUserId, deviceId);
    }

    await userRepository.softDeleteUser(guestUserId, connection);
    await connection.commit();
  } catch (err) {
    await connection.rollback();
    throw err;
  } finally {
    connection.release();
  }

  return issueSession(accountUser, deviceId);
}

/**
 * Login with email/password or Google. Optional guest JWT for device attach.
 * @param {{ email?: string, password?: string, googleIdToken?: string, guestUserId?: number|null, guestAccountStatus?: string|null, deviceId?: string|null }} input
 */
async function login(input) {
  const deviceId = input.deviceId || null;
  const googleIdToken = input.googleIdToken
    ? String(input.googleIdToken).trim()
    : '';

  let accountUser = null;

  if (googleIdToken) {
    const google = await verifyGoogleIdToken(googleIdToken);
    accountUser = await userRepository.findActiveByGoogleSub(google.sub);

    if (!accountUser && google.email) {
      accountUser = await userRepository.findActiveByEmail(google.email);
      if (accountUser && !accountUser.google_sub) {
        // Link Google to existing email account
        await pool.execute(
          `UPDATE users SET google_sub = ?, name = COALESCE(name, ?), last_login_at = CURRENT_TIMESTAMP
           WHERE id = ?`,
          [google.sub, google.name, accountUser.id],
        );
        accountUser = await userRepository.findActiveById(accountUser.id);
      }
    }

    if (!accountUser) {
      throw createError(
        'No account found for this Google user. Create an account first.',
        404,
        ErrorCodes.NOT_FOUND,
      );
    }
  } else {
    const email = normalizeEmail(input.email);
    const password = String(input.password || '');
    assertValidEmailPassword(email, password);

    accountUser = await userRepository.findActiveByEmail(email);
    if (!accountUser || !accountUser.password_hash) {
      throw createError('Invalid email or password.', 401, ErrorCodes.UNAUTHORIZED);
    }

    const ok = await bcrypt.compare(password, accountUser.password_hash);
    if (!ok) {
      throw createError('Invalid email or password.', 401, ErrorCodes.UNAUTHORIZED);
    }
  }

  if (accountUser.account_status !== 'registered') {
    throw createError(
      'This account is not fully registered yet.',
      403,
      ErrorCodes.FORBIDDEN,
    );
  }

  // Guest JWT present and different user → attach device / abandon empty guest
  if (
    input.guestUserId &&
    input.guestAccountStatus === 'guest' &&
    input.guestUserId !== accountUser.id
  ) {
    return attachDeviceToAccount({
      guestUserId: input.guestUserId,
      accountUser,
      deviceId,
    });
  }

  return issueSession(accountUser, deviceId);
}

/**
 * @param {{ refreshToken: string }} input
 */
async function refreshSession(input) {
  const refreshToken = String(input.refreshToken || '').trim();
  if (!refreshToken) {
    throw createError('refresh_token is required.', 400, ErrorCodes.VALIDATION);
  }

  let payload;
  try {
    payload = verifyRefreshToken(refreshToken);
  } catch {
    throw createError('Invalid or expired refresh token.', 401, ErrorCodes.UNAUTHORIZED);
  }

  if (payload.typ && payload.typ !== 'refresh') {
    throw createError('Invalid refresh token.', 401, ErrorCodes.UNAUTHORIZED);
  }

  const tokenHash = hashToken(refreshToken);
  const stored = await refreshTokenRepository.findValidByHash(tokenHash);
  if (!stored) {
    throw createError('Refresh token revoked or expired.', 401, ErrorCodes.UNAUTHORIZED);
  }

  const user = await userRepository.findActiveById(stored.user_id);
  if (!user) {
    throw createError('Account not found or inactive.', 401, ErrorCodes.UNAUTHORIZED);
  }

  await refreshTokenRepository.revokeByHash(tokenHash);

  const deviceId = stored.device_id || payload.device_id || null;
  const tokens = issueTokenPair({
    userId: user.id,
    accountStatus: user.account_status,
    deviceId,
  });

  await refreshTokenRepository.create(null, {
    userId: user.id,
    tokenHash: hashToken(tokens.refreshToken),
    deviceId,
    expiresAt: refreshExpiresAt(),
  });

  await userRepository.touchLastLogin(user.id);

  return {
    access_token: tokens.accessToken,
    refresh_token: tokens.refreshToken,
    user: publicUser(user),
  };
}

/**
 * @param {{ userId: number, deviceId?: string|null, refreshToken?: string }} input
 */
async function logout(input) {
  if (input.refreshToken) {
    await refreshTokenRepository.revokeByHash(hashToken(input.refreshToken));
  }
  await refreshTokenRepository.revokeAllForUserDevice(input.userId, input.deviceId || null);
  return { logged_out: true };
}

const OTP_TTL_MS = 15 * 60 * 1000;
const GENERIC_FORGOT_MESSAGE =
  'If an account exists for that email, we sent a reset code.';

function generateOtp() {
  return String(Math.floor(100000 + Math.random() * 900000));
}

/**
 * Request a password-reset OTP emailed to the user.
 * Always returns a generic success message (no email enumeration).
 */
async function requestPasswordReset({ email: rawEmail }) {
  const email = normalizeEmail(rawEmail);
  if (!EMAIL_RE.test(email)) {
    throw createError('Enter a valid email address.', 400, ErrorCodes.VALIDATION);
  }

  const user = await userRepository.findActiveByEmail(email);
  // Only email-password accounts can reset via OTP.
  if (
    user &&
    user.account_status === 'registered' &&
    user.password_hash
  ) {
    if (!mailUtil.isSmtpConfigured()) {
      throw createError(
        'Email delivery is not configured. Please try again later.',
        503,
        ErrorCodes.INTERNAL,
      );
    }

    const otp = generateOtp();
    const expiresAt = new Date(Date.now() + OTP_TTL_MS);
    await passwordResetRepository.createOtp({
      userId: user.id,
      email,
      otp,
      expiresAt,
    });

    try {
      await mailUtil.sendPasswordResetOtp({ to: email, otp });
    } catch (err) {
      console.error('[mail] password reset send failed', err?.message || err);
      throw createError(
        'Could not send the reset email. Please try again shortly.',
        502,
        ErrorCodes.INTERNAL,
      );
    }
  }

  return { sent: true, message: GENERIC_FORGOT_MESSAGE };
}

async function verifyPasswordResetOtp({ email: rawEmail, otp }) {
  const email = normalizeEmail(rawEmail);
  const code = String(otp || '').trim();

  if (!EMAIL_RE.test(email)) {
    throw createError('Enter a valid email address.', 400, ErrorCodes.VALIDATION);
  }
  if (!/^\d{6}$/.test(code)) {
    throw createError('Enter the 6-digit code from your email.', 400, ErrorCodes.VALIDATION);
  }

  const result = await passwordResetRepository.verifyOtp({ email, otp: code });
  if (!result.ok) {
    const messages = {
      not_found: 'No active reset code found. Request a new one.',
      expired: 'That code has expired. Request a new one.',
      locked: 'Too many attempts. Request a new code.',
      mismatch: 'Incorrect code. Please try again.',
    };
    throw createError(
      messages[result.reason] || 'Invalid reset code.',
      400,
      ErrorCodes.VALIDATION,
    );
  }

  return { verified: true, email };
}

async function resetPasswordWithOtp({
  email: rawEmail,
  otp,
  password,
}) {
  const email = normalizeEmail(rawEmail);
  const code = String(otp || '').trim();

  if (!EMAIL_RE.test(email)) {
    throw createError('Enter a valid email address.', 400, ErrorCodes.VALIDATION);
  }
  if (!/^\d{6}$/.test(code)) {
    throw createError('Enter the 6-digit code from your email.', 400, ErrorCodes.VALIDATION);
  }
  if (!password || String(password).length < 6) {
    throw createError(
      'Password must be at least 6 characters.',
      400,
      ErrorCodes.VALIDATION,
    );
  }

  const result = await passwordResetRepository.verifyOtp({ email, otp: code });
  if (!result.ok) {
    const messages = {
      not_found: 'No active reset code found. Request a new one.',
      expired: 'That code has expired. Request a new one.',
      locked: 'Too many attempts. Request a new code.',
      mismatch: 'Incorrect code. Please try again.',
    };
    throw createError(
      messages[result.reason] || 'Invalid reset code.',
      400,
      ErrorCodes.VALIDATION,
    );
  }

  const passwordHash = await bcrypt.hash(String(password), BCRYPT_ROUNDS);
  await userRepository.updatePasswordHash(result.row.user_id, passwordHash);
  await passwordResetRepository.markConsumed(result.row.id);
  await passwordResetRepository.invalidateOpenForEmail(email);

  return { reset: true };
}

module.exports = {
  createOrReuseGuest,
  upgradeGuest,
  login,
  refreshSession,
  logout,
  requestPasswordReset,
  verifyPasswordResetOtp,
  resetPasswordWithOtp,
};
