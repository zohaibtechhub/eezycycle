const postService = require('../services/post_service');
const { asyncHandler } = require('../utils/async_handler');

const getPosts = asyncHandler(async (req, res) => {
  const data = await postService.listPosts(req.userId, req.query);
  res.json({ success: true, data });
});

const createPost = asyncHandler(async (req, res) => {
  const body = { ...(req.body || {}) };
  if (req.file && req.file.filename) {
    body.image_url = `/uploads/posts/${req.file.filename}`;
  }
  const data = await postService.createPost(req.userId, body);
  res.json({
    success: true,
    message: 'Post published',
    data,
  });
});

const deletePost = asyncHandler(async (req, res) => {
  const data = await postService.deletePost(req.userId, req.params.id);
  res.json({
    success: true,
    message: 'Post removed',
    data,
  });
});

const togglePostLike = asyncHandler(async (req, res) => {
  const data = await postService.togglePostLike(req.userId, req.params.id);
  res.json({ success: true, data });
});

const getComments = asyncHandler(async (req, res) => {
  const data = await postService.listComments(req.userId, req.params.id);
  res.json({ success: true, data });
});

const createComment = asyncHandler(async (req, res) => {
  const data = await postService.createComment(
    req.userId,
    req.params.id,
    req.body || {},
  );
  res.json({
    success: true,
    message: 'Comment added',
    data,
  });
});

const toggleCommentLike = asyncHandler(async (req, res) => {
  const data = await postService.toggleCommentLike(req.userId, req.params.id);
  res.json({ success: true, data });
});

module.exports = {
  getPosts,
  createPost,
  deletePost,
  togglePostLike,
  getComments,
  createComment,
  toggleCommentLike,
};
