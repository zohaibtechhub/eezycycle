const { createError, ErrorCodes } = require('../utils/error');
const secretProfileRepository = require('../repositories/secret_profile_repository');

function normalizeUsername(raw) {
  return String(raw || '').trim().replace(/\s+/g, ' ');
}

function validateUsername(username) {
  if (username.length < 3 || username.length > 40) {
    throw createError(
      'Username must be between 3 and 40 characters.',
      400,
      ErrorCodes.VALIDATION,
    );
  }
}

async function withUserAvatar(row, tags) {
  if (!row) return null;
  const avatarUrl = await secretProfileRepository.getUserAvatarUrl(row.user_id);
  return secretProfileRepository.serializeProfile(row, tags, avatarUrl);
}

/**
 * GET /secret/profile — current user's secret identity (or null if unset).
 */
async function getMyProfile(userId) {
  const row = await secretProfileRepository.findByUserId(userId);
  if (!row) {
    return { profile: null };
  }
  const tags = await secretProfileRepository.listTags(userId);
  return {
    profile: await withUserAvatar(row, tags),
  };
}

/**
 * PUT /secret/profile — upsert username + tags.
 * Body: { username, tags?: string[] }
 * Avatar comes from the account profile photo (users.avatar_url).
 */
async function upsertMyProfile(userId, body = {}) {
  const username = normalizeUsername(body.username);
  validateUsername(username);

  const existingOther = await secretProfileRepository.findByUsername(username);
  if (existingOther && Number(existingOther.user_id) !== Number(userId)) {
    throw createError(
      'That username is already taken. Please choose another.',
      409,
      ErrorCodes.CONFLICT,
    );
  }

  const tags = Array.isArray(body.tags) ? body.tags : [];
  if (tags.length > 20) {
    throw createError(
      'You can select up to 20 profile tags.',
      400,
      ErrorCodes.VALIDATION,
    );
  }

  const accountAvatar = await secretProfileRepository.getUserAvatarUrl(userId);
  const existing = await secretProfileRepository.findByUserId(userId);
  const row = await secretProfileRepository.upsertProfile(userId, {
    username,
    avatarUrl: accountAvatar || existing?.avatar_url || null,
  });
  const savedTags = await secretProfileRepository.replaceTags(userId, tags);

  return {
    profile: await withUserAvatar(row, savedTags),
  };
}

/**
 * Ensures the user has a secret profile before posting / commenting.
 */
async function requireProfile(userId) {
  const row = await secretProfileRepository.findByUserId(userId);
  if (!row) {
    throw createError(
      'Set up your secret chat username before posting.',
      400,
      ErrorCodes.VALIDATION,
    );
  }
  return row;
}

module.exports = {
  getMyProfile,
  upsertMyProfile,
  requireProfile,
};
