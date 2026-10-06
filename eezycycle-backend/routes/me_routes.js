const express = require('express');
const {
  getMe,
  patchProfile,
  postConsents,
  postAvatar,
  patchPush,
  patchReminders,
} = require('../controllers/me_controller');
const { requireAuth } = require('../middleware/auth');
const { optionalAvatarImage } = require('../middleware/upload');

const router = express.Router();

router.use(requireAuth);

router.get('/', getMe);
router.patch('/profile', patchProfile);
router.patch('/push', patchPush);
router.patch('/reminders', patchReminders);
router.post('/consents', postConsents);
router.post('/avatar', optionalAvatarImage, postAvatar);

module.exports = router;
