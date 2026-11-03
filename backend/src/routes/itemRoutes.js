const express = require('express');
const router = express.Router({ mergeParams: true });
const itemService = require('../services/itemService');
const authenticateToken = require('../middleware/auth');
const db = require('../config/db');

// Apply auth middleware to all item routes
router.use(authenticateToken);

/**
 * Helper to resolve fridgeId if route is mounted at /api/items/:itemId/...
 */
async function resolveFridgeId(req) {
  if (req.params.id) {
    return req.params.id;
  }
  if (req.params.itemId) {
    let conn;
    try {
      conn = await db.getDbConnection();
      const res = await conn.execute(
        `SELECT fridge_id FROM items WHERE id = :itemId`,
        [req.params.itemId]
      );
      if (res.rows && res.rows.length > 0) {
        return res.rows[0][0];
      }
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }
  const err = new Error('Fridge ID not found or specified');
  err.statusCode = 400;
  throw err;
}

// GET /api/fridges/:id/items - List all items in a fridge (with zone, category, and search filter)
router.get('/', async (req, res, next) => {
  try {
    const fridgeId = await resolveFridgeId(req);
    const items = await itemService.getItemsByFridge(fridgeId, req.user.id, {
      zone: req.query.zone,
      category: req.query.category,
      search: req.query.search,
    });
    res.status(200).json({ items });
  } catch (err) {
    next(err);
  }
});

// POST /api/fridges/:id/items - Add a new item
router.post('/', async (req, res, next) => {
  try {
    const fridgeId = await resolveFridgeId(req);
    const item = await itemService.createItem(fridgeId, req.user.id, req.body);
    res.status(201).json({ success: true, item });
  } catch (err) {
    next(err);
  }
});

// GET /api/fridges/:id/items/:itemId or GET /api/items/:itemId - Get item details
router.get('/:itemId', async (req, res, next) => {
  try {
    const fridgeId = await resolveFridgeId(req);
    const item = await itemService.getItemById(fridgeId, req.params.itemId, req.user.id);
    res.status(200).json({ item });
  } catch (err) {
    next(err);
  }
});

// PATCH /api/fridges/:id/items/:itemId or PATCH /api/items/:itemId - Update item details
router.patch('/:itemId', async (req, res, next) => {
  try {
    const fridgeId = await resolveFridgeId(req);
    const item = await itemService.updateItem(fridgeId, req.params.itemId, req.user.id, req.body);
    res.status(200).json({ success: true, item });
  } catch (err) {
    next(err);
  }
});

// DELETE /api/fridges/:id/items/:itemId or DELETE /api/items/:itemId - Delete an item
router.delete('/:itemId', async (req, res, next) => {
  try {
    const fridgeId = await resolveFridgeId(req);
    const result = await itemService.deleteItem(fridgeId, req.params.itemId, req.user.id);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
});

// POST /api/fridges/:id/items/:itemId/consume or POST /api/items/:itemId/consume
router.post('/:itemId/consume', async (req, res, next) => {
  try {
    const fridgeId = await resolveFridgeId(req);
    const result = await itemService.consumeItem(fridgeId, req.params.itemId, req.user.id, req.body);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
});

// POST /api/fridges/:id/items/:itemId/consume/undo or POST /api/items/:itemId/consume/undo
router.post('/:itemId/consume/undo', async (req, res, next) => {
  try {
    const fridgeId = await resolveFridgeId(req);
    const historyId = req.body.historyId || req.query.historyId;
    if (!historyId) {
      return res.status(400).json({ error: 'historyId is required to undo consumption' });
    }
    const result = await itemService.undoConsume(fridgeId, historyId, req.user.id);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
