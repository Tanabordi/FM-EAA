const express = require('express');
const router = express.Router();

// TODO(route sync): POST /api/sync - Batch offline-first synchronization with Last-Write-Wins (LWW)
router.post('/', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: 'POST /api/sync' });
});

module.exports = router;

