function errorHandler(err, req, res, next) {
  console.error(`💥 Error [${req.method} ${req.url}]:`, err.stack || err.message);

  const statusCode = err.statusCode || err.status || 500;
  const message = err.message || 'Internal server error occurred';

  res.status(statusCode).json({
    success: false,
    error: {
      message,
      statusCode,
      code: err.code || 'INTERNAL_ERROR',
      ...(process.env.NODE_ENV === 'development' ? { stack: err.stack } : {}),
    },
  });
}

function notFoundHandler(req, res) {
  res.status(404).json({
    success: false,
    error: {
      message: `Cannot ${req.method} ${req.originalUrl} - Route not found`,
      code: 'NOT_FOUND',
    },
  });
}

module.exports = { errorHandler, notFoundHandler };
