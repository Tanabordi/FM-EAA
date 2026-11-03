const express = require('express');
const router = express.Router({ mergeParams: true });

// TODO(route items): GET /api/fridges/:id/items - List all items in a fridge (with zone and category filter)
router.get('/', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `GET /api/fridges/${req.params.id}/items` });
});

// TODO(route items): POST /api/fridges/:id/items - Add a new item
router.post('/', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `POST /api/fridges/${req.params.id}/items` });
});

// TODO(route items): GET /api/fridges/:id/items/:itemId - Get item details
router.get('/:itemId', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `GET /api/fridges/${req.params.id}/items/${req.params.itemId}` });
});

// TODO(route items): PATCH /api/fridges/:id/items/:itemId - Update item details
router.patch('/:itemId', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `PATCH /api/fridges/${req.params.id}/items/${req.params.itemId}` });
});

// TODO(route items): DELETE /api/fridges/:id/items/:itemId - Delete an item
router.delete('/:itemId', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `DELETE /api/fridges/${req.params.id}/items/${req.params.itemId}` });
});

// TODO(route items): POST /api/items/:id/consume - Consume item (partial amount or finished all)
router.post('/:itemId/consume', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `POST /api/items/${req.params.itemId}/consume` });
});

// TODO(route items): POST /api/items/:itemId/consume/undo - Undo consumption
router.post('/:itemId/consume/undo', (req, res) => {
  res.status(501).json({ error: 'Not implemented', route: `POST /api/items/${req.params.itemId}/consume/undo` });
});

module.exports = router;

