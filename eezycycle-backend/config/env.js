const path = require('path');

// cPanel/Passenger cwd is often NOT the app root — load .env next to package.json.
require('dotenv').config({
  path: path.join(__dirname, '..', '.env'),
});

const env = {
  port: Number(process.env.PORT) || 3000,
  db: {
    host: process.env.DB_HOST || '127.0.0.1',
    port: Number(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'eezycycle',
  },
  jwt: {
    accessSecret: process.env.JWT_ACCESS_SECRET || 'dev-access-secret-change-me',
    refreshSecret: process.env.JWT_REFRESH_SECRET || 'dev-refresh-secret-change-me',
  },
  smtp: {
    host: process.env.SMTP_HOST || '',
    port: Number(process.env.SMTP_PORT) || 465,
    secure:
      String(process.env.SMTP_SECURE || 'true').toLowerCase() === 'true' ||
      String(process.env.SMTP_SECURE) === '1',
    user: process.env.SMTP_USER || '',
    password: process.env.SMTP_PASSWORD || '',
    from: process.env.SMTP_FROM || process.env.SMTP_USER || '',
  },
  onesignal: {
    appId: process.env.ONESIGNAL_APP_ID || '',
    restApiKey: process.env.ONESIGNAL_REST_API_KEY || '',
    apiUrl: process.env.ONESIGNAL_API_URL || 'https://api.onesignal.com',
  },
};

// Safe startup log (no password) — check stderr on cPanel if DB still fails.
console.log(
  `[env] DB ${env.db.user}@${env.db.host}:${env.db.port}/${env.db.database}`,
);
if (env.onesignal.appId) {
  console.log(`[env] OneSignal app ${env.onesignal.appId.slice(0, 8)}… configured`);
} else {
  console.log('[env] OneSignal not configured (ONESIGNAL_APP_ID empty)');
}

module.exports = { env };
