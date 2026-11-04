const express = require('express');
const router = express.Router();
const fridgeService = require('../services/fridgeService');
const authenticateToken = require('../middleware/auth');

// Apply auth middleware to all fridge routes
router.use(authenticateToken);

// GET /api/fridges - List all fridges user has access to
router.get('/', async (req, res, next) => {
  try {
    const fridges = await fridgeService.getFridgesForUser(req.user.id);
    res.status(200).json({ fridges });
  } catch (err) {
    next(err);
  }
});

// POST /api/fridges - Create a new fridge
router.post('/', async (req, res, next) => {
  try {
    const fridge = await fridgeService.createFridge(req.user.id, req.body);
    res.status(201).json({ success: true, fridge });
  } catch (err) {
    next(err);
  }
});

// GET /api/fridges/:id - Get details of a fridge
router.get('/:id', async (req, res, next) => {
  try {
    const fridge = await fridgeService.getFridgeById(req.params.id, req.user.id);
    res.status(200).json({ fridge });
  } catch (err) {
    next(err);
  }
});

// PATCH /api/fridges/:id - Update fridge details (name, description)
router.patch('/:id', async (req, res, next) => {
  try {
    const fridge = await fridgeService.updateFridge(req.params.id, req.user.id, req.body);
    res.status(200).json({ success: true, fridge });
  } catch (err) {
    next(err);
  }
});

// DELETE /api/fridges/:id - Delete a fridge (Owner only)
router.delete('/:id', async (req, res, next) => {
  try {
    const result = await fridgeService.deleteFridge(req.params.id, req.user.id);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
});

// GET /api/fridges/:id/members - List fridge members
router.get('/:id/members', async (req, res, next) => {
  try {
    const members = await fridgeService.getMembers(req.params.id, req.user.id);
    res.status(200).json({ members });
  } catch (err) {
    next(err);
  }
});

// DELETE /api/fridges/:id/members/:userId - Remove a member
router.delete('/:id/members/:userId', async (req, res, next) => {
  try {
    const result = await fridgeService.removeMember(req.params.id, req.user.id, req.params.userId);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
});

// GET /api/fridges/:id/search-users - Search users for inviting to fridge
router.get('/:id/search-users', async (req, res, next) => {
  try {
    const users = await fridgeService.searchUsersForFridge(req.params.id, req.user.id, req.query.username);
    res.status(200).json({ users });
  } catch (err) {
    next(err);
  }
});

// POST /api/fridges/:id/invites - Invite user by username
router.post('/:id/invites', async (req, res, next) => {
  try {
    const result = await fridgeService.inviteMember(req.params.id, req.user.id, req.body.username);
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
});

// GET /api/fridges/:id/invites - List pending invites for fridge
router.get('/:id/invites', async (req, res, next) => {
  try {
    const invites = await fridgeService.getPendingInvites(req.params.id, req.user.id);
    res.status(200).json({ invites });
  } catch (err) {
    next(err);
  }
});

module.exports = router;

