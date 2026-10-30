const express = require('express');
const router = express.Router();

// TODO(route users): GET /api/users/search?username=
router.get('/search', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: 'GET /api/users/search' });
});

// TODO(route users): GET /api/users/me
router.get('/me', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: 'GET /api/users/me' });
});

// TODO(route users): PATCH /api/users/me
router.patch('/me', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: 'PATCH /api/users/me' });
});

module.exports = router;

