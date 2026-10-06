const { createError, ErrorCodes } = require('../utils/error');
const postRepository = require('../repositories/post_repository');
const secretProfileService = require('./secret_profile_service');
const secretProfileRepository = require('../repositories/secret_profile_repository');

function toTimeAgo(createdAt) {
  if (!createdAt) return '';
  const created = new Date(
    typeof createdAt === 'string' ? createdAt.replace(' ', 'T') : createdAt,
  );
  if (Number.isNaN(created.getTime())) return '';

  const seconds = Math.floor((Date.now() - created.getTime()) / 1000);
  if (seconds < 45) return 'Just now';
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days}d ago`;
  return created.toISOString().slice(0, 10);
}

function serializeAuthor(username, avatarUrl = null) {
  return {
    username: username || 'Anonymous',
    avatar_url: avatarUrl || null,
  };
}

function serializePost(row, viewerUserId) {
  return {
    id: String(row.id),
    content: row.content,
    image_url: row.image_url || null,
    likes_count: Number(row.likes_count) || 0,
    comments_count: Number(row.comments_count) || 0,
    liked_by_me: Boolean(Number(row.liked_by_me)),
    is_mine: Number(row.user_id) === Number(viewerUserId),
    created_at: row.created_at,
    time_ago: toTimeAgo(row.created_at),
    author: serializeAuthor(row.author_username, row.author_avatar_url),
  };
}

function serializeComment(row, viewerUserId) {
  return {
    id: String(row.id),
    post_id: String(row.post_id),
    body: row.body,
    likes_count: Number(row.likes_count) || 0,
    liked_by_me: Boolean(Number(row.liked_by_me)),
    is_mine: Number(row.user_id) === Number(viewerUserId),
    created_at: row.created_at,
    time_ago: toTimeAgo(row.created_at),
    author: serializeAuthor(row.author_username, row.author_avatar_url),
  };
}

/**
 * GET /posts?filter=popular|mine
 */
async function listPosts(userId, query = {}) {
  const filter = String(query.filter || 'popular').toLowerCase();
  const mineOnly = filter === 'mine';
  const rows = await postRepository.listPosts({
    viewerUserId: userId,
    mineOnly,
  });
  return {
    posts: rows.map((r) => serializePost(r, userId)),
  };
}

/**
 * POST /posts  { content, image_url? }
 */
async function createPost(userId, body = {}) {
  await secretProfileService.requireProfile(userId);

  const content = String(body.content || '').trim();
  if (!content) {
    throw createError('Please write something for your post.', 400, ErrorCodes.VALIDATION);
  }
  if (content.length > 4000) {
    throw createError('Post is too long (max 4000 characters).', 400, ErrorCodes.VALIDATION);
  }

  const imageUrl =
    typeof body.image_url === 'string' && body.image_url.trim()
      ? body.image_url.trim().slice(0, 512)
      : null;

  const created = await postRepository.createPost({
    userId,
    content,
    imageUrl,
  });

  const profile = await secretProfileService.requireProfile(userId);
  const avatarUrl = await secretProfileRepository.getUserAvatarUrl(userId);
  return {
    post: serializePost(
      {
        ...created,
        author_username: profile.username,
        author_avatar_url: avatarUrl,
        liked_by_me: 0,
      },
      userId,
    ),
  };
}

/**
 * DELETE /posts/:id
 */
async function deletePost(userId, postId) {
  const id = Number(postId);
  if (!id) {
    throw createError('Invalid post.', 400, ErrorCodes.VALIDATION);
  }
  const ok = await postRepository.softDeletePost(id, userId);
  if (!ok) {
    throw createError('Post not found or you cannot delete it.', 404, ErrorCodes.NOT_FOUND);
  }
  return { deleted: true, id: String(id) };
}

/**
 * POST /posts/:id/likes — toggle like
 */
async function togglePostLike(userId, postId) {
  const id = Number(postId);
  if (!id) {
    throw createError('Invalid post.', 400, ErrorCodes.VALIDATION);
  }
  const post = await postRepository.findPostById(id);
  if (!post || post.deleted_at || post.is_hidden) {
    throw createError('Post not found.', 404, ErrorCodes.NOT_FOUND);
  }

  const existing = await postRepository.findPostLike(id, userId);
  if (existing) {
    await postRepository.removePostLike(id, userId);
  } else {
    await postRepository.addPostLike(id, userId);
  }

  const updated = await postRepository.findPostById(id);
  const liked = !(existing);
  return {
    post_id: String(id),
    liked_by_me: liked,
    likes_count: Number(updated?.likes_count) || 0,
  };
}

/**
 * GET /posts/:id/comments
 */
async function listComments(userId, postId) {
  const id = Number(postId);
  if (!id) {
    throw createError('Invalid post.', 400, ErrorCodes.VALIDATION);
  }
  const post = await postRepository.findPostById(id);
  if (!post || post.deleted_at || post.is_hidden) {
    throw createError('Post not found.', 404, ErrorCodes.NOT_FOUND);
  }

  const rows = await postRepository.listComments(id, userId);
  return {
    comments: rows.map((r) => serializeComment(r, userId)),
  };
}

/**
 * POST /posts/:id/comments  { body }
 */
async function createComment(userId, postId, body = {}) {
  await secretProfileService.requireProfile(userId);

  const id = Number(postId);
  if (!id) {
    throw createError('Invalid post.', 400, ErrorCodes.VALIDATION);
  }
  const post = await postRepository.findPostById(id);
  if (!post || post.deleted_at || post.is_hidden) {
    throw createError('Post not found.', 404, ErrorCodes.NOT_FOUND);
  }

  const text = String(body.body || body.text || '').trim();
  if (!text) {
    throw createError('Comment cannot be empty.', 400, ErrorCodes.VALIDATION);
  }
  if (text.length > 2000) {
    throw createError('Comment is too long (max 2000 characters).', 400, ErrorCodes.VALIDATION);
  }

  const created = await postRepository.createComment({
    postId: id,
    userId,
    body: text,
  });
  const profile = await secretProfileService.requireProfile(userId);
  const avatarUrl = await secretProfileRepository.getUserAvatarUrl(userId);
  const updatedPost = await postRepository.findPostById(id);

  return {
    comment: serializeComment(
      {
        ...created,
        author_username: profile.username,
        author_avatar_url: avatarUrl,
        liked_by_me: 0,
      },
      userId,
    ),
    comments_count: Number(updatedPost?.comments_count) || 0,
  };
}

/**
 * POST /comments/:id/likes — toggle like
 */
async function toggleCommentLike(userId, commentId) {
  const id = Number(commentId);
  if (!id) {
    throw createError('Invalid comment.', 400, ErrorCodes.VALIDATION);
  }
  const comment = await postRepository.findCommentById(id);
  if (!comment || comment.deleted_at) {
    throw createError('Comment not found.', 404, ErrorCodes.NOT_FOUND);
  }

  const existing = await postRepository.findCommentLike(id, userId);
  if (existing) {
    await postRepository.removeCommentLike(id, userId);
  } else {
    await postRepository.addCommentLike(id, userId);
  }

  const updated = await postRepository.findCommentById(id);
  return {
    comment_id: String(id),
    liked_by_me: !existing,
    likes_count: Number(updated?.likes_count) || 0,
  };
}

module.exports = {
  listPosts,
  createPost,
  deletePost,
  togglePostLike,
  listComments,
  createComment,
  toggleCommentLike,
};
