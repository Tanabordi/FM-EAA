const express = require('express');
const router = express.Router();

// TODO(route fridges): GET /api/fridges - List all fridges user has access to
router.get('/', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: 'GET /api/fridges' });
});

// TODO(route fridges): POST /api/fridges - Create a new fridge
router.post('/', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: 'POST /api/fridges' });
});

// TODO(route fridges): GET /api/fridges/:id - Get details of a fridge
router.get('/:id', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `GET /api/fridges/${req.params.id}` });
});

// TODO(route fridges): PATCH /api/fridges/:id - Update fridge details (name, description)
router.patch('/:id', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `PATCH /api/fridges/${req.params.id}` });
});

// TODO(route fridges): DELETE /api/fridges/:id - Delete a fridge
router.delete('/:id', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `DELETE /api/fridges/${req.params.id}` });
});

// TODO(route fridges): GET /api/fridges/:id/members - List fridge members
router.get('/:id/members', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `GET /api/fridges/${req.params.id}/members` });
});

// TODO(route fridges): DELETE /api/fridges/:id/members/:userId - Remove a member
router.delete('/:id/members/:userId', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `DELETE /api/fridges/${req.params.id}/members/${req.params.userId}` });
});

// TODO(route fridges): POST /api/fridges/:id/invites - Invite a member by username
router.post('/:id/invites', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `POST /api/fridges/${req.params.id}/invites` });
});

// TODO(route fridges): POST /api/invites/:id/accept - Accept invitation
router.post('/invites/:id/accept', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `POST /api/invites/${req.params.id}/accept` });
});

// TODO(route fridges): POST /api/invites/:id/decline - Decline invitation
router.post('/invites/:id/decline', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `POST /api/invites/${req.params.id}/decline` });
});

module.exports = router;

