// TODO(service fridge): Implement multiple fridges CRUD, member role management (owner/member), and invitation flow
class FridgeService {
  async getFridgesForUser(userId) {
    // TODO: Query fridges where user is owner or in fridge_members
    throw new Error('Not implemented');
  }

  async createFridge(userId, data) {
    // TODO: Create fridge, assign userId as 'owner' in fridge_members
    throw new Error('Not implemented');
  }

  async updateFridge(fridgeId, userId, data) {
    // TODO: Verify owner permission and update name/description
    throw new Error('Not implemented');
  }

  async deleteFridge(fridgeId, userId) {
    // TODO: Verify owner permission and cascade delete
    throw new Error('Not implemented');
  }

  async getMembers(fridgeId) {
    // TODO: Query fridge_members with user profile details
    throw new Error('Not implemented');
  }

  async removeMember(fridgeId, currentUserId, targetUserId) {
    // TODO: Ensure owner can remove member, but cannot remove self directly
    throw new Error('Not implemented');
  }

  async inviteMember(fridgeId, fromUserId, targetUsername) {
    // TODO: Find target user by username, create fridge_invites record, push in-app notification
    throw new Error('Not implemented');
  }

  async handleInvite(inviteId, userId, action) {
    // TODO: Update invite status (accepted|declined), if accepted add to fridge_members
    throw new Error('Not implemented');
  }
}

module.exports = new FridgeService();

