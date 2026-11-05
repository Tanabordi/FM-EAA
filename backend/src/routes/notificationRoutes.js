const express = require('express');
const router = express.Router();
const authenticateToken = require('../middleware/auth');
const notificationService = require('../services/notificationService');

router.use(authenticateToken);

// GET /api/notifications - List notifications for current user (auto-checks for new expiry alerts)
router.get('/', async (req, res, next) => {
  try {
    // Proactively scan for any items expiring soon
    await notificationService.checkAndGenerateExpiryNotifications(req.user.id).catch(err => {
      console.warn('[NotificationRoutes] Expiry check warning:', err.message);
    });

    const result = await notificationService.getNotifications(req.user.id);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
});

// GET /api/notifications/unread-count - Get count of unread notifications
router.get('/unread-count', async (req, res, next) => {
  try {
    const result = await notificationService.getUnreadCount(req.user.id);
    res.status(200).json(result);
  } catch (err) {
    next(err);
  }
});

// POST /api/notifications/check-expiry - Manually trigger expiry notification generation
router.post('/check-expiry', async (req, res, next) => {
  try {
    const newlyGenerated = await notificationService.checkAndGenerateExpiryNotifications(req.user.id);
    res.status(200).json({
      success: true,
      count: newlyGenerated.length,
      notifications: newlyGenerated,
    });
  } catch (err) {
    next(err);
  }
});

// PATCH /api/notifications/read-all - Mark all notifications as read
router.patch('/read-all', async (req, res, next) => {
  try {
    const result = await notificationService.markAllAsRead(req.user.id);
    res.status(200).json({ success: true, message: 'All notifications marked as read', ...result });
  } catch (err) {
    next(err);
  }
});

// PATCH /api/notifications/:id/read - Mark single notification as read
router.patch('/:id/read', async (req, res, next) => {
  try {
    const result = await notificationService.markAsRead(req.params.id, req.user.id);
    res.status(200).json({ success: true, message: 'Notification marked as read', ...result });
  } catch (err) {
    next(err);
  }
});

// DELETE /api/notifications/:id - Delete single notification
router.delete('/:id', async (req, res, next) => {
  try {
    const result = await notificationService.deleteNotification(req.params.id, req.user.id);
    res.status(200).json({ success: true, message: 'Notification deleted', ...result });
  } catch (err) {
    next(err);
  }
});

// DELETE /api/notifications - Clear all notifications
router.delete('/', async (req, res, next) => {
  try {
    const result = await notificationService.clearAll(req.user.id);
    res.status(200).json({ success: true, message: 'All notifications cleared', ...result });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
