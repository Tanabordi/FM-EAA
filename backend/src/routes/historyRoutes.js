const express = require('express');
const router = express.Router({ mergeParams: true });

// TODO(route history): GET /api/fridges/:id/history?kind=consumed|expired
router.get('/', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `GET /api/fridges/${req.params.id}/history` });
});

// TODO(route history): DELETE /api/fridges/:id/history/clear?kind=consumed|expired
router.delete('/clear', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `DELETE /api/fridges/${req.params.id}/history/clear` });
});

// TODO(route history): DELETE /api/fridges/:id/history/:historyId - Delete single history record
router.delete('/:historyId', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `DELETE /api/fridges/${req.params.id}/history/${req.params.historyId}` });
});

module.exports = router;

