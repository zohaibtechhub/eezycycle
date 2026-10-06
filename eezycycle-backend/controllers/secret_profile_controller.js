const secretProfileService = require('../services/secret_profile_service');
const { asyncHandler } = require('../utils/async_handler');

const getProfile = asyncHandler(async (req, res) => {
  const data = await secretProfileService.getMyProfile(req.userId);
  res.json({ success: true, data });
});

const putProfile = asyncHandler(async (req, res) => {
  const data = await secretProfileService.upsertMyProfile(req.userId, req.body || {});
  res.json({
    success: true,
    message: 'Secret profile updated',
    data,
  });
});

module.exports = {
  getProfile,
  putProfile,
};
