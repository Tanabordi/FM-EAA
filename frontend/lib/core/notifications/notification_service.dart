import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service managing offline local notifications for item expiry alerts.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

      await _plugin.initialize(settings);
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  Future<bool?> requestPermissions() async {
    if (kIsWeb) return true;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('NotificationService requestPermissions error: $e');
    }
    return true;
  }

  Future<void> scheduleExpiryAlert({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // TODO(notifications local): Schedule notification based on expiry date
  }

  Future<void> cancelAlert(int id) async {
    if (kIsWeb) return;
    try {
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('NotificationService cancelAlert error: $e');
    }
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('NotificationService cancelAll error: $e');
    }
  }
}
