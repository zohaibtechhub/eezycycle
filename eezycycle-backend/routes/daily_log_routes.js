const express = require('express');
const { getLogs, putLogs } = require('../controllers/daily_log_controller');
const { requireAuth } = require('../middleware/auth');
const { requireConsents } = require('../middleware/consent');

const router = express.Router();

router.use(requireAuth);
router.use(requireConsents(['terms', 'health_data']));

router.get('/', getLogs);
router.put('/:date', putLogs);

module.exports = router;
