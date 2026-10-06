/**
 * AppError — structured API errors the Flutter client can show.
 */
class AppError extends Error {
  /**
   * @param {string} message  User-facing message
   * @param {number} statusCode  HTTP status
   * @param {string} code  Machine-readable code
   */
  constructor(message, statusCode = 500, code = 'INTERNAL_ERROR') {
    super(message);
    this.name = 'AppError';
    this.statusCode = statusCode;
    this.code = code;
    this.isOperational = true;
  }
}

const ErrorCodes = {
  NOT_FOUND: 'NOT_FOUND',
  VALIDATION: 'VALIDATION_ERROR',
  UNAUTHORIZED: 'UNAUTHORIZED',
  FORBIDDEN: 'FORBIDDEN',
  CONFLICT: 'CONFLICT',
  CONSENT_REQUIRED: 'CONSENT_REQUIRED',
  DEMO: 'DEMO_ERROR',
  INTERNAL: 'INTERNAL_ERROR',
};

function createError(message, statusCode, code) {
  return new AppError(message, statusCode, code);
}

function sendError(res, err) {
  const statusCode = err.statusCode || 500;
  const code = err.code || ErrorCodes.INTERNAL;
  const message =
    err.isOperational && err.message
      ? err.message
      : 'Something went wrong. Please try again.';

  return res.status(statusCode).json({
    success: false,
    error: {
      code,
      message,
      statusCode,
    },
  });
}

function notFound(req, res, next) {
  next(
    createError(
      `Route not found: ${req.method} ${req.originalUrl}`,
      404,
      ErrorCodes.NOT_FOUND,
    ),
  );
}

function errorMiddleware(err, req, res, next) {
  if (res.headersSent) {
    return next(err);
  }

  if (!(err instanceof AppError)) {
    console.error('[unhandled]', err);
    return sendError(
      res,
      createError('Something went wrong. Please try again.', 500, ErrorCodes.INTERNAL),
    );
  }

  return sendError(res, err);
}

module.exports = {
  AppError,
  ErrorCodes,
  createError,
  sendError,
  notFound,
  errorMiddleware,
};
