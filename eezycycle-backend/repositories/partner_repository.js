const { pool } = require('../config/db');

const DEFAULT_SHARE_SCOPE = [
  'cycle_phase',
  'predicted_period',
  'predicted_fertile',
  'predicted_ovulation',
];

function parseShareScope(raw) {
  if (Array.isArray(raw)) return raw;
  if (typeof raw === 'string') {
    try {
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed : DEFAULT_SHARE_SCOPE;
    } catch (_) {
      return DEFAULT_SHARE_SCOPE;
    }
  }
  return DEFAULT_SHARE_SCOPE;
}

function serialize(row) {
  if (!row) return null;
  return {
    id: row.id,
    code: row.code,
    owner_user_id: row.owner_user_id,
    partner_user_id: row.partner_user_id,
    status: row.status,
    share_scope: parseShareScope(row.share_scope),
    owner_consented_at: row.owner_consented_at,
    created_at: row.created_at,
    linked_at: row.linked_at,
    revoked_at: row.revoked_at,
  };
}

const SELECT_COLS = `id, code, owner_user_id, partner_user_id, status, share_scope,
            owner_consented_at, created_at, linked_at, revoked_at`;

/** Open invite template: pending + no partner yet (reusable for multi-join). */
async function findOpenInviteByCode(code) {
  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLS}
     FROM partner_links
     WHERE code = ?
       AND status = 'pending'
       AND partner_user_id IS NULL
     ORDER BY id DESC
     LIMIT 1`,
    [String(code || '').toUpperCase()],
  );
  return serialize(rows[0]);
}

/** Any non-revoked row for this code (fallback to discover owner after multi links). */
async function findByCode(code) {
  const invite = await findOpenInviteByCode(code);
  if (invite) return invite;

  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLS}
     FROM partner_links
     WHERE code = ?
       AND status IN ('pending', 'active')
     ORDER BY id DESC
     LIMIT 1`,
    [String(code || '').toUpperCase()],
  );
  return serialize(rows[0]);
}

async function findOpenInviteByOwner(ownerUserId) {
  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLS}
     FROM partner_links
     WHERE owner_user_id = ?
       AND status = 'pending'
       AND partner_user_id IS NULL
     ORDER BY id DESC
     LIMIT 1`,
    [ownerUserId],
  );
  return serialize(rows[0]);
}

async function findActiveOrPendingByOwner(ownerUserId) {
  const invite = await findOpenInviteByOwner(ownerUserId);
  if (invite) return invite;

  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLS}
     FROM partner_links
     WHERE owner_user_id = ?
       AND status IN ('pending', 'active')
     ORDER BY FIELD(status, 'active', 'pending'), id DESC
     LIMIT 1`,
    [ownerUserId],
  );
  return serialize(rows[0]);
}

async function listActiveByOwner(ownerUserId) {
  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLS}
     FROM partner_links
     WHERE owner_user_id = ?
       AND status = 'active'
       AND partner_user_id IS NOT NULL
     ORDER BY linked_at DESC, id DESC`,
    [ownerUserId],
  );
  return rows.map(serialize);
}

async function findActiveByPartner(partnerUserId) {
  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLS}
     FROM partner_links
     WHERE partner_user_id = ?
       AND status = 'active'
     ORDER BY id DESC
     LIMIT 1`,
    [partnerUserId],
  );
  return serialize(rows[0]);
}

async function findActiveByOwnerAndPartner(ownerUserId, partnerUserId) {
  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLS}
     FROM partner_links
     WHERE owner_user_id = ?
       AND partner_user_id = ?
       AND status = 'active'
     ORDER BY id DESC
     LIMIT 1`,
    [ownerUserId, partnerUserId],
  );
  return serialize(rows[0]);
}

async function findLinkForUser(userId) {
  const asOwner = await findActiveOrPendingByOwner(userId);
  if (asOwner) return { role: 'owner', link: asOwner };
  const asPartner = await findActiveByPartner(userId);
  if (asPartner) return { role: 'partner', link: asPartner };
  return { role: null, link: null };
}

async function createPending({ ownerUserId, code, shareScope, ownerConsentedAt }) {
  const scopeJson = JSON.stringify(shareScope || DEFAULT_SHARE_SCOPE);
  const [result] = await pool.execute(
    `INSERT INTO partner_links
       (code, owner_user_id, partner_user_id, status, share_scope, owner_consented_at)
     VALUES (?, ?, NULL, 'pending', ?, ?)`,
    [code, ownerUserId, scopeJson, ownerConsentedAt || new Date()],
  );
  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLS} FROM partner_links WHERE id = ? LIMIT 1`,
    [result.insertId],
  );
  return serialize(rows[0]);
}

/**
 * Attach a new partner under an existing invite code.
 * Keeps the pending invite row open so more partners can join.
 */
async function createActiveForPartner({
  ownerUserId,
  partnerUserId,
  code,
  shareScope,
  ownerConsentedAt,
}) {
  const scopeJson = JSON.stringify(shareScope || DEFAULT_SHARE_SCOPE);
  const [result] = await pool.execute(
    `INSERT INTO partner_links
       (code, owner_user_id, partner_user_id, status, share_scope,
        owner_consented_at, linked_at)
     VALUES (?, ?, ?, 'active', ?, ?, CURRENT_TIMESTAMP)`,
    [
      String(code).toUpperCase(),
      ownerUserId,
      partnerUserId,
      scopeJson,
      ownerConsentedAt || new Date(),
    ],
  );
  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLS} FROM partner_links WHERE id = ? LIMIT 1`,
    [result.insertId],
  );
  return serialize(rows[0]);
}

/** @deprecated prefer createActiveForPartner for multi-partner */
async function activateLink(linkId, partnerUserId) {
  await pool.execute(
    `UPDATE partner_links
     SET partner_user_id = ?,
         status = 'active',
         linked_at = CURRENT_TIMESTAMP
     WHERE id = ?
       AND status = 'pending'`,
    [partnerUserId, linkId],
  );
  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLS} FROM partner_links WHERE id = ? LIMIT 1`,
    [linkId],
  );
  return serialize(rows[0]);
}

async function revokeById(linkId) {
  await pool.execute(
    `UPDATE partner_links
     SET status = 'revoked',
         revoked_at = CURRENT_TIMESTAMP
     WHERE id = ?
       AND status IN ('pending', 'active')`,
    [linkId],
  );
  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLS} FROM partner_links WHERE id = ? LIMIT 1`,
    [linkId],
  );
  return serialize(rows[0]);
}

/** Owner disconnect: revoke all open invite + active partner rows for this owner. */
async function revokeAllForOwner(ownerUserId) {
  await pool.execute(
    `UPDATE partner_links
     SET status = 'revoked',
         revoked_at = CURRENT_TIMESTAMP
     WHERE owner_user_id = ?
       AND status IN ('pending', 'active')`,
    [ownerUserId],
  );
}

async function codeExists(code) {
  const [rows] = await pool.execute(
    `SELECT id FROM partner_links WHERE code = ? LIMIT 1`,
    [String(code || '').toUpperCase()],
  );
  return rows.length > 0;
}

module.exports = {
  DEFAULT_SHARE_SCOPE,
  findByCode,
  findOpenInviteByCode,
  findOpenInviteByOwner,
  findActiveOrPendingByOwner,
  listActiveByOwner,
  findActiveByPartner,
  findActiveByOwnerAndPartner,
  findLinkForUser,
  createPending,
  createActiveForPartner,
  activateLink,
  revokeById,
  revokeAllForOwner,
  codeExists,
};
