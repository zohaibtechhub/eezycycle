const app = require('./app');
const { env } = require('./config/env');
const { pingDb } = require('./config/db');

async function start() {
  let dbOk = false;
  try {
    const db = await pingDb();
    dbOk = true;
    console.log(`MySQL connected: ${db.database}`);
  } catch (err) {
    // Do not exit — on cPanel/Passenger, process.exit → opaque 503.
    console.error('MySQL connection failed:', err.message);
    console.error(
      'Fix DB_* in .env (host/user/password/database), then Restart App.',
    );
  }

  // cPanel Node selector injects PORT — prefer it over a hard-coded .env value.
  const port = Number(process.env.PORT) || env.port || 3000;

  app.listen(port, '0.0.0.0', () => {
    console.log(
      `EezyCycle API listening on http://0.0.0.0:${port} (db=${dbOk ? 'ok' : 'DOWN'})`,
    );
  });
}

start().catch((err) => {
  console.error('Fatal startup error:', err);
  process.exit(1);
});
