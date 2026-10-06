const articleBookmarkService = require('../services/article_bookmark_service');
const { asyncHandler } = require('../utils/async_handler');

const listBookmarks = asyncHandler(async (req, res) => {
  const data = await articleBookmarkService.listBookmarks(req.userId);
  res.json({ success: true, data });
});

const addBookmark = asyncHandler(async (req, res) => {
  const articleId = req.params.id || req.body?.article_id || req.body?.articleId;
  const data = await articleBookmarkService.addBookmark(req.userId, articleId);
  res.status(201).json({
    success: true,
    message: 'Article bookmarked',
    data,
  });
});

const removeBookmark = asyncHandler(async (req, res) => {
  const data = await articleBookmarkService.removeBookmark(
    req.userId,
    req.params.id,
  );
  res.json({
    success: true,
    message: 'Bookmark removed',
    data,
  });
});

const getBookmarkStatus = asyncHandler(async (req, res) => {
  const data = await articleBookmarkService.isBookmarked(
    req.userId,
    req.params.id,
  );
  res.json({ success: true, data });
});

module.exports = {
  listBookmarks,
  addBookmark,
  removeBookmark,
  getBookmarkStatus,
};
