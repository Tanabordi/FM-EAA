const admin = require('firebase-admin');
const { getMessaging } = require('firebase-admin/messaging');
const fs = require('fs');
const path = require('path');
const db = require('../config/db');

let firebaseApp = null;
let isInitialized = false;

function initFirebase() {
  if (isInitialized) return firebaseApp;

  try {
    let serviceAccount = null;

    // 1. Look for explicit firebase-service-account.json or google-services.json
    const standardPath = path.resolve(__dirname, '../../firebase-service-account.json');
    const googleServicesPath = path.resolve(__dirname, '../../google-services.json');
    if (fs.existsSync(standardPath)) {
      serviceAccount = JSON.parse(fs.readFileSync(standardPath, 'utf8'));
    } else if (fs.existsSync(googleServicesPath)) {
      serviceAccount = JSON.parse(fs.readFileSync(googleServicesPath, 'utf8'));
    } else {
      // 2. Search for any downloaded adminsdk json file in backend
      const backendDir = path.resolve(__dirname, '../../');
      const files = fs.readdirSync(backendDir);
      const keyFile = files.find(f => f.startsWith('fm-eaa-firebase-adminsdk') && f.endsWith('.json'));
      if (keyFile) {
        serviceAccount = JSON.parse(fs.readFileSync(path.join(backendDir, keyFile), 'utf8'));
      } else if (process.env.FIREBASE_SERVICE_ACCOUNT_KEY) {
        // 3. Fallback from environment variable string
        serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY);
      }
    }

    if (serviceAccount) {
      firebaseApp = admin.initializeApp({
        credential: admin.cert(serviceAccount),
      });
      isInitialized = true;
      console.log('[Firebase Admin] Successfully initialized Firebase Cloud Messaging.');
    } else {
      console.warn('[Firebase Admin] No service account key found. FCM push notifications disabled.');
    }
  } catch (err) {
    console.error('[Firebase Admin] Initialization error:', err.message);
  }

  return firebaseApp;
}

// Initialize on module load
initFirebase();

class PushNotificationService {
  constructor() {
    this._ensureTableExists();
  }

  async _ensureTableExists() {
    let conn;
    try {
      conn = await db.getDbConnection();
      await conn.execute(`
        CREATE TABLE user_fcm_tokens (
          user_id VARCHAR2(36) NOT NULL,
          fcm_token VARCHAR2(500) NOT NULL,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          CONSTRAINT pk_user_fcm PRIMARY KEY (user_id, fcm_token)
        )
      `);
      console.log('[PushNotificationService] Created user_fcm_tokens table in Oracle DB.');
    } catch (err) {
      // ORA-00955: name is already used by an existing object (Table already exists)
      if (!err.message || !err.message.includes('ORA-00955')) {
        // Not a critical error, just log warning
      }
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  _getTokensFromFile(userId) {
    try {
      const filePath = path.resolve(__dirname, '../../.fcm_tokens.json');
      if (!fs.existsSync(filePath)) return [];
      const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
      return data[userId] || [];
    } catch (_) {
      return [];
    }
  }

  _saveTokenToFile(userId, fcmToken) {
    try {
      const filePath = path.resolve(__dirname, '../../.fcm_tokens.json');
      let data = {};
      if (fs.existsSync(filePath)) {
        data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
      }
      if (!data[userId]) data[userId] = [];
      if (!data[userId].includes(fcmToken)) {
        data[userId].push(fcmToken);
      }
      fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
    } catch (_) {}
  }

  /**
   * Register or refresh a device FCM token for a user
   */
  async registerToken(userId, fcmToken) {
    if (!userId || !fcmToken) return;
    this._saveTokenToFile(userId, fcmToken);
    console.log(`[PushNotificationService] Registered FCM token for user ${userId}`);

    let conn;
    try {
      conn = await db.getDbConnection();
      const sql = `
        MERGE INTO user_fcm_tokens target
        USING (SELECT :userId AS user_id, :fcmToken AS fcm_token FROM dual) src
        ON (target.user_id = src.user_id AND target.fcm_token = src.fcm_token)
        WHEN MATCHED THEN
          UPDATE SET target.updated_at = CURRENT_TIMESTAMP
        WHEN NOT MATCHED THEN
          INSERT (user_id, fcm_token, updated_at)
          VALUES (src.user_id, src.fcm_token, CURRENT_TIMESTAMP)
      `;
      await conn.execute(sql, { userId, fcmToken }, { autoCommit: true });
    } catch (err) {
      // Fallback already safely handled by file persistence
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /**
   * Remove a device FCM token on logout
   */
  async removeToken(userId, fcmToken) {
    if (!userId || !fcmToken) return;
    let conn;
    try {
      conn = await db.getDbConnection();
      await conn.execute(
        `DELETE FROM user_fcm_tokens WHERE user_id = :userId AND fcm_token = :fcmToken`,
        { userId, fcmToken },
        { autoCommit: true }
      );
    } catch (err) {
      console.warn('[PushNotificationService] Failed to delete token:', err.message);
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /**
   * Send a push notification to all active devices of a user
   */
  async sendPushToUser(userId, { title, body, data = {} }) {
    if (!isInitialized || !firebaseApp) return;
    if (!userId) return;

    let conn;
    let tokens = [];
    try {
      conn = await db.getDbConnection();
      const result = await conn.execute(
        `SELECT fcm_token FROM user_fcm_tokens WHERE user_id = :userId`,
        [userId]
      );
      tokens = (result.rows || []).map(r => r[0]);
    } catch (_) {
      // Table doesn't exist or query failed, rely on file tokens
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }

    // Merge tokens from local persistent store
    const fileTokens = this._getTokensFromFile(userId);
    const allTokens = Array.from(new Set([...tokens, ...fileTokens]));

    // If userId was queried with specific ID or if broadcast fallback needed:
    if (!allTokens || allTokens.length === 0) {
      // Also check if any tokens exist in file store at all (e.g. single tester device)
      try {
        const filePath = path.resolve(__dirname, '../../.fcm_tokens.json');
        if (fs.existsSync(filePath)) {
          const allData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
          for (const userTokens of Object.values(allData)) {
            if (Array.isArray(userTokens)) {
              allTokens.push(...userTokens);
            }
          }
        }
      } catch (_) {}
    }

    if (!allTokens || allTokens.length === 0) {
      console.log(`[PushNotificationService] No active FCM tokens found for user ${userId}`);
      return;
    }

    // Convert all data payload properties to strings as required by FCM
    const stringData = {};
    for (const [key, value] of Object.entries(data)) {
      stringData[key] = value !== null && value !== undefined ? String(value) : '';
    }

    const messaging = getMessaging(firebaseApp);

    for (const token of allTokens) {
      const message = {
        token,
        notification: {
          title: title || 'FM-EAA',
          body: body || '',
        },
        data: stringData,
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'expiry_alerts',
            priority: 'high',
            defaultVibrateTimings: true,
            defaultSound: true,
          },
        },
      };

      try {
        await messaging.send(message);
        console.log(`[PushNotificationService] Push delivered to user ${userId}`);
      } catch (sendErr) {
        console.warn(`[PushNotificationService] Send failed to token:`, sendErr.message);
        // Automatically clean up stale or invalidated tokens
        if (
          sendErr.code === 'messaging/registration-token-not-registered' ||
          sendErr.code === 'messaging/invalid-registration-token'
        ) {
          this.removeToken(userId, token).catch(() => {});
        }
      }
    }
  }

  /**
   * Send push notification to multiple users simultaneously
   */
  async sendPushToMultipleUsers(userIds, { title, body, data = {} }) {
    if (!Array.isArray(userIds) || userIds.length === 0) return;
    for (const userId of userIds) {
      await this.sendPushToUser(userId, { title, body, data });
    }
  }
}

module.exports = new PushNotificationService();
