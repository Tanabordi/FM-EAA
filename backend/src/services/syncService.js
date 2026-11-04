const db = require('../config/db');

class SyncService {
  /**
   * Helper: verify if user is member or owner of the fridge
   * @param {object} conn 
   * @param {string} fridgeId 
   * @param {string} userId 
   * @returns {Promise<{ isMember: boolean, role: string|null }>}
   */
  async checkUserAccess(conn, fridgeId, userId) {
    const sql = `
      SELECT role FROM fridge_members 
      WHERE fridge_id = :fridgeId AND user_id = :userId
    `;
    const result = await conn.execute(sql, [fridgeId, userId]);
    if (result.rows && result.rows.length > 0) {
      return { isMember: true, role: result.rows[0][0] };
    }
    return { isMember: false, role: null };
  }

  /**
   * Process batched synchronization with Last-Write-Wins (LWW)
   * @param {string} userId
   * @param {object} payload
   */
  async processBatchSync(userId, payload) {
    if (!payload || typeof payload !== 'object') {
      const err = new Error('Invalid payload');
      err.statusCode = 400;
      throw err;
    }

    const fridgeId = payload.fridge_id || payload.fridgeId;
    if (!fridgeId || typeof fridgeId !== 'string' || !fridgeId.trim()) {
      const err = new Error('fridge_id is required');
      err.statusCode = 400;
      throw err;
    }

    const clientTimestamp = payload.client_timestamp || payload.clientTimestamp || new Date().toISOString();
    const items = Array.isArray(payload.items) ? payload.items : [];

    let conn;
    try {
      conn = await db.getDbConnection();

      // 1. Verify user membership in fridge
      const access = await this.checkUserAccess(conn, fridgeId, userId);
      if (!access.isMember) {
        const err = new Error('Fridge not found or access denied');
        err.statusCode = 403;
        throw err;
      }

      let upsertCount = 0;
      let deleteCount = 0;
      let skippedCount = 0;

      // 2. Process each client item with Last-Write-Wins (LWW)
      for (const item of items) {
        if (!item || !item.id) continue;

        const itemId = item.id;
        const itemName = (item.name || 'Untitled').trim();
        const category = (item.category || 'meals').toLowerCase();
        const zone = (item.zone || 'fridge').toLowerCase();
        const quantity = Number(item.quantity) || 1.0;
        const unit = item.unit || 'pieces';
        const imagePath = item.image_path || item.imagePath || null;
        const isDeleted = Boolean(item.is_deleted || item.isDeleted);
        
        let expiryDate = item.expiry_date || item.expiryDate || new Date().toISOString().split('T')[0];
        if (typeof expiryDate === 'string' && expiryDate.includes('T')) {
          expiryDate = expiryDate.split('T')[0];
        }

        const clientUpdatedAt = new Date(item.updated_at || item.updatedAt || clientTimestamp);

        // Check if item exists in DB
        const checkSql = `
          SELECT id, TO_CHAR(updated_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3"Z"') AS updated_at
          FROM items
          WHERE id = :itemId AND fridge_id = :fridgeId
        `;
        const checkRes = await conn.execute(checkSql, [itemId, fridgeId]);

        if (checkRes.rows && checkRes.rows.length > 0) {
          // Existing record: compare timestamps for LWW
          const serverUpdatedAtStr = checkRes.rows[0][1];
          const serverUpdatedAt = new Date(serverUpdatedAtStr);

          // If client timestamp is equal or newer -> client wins
          if (isNaN(serverUpdatedAt.getTime()) || clientUpdatedAt.getTime() >= serverUpdatedAt.getTime()) {
            if (isDeleted) {
              await conn.execute(
                `DELETE FROM items WHERE id = :itemId AND fridge_id = :fridgeId`,
                [itemId, fridgeId]
              );
              deleteCount++;
            } else {
              await conn.execute(
                `UPDATE items 
                 SET name = :name,
                     category = :category,
                     zone = :zone,
                     quantity = :quantity,
                     unit = :unit,
                     expiry_date = TO_DATE(:expiryDate, 'YYYY-MM-DD'),
                     image_path = :imagePath,
                     is_synced = 1,
                     updated_at = CURRENT_TIMESTAMP
                 WHERE id = :itemId AND fridge_id = :fridgeId`,
                [itemName, category, zone, quantity, unit, expiryDate, imagePath, itemId, fridgeId]
              );
              upsertCount++;
            }
          } else {
            // Server wins (server has newer timestamp)
            skippedCount++;
          }
        } else {
          // Item doesn't exist on server yet
          if (!isDeleted) {
            await conn.execute(
              `INSERT INTO items (
                 id, fridge_id, name, category, zone, quantity, unit, expiry_date, image_path, is_synced, created_at, updated_at
               ) VALUES (
                 :id, :fridgeId, :name, :category, :zone, :quantity, :unit, TO_DATE(:expiryDate, 'YYYY-MM-DD'), :imagePath, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
               )`,
              [itemId, fridgeId, itemName, category, zone, quantity, unit, expiryDate, imagePath]
            );
            upsertCount++;
          }
        }
      }

      // 3. Query all latest items for this fridge to sync back to client
      const fetchSql = `
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
          TO_CHAR(created_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3"Z"') AS created_at,
          TO_CHAR(updated_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3"Z"') AS updated_at
        FROM items
        WHERE fridge_id = :fridgeId
        ORDER BY expiry_date ASC, created_at DESC
      `;
      const fetchRes = await conn.execute(fetchSql, [fridgeId]);
      const serverItems = (fetchRes.rows || []).map(r => ({
        id: r[0],
        fridgeId: r[1],
        fridge_id: r[1],
        name: r[2],
        category: r[3],
        zone: r[4],
        quantity: Number(r[5]),
        unit: r[6],
        expiryDate: r[7],
        expiry_date: r[7],
        imagePath: r[8] || null,
        image_path: r[8] || null,
        createdAt: r[9],
        created_at: r[9],
        updatedAt: r[10],
        updated_at: r[10],
      }));

      await conn.commit();

      return {
        success: true,
        synced_at: new Date().toISOString(),
        syncedAt: new Date().toISOString(),
        fridge_id: fridgeId,
        fridgeId: fridgeId,
        stats: {
          client_items_received: items.length,
          upserted: upsertCount,
          deleted: deleteCount,
          skipped_server_won: skippedCount,
        },
        server_items: serverItems,
        serverItems: serverItems,
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
}

module.exports = new SyncService();
