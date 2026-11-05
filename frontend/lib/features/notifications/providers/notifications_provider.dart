import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/fridge_model.dart';
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
  final authState = ref.watch(authProvider);

  if (authState.user != null) {
    unawaited(repo.syncNotifications(userId).catchError((_) => <NotificationModel>[]));

    // Periodic polling every 4 seconds for real-time notification delivery (skipped during flutter test)
    if (!isTestEnvironment()) {
      final timer = Timer.periodic(const Duration(seconds: 4), (_) {
        unawaited(repo.syncNotifications(userId).catchError((_) => <NotificationModel>[]));
      });
      ref.onDispose(() => timer.cancel());
    }
  }

  return repo.watchNotifications(userId);
});

/// Default notifications stream provider matching the active logged-in user with auto-sync polling
final defaultNotificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  final userId = ref.watch(currentNotificationUserIdProvider);
  final repo = ref.watch(notificationRepositoryProvider);
  final authState = ref.watch(authProvider);

  if (authState.user != null) {
    // Sync with remote backend API in the background immediately
    unawaited(repo.syncNotifications(userId).catchError((_) => <NotificationModel>[]));

    // Periodic polling every 4 seconds while on the notifications screen (skipped during flutter test)
    if (!isTestEnvironment()) {
      final timer = Timer.periodic(const Duration(seconds: 4), (_) {
        unawaited(repo.syncNotifications(userId).catchError((_) => <NotificationModel>[]));
      });
      ref.onDispose(() => timer.cancel());
    }
  }

  return repo.watchNotifications(userId);
});

/// Stream of unread notification count for active user with auto-sync polling
final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final userId = ref.watch(currentNotificationUserIdProvider);
  final repo = ref.watch(notificationRepositoryProvider);
  final authState = ref.watch(authProvider);

  if (authState.user != null) {
    // Sync initially in the background
    unawaited(repo.syncNotifications(userId).catchError((_) => <NotificationModel>[]));

    // Periodic polling every 4 seconds to update badge without page refresh (skipped during flutter test)
    if (!isTestEnvironment()) {
      final timer = Timer.periodic(const Duration(seconds: 4), (_) {
        unawaited(repo.syncNotifications(userId).catchError((_) => <NotificationModel>[]));
      });
      ref.onDispose(() => timer.cancel());
    }
  }

  return repo.watchUnreadCount(userId);
});

/// Checks whether a notification strictly belongs to a specific fridge.
/// Prevents cross-fridge notification leaks.
bool notificationMatchesFridge(
  NotificationModel n,
  String fridgeId,
  String? fridgeName, [
  List<FridgeModel> allFridges = const [],
]) {
  // 1. Authoritative check: if fridgeId is populated, test ID equality directly.
  if (n.fridgeId != null && n.fridgeId!.isNotEmpty) {
    return n.fridgeId == fridgeId;
  }

  // 2. Extracted fridge name check (from model field or parsed from message pattern)
  final rawName = (n.fridgeName ?? n.extractedFridgeName)?.trim();
  if (rawName != null && rawName.isNotEmpty) {
    // Exact case match with current fridge
    if (fridgeName != null && rawName == fridgeName.trim()) {
      return true;
    }

    // Explicit rejection: If message names another known fridge by exact name, reject!
    for (final other in allFridges) {
      if (other.id != fridgeId && other.name.trim() == rawName) {
        return false;
      }
    }

    // Case-insensitive match if current fridge matches and no conflicting other fridge
    if (fridgeName != null && rawName.toLowerCase() == fridgeName.trim().toLowerCase()) {
      final hasConflict = allFridges.any(
        (f) => f.id != fridgeId && f.name.trim().toLowerCase() == rawName.toLowerCase(),
      );
      if (!hasConflict) {
        return true;
      }
    }

    // Explicit rejection for case-insensitive match on other fridges
    for (final other in allFridges) {
      if (other.id != fridgeId && other.name.trim().toLowerCase() == rawName.toLowerCase()) {
        return false;
      }
    }
  }

  // 3. Fallback: match quoted fridge name in message (e.g. in "Kitchen" or 'Kitchen')
  if (fridgeName != null && fridgeName.trim().isNotEmpty) {
    final curName = fridgeName.trim();
    final curNameLower = curName.toLowerCase();
    final quotedMatches = RegExp(r'["\x27]([^"\x27]+)["\x27]').allMatches(n.message);

    for (final q in quotedMatches) {
      final insideQuote = (q.group(1) ?? '').trim();
      if (insideQuote == curName) {
        return true;
      }
    }

    for (final q in quotedMatches) {
      final insideQuote = (q.group(1) ?? '').trim();
      if (insideQuote.toLowerCase() == curNameLower) {
        final hasConflict = allFridges.any(
          (f) => f.id != fridgeId && f.name.trim().toLowerCase() == curNameLower,
        );
        if (!hasConflict) {
          return true;
        }
      }
    }
  }

  return false;
}

/// Stream of unread notification count specifically for a fridge with auto-sync polling
final fridgeUnreadNotificationCountProvider = Provider.family<int, String>((ref, fridgeId) {
  final notifsAsync = ref.watch(defaultNotificationsStreamProvider);
  return notifsAsync.maybeWhen(
    data: (list) {
      final fridges = ref.watch(fridgesProvider);
      final match = fridges.where((f) => f.id == fridgeId);
      final fridgeName = match.isNotEmpty ? match.first.name : null;
      return list.where((n) {
        if (n.isRead) return false;
        return notificationMatchesFridge(n, fridgeId, fridgeName, fridges);
      }).length;
    },
    orElse: () => 0,
  );
});

/// Filtered list of notifications specifically for a fridge
final fridgeNotificationsProvider = Provider.family<List<NotificationModel>, String>((ref, fridgeId) {
  final notifsAsync = ref.watch(defaultNotificationsStreamProvider);
  return notifsAsync.maybeWhen(
    data: (list) {
      final fridges = ref.watch(fridgesProvider);
      final match = fridges.where((f) => f.id == fridgeId);
      final fridgeName = match.isNotEmpty ? match.first.name : null;
      return list.where((n) {
        return notificationMatchesFridge(n, fridgeId, fridgeName, fridges);
      }).toList();
    },
    orElse: () => const <NotificationModel>[],
  );
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

  Future<void> markFridgeAsRead(String fridgeId, [String? userId, String? fridgeName]) async {
    final String targetUserId = userId ?? _ref.read(currentNotificationUserIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final allNotifs = await _repository.getNotifications(targetUserId);
      final allFridges = _ref.read(fridgesProvider);
      for (final n in allNotifs) {
        final matches = notificationMatchesFridge(n, fridgeId, fridgeName, allFridges);
        if (matches && !n.isRead) {
          await _repository.markAsRead(n.id);
        }
      }
    });
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
