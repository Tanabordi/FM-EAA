import 'dart:convert';
import '../local/app_database.dart';
import '../models/notification_model.dart';
import '../remote/api_client.dart';

class NotificationRepository {
  final ApiClient apiClient;
  final AppDatabase database;

  NotificationRepository({
    required this.apiClient,
    required this.database,
  });

  /// Reactive stream of notifications for a user from Drift SQLite
  Stream<List<NotificationModel>> watchNotifications([String userId = 'user_1']) {
    return database
        .watchNotifications(userId)
        .map((entries) => entries.map(NotificationModel.fromEntry).toList());
  }

  /// Get notifications for a user from Drift SQLite
  Future<List<NotificationModel>> getNotifications([String userId = 'user_1']) async {
    final entries = await database.getNotifications(userId);
    return entries.map(NotificationModel.fromEntry).toList();
  }

  /// Insert a notification into local database
  Future<void> insertNotification(NotificationModel notif) async {
    final payloadJson = jsonEncode({
      'title': notif.title,
      'message': notif.message,
      'fridge_id': notif.fridgeId,
      'invite_id': notif.inviteId,
    });

    await database.insertNotification(
      id: notif.id,
      userId: notif.userId,
      type: notif.type,
      payloadJson: payloadJson,
      isRead: notif.isRead,
      createdAt: notif.createdAt,
    );
  }

  /// Mark a notification as read
  Future<void> markAsRead(String id) async {
    await database.markNotificationAsRead(id);
  }

  /// Delete a single notification
  Future<void> deleteNotification(String id) async {
    await database.deleteNotification(id);
  }

  /// Clear all notifications for a user
  Future<void> clearAllNotifications([String userId = 'user_1']) async {
    await database.clearNotifications(userId);
  }

  /// Respond to a family fridge invitation (Accept / Decline)
  Future<void> respondToInvite({
    required String notificationId,
    required String? inviteId,
    required bool accept,
  }) async {
    // Optimistically remove/mark the notification
    await database.deleteNotification(notificationId);

    // Call remote API or update local invite state
    try {
      if (inviteId != null) {
        await apiClient.dio.post(
          '/api/invites/$inviteId/${accept ? 'accept' : 'decline'}',
          data: {},
        );
      }
    } catch (_) {
      // Gracefully handle offline or 501 unmocked route
    }
  }

  /// Seed initial demo notifications matching Figma mockup if empty
  Future<void> seedInitialNotificationsIfEmpty([String userId = 'user_1']) async {
    final existing = await database.getNotifications(userId);
    if (existing.isNotEmpty) return;

    final now = DateTime.now();

    // 1. Family Invitation Card: "John invited you to join 'Home Fridge'"
    final invitePayload = jsonEncode({
      'title': 'Fridge Invitation',
      'message': "John invited you to join 'Home Fridge'",
      'fridge_id': 'fridge_home',
      'invite_id': 'invite_john_home',
    });

    await database.insertNotification(
      id: 'notif_demo_invite',
      userId: userId,
      type: 'invite',
      payloadJson: invitePayload,
      isRead: false,
      createdAt: now.subtract(const Duration(minutes: 45)),
    );

    // 2. Expiry Warning Card: "Milk expires tomorrow"
    final expiryPayload = jsonEncode({
      'title': 'Milk expires tomorrow',
      'message': 'Remember to consume before expiry.',
      'fridge_id': 'fridge_home',
    });

    await database.insertNotification(
      id: 'notif_demo_expiry',
      userId: userId,
      type: 'expiry',
      payloadJson: expiryPayload,
      isRead: false,
      createdAt: now.subtract(const Duration(hours: 2, minutes: 15)),
    );
  }
}
