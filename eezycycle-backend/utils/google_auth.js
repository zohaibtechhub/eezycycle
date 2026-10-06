const { OAuth2Client } = require('google-auth-library');
const { createError, ErrorCodes } = require('./error');

function clientIds() {
  const raw =
    process.env.GOOGLE_CLIENT_IDS ||
    process.env.GOOGLE_CLIENT_ID ||
    '';
  return raw
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
}

/**
 * Verifies a Google ID token and returns { sub, email, emailVerified, name }.
 * @param {string} idToken
 */
async function verifyGoogleIdToken(idToken) {
  const token = String(idToken || '').trim();
  if (!token) {
    throw createError('google_id_token is required.', 400, ErrorCodes.VALIDATION);
  }

  const audiences = clientIds();
  if (audiences.length === 0) {
    throw createError(
      'Google sign-in is not configured on the server.',
      503,
      ErrorCodes.INTERNAL,
    );
  }

  const client = new OAuth2Client();
  let ticket;
  try {
    ticket = await client.verifyIdToken({
      idToken: token,
      audience: audiences,
    });
  } catch {
    throw createError('Invalid Google sign-in token.', 401, ErrorCodes.UNAUTHORIZED);
  }

  const payload = ticket.getPayload();
  if (!payload || !payload.sub) {
    throw createError('Invalid Google sign-in token.', 401, ErrorCodes.UNAUTHORIZED);
  }

  return {
    sub: payload.sub,
    email: payload.email ? String(payload.email).toLowerCase() : null,
    emailVerified: Boolean(payload.email_verified),
    name: payload.name ? String(payload.name).slice(0, 120) : null,
  };
}

module.exports = { verifyGoogleIdToken, clientIds };
