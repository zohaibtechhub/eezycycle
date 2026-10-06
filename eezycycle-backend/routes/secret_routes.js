const express = require('express');
const {
  getProfile,
  putProfile,
} = require('../controllers/secret_profile_controller');
const { requireAuth } = require('../middleware/auth');
const { requireConsents } = require('../middleware/consent');

const router = express.Router();

router.use(requireAuth);
router.use(requireConsents(['terms', 'health_data']));

router.get('/profile', getProfile);
router.put('/profile', putProfile);

module.exports = router;
