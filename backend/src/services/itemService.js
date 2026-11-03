const crypto = require('crypto');
const db = require('../config/db');

const ALLOWED_CATEGORIES = ['proteins', 'veggies', 'beverages', 'meals', 'sauces'];
const ALLOWED_ZONES = ['fridge', 'freezer'];

class ItemService {
  /**
   * Helper: Check if user has access to the specified fridge
   * @param {object} conn 
   * @param {string} fridgeId 
   * @param {string} userId 
   */
  async checkFridgeAccess(conn, fridgeId, userId) {
    const sql = `
      SELECT role FROM fridge_members 
      WHERE fridge_id = :fridgeId AND user_id = :userId
    `;
    const result = await conn.execute(sql, [fridgeId, userId]);
    if (!result.rows || result.rows.length === 0) {
      const err = new Error('Fridge not found or access denied');
      err.statusCode = 404;
      throw err;
    }
    return result.rows[0][0]; // 'owner' or 'member'
  }

  /**
   * List all items in a fridge with optional filtering
   * @param {string} fridgeId 
   * @param {string} userId 
   * @param {{ zone?: string, category?: string, search?: string }} filters 
   */
  async getItemsByFridge(fridgeId, userId, filters = {}) {
    let conn;
    try {
      conn = await db.getDbConnection();
      await this.checkFridgeAccess(conn, fridgeId, userId);

      const conditions = ['fridge_id = :fridgeId'];
      const params = [fridgeId];

      if (filters.zone && ALLOWED_ZONES.includes(filters.zone.toLowerCase())) {
        conditions.push('zone = :zone');
        params.push(filters.zone.toLowerCase());
      }

      if (filters.category && ALLOWED_CATEGORIES.includes(filters.category.toLowerCase())) {
        conditions.push('category = :category');
        params.push(filters.category.toLowerCase());
      }

      if (filters.search && typeof filters.search === 'string' && filters.search.trim()) {
        conditions.push('LOWER(name) LIKE :search');
        params.push(`%${filters.search.trim().toLowerCase()}%`);
      }

      const sql = `
        SELECT 
          id,
          fridge_id,
          name,
          category,
          zone,
          quantity,
          unit,
          TO_CHAR(expiry_date, 'YYYY-MM-DD') AS expiry_date,
          image_path,
          created_at,
          updated_at
        FROM items
        WHERE ${conditions.join(' AND ')}
        ORDER BY expiry_date ASC, created_at DESC
      `;

      const result = await conn.execute(sql, params);
      return result.rows.map(r => ({
        id: r[0],
        fridgeId: r[1],
        name: r[2],
        category: r[3],
        zone: r[4],
        quantity: Number(r[5]),
        unit: r[6],
        expiryDate: r[7],
        imagePath: r[8] || null,
        createdAt: r[9],
        updatedAt: r[10],
      }));
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /**
   * Get item details by id
   * @param {string} fridgeId 
   * @param {string} itemId 
   * @param {string} userId 
   */
  async getItemById(fridgeId, itemId, userId) {
    let conn;
    try {
      conn = await db.getDbConnection();
      await this.checkFridgeAccess(conn, fridgeId, userId);

      const sql = `
        SELECT 
          id,
          fridge_id,
          name,
          category,
          zone,
          quantity,
          unit,
          TO_CHAR(expiry_date, 'YYYY-MM-DD') AS expiry_date,
          image_path,
          created_at,
          updated_at
        FROM items
        WHERE id = :itemId AND fridge_id = :fridgeId
      `;
      const result = await conn.execute(sql, [itemId, fridgeId]);
      if (!result.rows || result.rows.length === 0) {
        const err = new Error('Item not found');
        err.statusCode = 404;
        throw err;
      }

      const r = result.rows[0];
      return {
        id: r[0],
        fridgeId: r[1],
        name: r[2],
        category: r[3],
        zone: r[4],
        quantity: Number(r[5]),
        unit: r[6],
        expiryDate: r[7],
        imagePath: r[8] || null,
        createdAt: r[9],
        updatedAt: r[10],
      };
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /**
   * Create an item in a fridge
   * @param {string} fridgeId 
   * @param {string} userId 
   * @param {object} itemData 
   */
  async createItem(fridgeId, userId, itemData) {
    const {
      name,
      category,
      zone = 'fridge',
      quantity = 1,
      unit = 'pieces',
      expiryDate,
      imagePath = null,
      id,
    } = itemData;

    if (!name || typeof name !== 'string' || !name.trim()) {
      const err = new Error('Item name is required');
      err.statusCode = 400;
      throw err;
    }

    const cleanCategory = (category || '').toLowerCase().trim();
    if (!ALLOWED_CATEGORIES.includes(cleanCategory)) {
      const err = new Error(`Category must be one of: ${ALLOWED_CATEGORIES.join(', ')}`);
      err.statusCode = 400;
      throw err;
    }

    const cleanZone = (zone || 'fridge').toLowerCase().trim();
    if (!ALLOWED_ZONES.includes(cleanZone)) {
      const err = new Error(`Zone must be one of: ${ALLOWED_ZONES.join(', ')}`);
      err.statusCode = 400;
      throw err;
    }

    const numQuantity = Number(quantity);
    if (isNaN(numQuantity) || numQuantity <= 0) {
      const err = new Error('Quantity must be a positive number');
      err.statusCode = 400;
      throw err;
    }

    if (!expiryDate || !/^\d{4}-\d{2}-\d{2}$/.test(expiryDate)) {
      const err = new Error('A valid expiryDate in YYYY-MM-DD format is required');
      err.statusCode = 400;
      throw err;
    }

    const itemId = id || crypto.randomUUID();
    const cleanName = name.trim();
    const cleanUnit = (unit || 'pieces').trim();

    let conn;
    try {
      conn = await db.getDbConnection();
      await this.checkFridgeAccess(conn, fridgeId, userId);

      const sql = `
        INSERT INTO items (
          id, fridge_id, name, category, zone, quantity, unit, expiry_date, image_path, is_synced, created_at, updated_at
        ) VALUES (
          :id, :fridgeId, :name, :category, :zone, :quantity, :unit, TO_DATE(:expiryDate, 'YYYY-MM-DD'), :imagePath, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        )
      `;

      await conn.execute(sql, [
        itemId,
        fridgeId,
        cleanName,
        cleanCategory,
        cleanZone,
        numQuantity,
        cleanUnit,
        expiryDate,
        imagePath || null,
      ]);
      await conn.commit();

      return {
        id: itemId,
        fridgeId,
        name: cleanName,
        category: cleanCategory,
        zone: cleanZone,
        quantity: numQuantity,
        unit: cleanUnit,
        expiryDate,
        imagePath: imagePath || null,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
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
   * Update item details
   * @param {string} fridgeId 
   * @param {string} itemId 
   * @param {string} userId 
   * @param {object} itemData 
   */
  async updateItem(fridgeId, itemId, userId, itemData) {
    let conn;
    try {
      conn = await db.getDbConnection();
      await this.checkFridgeAccess(conn, fridgeId, userId);

      // Verify item exists
      const existing = await this.getItemById(fridgeId, itemId, userId);

      const updates = [];
      const params = [];

      if (itemData.name !== undefined) {
        if (!itemData.name || typeof itemData.name !== 'string' || !itemData.name.trim()) {
          const err = new Error('Item name cannot be empty');
          err.statusCode = 400;
          throw err;
        }
        updates.push('name = :name');
        params.push(itemData.name.trim());
      }

      if (itemData.category !== undefined) {
        const cat = itemData.category.toLowerCase().trim();
        if (!ALLOWED_CATEGORIES.includes(cat)) {
          const err = new Error(`Category must be one of: ${ALLOWED_CATEGORIES.join(', ')}`);
          err.statusCode = 400;
          throw err;
        }
        updates.push('category = :category');
        params.push(cat);
      }

      if (itemData.zone !== undefined) {
        const z = itemData.zone.toLowerCase().trim();
        if (!ALLOWED_ZONES.includes(z)) {
          const err = new Error(`Zone must be one of: ${ALLOWED_ZONES.join(', ')}`);
          err.statusCode = 400;
          throw err;
        }
        updates.push('zone = :zone');
        params.push(z);
      }

      if (itemData.quantity !== undefined) {
        const q = Number(itemData.quantity);
        if (isNaN(q) || q < 0) {
          const err = new Error('Quantity must be a non-negative number');
          err.statusCode = 400;
          throw err;
        }
        updates.push('quantity = :quantity');
        params.push(q);
      }

      if (itemData.unit !== undefined) {
        updates.push('unit = :unit');
        params.push((itemData.unit || 'pieces').trim());
      }

      if (itemData.expiryDate !== undefined) {
        if (!/^\d{4}-\d{2}-\d{2}$/.test(itemData.expiryDate)) {
          const err = new Error('A valid expiryDate in YYYY-MM-DD format is required');
          err.statusCode = 400;
          throw err;
        }
        updates.push("expiry_date = TO_DATE(:expiryDate, 'YYYY-MM-DD')");
        params.push(itemData.expiryDate);
      }

      if (itemData.imagePath !== undefined) {
        updates.push('image_path = :imagePath');
        params.push(itemData.imagePath || null);
      }

      if (updates.length === 0) {
        const err = new Error('No fields provided to update');
        err.statusCode = 400;
        throw err;
      }

      updates.push('updated_at = CURRENT_TIMESTAMP');
      params.push(itemId);
      params.push(fridgeId);

      const sql = `UPDATE items SET ${updates.join(', ')} WHERE id = :itemId AND fridge_id = :fridgeId`;
      await conn.execute(sql, params);
      await conn.commit();

      return await this.getItemById(fridgeId, itemId, userId);
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
   * Delete an item from a fridge
   * @param {string} fridgeId 
   * @param {string} itemId 
   * @param {string} userId 
   */
  async deleteItem(fridgeId, itemId, userId) {
    let conn;
    try {
      conn = await db.getDbConnection();
      await this.checkFridgeAccess(conn, fridgeId, userId);

      const result = await conn.execute(
        `DELETE FROM items WHERE id = :itemId AND fridge_id = :fridgeId`,
        [itemId, fridgeId]
      );
      if (result.rowsAffected === 0) {
        const err = new Error('Item not found');
        err.statusCode = 404;
        throw err;
      }

      await conn.commit();
      return { success: true, message: 'Item deleted successfully' };
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
   * Consume item (partial amount or finish all) and record in item_history
   * @param {string} fridgeId 
   * @param {string} itemId 
   * @param {string} userId 
   * @param {{ amount?: number, finishAll?: boolean }} consumeData 
   */
  async consumeItem(fridgeId, itemId, userId, consumeData = {}) {
    let conn;
    try {
      conn = await db.getDbConnection();
      await this.checkFridgeAccess(conn, fridgeId, userId);

      const item = await this.getItemById(fridgeId, itemId, userId);

      const finishAll = Boolean(consumeData.finishAll);
      const reqAmount = Number(consumeData.amount);

      let amountToConsume = finishAll ? item.quantity : (isNaN(reqAmount) || reqAmount <= 0 ? 1 : reqAmount);
      if (amountToConsume > item.quantity) {
        amountToConsume = item.quantity;
      }

      const quantityLeft = Math.max(0, item.quantity - amountToConsume);
      const historyId = crypto.randomUUID();

      // 1. Record in item_history
      await conn.execute(
        `INSERT INTO item_history (
          id, fridge_id, item_id, item_name, image_path, kind, quantity_changed, quantity_left, unit, by_user_id, created_at
        ) VALUES (
          :id, :fridgeId, :itemId, :itemName, :imagePath, 'consumed', :amount, :qtyLeft, :unit, :userId, CURRENT_TIMESTAMP
        )`,
        [
          historyId,
          fridgeId,
          itemId,
          item.name,
          item.imagePath,
          amountToConsume,
          quantityLeft,
          item.unit,
          userId,
        ]
      );

      // 2. If finished all, delete item, otherwise update quantity
      if (quantityLeft === 0) {
        await conn.execute(
          `DELETE FROM items WHERE id = :itemId AND fridge_id = :fridgeId`,
          [itemId, fridgeId]
        );
      } else {
        await conn.execute(
          `UPDATE items SET quantity = :qtyLeft, updated_at = CURRENT_TIMESTAMP WHERE id = :itemId AND fridge_id = :fridgeId`,
          [quantityLeft, itemId, fridgeId]
        );
      }

      await conn.commit();

      return {
        success: true,
        historyId,
        consumedAmount: amountToConsume,
        quantityLeft,
        finishedAll: quantityLeft === 0,
        item: {
          ...item,
          quantity: quantityLeft,
        },
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
   * Reverse consumption from item_history (Undo)
   * @param {string} fridgeId 
   * @param {string} historyId 
   * @param {string} userId 
   */
  async undoConsume(fridgeId, historyId, userId) {
    let conn;
    try {
      conn = await db.getDbConnection();
      await this.checkFridgeAccess(conn, fridgeId, userId);

      const histSql = `
        SELECT id, fridge_id, item_id, item_name, image_path, kind, quantity_changed, quantity_left, unit
        FROM item_history
        WHERE id = :historyId AND fridge_id = :fridgeId
      `;
      const histRes = await conn.execute(histSql, [historyId, fridgeId]);
      if (!histRes.rows || histRes.rows.length === 0) {
        const err = new Error('History record not found');
        err.statusCode = 404;
        throw err;
      }

      const h = histRes.rows[0];
      const itemId = h[2];
      const itemName = h[3];
      const imagePath = h[4];
      const quantityRestored = Number(h[6]);
      const unit = h[8];

      // Check if item still exists in items table
      if (itemId) {
        const itemRes = await conn.execute(
          `SELECT id, quantity FROM items WHERE id = :itemId AND fridge_id = :fridgeId`,
          [itemId, fridgeId]
        );

        if (itemRes.rows && itemRes.rows.length > 0) {
          // Increment quantity
          const newQty = Number(itemRes.rows[0][1]) + quantityRestored;
          await conn.execute(
            `UPDATE items SET quantity = :newQty, updated_at = CURRENT_TIMESTAMP WHERE id = :itemId`,
            [newQty, itemId]
          );
        } else {
          // Item was fully deleted, re-create item with today + 3 days or default
          const defaultExpiry = new Date();
          defaultExpiry.setDate(defaultExpiry.getDate() + 3);
          const expiryStr = defaultExpiry.toISOString().slice(0, 10);

          await conn.execute(
            `INSERT INTO items (
              id, fridge_id, name, category, zone, quantity, unit, expiry_date, image_path, is_synced, created_at, updated_at
            ) VALUES (
              :id, :fridgeId, :name, 'meals', 'fridge', :qty, :unit, TO_DATE(:expiryDate, 'YYYY-MM-DD'), :imagePath, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            )`,
            [itemId, fridgeId, itemName, quantityRestored, unit, expiryStr, imagePath]
          );
        }
      }

      // Remove the history record
      await conn.execute(`DELETE FROM item_history WHERE id = :historyId`, [historyId]);
      await conn.commit();

      return {
        success: true,
        message: 'Consumption undone successfully',
        restoredQuantity: quantityRestored,
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
   * Get history (consumed or expired)
   * @param {string} fridgeId 
   * @param {string} userId 
   * @param {string} [kind] 'consumed' or 'expired'
   */
  async getHistory(fridgeId, userId, kind = null) {
    let conn;
    try {
      conn = await db.getDbConnection();
      await this.checkFridgeAccess(conn, fridgeId, userId);

      const conditions = ['h.fridge_id = :fridgeId'];
      const params = [fridgeId];

      if (kind && ['consumed', 'expired'].includes(kind.toLowerCase())) {
        conditions.push('h.kind = :kind');
        params.push(kind.toLowerCase());
      }

      const sql = `
        SELECT 
          h.id,
          h.fridge_id,
          h.item_id,
          h.item_name,
          h.image_path,
          h.kind,
          h.quantity_changed,
          h.quantity_left,
          h.unit,
          u.username AS by_username,
          h.created_at
        FROM item_history h
        JOIN users u ON h.by_user_id = u.id
        WHERE ${conditions.join(' AND ')}
        ORDER BY h.created_at DESC
      `;

      const result = await conn.execute(sql, params);
      return result.rows.map(r => ({
        id: r[0],
        fridgeId: r[1],
        itemId: r[2],
        itemName: r[3],
        imagePath: r[4] || null,
        kind: r[5],
        quantityChanged: Number(r[6]),
        quantityLeft: Number(r[7]),
        unit: r[8],
        byUsername: r[9],
        createdAt: r[10],
      }));
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /**
   * Delete single history record
   * @param {string} fridgeId 
   * @param {string} historyId 
   * @param {string} userId 
   */
  async deleteHistoryItem(fridgeId, historyId, userId) {
    let conn;
    try {
      conn = await db.getDbConnection();
      await this.checkFridgeAccess(conn, fridgeId, userId);

      const res = await conn.execute(
        `DELETE FROM item_history WHERE id = :historyId AND fridge_id = :fridgeId`,
        [historyId, fridgeId]
      );
      if (res.rowsAffected === 0) {
        const err = new Error('History record not found');
        err.statusCode = 404;
        throw err;
      }
      await conn.commit();
      return { success: true, message: 'History record deleted' };
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
   * Clear all history records for a fridge (optionally matching kind)
   * @param {string} fridgeId 
   * @param {string} userId 
   * @param {string} [kind] 'consumed' or 'expired'
   */
  async clearHistory(fridgeId, userId, kind = null) {
    let conn;
    try {
      conn = await db.getDbConnection();
      await this.checkFridgeAccess(conn, fridgeId, userId);

      const conditions = ['fridge_id = :fridgeId'];
      const params = [fridgeId];

      if (kind && ['consumed', 'expired'].includes(kind.toLowerCase())) {
        conditions.push('kind = :kind');
        params.push(kind.toLowerCase());
      }

      await conn.execute(`DELETE FROM item_history WHERE ${conditions.join(' AND ')}`, params);
      await conn.commit();

      return { success: true, message: 'History cleared successfully' };
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
}

module.exports = new ItemService();
