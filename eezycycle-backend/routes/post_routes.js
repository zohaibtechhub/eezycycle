const express = require('express');
const {
  getPosts,
  createPost,
  deletePost,
  togglePostLike,
  getComments,
  createComment,
} = require('../controllers/post_controller');
const { requireAuth } = require('../middleware/auth');
const { requireConsents } = require('../middleware/consent');
const { optionalPostImage } = require('../middleware/upload');

const router = express.Router();

router.use(requireAuth);
router.use(requireConsents(['terms', 'health_data']));

router.get('/', getPosts);
router.post('/', optionalPostImage, createPost);
router.delete('/:id', deletePost);
router.post('/:id/likes', togglePostLike);
router.get('/:id/comments', getComments);
router.post('/:id/comments', createComment);

module.exports = router;
