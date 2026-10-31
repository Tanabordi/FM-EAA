import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/core/notifications/notification_service.dart';
import 'package:fm_eaa/data/local/app_database.dart';
import 'package:fm_eaa/data/models/notification_model.dart';
import 'package:fm_eaa/data/remote/api_client.dart';
import 'package:fm_eaa/data/repositories/notification_repository.dart';
import 'package:fm_eaa/features/notifications/presentation/pages/notifications_page.dart';
import 'package:fm_eaa/features/notifications/providers/notifications_provider.dart';

void main() {
  late AppDatabase db;
  late NotificationRepository notificationRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    notificationRepo = NotificationRepository(apiClient: ApiClient(), database: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('NotificationService Tests', () {
    test('createNotificationId generates deterministic positive 31-bit integers', () {
      final id1 = NotificationService.createNotificationId('item_milk_123');
      final id2 = NotificationService.createNotificationId('item_milk_123');
      final id3 = NotificationService.createNotificationId('item_spinach_456');

      expect(id1, id2);
      expect(id1, isNonNegative);
      expect(id3, isNonNegative);
      expect(id1, isNot(id3));
    });

    test('NotificationService singleton returns identical instance', () {
      final instance1 = NotificationService();
      final instance2 = NotificationService();
      expect(identical(instance1, instance2), true);
    });
  });

  group('NotificationRepository & SQLite Storage Tests', () {
    test('insertNotification and getNotifications work correctly', () async {
      final notif = NotificationModel(
        id: 'n_1',
        userId: 'user_1',
        type: 'expiry',
        title: 'Cheese Expiring',
        message: 'Cheddar cheese expires in 2 days',
        createdAt: DateTime.now(),
      );

      await notificationRepo.insertNotification(notif);

      final list = await notificationRepo.getNotifications('user_1');
      expect(list.length, 1);
      expect(list.first.id, 'n_1');
      expect(list.first.title, 'Cheese Expiring');
      expect(list.first.message, 'Cheddar cheese expires in 2 days');
      expect(list.first.isRead, false);
    });

    test('markAsRead updates notification status', () async {
      await notificationRepo.insertNotification(
        NotificationModel(
          id: 'n_read_test',
          userId: 'user_1',
          type: 'expiry',
          title: 'Alert',
          message: 'Item expiring',
          createdAt: DateTime.now(),
        ),
      );

      expect((await notificationRepo.getNotifications('user_1')).first.isRead, false);

      await notificationRepo.markAsRead('n_read_test');

      expect((await notificationRepo.getNotifications('user_1')).first.isRead, true);
    });

    test('deleteNotification removes single record', () async {
      await notificationRepo.insertNotification(
        NotificationModel(
          id: 'n_del_test',
          userId: 'user_1',
          type: 'invite',
          title: 'Invite',
          message: 'Join fridge',
          createdAt: DateTime.now(),
        ),
      );

      expect((await notificationRepo.getNotifications('user_1')).length, 1);

      await notificationRepo.deleteNotification('n_del_test');

      expect((await notificationRepo.getNotifications('user_1')).isEmpty, true);
    });

    test('respondToInvite removes notification and updates state', () async {
      await notificationRepo.insertNotification(
        NotificationModel(
          id: 'n_invite_resp',
          userId: 'user_1',
          type: 'invite',
          title: 'Invite',
          message: 'Join my fridge',
          inviteId: 'invite_123',
          createdAt: DateTime.now(),
        ),
      );

      await notificationRepo.respondToInvite(
        notificationId: 'n_invite_resp',
        inviteId: 'invite_123',
        accept: true,
      );

      final list = await notificationRepo.getNotifications('user_1');
      expect(list.isEmpty, true);
    });

    test('seedInitialNotificationsIfEmpty seeds invite and expiry cards', () async {
      await notificationRepo.seedInitialNotificationsIfEmpty('user_1');

      final list = await notificationRepo.getNotifications('user_1');
      expect(list.length, 2);
      expect(list.any((n) => n.isInvite), true);
      expect(list.any((n) => n.isExpiry), true);

      // Verify no duplicates on second call
      await notificationRepo.seedInitialNotificationsIfEmpty('user_1');
      final list2 = await notificationRepo.getNotifications('user_1');
      expect(list2.length, 2);
    });
  });

  group('NotificationsPage Widget Tests', () {
    testWidgets('NotificationsPage renders Invitation and Expiry cards', (tester) async {
      final sampleNotifs = [
        NotificationModel(
          id: 'notif_1',
          userId: 'user_1',
          type: 'invite',
          title: 'Fridge Invitation',
          message: "John invited you to join 'Home Fridge'",
          inviteId: 'inv_1',
          createdAt: DateTime.now(),
        ),
        NotificationModel(
          id: 'notif_2',
          userId: 'user_1',
          type: 'expiry',
          title: 'Milk expires tomorrow',
          message: 'Remember to consume before expiry.',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            defaultNotificationsStreamProvider.overrideWith((ref) => Stream.value(sampleNotifs)),
          ],
          child: const MaterialApp(
            home: NotificationsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify AppBar
      expect(find.text('Notifications'), findsOneWidget);

      // Verify Family Invitation Card
      expect(find.text("John invited you to join 'Home Fridge'"), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);

      // Verify Expiry Warning Card
      expect(find.text('Milk expires tomorrow'), findsOneWidget);
      expect(find.text('Remember to consume before expiry.'), findsOneWidget);
    });

    testWidgets('Tapping Accept or Decline invokes action', (tester) async {
      final sampleNotifs = [
        NotificationModel(
          id: 'notif_1',
          userId: 'user_1',
          type: 'invite',
          title: 'Fridge Invitation',
          message: "Sarah invited you to join 'Kitchen Fridge'",
          inviteId: 'inv_2',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            defaultNotificationsStreamProvider.overrideWith((ref) => Stream.value(sampleNotifs)),
          ],
          child: const MaterialApp(
            home: NotificationsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Accept
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      expect(find.text('Accepted invitation.'), findsOneWidget);
    });

    testWidgets('Empty State renders when no notifications exist', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            defaultNotificationsStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(
            home: NotificationsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Notifications'), findsOneWidget);
      expect(find.text("You're all caught up! Expiry alerts and family invites will appear here."), findsOneWidget);
    });
  });
}

