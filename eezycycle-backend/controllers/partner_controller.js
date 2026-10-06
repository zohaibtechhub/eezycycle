const partnerService = require('../services/partner_service');
const { asyncHandler } = require('../utils/async_handler');

const postCode = asyncHandler(async (req, res) => {
  const data = await partnerService.generateCode(req.userId, req.body || {});
  res.json({
    success: true,
    message: 'Partner code ready',
    data,
  });
});

const postLink = asyncHandler(async (req, res) => {
  const data = await partnerService.linkWithCode(req.userId, req.body || {});
  res.json({
    success: true,
    message: 'Partner linked successfully',
    data,
  });
});

const getStatus = asyncHandler(async (req, res) => {
  const data = await partnerService.getStatus(req.userId);
  res.json({ success: true, data });
});

const deleteLink = asyncHandler(async (req, res) => {
  const data = await partnerService.disconnect(req.userId);
  res.json({
    success: true,
    message: 'Partner disconnected',
    data,
  });
});

const getToday = asyncHandler(async (req, res) => {
  const data = await partnerService.getPartnerToday(req.userId, req.query);
  res.json({ success: true, data });
});

const getCalendar = asyncHandler(async (req, res) => {
  const data = await partnerService.getPartnerCalendar(req.userId, req.query);
  res.json({ success: true, data });
});

module.exports = {
  postCode,
  postLink,
  getStatus,
  deleteLink,
  getToday,
  getCalendar,
};
