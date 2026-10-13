const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');

const isVercel = process.env.VERCEL === '1' || process.env.VERCEL === 'true' || !!process.env.AWS_LAMBDA_FUNCTION_NAME;

const dbPath = process.env.DB_PATH 
  ? (path.isAbsolute(process.env.DB_PATH) ? process.env.DB_PATH : path.resolve(__dirname, '../../', process.env.DB_PATH))
  : (isVercel ? '/tmp/kaka_food.db' : path.resolve(__dirname, '../database/kaka_food.db'));

// Ensure parent directory exists
const dbDir = path.dirname(dbPath);
if (!fs.existsSync(dbDir)) {
  try {
    fs.mkdirSync(dbDir, { recursive: true });
  } catch (err) {
    console.warn('⚠️ Warning creating db directory:', dbDir, err.message);
  }
}

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('❌ Failed to connect to SQLite database:', err.message);
  } else {
    console.log(`📦 Connected to SQLite database at: ${dbPath} (Vercel=${isVercel})`);
  }
});

// Configure SQLite for high performance and integrity
db.serialize(() => {
  if (isVercel) {
    db.run('PRAGMA journal_mode = MEMORY;');
  } else {
    db.run('PRAGMA journal_mode = WAL;');
  }
  db.run('PRAGMA foreign_keys = ON;');
  db.run('PRAGMA synchronous = NORMAL;');
});

// Promise-based query helpers for clean async/await syntax
const runAsync = (sql, params = []) => {
  return new Promise((resolve, reject) => {
    db.run(sql, params, function (err) {
      if (err) return reject(err);
      resolve({ lastID: this.lastID, changes: this.changes });
    });
  });
};

const getAsync = (sql, params = []) => {
  return new Promise((resolve, reject) => {
    db.get(sql, params, (err, row) => {
      if (err) return reject(err);
      resolve(row);
    });
  });
};

const allAsync = (sql, params = []) => {
  return new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => {
      if (err) return reject(err);
      resolve(rows);
    });
  });
};

const execAsync = (sql) => {
  return new Promise((resolve, reject) => {
    db.exec(sql, (err) => {
      if (err) return reject(err);
      resolve();
    });
  });
};

module.exports = {
  db,
  dbPath,
  runAsync,
  getAsync,
  allAsync,
  execAsync,
};
