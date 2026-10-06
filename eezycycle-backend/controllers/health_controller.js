const { pingDb } = require('../config/db');
const { createError, ErrorCodes } = require('../utils/error');

async function getHealth(req, res, next) {
  try {
    const db = await pingDb();
    res.json({
      success: true,
      message: 'EezyCycle API is running',
      data: {
        database: db.database,
        dbConnected: db.ok,
      },
      timestamp: new Date().toISOString(),
    });
  } catch (err) {
    console.error('[db]', err.message);
    next(
      createError(
        'Database connection failed. Please try again.',
        503,
        ErrorCodes.INTERNAL,
      ),
    );
  }
}

function getPing(req, res) {
  res.json({
    success: true,
    data: { pong: true },
  });
}

function getDemoError(req, res, next) {
  next(
    createError(
      'Backend demo error: cycle sync failed. Please try again.',
      400,
      ErrorCodes.DEMO,
    ),
  );
}

module.exports = {
  getHealth,
  getPing,
  getDemoError,
};
