const nodemailer = require('nodemailer');
const { env } = require('../config/env');

let _transporter = null;

function isSmtpConfigured() {
  return Boolean(env.smtp.host && env.smtp.user && env.smtp.password);
}

function getTransporter() {
  if (_transporter) return _transporter;
  if (!isSmtpConfigured()) {
    throw new Error('SMTP is not configured');
  }
  _transporter = nodemailer.createTransport({
    host: env.smtp.host,
    port: env.smtp.port,
    secure: env.smtp.secure,
    auth: {
      user: env.smtp.user,
      pass: env.smtp.password,
    },
  });
  return _transporter;
}

/**
 * Sends a transactional email. Returns true on success.
 * Throws on hard SMTP misconfiguration / send failure.
 */
async function sendMail({ to, subject, text, html }) {
  const transporter = getTransporter();
  const from = env.smtp.from || env.smtp.user;
  await transporter.sendMail({
    from: `"EezyCycle" <${from}>`,
    to,
    subject,
    text,
    html,
  });
  return true;
}

async function sendPasswordResetOtp({ to, otp }) {
  const subject = 'Your EezyCycle password reset code';
  const text =
    `Your EezyCycle password reset code is ${otp}.\n\n` +
    `It expires in 15 minutes. If you did not request this, you can ignore this email.`;
  const html = `
    <div style="font-family: system-ui, -apple-system, sans-serif; max-width: 480px; margin: 0 auto; padding: 24px;">
      <h2 style="color: #1a1a1a; margin: 0 0 12px;">Reset your password</h2>
      <p style="color: #555; line-height: 1.5;">
        Use this one-time code to reset your EezyCycle password. It expires in
        <strong>15 minutes</strong>.
      </p>
      <p style="font-size: 32px; letter-spacing: 8px; font-weight: 700; color: #1a1a1a; margin: 24px 0;">
        ${otp}
      </p>
      <p style="color: #888; font-size: 13px; line-height: 1.4;">
        If you did not request a password reset, you can safely ignore this email.
      </p>
    </div>
  `;
  return sendMail({ to, subject, text, html });
}

module.exports = {
  isSmtpConfigured,
  sendMail,
  sendPasswordResetOtp,
};
