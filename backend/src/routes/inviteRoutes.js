const express = require('express');
const router = express.Router();
const fridgeService = require('../services/fridgeService');
const authenticateToken = require('../middleware/auth');
const db = require('../config/db');

// Apply auth middleware to all invite routes
router.use(authenticateToken);

// GET /api/invites/pending - List pending invites for current user
router.get('/pending', async (req, res, next) => {
  let conn;
  try {
    conn = await db.getDbConnection();
    const sql = `
      SELECT 
        fi.id,
        fi.fridge_id,
        f.name AS fridge_name,
        fi.from_user_id,
        u.username AS from_username,
        u.avatar_url AS from_avatar_url,
        fi.status,
        fi.created_at
      FROM fridge_invites fi
      JOIN fridges f ON fi.fridge_id = f.id
      JOIN users u ON fi.from_user_id = u.id
      WHERE fi.to_user_id = :userId AND fi.status = 'pending'
      ORDER BY fi.created_at DESC
    `;
    const result = await conn.execute(sql, [req.user.id]);
    const invites = (result.rows || []).map(r => ({
      id: r[0],
      fridgeId: r[1],
      fridgeName: r[2],
      fromUserId: r[3],
      fromUsername: r[4],
      fromAvatarUrl: r[5] || null,
      status: r[6],
      createdAt: r[7],
    }));
    res.status(200).json({ invites });
  } catch (err) {
    next(err);
  } finally {
    if (conn) {
      try { await conn.close(); } catch (_) {}
    }
  }
});

// POST /api/invites/:id/accept - Accept an invitation
router.post('/:id/accept', async (req, res, next) => {
  try {
    const result = await fridgeService.respondToInvite(req.params.id, req.user.id, true);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
});

// POST /api/invites/:id/decline - Decline an invitation
router.post('/:id/decline', async (req, res, next) => {
  try {
    const result = await fridgeService.respondToInvite(req.params.id, req.user.id, false);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
