import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return database
        .watchNotifications(userId)
        .map((entries) => entries
            .where((e) => !e.id.startsWith('notif_demo_'))
            .map(NotificationModel.fromEntry)
            .toList());
  }

  /// Watch unread notifications count for a user
  Stream<int> watchUnreadCount(String userId) {
    return database.watchUnreadNotificationCount(userId);
  }

  /// Get notifications for a user from Drift SQLite
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final entries = await database.getNotifications(userId);
    return entries
        .where((e) => !e.id.startsWith('notif_demo_'))
        .map(NotificationModel.fromEntry)
        .toList();
  }

  /// Fetch notifications from Backend API and sync into local Drift SQLite database
  Future<List<NotificationModel>> syncNotifications(String userId) async {
    // Purge any legacy demo notifications
    try {
      await database.purgeDemoNotifications();
    } catch (_) {}

    try {
      final response = await apiClient.dio.get('/notifications');
      if (response.statusCode == 200 && response.data != null) {
        final rawList = response.data['notifications'];
        if (rawList is List) {
          final models = <NotificationModel>[];
          final remoteIds = <String>{};
          for (final raw in rawList) {
            if (raw is Map<String, dynamic>) {
              final model = NotificationModel.fromJson(raw);
              await insertNotification(model);
              models.add(model);
              remoteIds.add(model.id);
            }
          }

          // Reconcile: delete local notifications for this user that no longer exist on server
          try {
            final localEntries = await database.getNotifications(userId);
            for (final entry in localEntries) {
              if (!remoteIds.contains(entry.id) || entry.id.startsWith('notif_demo_')) {
                await database.deleteNotification(entry.id);
              }
            }
          } catch (_) {}

          return models;
        }
      }
    } catch (e) {
      debugPrint('[NotificationRepository] Sync error (offline fallback): $e');
    }

    return getNotifications(userId);
  }

  /// Insert a notification into local database
  Future<void> insertNotification(NotificationModel notif) async {
    final payloadJson = jsonEncode({
      'title': notif.title,
      'message': notif.message,
      'fridge_id': notif.fridgeId,
      'invite_id': notif.inviteId,
      'item_id': notif.itemId,
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

  /// Mark a single notification as read (local-first with remote sync)
  Future<void> markAsRead(String id) async {
    await database.markNotificationAsRead(id);
    try {
      await apiClient.dio.patch('/notifications/$id/read');
    } catch (e) {
      debugPrint('[NotificationRepository] markAsRead remote error: $e');
    }
  }

  /// Mark all notifications for a user as read
  Future<void> markAllAsRead(String userId) async {
    await database.markAllNotificationsAsRead(userId);
    try {
      await apiClient.dio.patch('/notifications/read-all');
    } catch (e) {
      debugPrint('[NotificationRepository] markAllAsRead remote error: $e');
    }
  }

  /// Delete a single notification (local-first with remote sync)
  Future<void> deleteNotification(String id) async {
    await database.deleteNotification(id);
    try {
      await apiClient.dio.delete('/notifications/$id');
    } catch (e) {
      debugPrint('[NotificationRepository] deleteNotification remote error: $e');
    }
  }

  /// Clear all notifications for a user
  Future<void> clearAllNotifications(String userId) async {
    await database.clearNotifications(userId);
    try {
      await apiClient.dio.delete('/notifications');
    } catch (e) {
      debugPrint('[NotificationRepository] clearAll remote error: $e');
    }
  }

  /// Respond to a family fridge invitation (Accept / Decline)
  Future<void> respondToInvite({
    required String notificationId,
    required String? inviteId,
    required bool accept,
  }) async {
    // Optimistically remove notification locally
    await database.deleteNotification(notificationId);

    // Call remote API
    try {
      if (inviteId != null) {
        await apiClient.dio.post(
          '/invites/$inviteId/${accept ? 'accept' : 'decline'}',
          data: {},
        );
      }
    } catch (e) {
      debugPrint('[NotificationRepository] respondToInvite remote error: $e');
    }
  }

  /// Purge all legacy mock demo notifications
  Future<void> purgeDemoNotifications() async {
    await database.purgeDemoNotifications();
  }
}
