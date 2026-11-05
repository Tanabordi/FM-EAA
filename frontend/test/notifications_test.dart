import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/core/notifications/notification_service.dart';
import 'package:fm_eaa/core/theme/app_theme.dart';
import 'package:fm_eaa/data/local/app_database.dart';
import 'package:fm_eaa/data/models/notification_model.dart';
import 'package:fm_eaa/data/remote/api_client.dart';
import 'package:fm_eaa/data/repositories/notification_repository.dart';
import 'package:fm_eaa/features/fridges/providers/fridges_provider.dart';
import 'package:fm_eaa/features/notifications/presentation/pages/notifications_page.dart';
import 'package:fm_eaa/features/notifications/providers/notifications_provider.dart';

void main() {
  late AppDatabase db;
  late NotificationRepository notificationRepo;

  setUp(() {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'notifications': []},
            ),
          );
        },
      ),
    );
    db = AppDatabase(NativeDatabase.memory());
    notificationRepo = NotificationRepository(apiClient: ApiClient(customDio: dio), database: db);
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

    test('scheduleItemExpiryAlert and cancelItemExpiryAlert run without error', () async {
      final service = NotificationService();
      await service.scheduleItemExpiryAlert(
        itemId: 'item_apple_1',
        itemName: 'Apple',
        fridgeName: 'Kitchen',
        expiryDate: DateTime.now().add(const Duration(days: 2)),
      );

      await service.cancelItemExpiryAlert('item_apple_1');
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

    test('markAllAsRead marks all notifications for user as read', () async {
      await notificationRepo.insertNotification(
        NotificationModel(
          id: 'n_all_1',
          userId: 'user_1',
          type: 'expiry',
          title: 'Alert 1',
          message: 'Item 1 expiring',
          createdAt: DateTime.now(),
        ),
      );
      await notificationRepo.insertNotification(
        NotificationModel(
          id: 'n_all_2',
          userId: 'user_1',
          type: 'invite',
          title: 'Alert 2',
          message: 'Invite 2',
          createdAt: DateTime.now(),
        ),
      );

      final before = await notificationRepo.getNotifications('user_1');
      expect(before.every((n) => !n.isRead), true);

      await notificationRepo.markAllAsRead('user_1');

      final after = await notificationRepo.getNotifications('user_1');
      expect(after.every((n) => n.isRead), true);
    });

    test('watchUnreadCount accurately streams unread count', () async {
      expect(await notificationRepo.watchUnreadCount('user_1').first, 0);

      await notificationRepo.insertNotification(
        NotificationModel(
          id: 'n_unread_1',
          userId: 'user_1',
          type: 'expiry',
          title: 'Item Expiry',
          message: 'Milk expires soon',
          createdAt: DateTime.now(),
        ),
      );

      expect(await notificationRepo.watchUnreadCount('user_1').first, 1);

      await notificationRepo.markAsRead('n_unread_1');

      expect(await notificationRepo.watchUnreadCount('user_1').first, 0);
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

    test('purgeDemoNotifications removes all mockup demo notifications', () async {
      await notificationRepo.insertNotification(
        NotificationModel(
          id: 'notif_demo_invite',
          userId: 'user_1',
          type: 'invite',
          title: 'Demo',
          message: 'Demo invite',
          createdAt: DateTime.now(),
        ),
      );
      await notificationRepo.insertNotification(
        NotificationModel(
          id: 'real_notif',
          userId: 'user_1',
          type: 'expiry',
          title: 'Real',
          message: 'Real alert',
          createdAt: DateTime.now(),
        ),
      );

      await notificationRepo.purgeDemoNotifications();

      final list = await notificationRepo.getNotifications('user_1');
      expect(list.length, 1);
      expect(list.first.id, 'real_notif');
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
            appDatabaseProvider.overrideWithValue(db),
            notificationRepositoryProvider.overrideWithValue(notificationRepo),
            defaultNotificationsStreamProvider.overrideWith((ref) => Stream.value(sampleNotifs)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const NotificationsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify AppBar
      expect(find.text('Notifications'), findsOneWidget);

      // Verify Mark all as read button is shown since unread notifications exist
      expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);

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
          inviteId: null,
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            notificationRepositoryProvider.overrideWithValue(notificationRepo),
            defaultNotificationsStreamProvider.overrideWith((ref) => Stream.value(sampleNotifs)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const NotificationsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Accept
      await tester.tap(find.text('Accept'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Accepted invitation.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('Empty State renders when no notifications exist', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            notificationRepositoryProvider.overrideWithValue(notificationRepo),
            defaultNotificationsStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const NotificationsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Notifications'), findsOneWidget);
      expect(find.text("You're all caught up! Expiry alerts and family invites will appear here."), findsOneWidget);
    });

    testWidgets('NotificationsPage renders Member Joined and Item Action cards correctly', (tester) async {
      final sampleNotifs = [
        NotificationModel(
          id: 'notif_member_1',
          userId: 'user_1',
          type: 'member_joined',
          title: 'New Member Joined',
          message: "Bob joined 'Kitchen Fridge' (invited by Alice)",
          fridgeId: 'fridge_1',
          createdAt: DateTime.now(),
        ),
        NotificationModel(
          id: 'notif_item_add',
          userId: 'user_1',
          type: 'item_added',
          title: 'New Item Added',
          message: 'Alice added "Greek Yogurt" to "Kitchen Fridge"',
          fridgeId: 'fridge_1',
          createdAt: DateTime.now(),
        ),
        NotificationModel(
          id: 'notif_item_consume',
          userId: 'user_1',
          type: 'item_consumed',
          title: 'Item Consumed',
          message: 'Alice ate 1 cup of "Greek Yogurt" in "Kitchen Fridge"',
          fridgeId: 'fridge_1',
          createdAt: DateTime.now(),
        ),
        NotificationModel(
          id: 'notif_item_del',
          userId: 'user_1',
          type: 'item_deleted',
          title: 'Item Removed',
          message: 'Bob removed "Old Spinach" from "Kitchen Fridge"',
          fridgeId: 'fridge_1',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            notificationRepositoryProvider.overrideWithValue(notificationRepo),
            defaultNotificationsStreamProvider.overrideWith((ref) => Stream.value(sampleNotifs)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const NotificationsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Member Joined card
      expect(find.text('New Member Joined'), findsOneWidget);
      expect(find.text("Bob joined 'Kitchen Fridge' (invited by Alice)"), findsOneWidget);
      expect(find.byIcon(Icons.group_add_rounded), findsOneWidget);

      // Verify Item Added card
      expect(find.text('New Item Added'), findsOneWidget);
      expect(find.text('Alice added "Greek Yogurt" to "Kitchen Fridge"'), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);

      // Verify Item Consumed card
      expect(find.text('Item Consumed'), findsOneWidget);
      expect(find.text('Alice ate 1 cup of "Greek Yogurt" in "Kitchen Fridge"'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);

      // Verify Item Removed card
      expect(find.text('Item Removed'), findsOneWidget);
      expect(find.text('Bob removed "Old Spinach" from "Kitchen Fridge"'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    test('NotificationModel auto-corrects timestamps shifted into the future', () {
      final now = DateTime.now();
      // Simulate a timestamp that was pushed 7 hours into the future due to double-offset
      final futureTime = now.add(const Duration(hours: 7));
      final json = {
        'id': 'notif_future',
        'userId': 'user_1',
        'type': 'expiry',
        'title': 'Test',
        'message': 'Test message',
        'createdAt': futureTime.toUtc().toIso8601String(),
      };

      final model = NotificationModel.fromJson(json);
      // The parsed time should have subtracted the timezone offset and be near 'now', NOT in the future
      expect(model.createdAt.isBefore(now.add(const Duration(minutes: 5))), true);
    });

    testWidgets('fridgeUnreadNotificationCountProvider calculates unread count strictly for specified fridge', (tester) async {
      final notifs = [
        NotificationModel(
          id: 'n_f1_unread',
          userId: 'user_1',
          type: 'item_added',
          title: 'Added',
          message: 'Item added',
          fridgeId: 'fridge_alpha',
          isRead: false,
          createdAt: DateTime.now(),
        ),
        NotificationModel(
          id: 'n_f1_read',
          userId: 'user_1',
          type: 'item_added',
          title: 'Added',
          message: 'Item added',
          fridgeId: 'fridge_alpha',
          isRead: true,
          createdAt: DateTime.now(),
        ),
        NotificationModel(
          id: 'n_f2_unread',
          userId: 'user_1',
          type: 'item_added',
          title: 'Added',
          message: 'Item added',
          fridgeId: 'fridge_beta',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationRepositoryProvider.overrideWithValue(notificationRepo),
          defaultNotificationsStreamProvider.overrideWith((ref) => Stream.value(notifs)),
        ],
      );
      addTearDown(container.dispose);

      // Wait for stream to emit
      await container.read(defaultNotificationsStreamProvider.future);

      final countAlpha = container.read(fridgeUnreadNotificationCountProvider('fridge_alpha'));
      final countBeta = container.read(fridgeUnreadNotificationCountProvider('fridge_beta'));
      final countGamma = container.read(fridgeUnreadNotificationCountProvider('fridge_gamma'));

      expect(countAlpha, 1);
      expect(countBeta, 1);
      expect(countGamma, 0);
    });

    testWidgets('NotificationsPage with fridgeId only renders notifications for that fridge', (tester) async {
      final sampleNotifs = [
        NotificationModel(
          id: 'notif_alpha',
          userId: 'user_1',
          type: 'item_added',
          title: 'New Item Added',
          message: 'Milk added to Alpha',
          fridgeId: 'fridge_alpha',
          createdAt: DateTime.now(),
        ),
        NotificationModel(
          id: 'notif_beta',
          userId: 'user_1',
          type: 'item_added',
          title: 'New Item Added',
          message: 'Eggs added to Beta',
          fridgeId: 'fridge_beta',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            notificationRepositoryProvider.overrideWithValue(notificationRepo),
            defaultNotificationsStreamProvider.overrideWith((ref) => Stream.value(sampleNotifs)),
          ],
          child: const MaterialApp(
            home: NotificationsPage(
              fridgeId: 'fridge_alpha',
              fridgeName: 'Fridge Alpha',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Fridge Alpha's notification is present
      expect(find.text('Milk added to Alpha'), findsOneWidget);
      expect(find.text('Fridge Alpha'), findsOneWidget);

      // Verify Fridge Beta's notification is NOT rendered
      expect(find.text('Eggs added to Beta'), findsNothing);
    });

    test('notificationMatchesFridge strictly rejects notifications belonging to other fridges', () {
      final notifFromOtherFridge = NotificationModel(
        id: 'n_other',
        userId: 'user_1',
        type: 'item_added',
        title: 'New Item Added',
        message: 'Somchai added "Apples" (5 pieces) to "Office Fridge"',
        fridgeId: null, // Test fallback when fridgeId is missing
        fridgeName: 'Office Fridge',
        createdAt: DateTime.now(),
      );

      final isMatchTarget = notificationMatchesFridge(
        notifFromOtherFridge,
        'home_fridge_id',
        'Home Fridge',
      );
      expect(isMatchTarget, isFalse);

      final isMatchOffice = notificationMatchesFridge(
        notifFromOtherFridge,
        'office_fridge_id',
        'Office Fridge',
      );
      expect(isMatchOffice, isTrue);
    });

    test('NotificationModel.fromJson parses dynamic map payload correctly', () {
      final dynamicJson = <dynamic, dynamic>{
        'id': 'notif_dyn',
        'user_id': 'user_1',
        'type': 'item_added',
        'payload': <dynamic, dynamic>{
          'fridge_id': 'f_dyn_123',
          'fridge_name': 'Kitchen',
          'title': 'Dynamically parsed',
          'message': 'Parsed successfully',
        },
      };

      final model = NotificationModel.fromJson(Map<String, dynamic>.from(dynamicJson));
      expect(model.fridgeId, 'f_dyn_123');
      expect(model.fridgeName, 'Kitchen');
      expect(model.title, 'Dynamically parsed');
    });

    testWidgets('NotificationController performs actions and state transitions cleanly', (tester) async {
      final container = ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationRepositoryProvider.overrideWithValue(notificationRepo),
          fridgesProvider.overrideWith((ref) => FridgesNotifier()),
        ],
        child: Container(),
      );

      await tester.pumpWidget(container);
      final element = tester.element(find.byType(Container));
      final containerRef = ProviderScope.containerOf(element);

      final controller = containerRef.read(notificationControllerProvider.notifier);

      // Insert test notification into db
      await db.insertNotification(
        id: 'notif_ctrl_1',
        userId: 'user_1',
        type: 'item_added',
        payloadJson: '{"title":"Test Notif","message":"Testing controller"}',
      );

      // Mark single read
      await controller.markAsRead('notif_ctrl_1');
      expect(containerRef.read(notificationControllerProvider), isA<AsyncData<void>>());

      // Mark fridge as read
      await controller.markFridgeAsRead('fridge_1', 'user_1', 'Kitchen');
      expect(containerRef.read(notificationControllerProvider), isA<AsyncData<void>>());

      // Mark all as read
      await controller.markAllAsRead('user_1');
      expect(containerRef.read(notificationControllerProvider), isA<AsyncData<void>>());

      // Delete notification
      await controller.deleteNotification('notif_ctrl_1');
      expect(containerRef.read(notificationControllerProvider), isA<AsyncData<void>>());

      // Clear all
      await controller.clearAll('user_1');
      expect(containerRef.read(notificationControllerProvider), isA<AsyncData<void>>());
    });
  });
}

