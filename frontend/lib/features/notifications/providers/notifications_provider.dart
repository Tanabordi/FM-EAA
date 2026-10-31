import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/remote/api_client.dart';
import '../../../data/repositories/notification_repository.dart';

/// Provider for NotificationRepository bound with AppDatabase and ApiClient
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return NotificationRepository(apiClient: ApiClient(), database: db);
});

/// Reactive stream of notifications for a user (auto-seeds demo notifications if empty)
final notificationsStreamProvider = StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
  final repo = ref.watch(notificationRepositoryProvider);
  repo.seedInitialNotificationsIfEmpty(userId);
  return repo.watchNotifications(userId);
});

/// Convenience provider for default user_1 notifications
final defaultNotificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  return ref.watch(notificationsStreamProvider('user_1'));
});

/// Backward-compatible FutureProvider for notifications list
final notificationsListProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  await repo.seedInitialNotificationsIfEmpty('user_1');
  return repo.getNotifications('user_1');
});

/// Controller for notification actions (Accept/Decline invite, Mark read, Delete, Clear all)
class NotificationController extends StateNotifier<AsyncValue<void>> {
  final NotificationRepository _repository;

  NotificationController(this._repository) : super(const AsyncData(null));

  Future<void> respondToInvite({
    required String notificationId,
    required String? inviteId,
    required bool accept,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.respondToInvite(
          notificationId: notificationId,
          inviteId: inviteId,
          accept: accept,
        ));
  }

  Future<void> markAsRead(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.markAsRead(id));
  }

  Future<void> deleteNotification(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.deleteNotification(id));
  }

  Future<void> clearAll([String userId = 'user_1']) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.clearAllNotifications(userId));
  }
}

final notificationControllerProvider = StateNotifierProvider<NotificationController, AsyncValue<void>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return NotificationController(repo);
});
