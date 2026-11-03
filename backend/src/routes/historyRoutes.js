const express = require('express');
const router = express.Router({ mergeParams: true });
const itemService = require('../services/itemService');
const authenticateToken = require('../middleware/auth');

// Apply auth middleware to all history routes
router.use(authenticateToken);

// GET /api/fridges/:id/history?kind=consumed|expired
router.get('/', async (req, res, next) => {
  try {
    const history = await itemService.getHistory(req.params.id, req.user.id, req.query.kind);
    res.status(200).json({ history });
  } catch (err) {
    next(err);
  }
});

// DELETE /api/fridges/:id/history/clear?kind=consumed|expired
router.delete('/clear', async (req, res, next) => {
  try {
    const result = await itemService.clearHistory(req.params.id, req.user.id, req.query.kind);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
});

// DELETE /api/fridges/:id/history/:historyId - Delete single history record
router.delete('/:historyId', async (req, res, next) => {
  try {
    const result = await itemService.deleteHistoryItem(req.params.id, req.params.historyId, req.user.id);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
