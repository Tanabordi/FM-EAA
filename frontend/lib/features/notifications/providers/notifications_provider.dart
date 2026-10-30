import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/remote/api_client.dart';
import '../../../data/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(apiClient: ApiClient());
});

final notificationsListProvider = FutureProvider<List<NotificationModel>>((ref) async {
  // Mock notifications for skeleton
  return [
    NotificationModel(
      id: 'notif_1',
      userId: 'user_1',
      type: 'invite',
      title: 'Fridge Invitation',
      message: "John invited you to join 'Home Fridge'",
      fridgeId: 'fridge_home',
      inviteId: 'invite_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificationModel(
      id: 'notif_2',
      userId: 'user_1',
      type: 'expiry',
      title: 'Item Expiry Warning',
      message: 'Milk expires tomorrow',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];
});

