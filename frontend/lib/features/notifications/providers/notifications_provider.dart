import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/remote/api_client.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../shared/utils/environment.dart';
import '../../auth/providers/auth_provider.dart';
import '../../fridges/providers/fridges_provider.dart';

/// Provider for NotificationRepository bound with AppDatabase and ApiClient
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return NotificationRepository(apiClient: ApiClient(), database: db);
});

/// Current authenticated user ID (or 'user_1' fallback for offline/guest)
final currentNotificationUserIdProvider = Provider<String>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user?.id ?? 'user_1';
});

/// Reactive stream of notifications for a user with auto-sync polling
final notificationsStreamProvider = StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
  final repo = ref.watch(notificationRepositoryProvider);
  unawaited(repo.syncNotifications(userId).catchError((_) => <NotificationModel>[]));

  // Periodic polling every 2 seconds for real-time notification delivery (skipped during flutter test)
  if (!isTestEnvironment()) {
    final timer = Timer.periodic(const Duration(seconds: 2), (_) {
      unawaited(repo.syncNotifications(userId).catchError((_) => <NotificationModel>[]));
    });
    ref.onDispose(() => timer.cancel());
  }

  return repo.watchNotifications(userId);
});

/// Default notifications stream provider matching the active logged-in user with auto-sync polling
final defaultNotificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  final userId = ref.watch(currentNotificationUserIdProvider);
  final repo = ref.watch(notificationRepositoryProvider);

  // Sync with remote backend API in the background immediately
  unawaited(repo.syncNotifications(userId).catchError((_) => <NotificationModel>[]));

  // Periodic polling every 2 seconds while on the notifications screen (skipped during flutter test)
  if (!isTestEnvironment()) {
    final timer = Timer.periodic(const Duration(seconds: 2), (_) {
      unawaited(repo.syncNotifications(userId).catchError((_) => <NotificationModel>[]));
    });
    ref.onDispose(() => timer.cancel());
  }

  return repo.watchNotifications(userId);
});

/// Stream of unread notification count for active user with auto-sync polling
final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final userId = ref.watch(currentNotificationUserIdProvider);
  final repo = ref.watch(notificationRepositoryProvider);

  // Sync initially in the background
  unawaited(repo.syncNotifications(userId).catchError((_) => <NotificationModel>[]));

  // Periodic polling every 2 seconds to update badge without page refresh (skipped during flutter test)
  if (!isTestEnvironment()) {
    final timer = Timer.periodic(const Duration(seconds: 2), (_) {
      unawaited(repo.syncNotifications(userId).catchError((_) => <NotificationModel>[]));
    });
    ref.onDispose(() => timer.cancel());
  }

  return repo.watchUnreadCount(userId);
});

/// Backward-compatible FutureProvider for notifications list
final notificationsListProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final userId = ref.watch(currentNotificationUserIdProvider);
  final repo = ref.watch(notificationRepositoryProvider);
  await repo.syncNotifications(userId);
  return repo.getNotifications(userId);
});

/// Controller for notification actions (Accept/Decline invite, Mark read, Delete, Clear all)
class NotificationController extends StateNotifier<AsyncValue<void>> {
  final NotificationRepository _repository;
  final Ref _ref;

  NotificationController(this._repository, this._ref) : super(const AsyncData(null));

  Future<void> respondToInvite({
    required String notificationId,
    required String? inviteId,
    required bool accept,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.respondToInvite(
        notificationId: notificationId,
        inviteId: inviteId,
        accept: accept,
      );

      // If user accepted a fridge invitation, reload the fridges list in the background
      if (accept) {
        try {
          unawaited(_ref.read(fridgesProvider.notifier).loadFridges().catchError((_) {}));
        } catch (_) {}
      }
    });
  }

  Future<void> markAsRead(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.markAsRead(id));
  }

  Future<void> markAllAsRead([String? userId]) async {
    final String targetUserId = userId ?? _ref.read(currentNotificationUserIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.markAllAsRead(targetUserId));
  }

  Future<void> deleteNotification(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.deleteNotification(id));
  }

  Future<void> clearAll([String? userId]) async {
    final String targetUserId = userId ?? _ref.read(currentNotificationUserIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.clearAllNotifications(targetUserId));
  }

  Future<void> sync([String? userId]) async {
    final String targetUserId = userId ?? _ref.read(currentNotificationUserIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.syncNotifications(targetUserId));
  }
}

final notificationControllerProvider = StateNotifierProvider<NotificationController, AsyncValue<void>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return NotificationController(repo, ref);
});
