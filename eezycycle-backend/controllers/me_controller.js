const meService = require('../services/me_service');
const { asyncHandler } = require('../utils/async_handler');
const { createError, ErrorCodes } = require('../utils/error');

const getMe = asyncHandler(async (req, res) => {
  const data = await meService.getMe(req.userId);
  res.json({ success: true, data });
});

const patchProfile = asyncHandler(async (req, res) => {
  const data = await meService.updateProfile(req.userId, req.body);
  res.json({ success: true, message: 'Profile updated', data });
});

const postConsents = asyncHandler(async (req, res) => {
  const data = await meService.saveConsents(req.userId, req.body);
  res.json({ success: true, message: 'Consents saved', data });
});

const postAvatar = asyncHandler(async (req, res) => {
  if (!req.file) {
    throw createError('Please choose a photo to upload.', 400, ErrorCodes.VALIDATION);
  }
  const relativeUrl = `/uploads/avatars/${req.file.filename}`;
  const data = await meService.updateAvatar(req.userId, relativeUrl);
  res.json({
    success: true,
    message: 'Profile photo updated',
    data,
  });
});

const patchPush = asyncHandler(async (req, res) => {
  const data = await meService.updatePush(req.userId, req.body || {});
  res.json({ success: true, message: 'Push device updated', data });
});

const patchReminders = asyncHandler(async (req, res) => {
  const data = await meService.updateReminders(req.userId, req.body || {});
  res.json({ success: true, message: 'Reminders updated', data });
});

module.exports = {
  getMe,
  patchProfile,
  postConsents,
  postAvatar,
  patchPush,
  patchReminders,
};
