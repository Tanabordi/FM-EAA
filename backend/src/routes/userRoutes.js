const express = require('express');
const router = express.Router();
const authService = require('../services/authService');
const authenticateToken = require('../middleware/auth');

// GET /api/users/avatar-proxy - Proxy external avatar images to bypass browser CORS & 429 rate-limiting
router.get('/avatar-proxy', async (req, res) => {
  try {
    const rawUrl = req.query.url;
    if (!rawUrl || typeof rawUrl !== 'string') {
      return res.status(400).send('Missing url parameter');
    }
    const decodedUrl = decodeURIComponent(rawUrl);
    if (!decodedUrl.startsWith('http://') && !decodedUrl.startsWith('https://')) {
      return res.status(400).send('Invalid url protocol');
    }

    const response = await fetch(decodedUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        Accept: 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
      },
    });

    if (!response.ok) {
      return res.status(response.status).send('Failed to fetch avatar');
    }

    const contentType = response.headers.get('content-type') || 'image/jpeg';
    res.setHeader('Content-Type', contentType);
    res.setHeader('Cache-Control', 'public, max-age=86400');
    const arrayBuffer = await response.arrayBuffer();
    return res.send(Buffer.from(arrayBuffer));
  } catch (err) {
    return res.status(500).send('Proxy error');
  }
});

const multer = require('multer');
const storageService = require('../services/storageService');

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowedMime = ['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif'];
    if (!allowedMime.includes(file.mimetype)) {
      const err = new Error('Invalid file type. Only JPEG, PNG, and WebP are supported.');
      err.statusCode = 400;
      return cb(err, false);
    }
    cb(null, true);
  },
});

// GET /api/users/me - Get current user profile
router.get('/me', authenticateToken, async (req, res, next) => {
  try {
    const user = await authService.getProfile(req.user.id);
    res.status(200).json({ user });
  } catch (err) {
    next(err);
  }
});

// POST /api/users/me/avatar - Upload avatar image to Oracle Cloud Object Storage
router.post('/me/avatar', authenticateToken, (req, res, next) => {
  upload.single('avatar')(req, res, (err) => {
    if (err instanceof multer.MulterError) {
      if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(413).json({ error: 'File size exceeded (Max: 5MB)' });
      }
      return res.status(400).json({ error: err.message });
    }
    if (err) {
      return res.status(err.statusCode || 400).json({ error: err.message });
    }
    next();
  });
}, async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Image file is required (field: avatar)' });
    }

    const avatarUrl = await storageService.uploadAvatar(
      req.user.id,
      req.file.buffer,
      req.file.mimetype,
      req.file.originalname
    );

    const user = await authService.updateProfile(req.user.id, { avatarUrl });
    res.status(200).json({
      message: 'Avatar uploaded successfully',
      avatarUrl,
      user,
    });
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

const pushNotificationService = require('../services/pushNotificationService');

// POST /api/users/fcm-token - Register or update device FCM token
router.post('/fcm-token', authenticateToken, async (req, res, next) => {
  try {
    const { fcmToken } = req.body;
    if (!fcmToken || typeof fcmToken !== 'string') {
      return res.status(400).json({ error: 'fcmToken is required' });
    }
    await pushNotificationService.registerToken(req.user.id, fcmToken.trim());
    res.status(200).json({ success: true, message: 'FCM token registered' });
  } catch (err) {
    next(err);
  }
});

// DELETE /api/users/fcm-token - Remove device token on logout
router.delete('/fcm-token', authenticateToken, async (req, res, next) => {
  try {
    const { fcmToken } = req.body;
    if (fcmToken) {
      await pushNotificationService.removeToken(req.user.id, fcmToken.trim());
    }
    res.status(200).json({ success: true, message: 'FCM token removed' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;

