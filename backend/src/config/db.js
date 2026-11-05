const oracledb = require('oracledb');
const config = require('./env');

// Automatically fetch CLOB columns as strings instead of Lob instances
oracledb.fetchAsString = [oracledb.CLOB];


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
      sessionCallback: (connection, requestedTag, cb) => {
        const schemaClause = config.oracle.schema ? `CURRENT_SCHEMA = ${config.oracle.schema}` : '';
        const sql = schemaClause
          ? `ALTER SESSION SET ${schemaClause} TIME_ZONE = '+07:00'`
          : `ALTER SESSION SET TIME_ZONE = '+07:00'`;
        connection.execute(sql, cb);
      },
    });
    console.log(`[DB] Oracle Cloud connection pool initialized (Schema: ${config.oracle.schema || config.oracle.user}).`);
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

