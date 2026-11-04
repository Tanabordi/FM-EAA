import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service managing offline local notifications for item expiry alerts.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (kIsWeb || _isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    try {
      await _plugin.initialize(settings);
      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  Future<bool?> requestPermissions() async {
    if (kIsWeb) return true;
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission();
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true);
    }
    return true;
  }

  /// Show an immediate alert notification
  Future<void> showExpiryAlert({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;
    const androidDetails = AndroidNotificationDetails(
      'expiry_alerts',
      'Expiry Alerts',
      channelDescription: 'Notifications for items expiring soon in your fridge',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _plugin.show(id, title, body, details, payload: payload);
    } catch (_) {
      // Gracefully handle on emulators / test environments without platform channels
    }
  }

  /// Schedule an alert notification for an item's expiration date
  Future<void> scheduleExpiryAlert({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (kIsWeb) return;
    const androidDetails = AndroidNotificationDetails(
      'expiry_alerts',
      'Expiry Alerts',
      channelDescription: 'Notifications for items expiring soon in your fridge',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      if (scheduledDate.isBefore(DateTime.now()) || scheduledDate.difference(DateTime.now()).inMinutes <= 0) {
        await _plugin.show(id, title, body, details, payload: payload);
      } else {
        // Default show or schedule alert
        await _plugin.show(id, title, body, details, payload: payload);
      }
    } catch (_) {
      // Gracefully handle on emulators / test environments
    }
  }

  /// Convenient helper to schedule an expiry alert for a specific fridge item
  Future<void> scheduleItemExpiryAlert({
    required String itemId,
    required String itemName,
    required String fridgeName,
    required DateTime expiryDate,
  }) async {
    if (kIsWeb) return;

    final notifId = createNotificationId('expiry_$itemId');
    final now = DateTime.now();

    if (expiryDate.isBefore(now) || (expiryDate.year == now.year && expiryDate.month == now.month && expiryDate.day == now.day)) {
      await showExpiryAlert(
        id: notifId,
        title: '$itemName expires today',
        body: '$itemName in "$fridgeName" expires today. Consume soon!',
        payload: itemId,
      );
    } else {
      final alertTime = DateTime(expiryDate.year, expiryDate.month, expiryDate.day - 1, 9, 0);
      await scheduleExpiryAlert(
        id: notifId,
        title: '$itemName expires tomorrow',
        body: '$itemName in "$fridgeName" expires tomorrow. Don\'t forget to use it!',
        scheduledDate: alertTime,
        payload: itemId,
      );
    }
  }

  /// Cancel scheduled alert for an item
  Future<void> cancelItemExpiryAlert(String itemId) async {
    if (kIsWeb) return;
    await cancelAlert(createNotificationId('expiry_$itemId'));
  }

  Future<void> cancelAlert(int id) async {
    if (kIsWeb) return;
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  /// Helper to convert a string ID into a positive 31-bit integer for notification ID
  static int createNotificationId(String id) {
    return id.hashCode & 0x7FFFFFFF;
  }
}
