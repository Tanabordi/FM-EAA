const crypto = require('crypto');
const db = require('../config/db');
const notificationService = require('./notificationService');

class FridgeService {
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
   * List all fridges user has access to (owned or member)
   * @param {string} userId 
   */
  async getFridgesForUser(userId) {
    let conn;
    try {
      conn = await db.getDbConnection();
      const sql = `
        SELECT 
          f.id,
          f.name,
          f.description,
          f.owner_id,
          fm.role,
          f.created_at,
          f.updated_at,
          (SELECT COUNT(*) FROM fridge_members WHERE fridge_id = f.id) AS member_count,
          (SELECT COUNT(*) FROM items WHERE fridge_id = f.id AND quantity > 0) AS item_count,
          (SELECT COUNT(*) FROM items WHERE fridge_id = f.id AND TRUNC(expiry_date) <= TRUNC(CURRENT_DATE) AND quantity > 0) AS expiring_today_count
        FROM fridges f
        JOIN fridge_members fm ON f.id = fm.fridge_id
        WHERE fm.user_id = :userId
        ORDER BY f.created_at DESC
      `;
      const result = await conn.execute(sql, [userId]);
      return result.rows.map(row => ({
        id: row[0],
        name: row[1],
        description: row[2] || '',
        ownerId: row[3],
        role: row[4],
        createdAt: row[5],
        updatedAt: row[6],
        memberCount: Number(row[7]) || 1,
        itemCount: Number(row[8]) || 0,
        expiringTodayCount: Number(row[9]) || 0,
      }));
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /**
   * Create a new fridge and assign creator as 'owner'
   * @param {string} userId 
   * @param {{ name: string, description?: string, id?: string }} data 
   */
  async createFridge(userId, data) {
    const { name, description = '', id } = data;
    if (!name || typeof name !== 'string' || !name.trim()) {
      const err = new Error('Fridge name is required');
      err.statusCode = 400;
      throw err;
    }

    const fridgeId = id || crypto.randomUUID();
    const cleanName = name.trim();
    const cleanDesc = (description || '').trim();

    let conn;
    try {
      conn = await db.getDbConnection();

      // 1. Insert into fridges
      await conn.execute(
        `INSERT INTO fridges (id, name, description, owner_id, is_synced, created_at, updated_at)
         VALUES (:id, :name, :description, :ownerId, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)`,
        [fridgeId, cleanName, cleanDesc, userId]
      );

      // 2. Insert into fridge_members as owner
      await conn.execute(
        `INSERT INTO fridge_members (fridge_id, user_id, role, created_at, updated_at)
         VALUES (:fridgeId, :userId, 'owner', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)`,
        [fridgeId, userId]
      );

      await conn.commit();

      return {
        id: fridgeId,
        name: cleanName,
        description: cleanDesc,
        ownerId: userId,
        role: 'owner',
        memberCount: 1,
        itemCount: 0,
        expiringTodayCount: 0,
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
   * Get single fridge details with member list
   * @param {string} fridgeId 
   * @param {string} userId 
   */
  async getFridgeById(fridgeId, userId) {
    let conn;
    try {
      conn = await db.getDbConnection();
      const access = await this.checkUserAccess(conn, fridgeId, userId);
      if (!access.isMember) {
        const err = new Error('Fridge not found or access denied');
        err.statusCode = 404;
        throw err;
      }

      const fridgeSql = `
        SELECT 
          f.id, f.name, f.description, f.owner_id, fm.role, f.created_at, f.updated_at,
          (SELECT COUNT(*) FROM items WHERE fridge_id = f.id AND quantity > 0) AS item_count,
          (SELECT COUNT(*) FROM items WHERE fridge_id = f.id AND TRUNC(expiry_date) <= TRUNC(CURRENT_DATE) AND quantity > 0) AS expiring_today_count
        FROM fridges f
        JOIN fridge_members fm ON f.id = fm.fridge_id
        WHERE f.id = :fridgeId AND fm.user_id = :userId
      `;
      const result = await conn.execute(fridgeSql, [fridgeId, userId]);
      if (!result.rows || result.rows.length === 0) {
        const err = new Error('Fridge not found');
        err.statusCode = 404;
        throw err;
      }

      const row = result.rows[0];

      // Fetch members
      const members = await this.getMembers(fridgeId, userId, conn);

      return {
        id: row[0],
        name: row[1],
        description: row[2] || '',
        ownerId: row[3],
        role: row[4],
        createdAt: row[5],
        updatedAt: row[6],
        memberCount: members.length,
        itemCount: Number(row[7]) || 0,
        expiringTodayCount: Number(row[8]) || 0,
        members,
      };
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /**
   * Update fridge details (owner or member)
   * @param {string} fridgeId 
   * @param {string} userId 
   * @param {{ name?: string, description?: string }} data 
   */
  async updateFridge(fridgeId, userId, data) {
    let conn;
    try {
      conn = await db.getDbConnection();
      const access = await this.checkUserAccess(conn, fridgeId, userId);
      if (!access.isMember) {
        const err = new Error('Fridge not found or access denied');
        err.statusCode = 404;
        throw err;
      }

      if (access.role !== 'owner') {
        const err = new Error('Only the fridge owner can update this fridge');
        err.statusCode = 403;
        throw err;
      }

      const updates = [];
      const params = [];

      if (data.name !== undefined) {
        if (!data.name || typeof data.name !== 'string' || !data.name.trim()) {
          const err = new Error('Fridge name cannot be empty');
          err.statusCode = 400;
          throw err;
        }
        updates.push(`name = :name`);
        params.push(data.name.trim());
      }

      if (data.description !== undefined) {
        updates.push(`description = :description`);
        params.push((data.description || '').trim());
      }

      if (updates.length === 0) {
        const err = new Error('No fields provided to update');
        err.statusCode = 400;
        throw err;
      }

      updates.push(`updated_at = CURRENT_TIMESTAMP`);
      params.push(fridgeId);

      const updateSql = `UPDATE fridges SET ${updates.join(', ')} WHERE id = :fridgeId`;
      await conn.execute(updateSql, params);
      await conn.commit();

      return await this.getFridgeById(fridgeId, userId);
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
   * Delete fridge (Only Owner can delete)
   * @param {string} fridgeId 
   * @param {string} userId 
   */
  async deleteFridge(fridgeId, userId) {
    let conn;
    try {
      conn = await db.getDbConnection();
      const access = await this.checkUserAccess(conn, fridgeId, userId);
      if (!access.isMember) {
        const err = new Error('Fridge not found or access denied');
        err.statusCode = 404;
        throw err;
      }

      if (access.role !== 'owner') {
        const err = new Error('Only the fridge owner can delete this fridge');
        err.statusCode = 403;
        throw err;
      }

      // Delete cascade will handle items, members, history, and invites
      await conn.execute(`DELETE FROM fridges WHERE id = :fridgeId`, [fridgeId]);
      await conn.commit();

      return { success: true, message: 'Fridge deleted successfully' };
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
   * List members of a fridge
   * @param {string} fridgeId 
   * @param {string} userId 
   * @param {object} [existingConn] 
   */
  async getMembers(fridgeId, userId, existingConn = null) {
    const conn = existingConn || await db.getDbConnection();
    try {
      if (!existingConn) {
        const access = await this.checkUserAccess(conn, fridgeId, userId);
        if (!access.isMember) {
          const err = new Error('Fridge not found or access denied');
          err.statusCode = 404;
          throw err;
        }
      }

      const sql = `
        SELECT 
          u.id,
          u.username,
          u.email,
          u.avatar_url,
          fm.role,
          fm.created_at
        FROM fridge_members fm
        JOIN users u ON fm.user_id = u.id
        WHERE fm.fridge_id = :fridgeId
        ORDER BY CASE WHEN fm.role = 'owner' THEN 0 ELSE 1 END, fm.created_at ASC
      `;
      const result = await conn.execute(sql, [fridgeId]);
      return result.rows.map(r => ({
        id: r[0],
        username: r[1],
        email: r[2],
        avatarUrl: r[3] || null,
        role: r[4],
        joinedAt: r[5],
      }));
    } finally {
      if (!existingConn && conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /**
   * Remove a member or leave fridge
   * @param {string} fridgeId 
   * @param {string} currentUserId 
   * @param {string} targetUserId 
   */
  async removeMember(fridgeId, currentUserId, targetUserId) {
    let conn;
    try {
      conn = await db.getDbConnection();
      const access = await this.checkUserAccess(conn, fridgeId, currentUserId);
      if (!access.isMember) {
        const err = new Error('Fridge not found or access denied');
        err.statusCode = 404;
        throw err;
      }

      // If removing someone else, must be owner
      if (currentUserId !== targetUserId && access.role !== 'owner') {
        const err = new Error('Only the owner can remove other members');
        err.statusCode = 403;
        throw err;
      }

      // Owner cannot leave or remove self without transferring ownership / deleting fridge
      if (currentUserId === targetUserId && access.role === 'owner') {
        const err = new Error('Fridge owner cannot leave the fridge. Delete the fridge or transfer ownership first.');
        err.statusCode = 400;
        throw err;
      }

      await conn.execute(
        `DELETE FROM fridge_members WHERE fridge_id = :fridgeId AND user_id = :targetUserId`,
        [fridgeId, targetUserId]
      );
      await conn.commit();

      return { success: true, message: 'Member removed successfully' };
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
   * Search users to invite to a fridge with status: 'already' | 'pending' | 'available'
   * @param {string} fridgeId 
   * @param {string} currentUserId 
   * @param {string} query 
   */
  async searchUsersForFridge(fridgeId, currentUserId, query) {
    if (!query || typeof query !== 'string' || !query.trim()) {
      return [];
    }

    let conn;
    try {
      conn = await db.getDbConnection();
      const access = await this.checkUserAccess(conn, fridgeId, currentUserId);
      if (!access.isMember) {
        const err = new Error('Fridge not found or access denied');
        err.statusCode = 404;
        throw err;
      }

      const searchSql = `
        SELECT id, username, email, avatar_url
        FROM users
        WHERE (LOWER(username) LIKE LOWER(:term) OR LOWER(email) LIKE LOWER(:term))
          AND id != :currentUserId
        FETCH FIRST 20 ROWS ONLY
      `;
      const searchResult = await conn.execute(searchSql, {
        term: `%${query.trim()}%`,
        currentUserId,
      });
      const foundUsers = (searchResult.rows || []).map(r => ({
        id: r[0],
        username: r[1],
        email: r[2],
        avatarUrl: r[3] || '',
      }));

      if (foundUsers.length === 0) {
        return [];
      }

      // Check member status
      const memberSql = `
        SELECT user_id FROM fridge_members WHERE fridge_id = :fridgeId
      `;
      const memberRes = await conn.execute(memberSql, [fridgeId]);
      const memberSet = new Set((memberRes.rows || []).map(r => r[0]));

      // Check pending invite status
      const inviteSql = `
        SELECT to_user_id FROM fridge_invites 
        WHERE fridge_id = :fridgeId AND status = 'pending'
      `;
      const inviteRes = await conn.execute(inviteSql, [fridgeId]);
      const pendingSet = new Set((inviteRes.rows || []).map(r => r[0]));

      return foundUsers.map(u => {
        let status = 'available';
        if (memberSet.has(u.id)) {
          status = 'already';
        } else if (pendingSet.has(u.id)) {
          status = 'pending';
        }
        return {
          id: u.id,
          username: u.username,
          email: u.email,
          avatarUrl: u.avatarUrl,
          status,
        };
      });
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /**
   * Invite a user to a fridge by username
   * @param {string} fridgeId 
   * @param {string} currentUserId 
   * @param {string} username 
   */
  async inviteMember(fridgeId, currentUserId, username) {
    if (!username || typeof username !== 'string' || !username.trim()) {
      const err = new Error('Username is required');
      err.statusCode = 400;
      throw err;
    }

    const cleanUsername = username.trim();

    let conn;
    try {
      conn = await db.getDbConnection();
      const access = await this.checkUserAccess(conn, fridgeId, currentUserId);
      if (!access.isMember) {
        const err = new Error('Fridge not found or access denied');
        err.statusCode = 404;
        throw err;
      }

      // 1. Find target user
      const userRes = await conn.execute(
        `SELECT id, username, email, avatar_url FROM users WHERE (LOWER(username) = LOWER(:username) OR LOWER(email) = LOWER(:username))`,
        { username: cleanUsername }
      );
      if (!userRes.rows || userRes.rows.length === 0) {
        const err = new Error(`User '${cleanUsername}' not found`);
        err.statusCode = 404;
        throw err;
      }

      const targetUser = {
        id: userRes.rows[0][0],
        username: userRes.rows[0][1],
        email: userRes.rows[0][2],
        avatarUrl: userRes.rows[0][3] || '',
      };

      if (targetUser.id === currentUserId) {
        const err = new Error('Cannot invite yourself');
        err.statusCode = 400;
        throw err;
      }

      // 2. Check if already member
      const memberRes = await conn.execute(
        `SELECT 1 FROM fridge_members WHERE fridge_id = :fridgeId AND user_id = :targetUserId`,
        [fridgeId, targetUser.id]
      );
      if (memberRes.rows && memberRes.rows.length > 0) {
        const err = new Error(`User '${targetUser.username}' is already in this family`);
        err.statusCode = 400;
        throw err;
      }

      // 3. Check if pending invite exists
      const inviteRes = await conn.execute(
        `SELECT id FROM fridge_invites WHERE fridge_id = :fridgeId AND to_user_id = :targetUserId AND status = 'pending'`,
        [fridgeId, targetUser.id]
      );
      if (inviteRes.rows && inviteRes.rows.length > 0) {
        const err = new Error(`Invitation already sent to '${targetUser.username}'`);
        err.statusCode = 400;
        throw err;
      }

      // 4. Fetch fridge name & inviter username for notification
      const fridgeRes = await conn.execute(`SELECT name FROM fridges WHERE id = :fridgeId`, [fridgeId]);
      const fridgeName = (fridgeRes.rows && fridgeRes.rows[0]) ? fridgeRes.rows[0][0] : 'Fridge';

      const inviterRes = await conn.execute(`SELECT username FROM users WHERE id = :currentUserId`, [currentUserId]);
      const inviterUsername = (inviterRes.rows && inviterRes.rows[0]) ? inviterRes.rows[0][0] : 'Someone';

      const inviteId = crypto.randomUUID();
      const notifId = crypto.randomUUID();

      // 5. Insert fridge_invites
      await conn.execute(
        `INSERT INTO fridge_invites (id, fridge_id, from_user_id, to_user_id, status, created_at, updated_at)
         VALUES (:id, :fridgeId, :fromUserId, :toUserId, 'pending', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)`,
        [inviteId, fridgeId, currentUserId, targetUser.id]
      );

      // 6. Insert notification for target user
      const notifPayload = JSON.stringify({
        title: 'Fridge Invitation',
        message: `${inviterUsername} invited you to join '${fridgeName}'`,
        fridge_id: fridgeId,
        fridge_name: fridgeName,
        invite_id: inviteId,
        from_user_id: currentUserId,
        from_username: inviterUsername,
      });

      await conn.execute(
        `INSERT INTO notifications (id, user_id, type, payload_json, is_read, created_at)
         VALUES (:id, :userId, 'invite', :payload, 0, CURRENT_TIMESTAMP)`,
        [notifId, targetUser.id, notifPayload]
      );

      await conn.commit();

      return {
        success: true,
        message: `Invitation sent to ${targetUser.username}`,
        invite: {
          id: inviteId,
          fridgeId,
          toUserId: targetUser.id,
          username: targetUser.username,
          status: 'pending',
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
   * Get pending invitations for a fridge
   * @param {string} fridgeId 
   * @param {string} currentUserId 
   */
  async getPendingInvites(fridgeId, currentUserId) {
    let conn;
    try {
      conn = await db.getDbConnection();
      const access = await this.checkUserAccess(conn, fridgeId, currentUserId);
      if (!access.isMember) {
        const err = new Error('Fridge not found or access denied');
        err.statusCode = 404;
        throw err;
      }

      const sql = `
        SELECT 
          fi.id,
          fi.from_user_id,
          u_from.username,
          fi.to_user_id,
          u_to.username,
          u_to.email,
          u_to.avatar_url,
          fi.status,
          fi.created_at
        FROM fridge_invites fi
        JOIN users u_from ON fi.from_user_id = u_from.id
        JOIN users u_to ON fi.to_user_id = u_to.id
        WHERE fi.fridge_id = :fridgeId AND fi.status = 'pending'
        ORDER BY fi.created_at DESC
      `;
      const result = await conn.execute(sql, [fridgeId]);
      return (result.rows || []).map(r => ({
        id: r[0],
        fromUserId: r[1],
        fromUsername: r[2],
        toUserId: r[3],
        toUsername: r[4],
        toEmail: r[5],
        toAvatarUrl: r[6] || null,
        status: r[7],
        createdAt: r[8],
      }));
    } finally {
      if (conn) {
        try { await conn.close(); } catch (_) {}
      }
    }
  }

  /**
   * Accept or decline a fridge invitation
   * @param {string} inviteId 
   * @param {string} currentUserId 
   * @param {boolean} accept 
   */
  async respondToInvite(inviteId, currentUserId, accept) {
    let conn;
    try {
      conn = await db.getDbConnection();
      const inviteRes = await conn.execute(
        `SELECT id, fridge_id, to_user_id, status, from_user_id FROM fridge_invites WHERE id = :inviteId`,
        [inviteId]
      );

      if (!inviteRes.rows || inviteRes.rows.length === 0) {
        const err = new Error('Invitation not found');
        err.statusCode = 404;
        throw err;
      }

      const [id, fridgeId, toUserId, status, fromUserId] = inviteRes.rows[0];

      if (toUserId !== currentUserId) {
        const err = new Error('Unauthorized to respond to this invitation');
        err.statusCode = 403;
        throw err;
      }

      if (status !== 'pending') {
        // If invitation was already resolved, ensure invite notifications are deleted
        await conn.execute(
          `DELETE FROM notifications 
           WHERE user_id = :userId AND payload_json LIKE :pattern`,
          [currentUserId, `%"invite_id":"${inviteId}"%`]
        );
        await conn.commit();
        return {
          success: true,
          message: `Invitation has already been ${status}`,
          status,
          fridgeId,
        };
      }

      const newStatus = accept ? 'accepted' : 'declined';

      // 1. Update fridge_invites
      await conn.execute(
        `UPDATE fridge_invites SET status = :status, updated_at = CURRENT_TIMESTAMP WHERE id = :inviteId`,
        [newStatus, inviteId]
      );

      // 2. If accepted, add to fridge_members
      if (accept) {
        await conn.execute(
          `INSERT INTO fridge_members (fridge_id, user_id, role, created_at, updated_at)
           VALUES (:fridgeId, :userId, 'member', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)`,
          [fridgeId, currentUserId]
        );

        // Notify all other fridge members who joined and who invited them
        try {
          const userRes = await conn.execute(`SELECT username FROM users WHERE id = :userId`, [currentUserId]);
          const joinedUsername = (userRes.rows && userRes.rows[0]) ? userRes.rows[0][0] : 'A user';
          const inviterRes = await conn.execute(`SELECT username FROM users WHERE id = :fromUserId`, [fromUserId]);
          const inviterUsername = (inviterRes.rows && inviterRes.rows[0]) ? inviterRes.rows[0][0] : 'Someone';
          const fridgeRes = await conn.execute(`SELECT name FROM fridges WHERE id = :fridgeId`, [fridgeId]);
          const fridgeName = (fridgeRes.rows && fridgeRes.rows[0]) ? fridgeRes.rows[0][0] : 'Fridge';

          const notifTitle = 'New Member Joined';
          const notifMessage = `${joinedUsername} joined "${fridgeName}" (invited by ${inviterUsername})`;

          await notificationService.notifyFridgeMembers(conn, fridgeId, currentUserId, {
            type: 'member_joined',
            subType: 'member_joined',
            title: notifTitle,
            message: notifMessage,
            fridge_name: fridgeName,
            joined_user_id: currentUserId,
            joined_username: joinedUsername,
            invited_by_user_id: fromUserId,
            invited_by_username: inviterUsername,
          });
        } catch (e) {
          console.warn('[FridgeService] Error creating member joined notifications:', e.message);
        }
      }

      // 3. Delete invite notification from notifications table so it never reappears
      await conn.execute(
        `DELETE FROM notifications 
         WHERE user_id = :userId AND payload_json LIKE :pattern`,
        [currentUserId, `%"invite_id":"${inviteId}"%`]
      );

      await conn.commit();

      return {
        success: true,
        message: accept ? 'Invitation accepted successfully' : 'Invitation declined',
        status: newStatus,
        fridgeId,
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

module.exports = new FridgeService();
