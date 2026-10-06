const express = require('express');
const {
  postCode,
  postLink,
  getStatus,
  deleteLink,
  getToday,
  getCalendar,
} = require('../controllers/partner_controller');
const { requireAuth } = require('../middleware/auth');
const { requireConsents } = require('../middleware/consent');

const router = express.Router();

router.use(requireAuth);
router.use(requireConsents(['terms', 'health_data']));

router.post('/code', postCode);
router.post('/link', postLink);
router.get('/status', getStatus);
router.delete('/link', deleteLink);
router.get('/today', getToday);
router.get('/calendar', getCalendar);

module.exports = router;
