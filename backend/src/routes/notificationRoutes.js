const express = require('express');
const router = express.Router();

// TODO(route notifications): GET /api/notifications - List notifications (invites, expiry warnings)
router.get('/', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: 'GET /api/notifications' });
});

// TODO(route notifications): PATCH /api/notifications/:id/read - Mark notification as read
router.patch('/:id/read', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `PATCH /api/notifications/${req.params.id}/read` });
});

module.exports = router;

