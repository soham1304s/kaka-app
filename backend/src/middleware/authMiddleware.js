const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'kaka_super_secret_jwt_key_2026_food_delivery';

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.startsWith('Bearer ') 
    ? authHeader.split(' ')[1] 
    : null;

  if (!token) {
    return res.status(401).json({
      success: false,
      error: {
        message: 'Authentication token required. Please sign in.',
        code: 'UNAUTHORIZED',
      },
    });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded; // { id, email }
    next();
  } catch (err) {
    return res.status(403).json({
      success: false,
      error: {
        message: 'Invalid or expired authentication token. Please log in again.',
        code: 'FORBIDDEN',
      },
    });
  }
}

// Optional auth: attaches req.user if present, but doesn't block guests
function optionalAuth(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.startsWith('Bearer ') 
    ? authHeader.split(' ')[1] 
    : null;

  if (token) {
    try {
      req.user = jwt.verify(token, JWT_SECRET);
    } catch {
      // Ignored for optional
    }
  }
  next();
}

module.exports = {
  authenticateToken,
  optionalAuth,
  JWT_SECRET,
};
