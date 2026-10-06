const express = require('express');
const {
  getHealth,
  getPing,
  getDemoError,
} = require('../controllers/health_controller');

const router = express.Router();

router.get('/health', getHealth);
router.get('/ping', getPing);
router.get('/demo-error', getDemoError);

module.exports = router;
