const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const oracledb = require('oracledb');
const config = require('../config/env');
const { getDbConnection } = require('../config/db');

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
}

module.exports = new AuthService();

