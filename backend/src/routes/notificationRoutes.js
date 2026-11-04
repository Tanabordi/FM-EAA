const express = require('express');
const router = express.Router();
const authenticateToken = require('../middleware/auth');
const db = require('../config/db');

router.use(authenticateToken);

// GET /api/notifications - List notifications for current user
router.get('/', async (req, res, next) => {
  let conn;
  try {
    conn = await db.getDbConnection();
    const sql = `
      SELECT id, user_id, type, payload_json, is_read, created_at
      FROM notifications
      WHERE user_id = :userId
      ORDER BY created_at DESC
    `;
    const result = await conn.execute(sql, [req.user.id]);
    const notifications = (result.rows || []).map(r => {
      let payload = {};
      try {
        payload = typeof r[3] === 'string' ? JSON.parse(r[3]) : (r[3] || {});
      } catch (_) {
        payload = { raw: r[3] };
      }
      return {
        id: r[0],
        userId: r[1],
        type: r[2],
        payload,
        isRead: Boolean(r[4]),
        createdAt: r[5],
      };
    });
    res.status(200).json({ notifications });
  } catch (err) {
    next(err);
  } finally {
    if (conn) {
      try { await conn.close(); } catch (_) {}
    }
  }
});

// PATCH /api/notifications/:id/read - Mark notification as read
router.patch('/:id/read', async (req, res, next) => {
  let conn;
  try {
    conn = await db.getDbConnection();
    await conn.execute(
      `UPDATE notifications SET is_read = 1 WHERE id = :id AND user_id = :userId`,
      [req.params.id, req.user.id]
    );
    await conn.commit();
    res.status(200).json({ success: true, message: 'Notification marked as read' });
  } catch (err) {
    if (conn) {
      try { await conn.rollback(); } catch (_) {}
    }
    next(err);
  } finally {
    if (conn) {
      try { await conn.close(); } catch (_) {}
    }
  }
});

// DELETE /api/notifications/:id - Delete single notification
router.delete('/:id', async (req, res, next) => {
  let conn;
  try {
    conn = await db.getDbConnection();
    await conn.execute(
      `DELETE FROM notifications WHERE id = :id AND user_id = :userId`,
      [req.params.id, req.user.id]
    );
    await conn.commit();
    res.status(200).json({ success: true, message: 'Notification deleted' });
  } catch (err) {
    if (conn) {
      try { await conn.rollback(); } catch (_) {}
    }
    next(err);
  } finally {
    if (conn) {
      try { await conn.close(); } catch (_) {}
    }
  }
});

// DELETE /api/notifications - Clear all notifications
router.delete('/', async (req, res, next) => {
  let conn;
  try {
    conn = await db.getDbConnection();
    await conn.execute(
      `DELETE FROM notifications WHERE user_id = :userId`,
      [req.user.id]
    );
    await conn.commit();
    res.status(200).json({ success: true, message: 'All notifications cleared' });
  } catch (err) {
    if (conn) {
      try { await conn.rollback(); } catch (_) {}
    }
    next(err);
  } finally {
    if (conn) {
      try { await conn.close(); } catch (_) {}
    }
  }
});

module.exports = router;
