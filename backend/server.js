require('dotenv').config();
const app = require('./src/app');
const { initializeDatabase } = require('./src/database/initDb');
const { db } = require('./src/config/db');

const PORT = process.env.PORT || 5000;
const HOST = '0.0.0.0';

async function startServer() {
  try {
    // Initialize database schema and initial seed data
    await initializeDatabase();

    const server = app.listen(PORT, HOST, () => {
      console.log(`\n==================================================`);
      console.log(`🚀 KAKA FOOD BACKEND RUNNING AT http://localhost:${PORT}`);
      console.log(`📡 Health Check:  http://localhost:${PORT}/api/health`);
      console.log(`🍔 Food Menu:     http://localhost:${PORT}/api/food`);
      console.log(`🏷️  Categories:    http://localhost:${PORT}/api/food/categories`);
      console.log(`🎁 Promo Banners: http://localhost:${PORT}/api/food/promos`);
      console.log(`🔑 Auth Endpoints:http://localhost:${PORT}/api/auth/login`);
      console.log(`==================================================\n`);
    });

    // Graceful shutdown
    const shutdown = () => {
      console.log('\n🛑 Gracefully shutting down server...');
      server.close(() => {
        console.log('🚪 HTTP server closed.');
        db.close((err) => {
          if (err) console.error('Error closing SQLite DB:', err);
          else console.log('📦 SQLite database connection closed.');
          process.exit(0);
        });
      });
    };

    process.on('SIGINT', shutdown);
    process.on('SIGTERM', shutdown);
  } catch (error) {
    console.error('❌ Failed to start Kaka Food backend server:', error);
    process.exit(1);
  }
}

startServer();
