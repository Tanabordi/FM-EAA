import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/core/notifications/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dexterous.com/flutter/local_notifications'),
      (call) async => true,
    );
  });

  group('NotificationService Unit Tests', () {
    final service = NotificationService();

    test('createNotificationId creates consistent positive 31-bit integer', () {
      final id1 = NotificationService.createNotificationId('item_123');
      final id2 = NotificationService.createNotificationId('item_123');
      final id3 = NotificationService.createNotificationId('item_456');

      expect(id1, id2);
      expect(id1 >= 0, isTrue);
      expect(id3 >= 0, isTrue);
    });

    test('showExpiryAlert executes gracefully without throwing', () async {
      await expectLater(
        service.showExpiryAlert(
          id: 101,
          title: 'Strawberries expiring',
          body: 'Use strawberries soon!',
          payload: 'item_strawberries',
        ),
        completes,
      );
    });

    test('scheduleExpiryAlert executes gracefully', () async {
      await expectLater(
        service.scheduleExpiryAlert(
          id: 102,
          title: 'Milk expiring',
          body: 'Milk expires soon',
          scheduledDate: DateTime.now().add(const Duration(days: 1)),
          payload: 'item_milk',
        ),
        completes,
      );
    });

    test('scheduleItemExpiryAlert for item expiring today and tomorrow', () async {
      final now = DateTime.now();

      // Expiring today
      await expectLater(
        service.scheduleItemExpiryAlert(
          itemId: 'i_today',
          itemName: 'Spinach',
          fridgeName: 'Kitchen',
          expiryDate: now,
        ),
        completes,
      );

      // Expiring tomorrow
      await expectLater(
        service.scheduleItemExpiryAlert(
          itemId: 'i_tomorrow',
          itemName: 'Yogurt',
          fridgeName: 'Kitchen',
          expiryDate: now.add(const Duration(days: 2)),
        ),
        completes,
      );
    });

    test('cancelItemExpiryAlert, cancelAlert, and cancelAll execute without errors', () async {
      await expectLater(service.cancelItemExpiryAlert('i_today'), completes);
      await expectLater(service.cancelAlert(999), completes);
      await expectLater(service.cancelAll(), completes);
    });

    test('notification permission methods execute safely in test environment', () async {
      final allowed = await service.areNotificationsEnabled();
      expect(allowed, isA<bool>());

      final opened = await service.openNotificationSettings();
      expect(opened, isA<bool>());

      final req = await service.requestPermissions();
      expect(req, isNotNull);
    });

    testWidgets('requestPermissionsWithFallback executes with BuildContext', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  await service.requestPermissionsWithFallback(context, false);
                  await service.requestPermissionsWithFallback(context, true);
                },
                child: const Text('Check'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}

