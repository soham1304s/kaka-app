const express = require('express');
const cors = require('cors');
const { requestLogger } = require('./middleware/logger');
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');

const authRoutes = require('./routes/authRoutes');
const foodRoutes = require('./routes/foodRoutes');
const orderRoutes = require('./routes/orderRoutes');
const { getAsync } = require('./config/db');

const app = express();

// 1. Global Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(requestLogger);

// 2. Health check endpoint
app.get('/api/health', async (req, res) => {
  let dbStatus = 'disconnected';
  try {
    await getAsync('SELECT 1');
    dbStatus = 'connected (SQLite WAL)';
  } catch (err) {
    dbStatus = `error: ${err.message}`;
  }

  res.json({
    status: 'ok',
    service: 'Kaka Food Delivery API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    database: dbStatus,
    uptimeSeconds: Math.floor(process.uptime()),
  });
});

// 3. API Routes
app.use('/api/auth', authRoutes);
app.use('/api/food', foodRoutes);
app.use('/api/orders', orderRoutes);

// 4. Fallback and Error Handling
app.use(notFoundHandler);
app.use(errorHandler);

module.exports = app;
