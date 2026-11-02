const express = require('express');
const router = express.Router();
const authService = require('../services/authService');
const authenticateToken = require('../middleware/auth');

// GET /api/users/me - Get current user profile
router.get('/me', authenticateToken, async (req, res, next) => {
  try {
    const user = await authService.getProfile(req.user.id);
    res.status(200).json({ user });
  } catch (err) {
    next(err);
  }
});

// PATCH /api/users/me - Update profile (username, email, avatar, password)
router.patch('/me', authenticateToken, async (req, res, next) => {
  try {
    const { username, email, avatarUrl, currentPassword, newPassword } = req.body;
    const user = await authService.updateProfile(req.user.id, {
      username,
      email,
      avatarUrl,
      currentPassword,
      newPassword,
    });
    res.status(200).json({ message: 'Profile updated successfully', user });
  } catch (err) {
    next(err);
  }
});

// Search users by username (for inviting members)
router.get('/search', authenticateToken, async (req, res, next) => {
  try {
    const query = req.query.username;
    if (!query) {
      return res.status(200).json({ users: [] });
    }
    // Search users in DB
    const { getDbConnection } = require('../config/db');
    const oracledb = require('oracledb');
    let conn;
    try {
      conn = await getDbConnection();
      const sql = `
        SELECT id, username, email, avatar_url
        FROM users
        WHERE LOWER(username) LIKE LOWER(:term)
        FETCH FIRST 20 ROWS ONLY
      `;
      const result = await conn.execute(
        sql,
        { term: `%${query.trim()}%` },
        { outFormat: oracledb.OUT_FORMAT_OBJECT }
      );
      const users = (result.rows || []).map((u) => ({
        id: u.ID,
        username: u.USERNAME,
        email: u.EMAIL,
        avatarUrl: u.AVATAR_URL,
      }));
      res.status(200).json({ users });
    } finally {
      if (conn) {
        try {
          await conn.close();
        } catch (_) {}
      }
    }
  } catch (err) {
    next(err);
  }
});

module.exports = router;

