const express = require('express');
const {
  getOnboarding,
  putAnswers,
  putGoals,
  postComplete,
} = require('../controllers/onboarding_controller');
const { requireAuth } = require('../middleware/auth');
const { requireConsents } = require('../middleware/consent');

const router = express.Router();

router.use(requireAuth);
router.use(requireConsents(['terms', 'health_data']));

router.get('/', getOnboarding);
router.put('/answers', putAnswers);
router.put('/goals', putGoals);
router.post('/complete', postComplete);

module.exports = router;
