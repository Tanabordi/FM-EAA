const oracledb = require('oracledb');
const config = require('./env');

// TODO(backend db): Configure connection pool for Oracle Cloud Autonomous Database (OCI)
// Note: When connecting to OCI, ensure TNS_ADMIN or wallet path is configured if using mTLS.

let pool = null;

async function initDbPool() {
  if (!config.oracle.user || !config.oracle.connectString) {
    console.warn('[DB] Oracle credentials not fully set. Running in skeleton mock mode.');
    return null;
  }
  try {
    pool = await oracledb.createPool({
      user: config.oracle.user,
      password: config.oracle.password,
      connectString: config.oracle.connectString,
      poolMin: 2,
      poolMax: 10,
      poolIncrement: 2,
    });
    console.log('[DB] Oracle Cloud connection pool initialized.');
    return pool;
  } catch (err) {
    console.error('[DB] Failed to initialize Oracle connection pool:', err.message);
    throw err;
  }
}

async function getDbConnection() {
  if (!pool) {
    throw new Error('Database pool has not been initialized.');
  }
  return pool.getConnection();
}

async function closeDbPool() {
  if (pool) {
    await pool.close(10);
    pool = null;
    console.log('[DB] Oracle connection pool closed.');
  }
}

module.exports = {
  initDbPool,
  getDbConnection,
  closeDbPool,
};

