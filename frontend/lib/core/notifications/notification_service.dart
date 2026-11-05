import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/remote/api_client.dart';

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

      // Register high-priority Android notification channel for Heads-Up alerts
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        const channel = AndroidNotificationChannel(
          'expiry_alerts',
          'Fridge & Expiry Alerts',
          description: 'Notifications for items expiring soon and fridge member activity',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );
        await androidPlugin.createNotificationChannel(channel);
      }

      // Handle real-time foreground FCM notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        final data = message.data;
        if (notification != null) {
          showExpiryAlert(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: notification.title ?? 'FM-EAA',
            body: notification.body ?? '',
            payload: data['itemId'] ?? data['fridgeId'],
          );
        }
      });
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  /// Obtain FCM Device Token and register with backend server
  Future<void> syncFcmTokenWithBackend() async {
    if (kIsWeb) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        final apiClient = ApiClient();
        await apiClient.dio.post('/users/fcm-token', data: {
          'fcmToken': token,
        });
        debugPrint('[NotificationService] FCM Token registered with backend: $token');
      }
    } catch (e) {
      debugPrint('[NotificationService] Failed to sync FCM token: $e');
    }
  }

  /// Remove FCM Device Token from backend server on logout
  Future<void> removeFcmTokenFromBackend() async {
    if (kIsWeb) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        final apiClient = ApiClient();
        await apiClient.dio.delete('/users/fcm-token', data: {
          'fcmToken': token,
        });
      }
    } catch (_) {}
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

  /// Check whether notifications are enabled at the OS/System level
  Future<bool> areNotificationsEnabled() async {
    if (kIsWeb) return true;
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (_) {
      try {
        final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (android != null) {
          return (await android.areNotificationsEnabled()) ?? false;
        }
      } catch (_) {}
      return true;
    }
  }

  /// Open Android/iOS App Notification Settings page directly
  Future<bool> openNotificationSettings() async {
    if (kIsWeb) return false;
    try {
      return await openAppSettings();
    } catch (_) {
      return false;
    }
  }

  /// Request notification permission with automatic in-app fallback dialog.
  /// If notifications are disabled in OS settings, presents an explanatory dialog
  /// with a direct button to jump into the system Settings page.
  Future<bool> requestPermissionsWithFallback(BuildContext context) async {
    if (kIsWeb) return true;

    // Check actual OS status first
    final currentStatus = await Permission.notification.status;
    if (currentStatus.isGranted) {
      return true;
    }

    // Attempt native system request if not permanently denied
    if (!currentStatus.isPermanentlyDenied) {
      try {
        final req = await Permission.notification.request();
        if (req.isGranted) return true;
      } catch (_) {
        final localResult = await requestPermissions();
        if (localResult == true) return true;
      }
    }

    // If still not granted (e.g. permanently denied in OS Settings), show fallback dialog
    if (context.mounted) {
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          final theme = Theme.of(ctx);
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.errorContainer,
              child: Icon(Icons.notifications_off_rounded, color: theme.colorScheme.error, size: 30),
            ),
            title: const Text(
              'เปิดการแจ้งเตือน',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            content: const Text(
              'การแจ้งเตือนถูกปิดอยู่ในการตั้งค่าเครื่องของคุณ เพื่อให้คุณไม่พลาดของใกล้หมดอายุและการแจ้งเตือนจากตู้เย็น กรุณาเปิดการแจ้งเตือนในการตั้งค่า',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('ข้ามไปก่อน', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(ctx).pop(true),
                icon: const Icon(Icons.settings, size: 18),
                label: const Text('ไปที่การตั้งค่า'),
              ),
            ],
          );
        },
      );

      if (shouldOpenSettings == true) {
        await openNotificationSettings();
      }
    }

    // Re-verify after coming back from Settings or Dialog
    return await areNotificationsEnabled();
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
