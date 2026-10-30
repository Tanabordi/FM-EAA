const express = require('express');
const router = express.Router();

// TODO(route auth): POST /api/auth/register
router.post('/register', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: 'POST /api/auth/register' });
});

// TODO(route auth): POST /api/auth/login (supports username or email + password)
router.post('/login', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: 'POST /api/auth/login' });
});

// TODO(route auth): POST /api/auth/google
router.post('/google', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: 'POST /api/auth/google' });
});

// TODO(route auth): POST /api/auth/forgot-password
router.post('/forgot-password', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: 'POST /api/auth/forgot-password' });
});

// TODO(route auth): POST /api/auth/reset-password
router.post('/reset-password', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: 'POST /api/auth/reset-password' });
});

module.exports = router;

