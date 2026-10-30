const app = require('./app');
const config = require('./config/env');
const { initDbPool, closeDbPool } = require('./config/db');

async function startServer() {
  try {
    await initDbPool();
  } catch (err) {
    console.warn('[Server] Starting without live Oracle DB connection (skeleton mode).');
  }

  const server = app.listen(config.port, () => {
    console.log(`[Server] FM-EAA backend running on port ${config.port} (${config.nodeEnv})`);
  });

  const shutdown = async () => {
    console.log('[Server] Gracefully shutting down...');
    server.close(async () => {
      await closeDbPool();
      process.exit(0);
    });
  };

  process.on('SIGTERM', shutdown);
  process.on('SIGINT', shutdown);
}

if (require.main === module) {
  startServer();
}

module.exports = startServer;

