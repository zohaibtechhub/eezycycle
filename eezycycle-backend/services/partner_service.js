const { createError, ErrorCodes } = require('../utils/error');
const partnerRepository = require('../repositories/partner_repository');
const profileRepository = require('../repositories/profile_repository');
const userRepository = require('../repositories/user_repository');
const cycleService = require('./cycle_service');

const CODE_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

function generateCodeString(length = 6) {
  let out = '';
  for (let i = 0; i < length; i += 1) {
    out += CODE_ALPHABET[Math.floor(Math.random() * CODE_ALPHABET.length)];
  }
  return out;
}

async function uniqueCode() {
  for (let attempt = 0; attempt < 12; attempt += 1) {
    const code = generateCodeString(6);
    // eslint-disable-next-line no-await-in-loop
    if (!(await partnerRepository.codeExists(code))) return code;
  }
  throw createError(
    'Could not generate a partner code. Please try again.',
    500,
    ErrorCodes.INTERNAL,
  );
}

function stripIntimateToday(payload) {
  if (!payload || typeof payload !== 'object') return payload;
  const {
    insights: _insights,
    evidence_sources: _sources,
    predictions_for_date: _preds,
    ...safe
  } = payload;
  return {
    ...safe,
    insights: [],
    partner_view: true,
  };
}

function stripIntimateCalendar(payload) {
  if (!payload || typeof payload !== 'object') return payload;
  const days = Array.isArray(payload.days)
    ? payload.days.map((d) => ({
        date: d.date,
        day_type: d.day_type,
        is_predicted: Boolean(d.is_predicted),
        is_observation: Boolean(d.is_observation),
        period_day: d.period_day ?? null,
      }))
    : [];
  return {
    from: payload.from,
    to: payload.to,
    days,
    last_period_start: payload.last_period_start || null,
    algorithm_version: payload.algorithm_version || null,
    partner_view: true,
    profile: payload.profile
      ? {
          experience_mode: 'partner',
          avg_cycle_length: payload.profile.avg_cycle_length,
          avg_period_length: payload.profile.avg_period_length,
          fertile_window_mode: payload.profile.fertile_window_mode,
          pregnancy_mode_active: payload.profile.pregnancy_mode_active,
          last_period_start: payload.profile.last_period_start,
        }
      : null,
  };
}

/**
 * Woman (owner): generate or reuse invite code (shared by multiple partners).
 * Body: { consented?: true }
 */
async function generateCode(userId, body = {}) {
  await profileRepository.ensureExists(userId);
  const profile = await profileRepository.findByUserId(userId);

  if (profile?.usage_path === 'partner' || profile?.experience_mode === 'partner') {
    throw createError(
      'Partner accounts cannot generate invite codes.',
      403,
      ErrorCodes.FORBIDDEN,
    );
  }

  const activePartners = await partnerRepository.listActiveByOwner(userId);
  let invite = await partnerRepository.findOpenInviteByOwner(userId);

  if (!invite) {
    // Prefer reusing code from an existing active link if invite row was consumed
    // under the old single-partner flow.
    const existing = await partnerRepository.findActiveOrPendingByOwner(userId);
    if (existing?.code) {
      invite = await partnerRepository.createPending({
        ownerUserId: userId,
        code: existing.code,
        shareScope: existing.share_scope,
        ownerConsentedAt: existing.owner_consented_at || new Date(),
      });
    }
  }

  if (invite) {
    return {
      code: invite.code,
      status: invite.status,
      share_scope: invite.share_scope,
      linked: activePartners.length > 0,
      partner_count: activePartners.length,
      partner_user_ids: activePartners.map((p) => p.partner_user_id),
      partner_user_id: activePartners[0]?.partner_user_id || null,
    };
  }

  const consented = body.consented !== false;
  if (!consented) {
    throw createError(
      'Please accept partner sharing disclosure before generating a code.',
      400,
      ErrorCodes.VALIDATION,
    );
  }

  const code = await uniqueCode();
  const link = await partnerRepository.createPending({
    ownerUserId: userId,
    code,
    shareScope: partnerRepository.DEFAULT_SHARE_SCOPE,
    ownerConsentedAt: new Date(),
  });

  return {
    code: link.code,
    status: link.status,
    share_scope: link.share_scope,
    linked: false,
    partner_count: 0,
    partner_user_ids: [],
    partner_user_id: null,
  };
}

/**
 * Male partner: enter code + consent to link.
 * Same code can be used by multiple partners (one active link each).
 * If already linked to this code (or already an active partner on it), succeed
 * so onboarding / retries can proceed without 409.
 * Body: { code, consented: true }
 */
async function linkWithCode(userId, body = {}) {
  const rawCode = String(body.code || body.partner_code || '').trim().toUpperCase();
  if (!/^[A-Z0-9]{4,8}$/.test(rawCode)) {
    throw createError(
      'Enter a valid partner code (6 characters).',
      400,
      ErrorCodes.VALIDATION,
    );
  }
  if (body.consented !== true && body.consented !== 1 && body.consented !== 'true') {
    throw createError(
      'Please accept what your partner can share before linking.',
      400,
      ErrorCodes.VALIDATION,
    );
  }

  async function succeedExisting(link, { alreadyLinked = true } = {}) {
    await profileRepository.ensureExists(userId);
    await profileRepository.update(userId, {
      usage_path: 'partner',
      experience_mode: 'partner',
      partner_code_entered: link.code,
    });
    const partnerCount = (
      await partnerRepository.listActiveByOwner(link.owner_user_id)
    ).length;
    return {
      linked: true,
      already_linked: alreadyLinked,
      code: link.code,
      status: link.status,
      role: 'partner',
      owner_user_id: link.owner_user_id,
      share_scope: link.share_scope,
      linked_at: link.linked_at,
      partner_count: partnerCount,
    };
  }

  const alreadyPartner = await partnerRepository.findActiveByPartner(userId);
  if (alreadyPartner) {
    if (String(alreadyPartner.code).toUpperCase() === rawCode) {
      return succeedExisting(alreadyPartner);
    }
    throw createError(
      'You are already linked to a different partner. Disconnect first to switch.',
      409,
      ErrorCodes.CONFLICT,
    );
  }

  const asOwnerInvite = await partnerRepository.findOpenInviteByOwner(userId);
  const asOwnerAny = await partnerRepository.findActiveOrPendingByOwner(userId);
  if (asOwnerInvite || asOwnerAny) {
    throw createError(
      'This account already has a partner invite. Disconnect first.',
      409,
      ErrorCodes.CONFLICT,
    );
  }

  let invite = await partnerRepository.findOpenInviteByCode(rawCode);
  // Legacy: first partner consumed the pending row — recover from any live code row.
  if (!invite) {
    const legacy = await partnerRepository.findByCode(rawCode);
    if (!legacy || legacy.status === 'revoked') {
      throw createError('Partner code not found or expired.', 404, ErrorCodes.NOT_FOUND);
    }
    if (Number(legacy.owner_user_id) === Number(userId)) {
      throw createError('You cannot link to your own code.', 400, ErrorCodes.VALIDATION);
    }
    // Recreate open invite so future partners can join the same code.
    invite = await partnerRepository.createPending({
      ownerUserId: legacy.owner_user_id,
      code: legacy.code,
      shareScope: legacy.share_scope,
      ownerConsentedAt: legacy.owner_consented_at || new Date(),
    });
  }

  if (Number(invite.owner_user_id) === Number(userId)) {
    throw createError('You cannot link to your own code.', 400, ErrorCodes.VALIDATION);
  }

  const alreadyOnThisOwner = await partnerRepository.findActiveByOwnerAndPartner(
    invite.owner_user_id,
    userId,
  );
  if (alreadyOnThisOwner) {
    return succeedExisting(alreadyOnThisOwner);
  }

  const activated = await partnerRepository.createActiveForPartner({
    ownerUserId: invite.owner_user_id,
    partnerUserId: userId,
    code: invite.code,
    shareScope: invite.share_scope,
    ownerConsentedAt: invite.owner_consented_at,
  });

  await profileRepository.ensureExists(userId);
  await profileRepository.update(userId, {
    usage_path: 'partner',
    experience_mode: 'partner',
    partner_code_entered: activated.code,
  });

  const partnerCount = (
    await partnerRepository.listActiveByOwner(invite.owner_user_id)
  ).length;

  return {
    linked: true,
    already_linked: false,
    code: activated.code,
    status: activated.status,
    role: 'partner',
    owner_user_id: activated.owner_user_id,
    share_scope: activated.share_scope,
    linked_at: activated.linked_at,
    partner_count: partnerCount,
  };
}

async function getStatus(userId) {
  const asPartner = await partnerRepository.findActiveByPartner(userId);
  if (asPartner) {
    const owner = await userRepository.findActiveById(asPartner.owner_user_id);
    return {
      connected: true,
      role: 'partner',
      code: asPartner.code,
      status: asPartner.status,
      share_scope: asPartner.share_scope,
      owner_user_id: asPartner.owner_user_id,
      partner_user_id: asPartner.partner_user_id,
      linked_at: asPartner.linked_at,
      partner_count: 1,
      owner_avatar_url: owner?.avatar_url || null,
      owner_name: owner?.name || null,
    };
  }

  const invite =
    (await partnerRepository.findOpenInviteByOwner(userId)) ||
    (await partnerRepository.findActiveOrPendingByOwner(userId));
  const activePartners = await partnerRepository.listActiveByOwner(userId);

  if (!invite && activePartners.length === 0) {
    return {
      connected: false,
      role: null,
      code: null,
      status: null,
      share_scope: partnerRepository.DEFAULT_SHARE_SCOPE,
      partner_count: 0,
      partner_user_ids: [],
    };
  }

  const self = await userRepository.findActiveById(userId);
  return {
    connected: activePartners.length > 0,
    role: 'owner',
    code: invite?.code || activePartners[0]?.code || null,
    status: invite?.status || 'active',
    share_scope:
      invite?.share_scope ||
      activePartners[0]?.share_scope ||
      partnerRepository.DEFAULT_SHARE_SCOPE,
    owner_user_id: userId,
    partner_user_id: activePartners[0]?.partner_user_id || null,
    partner_count: activePartners.length,
    partner_user_ids: activePartners.map((p) => p.partner_user_id),
    linked_at: activePartners[0]?.linked_at || null,
    owner_avatar_url: self?.avatar_url || null,
  };
}

async function disconnect(userId) {
  const asPartner = await partnerRepository.findActiveByPartner(userId);
  if (asPartner) {
    const revoked = await partnerRepository.revokeById(asPartner.id);
    await profileRepository.update(userId, {
      partner_code_entered: null,
    });
    return {
      connected: false,
      status: revoked?.status || 'revoked',
      code: revoked?.code || asPartner.code,
      role: 'partner',
    };
  }

  const asOwner =
    (await partnerRepository.findOpenInviteByOwner(userId)) ||
    (await partnerRepository.findActiveOrPendingByOwner(userId));
  const activePartners = await partnerRepository.listActiveByOwner(userId);
  if (!asOwner && activePartners.length === 0) {
    throw createError('No partner connection to disconnect.', 404, ErrorCodes.NOT_FOUND);
  }

  await partnerRepository.revokeAllForOwner(userId);

  return {
    connected: false,
    status: 'revoked',
    code: asOwner?.code || activePartners[0]?.code || null,
    role: 'owner',
    partner_count: 0,
  };
}

async function resolveOwnerUserId(viewerUserId) {
  const asPartner = await partnerRepository.findActiveByPartner(viewerUserId);
  if (!asPartner) {
    throw createError(
      'Link with a partner code to view shared cycle insights.',
      403,
      ErrorCodes.FORBIDDEN,
    );
  }
  return { ownerUserId: asPartner.owner_user_id, link: asPartner };
}

async function getPartnerToday(userId, query = {}) {
  const { ownerUserId, link } = await resolveOwnerUserId(userId);
  const today = await cycleService.getToday(ownerUserId, query);
  return {
    ...stripIntimateToday(today),
    share_scope: link.share_scope,
    link_status: link.status,
  };
}

async function getPartnerCalendar(userId, query = {}) {
  const { ownerUserId, link } = await resolveOwnerUserId(userId);
  const calendar = await cycleService.getCalendar(ownerUserId, query);
  return {
    ...stripIntimateCalendar(calendar),
    share_scope: link.share_scope,
    link_status: link.status,
  };
}

module.exports = {
  generateCode,
  linkWithCode,
  getStatus,
  disconnect,
  getPartnerToday,
  getPartnerCalendar,
};
