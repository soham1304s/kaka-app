const app = require('../src/app');
const { initializeDatabase } = require('../src/database/initDb');

let initPromise = null;
let isInitialized = false;

async function ensureDatabaseInitialized() {
  if (isInitialized) return;
  if (!initPromise) {
    initPromise = initializeDatabase()
      .then(() => {
        isInitialized = true;
        console.log('🚀 Database initialized on Vercel serverless instance');
      })
      .catch((err) => {
        console.error('⚠️ Database initialization error on Vercel cold-start:', err.message);
        isInitialized = true;
      });
  }
  await initPromise;
}

module.exports = async (req, res) => {
  await ensureDatabaseInitialized();
  return app(req, res);
};
