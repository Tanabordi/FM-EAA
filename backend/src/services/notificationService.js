// TODO(service notification): Implement in-app notifications fetch, mark read, and push dispatch
class NotificationService {
  async getNotifications(userId) {
    // TODO: Query notifications for user, ordered by created_at DESC
    throw new Error('Not implemented');
  }

  async markAsRead(notificationId, userId) {
    // TODO: Update is_read = 1
    throw new Error('Not implemented');
  }

  async createNotification(userId, type, payload) {
    // TODO: Insert notification record
    throw new Error('Not implemented');
  }
}

module.exports = new NotificationService();

