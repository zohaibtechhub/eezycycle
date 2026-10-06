const { createError, ErrorCodes } = require('../utils/error');
const articleBookmarkRepository = require('../repositories/article_bookmark_repository');

const ARTICLE_ID_RE = /^[A-Za-z0-9_-]{1,64}$/;

function normalizeArticleId(raw) {
  const id = String(raw || '').trim();
  if (!ARTICLE_ID_RE.test(id)) {
    throw createError('Invalid article id.', 400, ErrorCodes.VALIDATION);
  }
  return id;
}

async function listBookmarks(userId) {
  const rows = await articleBookmarkRepository.listByUser(userId);
  return {
    article_ids: rows.map((r) => r.article_id),
    items: rows.map((r) => ({
      article_id: r.article_id,
      created_at: r.created_at,
    })),
  };
}

async function addBookmark(userId, articleIdRaw) {
  const articleId = normalizeArticleId(articleIdRaw);
  const row = await articleBookmarkRepository.create(userId, articleId);
  return {
    article_id: articleId,
    bookmarked: true,
    created_at: row?.created_at || null,
  };
}

async function removeBookmark(userId, articleIdRaw) {
  const articleId = normalizeArticleId(articleIdRaw);
  await articleBookmarkRepository.remove(userId, articleId);
  return { article_id: articleId, bookmarked: false };
}

async function isBookmarked(userId, articleIdRaw) {
  const articleId = normalizeArticleId(articleIdRaw);
  const row = await articleBookmarkRepository.findOne(userId, articleId);
  return { article_id: articleId, bookmarked: !!row };
}

module.exports = {
  listBookmarks,
  addBookmark,
  removeBookmark,
  isBookmarked,
};
