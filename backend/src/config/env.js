require('dotenv').config();

module.exports = {
  port: process.env.PORT || 5000,
  nodeEnv: process.env.NODE_ENV || 'development',
  oracle: {
    user: process.env.ORACLE_DB_USER || '',
    password: process.env.ORACLE_DB_PASSWORD || '',
    connectString: process.env.ORACLE_DB_CONNECT_STRING || '',
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'dev_secret_change_in_production',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },
  google: {
    clientId: process.env.GOOGLE_CLIENT_ID || '',
  },
  gemini: {
    apiKey: process.env.GEMINI_API_KEY || '',
  },
};

