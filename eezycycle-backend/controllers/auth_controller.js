const authService = require('../services/auth_service');
const { asyncHandler } = require('../utils/async_handler');

const createGuest = asyncHandler(async (req, res) => {
  const data = await authService.createOrReuseGuest({
    deviceId: req.body.device_id || req.body.deviceId,
    platform: req.body.platform,
    appVersion: req.body.app_version || req.body.appVersion,
  });

  res.status(201).json({
    success: true,
    message: 'Guest session ready',
    data,
  });
});

const refresh = asyncHandler(async (req, res) => {
  const data = await authService.refreshSession({
    refreshToken: req.body.refresh_token || req.body.refreshToken,
  });

  res.json({
    success: true,
    data,
  });
});

const logout = asyncHandler(async (req, res) => {
  const data = await authService.logout({
    userId: req.userId,
    deviceId: req.deviceId,
    refreshToken: req.body.refresh_token || req.body.refreshToken,
  });

  res.json({
    success: true,
    message: 'Logged out',
    data,
  });
});

/** Guest JWT required — upgrades same user_id in place. */
const upgrade = asyncHandler(async (req, res) => {
  const data = await authService.upgradeGuest({
    userId: req.userId,
    accountStatus: req.accountStatus,
    deviceId: req.deviceId,
    email: req.body.email,
    password: req.body.password,
    googleIdToken: req.body.google_id_token || req.body.googleIdToken,
  });

  res.json({
    success: true,
    message: 'Account created — your cycle data stays with you',
    data,
  });
});

/** Optional guest JWT — attaches device when logging into existing account. */
const login = asyncHandler(async (req, res) => {
  const data = await authService.login({
    email: req.body.email,
    password: req.body.password,
    googleIdToken: req.body.google_id_token || req.body.googleIdToken,
    guestUserId: req.userId || null,
    guestAccountStatus: req.accountStatus || null,
    deviceId: req.deviceId || null,
  });

  res.json({
    success: true,
    message: 'Signed in',
    data,
  });
});

const forgotPassword = asyncHandler(async (req, res) => {
  const data = await authService.requestPasswordReset({
    email: req.body.email,
  });

  res.json({
    success: true,
    message: data.message,
    data,
  });
});

const verifyResetOtp = asyncHandler(async (req, res) => {
  const data = await authService.verifyPasswordResetOtp({
    email: req.body.email,
    otp: req.body.otp || req.body.code,
  });

  res.json({
    success: true,
    message: 'Code verified',
    data,
  });
});

const resetPassword = asyncHandler(async (req, res) => {
  const data = await authService.resetPasswordWithOtp({
    email: req.body.email,
    otp: req.body.otp || req.body.code,
    password: req.body.password || req.body.new_password || req.body.newPassword,
  });

  res.json({
    success: true,
    message: 'Password updated. You can sign in now.',
    data,
  });
});

module.exports = {
  createGuest,
  refresh,
  logout,
  upgrade,
  login,
  forgotPassword,
  verifyResetOtp,
  resetPassword,
};
