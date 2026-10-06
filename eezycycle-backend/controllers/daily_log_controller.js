const dailyLogService = require('../services/daily_log_service');
const { asyncHandler } = require('../utils/async_handler');

const getLogs = asyncHandler(async (req, res) => {
  const data = await dailyLogService.getLogs(req.userId, req.query);
  res.json({ success: true, data });
});

const putLogs = asyncHandler(async (req, res) => {
  const data = await dailyLogService.putLogs(
    req.userId,
    req.params.date,
    req.body,
  );
  res.json({ success: true, message: 'Daily log saved', data });
});

module.exports = {
  getLogs,
  putLogs,
};
