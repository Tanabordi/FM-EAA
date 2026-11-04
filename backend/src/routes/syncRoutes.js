const express = require('express');
const router = express.Router();
const syncService = require('../services/syncService');
const authenticateToken = require('../middleware/auth');

// Require authentication for all sync routes
router.use(authenticateToken);

// POST /api/sync - Batch offline-first synchronization with Last-Write-Wins (LWW)
router.post('/', async (req, res, next) => {
  try {
    const result = await syncService.processBatchSync(req.user.id, req.body);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
