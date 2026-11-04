const db = require('../config/db');
const { v4: uuidv4 } = require('uuid');

class NotificationService {
  /**
   * Get all notifications for a user, ordered by creation date descending.
   */
  async getNotifications(userId) {
    let conn;
    try {
      conn = await db.getDbConnection();

      // Purge any stale invite notifications whose invite status in fridge_invites is no longer pending
      try {
        await conn.execute(`
          DELETE FROM notifications n
          WHERE n.user_id = :userId
            AND n.type = 'invite'
            AND EXISTS (
              SELECT 1 FROM fridge_invites fi
              WHERE n.payload_json LIKE '%' || fi.id || '%'
                AND fi.status IN ('accepted', 'declined')
            )
        `, [userId]);
        await conn.commit();
      } catch (cleanErr) {
        console.warn('[NotificationService] Clean stale invites warning:', cleanErr.message);
      }

      const sql = `
        SELECT id, user_id, type, payload_json, is_read,
               TO_CHAR(created_at, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS created_at
        FROM notifications
        WHERE user_id = :userId
        ORDER BY created_at DESC
      `;
      const result = await conn.execute(sql, [userId]);
      const notifications = (result.rows || []).map(r => {
        let payload = {};
        try {
          payload = typeof r[3] === 'string' ? JSON.parse(r[3]) : (r[3] || {});
        } catch (_) {
          payload = { raw: r[3] };
        }
        const effectiveType = payload.sub_type || payload.type || r[2];
        return {
          id: r[0],
          userId: r[1],
          type: effectiveType,
          title: payload.title || '',
          message: payload.message || '',
          payload,
          isRead: Boolean(r[4]),
          createdAt: r[5],
        };
      });

      const unreadCount = notifications.filter(n => !n.isRead).length;
      return { notifications, unreadCount };
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /**
   * Helper: Notify members of a fridge (optionally excluding actor).
   * Compatible with Oracle DB check constraint (type in ('invite', 'expiry')).
   */
  async notifyFridgeMembers(connOrFridgeId, fridgeIdOrExclude, excludeOrData, maybeData) {
    let conn;
    let fridgeId;
    let excludeUserId;
    let notifData;
    let shouldClose = false;

    if (connOrFridgeId && typeof connOrFridgeId.execute === 'function') {
      conn = connOrFridgeId;
      fridgeId = fridgeIdOrExclude;
      excludeUserId = excludeOrData;
      notifData = maybeData || {};
    } else {
      conn = await db.getDbConnection();
      fridgeId = connOrFridgeId;
      excludeUserId = fridgeIdOrExclude;
      notifData = excludeOrData || {};
      shouldClose = true;
    }

    try {
      const { type = 'item_action', subType, title = 'Notification', message = '', ...extra } = notifData;
      const finalSubType = subType || type;
      const dbType = (type === 'invite' || finalSubType === 'member_joined' || type === 'member_joined') ? 'invite' : 'expiry';

      const membersRes = await conn.execute(
        `SELECT user_id FROM fridge_members WHERE fridge_id = :fridgeId AND user_id != :excludeUserId`,
        [fridgeId, excludeUserId || '']
      );
      const memberIds = (membersRes.rows || []).map(r => r[0]);
      if (memberIds.length === 0) return [];

      const payloadObj = {
        title,
        message,
        sub_type: finalSubType,
        fridge_id: fridgeId,
        ...extra,
      };
      const payloadStr = JSON.stringify(payloadObj);

      for (const memberId of memberIds) {
        const id = uuidv4();
        await conn.execute(
          `INSERT INTO notifications (id, user_id, type, payload_json, is_read, created_at)
           VALUES (:id, :userId, :dbType, :payloadJson, 0, CURRENT_TIMESTAMP)`,
          [id, memberId, dbType, payloadStr]
        );
      }

      if (shouldClose) {
        await conn.commit();
      }
      return memberIds;
    } catch (err) {
      if (shouldClose && conn) {
        try { await conn.rollback(); } catch (_) {}
      }
      throw err;
    } finally {
      if (shouldClose && conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /**
   * Get the unread count for a user.
   */
  async getUnreadCount(userId) {
    let conn;
    try {
      conn = await db.getDbConnection();
      const sql = `
        SELECT COUNT(*)
        FROM notifications
        WHERE user_id = :userId AND is_read = 0
      `;
      const result = await conn.execute(sql, [userId]);
      const count = result.rows && result.rows[0] ? Number(result.rows[0][0]) : 0;
      return { unreadCount: count };
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /**
   * Mark a single notification as read.
   */
  async markAsRead(notificationId, userId) {
    let conn;
    try {
      conn = await db.getDbConnection();
      const result = await conn.execute(
        `UPDATE notifications SET is_read = 1 WHERE id = :id AND user_id = :userId`,
        [notificationId, userId]
      );
      await conn.commit();
      return { success: true, updated: result.rowsAffected || 0 };
    } catch (err) {
      if (conn) {
        try { await conn.rollback(); } catch (_) {}
      }
      throw err;
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /**
   * Mark all notifications for a user as read.
   */
  async markAllAsRead(userId) {
    let conn;
    try {
      conn = await db.getDbConnection();
      const result = await conn.execute(
        `UPDATE notifications SET is_read = 1 WHERE user_id = :userId`,
        [userId]
      );
      await conn.commit();
      return { success: true, updated: result.rowsAffected || 0 };
    } catch (err) {
      if (conn) {
        try { await conn.rollback(); } catch (_) {}
      }
      throw err;
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /**
   * Delete a single notification.
   */
  async deleteNotification(notificationId, userId) {
    let conn;
    try {
      conn = await db.getDbConnection();
      const result = await conn.execute(
        `DELETE FROM notifications WHERE id = :id AND user_id = :userId`,
        [notificationId, userId]
      );
      await conn.commit();
      return { success: true, deleted: result.rowsAffected || 0 };
    } catch (err) {
      if (conn) {
        try { await conn.rollback(); } catch (_) {}
      }
      throw err;
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /**
   * Clear all notifications for a user.
   */
  async clearAll(userId) {
    let conn;
    try {
      conn = await db.getDbConnection();
      const result = await conn.execute(
        `DELETE FROM notifications WHERE user_id = :userId`,
        [userId]
      );
      await conn.commit();
      return { success: true, deleted: result.rowsAffected || 0 };
    } catch (err) {
      if (conn) {
        try { await conn.rollback(); } catch (_) {}
      }
      throw err;
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /**
   * Create an in-app notification for a user.
   */
  async createNotification(userId, type, payload) {
    let conn;
    try {
      conn = await db.getDbConnection();
      const id = uuidv4();
      const payloadObj = typeof payload === 'string' ? JSON.parse(payload) : (payload || {});
      const subType = payloadObj.sub_type || type;
      payloadObj.sub_type = subType;
      const dbType = (type === 'invite' || subType === 'member_joined' || type === 'member_joined') ? 'invite' : 'expiry';
      const payloadStr = JSON.stringify(payloadObj);
      const sql = `
        INSERT INTO notifications (id, user_id, type, payload_json, is_read, created_at)
        VALUES (:id, :userId, :dbType, :payloadJson, 0, CURRENT_TIMESTAMP)
      `;
      await conn.execute(sql, [id, userId, dbType, payloadStr]);
      await conn.commit();
      return {
        id,
        userId,
        type: subType,
        payload: payloadObj,
        isRead: false,
      };
    } catch (err) {
      if (conn) {
        try { await conn.rollback(); } catch (_) {}
      }
      throw err;
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /**
   * Scan items in the user's fridges that are expiring soon (<= 3 days) or already expired,
   * and generate in-app notifications if not already generated.
   */
  async checkAndGenerateExpiryNotifications(userId) {
    let conn;
    try {
      conn = await db.getDbConnection();

      // Find items in fridges accessible to user that are expiring soon or expired
      const itemsSql = `
        SELECT i.id, i.name, i.fridge_id, f.name AS fridge_name,
               TO_CHAR(i.expiry_date, 'YYYY-MM-DD') AS expiry_date,
               ROUND(TRUNC(i.expiry_date) - TRUNC(CURRENT_DATE)) AS days_left
        FROM items i
        JOIN fridge_members fm ON fm.fridge_id = i.fridge_id
        JOIN fridges f ON f.id = i.fridge_id
        WHERE fm.user_id = :userId
          AND TRUNC(i.expiry_date) <= TRUNC(CURRENT_DATE) + 3
        ORDER BY i.expiry_date ASC
      `;

      const itemsResult = await conn.execute(itemsSql, [userId]);
      const expiringItems = itemsResult.rows || [];
      if (expiringItems.length === 0) {
        return [];
      }

      // Check existing notifications for this user created in the last 24 hours to prevent duplicate spam
      const existingSql = `
        SELECT payload_json
        FROM notifications
        WHERE user_id = :userId
          AND type = 'expiry'
          AND created_at >= CURRENT_TIMESTAMP - INTERVAL '1' DAY
      `;
      const existingResult = await conn.execute(existingSql, [userId]);
      const recentNotifiedItemIds = new Set();

      for (const row of existingResult.rows || []) {
        try {
          const parsed = typeof row[0] === 'string' ? JSON.parse(row[0]) : (row[0] || {});
          if (parsed.item_id) {
            recentNotifiedItemIds.add(parsed.item_id);
          }
        } catch (_) {}
      }

      const generated = [];
      for (const item of expiringItems) {
        const itemId = item[0];
        const itemName = item[1];
        const fridgeId = item[2];
        const fridgeName = item[3];
        const expiryDate = item[4];
        const daysLeft = Number(item[5]);

        if (recentNotifiedItemIds.has(itemId)) {
          continue; // Already notified recently
        }

        let title = '';
        let message = '';
        if (daysLeft < 0) {
          title = `${itemName} has expired`;
          message = `${itemName} in "${fridgeName}" expired on ${expiryDate}.`;
        } else if (daysLeft === 0) {
          title = `${itemName} expires today`;
          message = `${itemName} in "${fridgeName}" expires today. Consume soon!`;
        } else if (daysLeft === 1) {
          title = `${itemName} expires tomorrow`;
          message = `${itemName} in "${fridgeName}" expires tomorrow (${expiryDate}).`;
        } else {
          title = `${itemName} expires in ${daysLeft} days`;
          message = `${itemName} in "${fridgeName}" expires on ${expiryDate}.`;
        }

        const id = uuidv4();
        const payload = {
          item_id: itemId,
          fridge_id: fridgeId,
          fridge_name: fridgeName,
          expiry_date: expiryDate,
          days_left: daysLeft,
          title,
          message,
        };

        await conn.execute(
          `INSERT INTO notifications (id, user_id, type, payload_json, is_read, created_at)
           VALUES (:id, :userId, 'expiry', :payloadJson, 0, CURRENT_TIMESTAMP)`,
          [id, userId, JSON.stringify(payload)]
        );

        recentNotifiedItemIds.add(itemId);
        generated.push({ id, userId, type: 'expiry', payload, isRead: false });
      }

      if (generated.length > 0) {
        await conn.commit();
      }

      return generated;
    } catch (err) {
      if (conn) {
        try { await conn.rollback(); } catch (_) {}
      }
      console.error('[NotificationService] checkAndGenerateExpiryNotifications error:', err.message);
      return [];
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }
}

module.exports = new NotificationService();
