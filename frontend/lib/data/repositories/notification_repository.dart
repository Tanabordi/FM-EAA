import '../models/notification_model.dart';
import '../remote/api_client.dart';

// TODO(repo notification): Implement notifications fetching and mark read
class NotificationRepository {
  final ApiClient apiClient;

  NotificationRepository({required this.apiClient});

  Future<List<NotificationModel>> getNotifications() async {
    // TODO: GET /api/notifications
    return [];
  }

  Future<void> markAsRead(String id) async {
    // TODO: PATCH /api/notifications/:id/read
  }
}

