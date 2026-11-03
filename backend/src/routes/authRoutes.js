const express = require('express');
const router = express.Router();
const authService = require('../services/authService');
const authenticateToken = require('../middleware/auth');

/**
 * POST /api/auth/register
 * Body: { username, email, password }
 */
router.post('/register', async (req, res, next) => {
  try {
    const { username, email, password } = req.body;
    const result = await authService.register(username, email, password);
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
});

/**
 * POST /api/auth/login
 * Body: { identifier, password } OR { email/username, password }
 */
router.post('/login', async (req, res, next) => {
  try {
    const identifier = req.body.identifier || req.body.username || req.body.email;
    const { password } = req.body;
    const result = await authService.login(identifier, password);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/auth/me
 * Headers: Authorization: Bearer <token>
 */
router.get('/me', authenticateToken, async (req, res, next) => {
  try {
    const user = await authService.getProfile(req.user.id);
    res.status(200).json({ user });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /api/auth/google
 * Body: { idToken }
 */
router.post('/google', async (req, res, next) => {
  try {
    const { idToken, accessToken, displayName, photoUrl } = req.body;
    const result = await authService.loginWithGoogle(idToken, { accessToken, displayName, photoUrl });
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
});

/**
 * POST /api/auth/forgot-password
 * Body: { email }
 */
router.post('/forgot-password', async (req, res, next) => {
  try {
    const { email } = req.body;
    const result = await authService.requestPasswordReset(email);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
});

/**
 * POST /api/auth/reset-password
 * Body: { email, otp, newPassword }
 */
router.post('/reset-password', async (req, res, next) => {
  try {
    const { email, otp, newPassword } = req.body;
    const result = await authService.resetPassword(email, otp, newPassword);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
});

module.exports = router;

