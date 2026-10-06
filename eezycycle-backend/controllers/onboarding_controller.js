const onboardingService = require('../services/onboarding_service');
const { asyncHandler } = require('../utils/async_handler');

const getOnboarding = asyncHandler(async (req, res) => {
  const data = await onboardingService.getOnboardingState(
    req.userId,
    req.query.flow_key || req.query.flow,
  );
  res.json({ success: true, data });
});

const putAnswers = asyncHandler(async (req, res) => {
  const data = await onboardingService.upsertAnswers(req.userId, req.body);
  res.json({ success: true, message: 'Answers saved', data });
});

const putGoals = asyncHandler(async (req, res) => {
  const data = await onboardingService.replaceGoals(req.userId, req.body);
  res.json({ success: true, message: 'Goals saved', data });
});

const postComplete = asyncHandler(async (req, res) => {
  const data = await onboardingService.completeOnboarding(req.userId, req.body);
  res.json({ success: true, message: 'Onboarding completed', data });
});

module.exports = {
  getOnboarding,
  putAnswers,
  putGoals,
  postComplete,
};
