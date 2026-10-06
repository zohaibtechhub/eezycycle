/**
 * Wraps async Express handlers so rejected promises reach errorMiddleware.
 * @param {(req, res, next) => Promise<void>} fn
 */
function asyncHandler(fn) {
  return function wrapped(req, res, next) {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

module.exports = { asyncHandler };
