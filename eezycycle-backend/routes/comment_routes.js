const express = require('express');
const { toggleCommentLike } = require('../controllers/post_controller');
const { requireAuth } = require('../middleware/auth');
const { requireConsents } = require('../middleware/consent');

const router = express.Router();

router.use(requireAuth);
router.use(requireConsents(['terms', 'health_data']));

router.post('/:id/likes', toggleCommentLike);

module.exports = router;
