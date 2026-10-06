const express = require('express');
const {
  createGuest,
  refresh,
  logout,
  upgrade,
  login,
  forgotPassword,
  verifyResetOtp,
  resetPassword,
} = require('../controllers/auth_controller');
const { requireAuth } = require('../middleware/auth');
const { optionalAuth } = require('../middleware/optional_auth');

const router = express.Router();

router.post('/guest', createGuest);
router.post('/refresh', refresh);
router.post('/logout', requireAuth, logout);
router.post('/upgrade', requireAuth, upgrade);
router.post('/login', optionalAuth, login);
router.post('/forgot-password', forgotPassword);
router.post('/verify-reset-otp', verifyResetOtp);
router.post('/reset-password', resetPassword);

module.exports = router;
