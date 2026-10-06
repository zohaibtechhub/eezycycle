const express = require('express');
const {
  putPeriodDays,
  getPeriodDays,
  getToday,
  getCalendar,
  rebuildPredictions,
  putObservations,
  getObservations,
  deleteObservation,
  getInsights,
} = require('../controllers/cycle_controller');
const { requireAuth } = require('../middleware/auth');
const { requireConsents } = require('../middleware/consent');

const router = express.Router();

router.use(requireAuth);
router.use(requireConsents(['terms', 'health_data']));

router.get('/today', getToday);
router.get('/calendar', getCalendar);
router.get('/insights', getInsights);
router.get('/period-days', getPeriodDays);
router.put('/period-days', putPeriodDays);
router.post('/predictions/rebuild', rebuildPredictions);

router.get('/observations', getObservations);
router.put('/observations', putObservations);
router.delete('/observations', deleteObservation);

module.exports = router;
