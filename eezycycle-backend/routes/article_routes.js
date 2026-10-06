const express = require('express');
const {
  listBookmarks,
  addBookmark,
  removeBookmark,
  getBookmarkStatus,
} = require('../controllers/article_bookmark_controller');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// Any valid JWT (guest or registered) — bookmarks are keyed by user_id.
router.use(requireAuth);

router.get('/bookmarks', listBookmarks);
router.get('/:id/bookmark', getBookmarkStatus);
router.post('/:id/bookmark', addBookmark);
router.delete('/:id/bookmark', removeBookmark);

module.exports = router;
