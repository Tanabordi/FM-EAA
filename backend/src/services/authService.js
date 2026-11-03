const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const oracledb = require('oracledb');
const { OAuth2Client } = require('google-auth-library');
const config = require('../config/env');
const { getDbConnection } = require('../config/db');

const googleClient = new OAuth2Client(config.google.clientId);

class AuthService {
  /**
   * Helper: Generate signed JWT token
   */
  generateToken(payload) {
    return jwt.sign(payload, config.jwt.secret, {
      expiresIn: config.jwt.expiresIn,
    });
  }

  /**
   * Register a new user
   */
  async register(username, email, password) {
    if (!username || typeof username !== 'string' || username.trim().length < 3) {
      const err = new Error('Username must be at least 3 characters long');
      err.statusCode = 400;
      throw err;
    }

    if (username.trim().length > 20) {
      const err = new Error('Username must not exceed 20 characters');
      err.statusCode = 400;
      throw err;
    }

    const usernameRegex = /^[a-zA-Z0-9_]+$/;
    if (!usernameRegex.test(username.trim())) {
      const err = new Error('Username can only contain letters, numbers, and underscore');
      err.statusCode = 400;
      throw err;
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!email || !emailRegex.test(email.trim())) {
      const err = new Error('A valid email address is required');
      err.statusCode = 400;
      throw err;
    }

    if (!password || typeof password !== 'string' || password.length < 6) {
      const err = new Error('Password must be at least 6 characters long');
      err.statusCode = 400;
      throw err;
    }

    const cleanUsername = username.trim();
    const cleanEmail = email.trim().toLowerCase();

    let conn;
    try {
      conn = await getDbConnection();

      // Check for existing user by username or email
      const checkSql = `
        SELECT id, username, email FROM users
        WHERE LOWER(username) = LOWER(:username) OR LOWER(email) = LOWER(:email)
      `;
      const existing = await conn.execute(
        checkSql,
        { username: cleanUsername, email: cleanEmail },
        { outFormat: oracledb.OUT_FORMAT_OBJECT }
      );

      if (existing.rows && existing.rows.length > 0) {
        const found = existing.rows[0];
        const isEmail = found.EMAIL.toLowerCase() === cleanEmail;
        const err = new Error(isEmail ? 'Email is already registered' : 'Username is already taken');
        err.statusCode = 409;
        throw err;
      }

      // Hash password with bcrypt
      const passwordHash = await bcrypt.hash(password, 10);
      const userId = crypto.randomUUID();

      // Insert new user into Oracle DB
      const insertSql = `
        INSERT INTO users (id, username, email, password_hash, created_at, updated_at)
        VALUES (:id, :username, :email, :passwordHash, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      `;
      await conn.execute(
        insertSql,
        {
          id: userId,
          username: cleanUsername,
          email: cleanEmail,
          passwordHash,
        },
        { autoCommit: true }
      );

      const token = this.generateToken({
        id: userId,
        username: cleanUsername,
        email: cleanEmail,
      });

      return {
        user: {
          id: userId,
          username: cleanUsername,
          email: cleanEmail,
          avatarUrl: null,
        },
        token,
      };
    } finally {
      if (conn) {
        try {
          await conn.close();
        } catch (_) {}
      }
    }
  }

  /**
   * Login with identifier (username or email) and password
   */
  async login(identifier, password) {
    if (!identifier || typeof identifier !== 'string' || !identifier.trim()) {
      const err = new Error('Username or email is required');
      err.statusCode = 400;
      throw err;
    }

    if (!password || typeof password !== 'string') {
      const err = new Error('Password is required');
      err.statusCode = 400;
      throw err;
    }

    const cleanIdentifier = identifier.trim().toLowerCase();

    let conn;
    try {
      conn = await getDbConnection();

      const querySql = `
        SELECT id, username, email, password_hash, avatar_url, created_at, updated_at
        FROM users
        WHERE LOWER(username) = LOWER(:identifier) OR LOWER(email) = LOWER(:identifier)
      `;
      const result = await conn.execute(
        querySql,
        { identifier: cleanIdentifier },
        { outFormat: oracledb.OUT_FORMAT_OBJECT }
      );

      if (!result.rows || result.rows.length === 0) {
        const err = new Error('Invalid username/email or password');
        err.statusCode = 401;
        throw err;
      }

      const user = result.rows[0];
      const dbHash = user.PASSWORD_HASH || '';

      let isMatch = false;
      if (dbHash.startsWith('$2a$') || dbHash.startsWith('$2b$')) {
        isMatch = await bcrypt.compare(password, dbHash);
      } else {
        // Fallback check for seed passwords, then automatically upgrade to bcrypt
        isMatch = password === dbHash;
        if (isMatch) {
          const upgradedHash = await bcrypt.hash(password, 10);
          await conn.execute(
            'UPDATE users SET password_hash = :upgradedHash WHERE id = :id',
            { upgradedHash, id: user.ID },
            { autoCommit: true }
          );
        }
      }

      if (!isMatch) {
        const err = new Error('Invalid username/email or password');
        err.statusCode = 401;
        throw err;
      }

      const token = this.generateToken({
        id: user.ID,
        username: user.USERNAME,
        email: user.EMAIL,
      });

      return {
        user: {
          id: user.ID,
          username: user.USERNAME,
          email: user.EMAIL,
          avatarUrl: user.AVATAR_URL,
        },
        token,
      };
    } finally {
      if (conn) {
        try {
          await conn.close();
        } catch (_) {}
      }
    }
  }

  /**
   * Fetch user profile by ID
   */
  async getProfile(userId) {
    let conn;
    try {
      conn = await getDbConnection();
      const sql = `
        SELECT id, username, email, avatar_url, created_at, updated_at
        FROM users
        WHERE id = :userId
      `;
      const result = await conn.execute(
        sql,
        { userId },
        { outFormat: oracledb.OUT_FORMAT_OBJECT }
      );

      if (!result.rows || result.rows.length === 0) {
        const err = new Error('User not found');
        err.statusCode = 404;
        throw err;
      }

      const user = result.rows[0];
      return {
        id: user.ID,
        username: user.USERNAME,
        email: user.EMAIL,
        avatarUrl: user.AVATAR_URL,
        createdAt: user.CREATED_AT,
        updatedAt: user.UPDATED_AT,
      };
    } finally {
      if (conn) {
        try {
          await conn.close();
        } catch (_) {}
      }
    }
  }

  /**
   * Update user profile
   */
  async updateProfile(userId, { username, email, avatarUrl, currentPassword, newPassword } = {}) {
    let conn;
    try {
      conn = await getDbConnection();

      const existingSql = `
        SELECT id, username, email, password_hash, avatar_url
        FROM users
        WHERE id = :userId
      `;
      const result = await conn.execute(
        existingSql,
        { userId },
        { outFormat: oracledb.OUT_FORMAT_OBJECT }
      );

      if (!result.rows || result.rows.length === 0) {
        const err = new Error('User not found');
        err.statusCode = 404;
        throw err;
      }

      const currentUser = result.rows[0];
      let cleanUsername = currentUser.USERNAME;
      let cleanEmail = currentUser.EMAIL;
      let newPasswordHash = currentUser.PASSWORD_HASH;
      let newAvatarUrl = avatarUrl !== undefined ? avatarUrl : currentUser.AVATAR_URL;

      if (username && username.trim()) {
        cleanUsername = username.trim();
        if (cleanUsername.length < 3) {
          const err = new Error('Username must be at least 3 characters long');
          err.statusCode = 400;
          throw err;
        }
        if (cleanUsername.length > 20) {
          const err = new Error('Username must not exceed 20 characters');
          err.statusCode = 400;
          throw err;
        }
        const usernameRegex = /^[a-zA-Z0-9_]+$/;
        if (!usernameRegex.test(cleanUsername)) {
          const err = new Error('Username can only contain letters, numbers, and underscore');
          err.statusCode = 400;
          throw err;
        }
      }

      if (email && email.trim()) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        cleanEmail = email.trim().toLowerCase();
        if (!emailRegex.test(cleanEmail)) {
          const err = new Error('A valid email address is required');
          err.statusCode = 400;
          throw err;
        }
      }

      // Check unique username/email against other users
      const dupCheckSql = `
        SELECT id, username, email FROM users
        WHERE (LOWER(username) = LOWER(:username) OR LOWER(email) = LOWER(:email))
          AND id != :userId
      `;
      const dupCheck = await conn.execute(
        dupCheckSql,
        { username: cleanUsername, email: cleanEmail, userId },
        { outFormat: oracledb.OUT_FORMAT_OBJECT }
      );

      if (dupCheck.rows && dupCheck.rows.length > 0) {
        const dup = dupCheck.rows[0];
        const isSameUsername = dup.USERNAME && dup.USERNAME.toLowerCase() === cleanUsername.toLowerCase();
        const err = new Error(
          isSameUsername ? 'Username is already taken' : 'Email is already in use by another account'
        );
        err.statusCode = 409;
        throw err;
      }

      // If new password provided, verify current password
      if (newPassword && newPassword.length > 0) {
        if (!currentPassword) {
          const err = new Error('Current password is required to set a new password');
          err.statusCode = 400;
          throw err;
        }
        if (newPassword.length < 6) {
          const err = new Error('New password must be at least 6 characters long');
          err.statusCode = 400;
          throw err;
        }

        const isMatch = await bcrypt.compare(currentPassword, currentUser.PASSWORD_HASH);
        if (!isMatch) {
          const err = new Error('Current password does not match');
          err.statusCode = 401;
          throw err;
        }
        newPasswordHash = await bcrypt.hash(newPassword, 10);
      }

      const updateSql = `
        UPDATE users
        SET username = :username,
            email = :email,
            avatar_url = :avatarUrl,
            password_hash = :passwordHash,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = :userId
      `;
      await conn.execute(
        updateSql,
        {
          username: cleanUsername,
          email: cleanEmail,
          avatarUrl: newAvatarUrl,
          passwordHash: newPasswordHash,
          userId,
        },
        { autoCommit: true }
      );

      return {
        id: userId,
        username: cleanUsername,
        email: cleanEmail,
        avatarUrl: newAvatarUrl,
      };
    } finally {
      if (conn) {
        try {
          await conn.close();
        } catch (_) {}
      }
    }
  }

  /**
   * Helper: Generate unique username in DB
   */
  async _getUniqueUsername(conn, desiredName, currentUserId = null) {
    let base = (desiredName || '').trim().replace(/[\r\n\t]/g, ' ').slice(0, 45) || 'user';
    let candidate = base;
    let counter = 1;

    while (true) {
      let checkSql = 'SELECT id FROM users WHERE LOWER(username) = LOWER(:u)';
      const binds = { u: candidate };
      if (currentUserId) {
        checkSql += ' AND id != :userId';
        binds.userId = currentUserId;
      }
      const checkRes = await conn.execute(
        checkSql,
        binds,
        { outFormat: oracledb.OUT_FORMAT_OBJECT }
      );
      if (!checkRes.rows || checkRes.rows.length === 0) {
        return candidate;
      }
      candidate = `${base.slice(0, 40)}_${counter++}`;
    }
  }

  /**
   * Google OAuth 2.0 login / registration
   * Verifies Google idToken, retrieves user info, and creates/returns user in Oracle DB
   */
  async loginWithGoogle(idToken, { accessToken, displayName, photoUrl } = {}) {
    if (!idToken && !accessToken) {
      const err = new Error('Google idToken or accessToken is required');
      err.statusCode = 400;
      throw err;
    }

    let payload;
    try {
      if (idToken && typeof idToken === 'string' && idToken.trim()) {
        const ticket = await googleClient.verifyIdToken({
          idToken,
          audience: config.google.clientId,
        });
        payload = ticket.getPayload();
      } else if (accessToken && typeof accessToken === 'string' && accessToken.trim()) {
        const tokenInfo = await googleClient.getTokenInfo(accessToken);
        if (tokenInfo.aud && tokenInfo.aud !== config.google.clientId) {
          const err = new Error('Token audience mismatch');
          err.statusCode = 401;
          throw err;
        }
        const userinfoRes = await fetch('https://www.googleapis.com/oauth2/v3/userinfo', {
          headers: { Authorization: `Bearer ${accessToken}` },
        });
        if (!userinfoRes.ok) {
          const err = new Error(`Failed to fetch Google userinfo: ${userinfoRes.status}`);
          err.statusCode = 401;
          throw err;
        }
        const userinfo = await userinfoRes.json();
        payload = {
          sub: tokenInfo.sub || userinfo.sub,
          email: tokenInfo.email || userinfo.email,
          name: userinfo.name,
          picture: userinfo.picture,
          given_name: userinfo.given_name,
          family_name: userinfo.family_name,
        };
      }
    } catch (verifyErr) {
      const err = new Error(`Invalid Google token: ${verifyErr.message}`);
      err.statusCode = 401;
      throw err;
    }

    if (!payload || !payload.sub || !payload.email) {
      const err = new Error('Invalid Google payload: missing email or sub');
      err.statusCode = 401;
      throw err;
    }

    const googleId = payload.sub;
    const email = payload.email.trim().toLowerCase();
    const name = displayName || payload.name || payload.given_name || email.split('@')[0];
    const picture = photoUrl || payload.picture || null;

    let conn;
    try {
      conn = await getDbConnection();

      // Check if user exists by google_id or email
      const findSql = `
        SELECT id, username, email, avatar_url, google_id
        FROM users
        WHERE google_id = :googleId OR LOWER(email) = LOWER(:email)
      `;
      const result = await conn.execute(
        findSql,
        { googleId, email },
        { outFormat: oracledb.OUT_FORMAT_OBJECT }
      );

      let user;
      if (result.rows && result.rows.length > 0) {
        user = result.rows[0];

        // Preserve user's chosen username; only fallback to Google name if user has no username
        let targetUsername = user.USERNAME;
        if (!targetUsername || !targetUsername.trim()) {
          targetUsername = await this._getUniqueUsername(conn, name, user.ID);
        }

        // Preserve custom avatar if user already uploaded one, otherwise fallback to Google photo
        const newAvatar = user.AVATAR_URL || picture;

        const updateSql = `
          UPDATE users
          SET google_id = :googleId,
              username = :username,
              avatar_url = :avatarUrl,
              updated_at = CURRENT_TIMESTAMP
          WHERE id = :id
        `;
        await conn.execute(
          updateSql,
          {
            googleId,
            username: targetUsername,
            avatarUrl: newAvatar,
            id: user.ID,
          },
          { autoCommit: true }
        );

        user.USERNAME = targetUsername;
        user.AVATAR_URL = newAvatar;

        const token = this.generateToken({
          id: user.ID,
          username: user.USERNAME,
          email: user.EMAIL,
        });

        return {
          isNewUser: false,
          user: {
            id: user.ID,
            username: user.USERNAME,
            email: user.EMAIL,
            avatarUrl: user.AVATAR_URL || picture,
          },
          token,
        };
      } else {
        // User does not exist in DB yet: prompt registration with locked Google email
        return {
          isNewUser: true,
          email,
          displayName: name,
          photoUrl: picture,
          googleId,
        };
      }
    } finally {
      if (conn) {
        try {
          await conn.close();
        } catch (_) {}
      }
    }
  }
}

module.exports = new AuthService();

