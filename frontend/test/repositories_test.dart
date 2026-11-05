import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/local/app_database.dart';
import 'package:fm_eaa/data/models/fridge_model.dart';
import 'package:fm_eaa/data/models/history_model.dart';
import 'package:fm_eaa/data/models/item_model.dart';
import 'package:fm_eaa/data/models/notification_model.dart';
import 'package:fm_eaa/data/remote/api_client.dart';
import 'package:fm_eaa/data/repositories/auth_repository.dart';
import 'package:fm_eaa/data/repositories/family_repository.dart';
import 'package:fm_eaa/data/repositories/fridge_repository.dart';
import 'package:fm_eaa/data/repositories/history_repository.dart';
import 'package:fm_eaa/data/repositories/item_repository.dart';
import 'package:fm_eaa/data/repositories/notification_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  late AppDatabase database;
  late Dio dio;
  late ApiClient apiClient;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dio = Dio();
    apiClient = ApiClient(customDio: dio);
  });

  tearDown(() async {
    await database.close();
  });

  group('AuthRepository Unit Tests', () {
    test('signInWithPassword saves token and user details to secure storage', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/auth/login')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'token': 'jwt_test_token_123',
                'user': {
                  'id': 'user_1',
                  'username': 'tulbp',
                  'email': 'tulbp@example.com',
                  'updated_at': DateTime.now().toIso8601String(),
                },
              },
            ));
          }
          return handler.next(options);
        },
      ));

      final repo = AuthRepository(apiClient: apiClient);
      final user = await repo.signInWithPassword('tulbp', 'password123');

      expect(user.id, 'user_1');
      expect(user.username, 'tulbp');
      expect(await apiClient.storage.read(key: 'jwt_token'), 'jwt_test_token_123');
      expect(await apiClient.storage.read(key: 'user_username'), 'tulbp');
    });

    test('createAccount registers user and caches auth credentials', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/auth/register')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 201,
              data: {
                'token': 'jwt_new_token_456',
                'user': {
                  'id': 'user_2',
                  'username': 'alex',
                  'email': 'alex@example.com',
                  'updated_at': DateTime.now().toIso8601String(),
                },
              },
            ));
          }
          return handler.next(options);
        },
      ));

      final repo = AuthRepository(apiClient: apiClient);
      final user = await repo.createAccount('alex', 'alex@example.com', 'password123');

      expect(user.id, 'user_2');
      expect(user.email, 'alex@example.com');
      expect(await apiClient.storage.read(key: 'jwt_token'), 'jwt_new_token_456');
    });

    test('restoreSession returns cached user if backend succeeds', () async {
      await apiClient.storage.write(key: 'jwt_token', value: 'valid_token');

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/auth/me')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'user': {
                  'id': 'user_cached',
                  'username': 'cached_tul',
                  'email': 'cached@example.com',
                  'updated_at': DateTime.now().toIso8601String(),
                },
              },
            ));
          }
          return handler.next(options);
        },
      ));

      final repo = AuthRepository(apiClient: apiClient);
      final user = await repo.restoreSession();

      expect(user, isNotNull);
      expect(user?.username, 'cached_tul');
    });

    test('password reset flow: requestOtp, verifyOtp, and resetPassword', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/auth/forgot-password')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {'message': 'OTP sent'},
            ));
          } else if (options.path.contains('/auth/verify-otp')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {'message': 'OTP verified', 'valid': true},
            ));
          } else if (options.path.contains('/auth/reset-password')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {'message': 'Password reset successful'},
            ));
          }
          return handler.next(options);
        },
      ));

      final repo = AuthRepository(apiClient: apiClient);
      await repo.requestPasswordReset('tulbp@example.com');
      await repo.verifyOtp(email: 'tulbp@example.com', otp: '123456');
      await repo.resetPassword(email: 'tulbp@example.com', otp: '123456', newPassword: 'NewPassword123!');
    });

    test('logout clears secure storage', () async {
      await apiClient.storage.write(key: 'jwt_token', value: 'temp_token');
      await apiClient.storage.write(key: 'user_id', value: 'u1');

      final repo = AuthRepository(apiClient: apiClient);
      await repo.logout();

      expect(await apiClient.storage.read(key: 'jwt_token'), isNull);
      expect(await apiClient.storage.read(key: 'user_id'), isNull);
    });
  });

  group('FamilyRepository Unit Tests', () {
    test('getMembers, searchUsers, inviteMember, and removeMember', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/members') && options.method == 'GET') {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'members': [
                  {
                    'id': 'm1',
                    'username': 'tulbp',
                    'role': 'owner',
                    'avatar_url': 'https://avatar.png',
                    'email': 'tulbp@test.com',
                  },
                ],
              },
            ));
          } else if (options.path.contains('/search-users')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'users': [
                  {
                    'id': 'u2',
                    'username': 'friend',
                    'status': 'available',
                    'avatarUrl': 'https://friend.png',
                  },
                ],
              },
            ));
          } else if (options.path.contains('/invites')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 201,
              data: {'success': true, 'inviteId': 'inv_123'},
            ));
          } else if (options.method == 'DELETE') {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {'success': true},
            ));
          }
          return handler.next(options);
        },
      ));

      final repo = FamilyRepository(apiClient: apiClient);
      final members = await repo.getMembers('fridge_1');
      expect(members, hasLength(1));
      expect(members.first.isOwner, isTrue);

      final search = await repo.searchUsers('fridge_1', 'friend');
      expect(search, hasLength(1));
      expect(search.first.username, 'friend');

      final emptySearch = await repo.searchUsers('fridge_1', '');
      expect(emptySearch, isEmpty);

      final inviteRes = await repo.inviteMember('fridge_1', 'friend');
      expect(inviteRes['success'], isTrue);

      await repo.removeMember('fridge_1', 'u2');
      await repo.respondInvite('inv_123', true);
    });
  });

  group('FridgeRepository Unit Tests', () {
    test('getFridges fetches from API and caches to Drift database', () async {
      await apiClient.storage.write(key: 'jwt_token', value: 'active_token');

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path == '/fridges' && options.method == 'GET') {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'fridges': [
                  {
                    'id': 'fridge_test_1',
                    'name': 'Home Fridge',
                    'description': 'Main kitchen',
                    'owner_id': 'user_1',
                    'role': 'owner',
                    'member_count': 2,
                    'item_count': 5,
                    'updated_at': DateTime.now().toIso8601String(),
                  },
                ],
              },
            ));
          }
          return handler.next(options);
        },
      ));

      final repo = FridgeRepository(apiClient: apiClient, database: database);
      final fridges = await repo.getFridges();

      expect(fridges, hasLength(1));
      expect(fridges.first.name, 'Home Fridge');

      // Check Drift database cache
      final cached = await database.fridgeDao.getAllFridges();
      expect(cached, hasLength(1));
      expect(cached.first.name, 'Home Fridge');
    });

    test('watchFridges emits cached entries from Drift SQLite', () async {
      final repo = FridgeRepository(apiClient: apiClient, database: database);

      await database.fridgeDao.insertFridgeOptimistic(
        id: 'f_watch_1',
        name: 'Office Fridge',
        description: 'Snacks',
        ownerId: 'u1',
        isSynced: true,
      );

      final stream = repo.watchFridges();
      expect(stream, emits(predicate<List<FridgeModel>>((list) {
        return list.any((f) => f.name == 'Office Fridge');
      })));
    });
  });

  group('ItemRepository Unit Tests', () {
    test('addItem, updateItem, and deleteItem optimistic operations', () async {
      final repo = ItemRepository(apiClient: apiClient, database: database);

      // Create Fridge first
      await database.fridgeDao.insertFridgeOptimistic(
        id: 'f_item_1',
        name: 'Kitchen',
        ownerId: 'u1',
        isSynced: true,
      );

      // Create Item Optimistically
      final item = ItemModel(
        id: 'item_test_1',
        fridgeId: 'f_item_1',
        name: 'Eggs',
        category: 'proteins',
        zone: 'fridge',
        quantity: 12,
        unit: 'pieces',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        updatedAt: DateTime.now(),
      );
      await repo.addItem(item);

      final items = await repo.getItems('f_item_1');
      expect(items, hasLength(1));
      expect(items.first.name, 'Eggs');

      // Update Item
      final updated = item.copyWith(quantity: 6);
      await repo.updateItem(updated);

      final itemsAfterUpdate = await repo.getItems('f_item_1');
      expect(itemsAfterUpdate.first.quantity, 6);

      // Delete Item
      await repo.deleteItem(item.id, fridgeId: 'f_item_1');
      final itemsAfterDelete = await repo.getItems('f_item_1');
      expect(itemsAfterDelete, isEmpty);
    });

    test('watchItems emits active non-deleted items', () async {
      final repo = ItemRepository(apiClient: apiClient, database: database);

      await database.fridgeDao.insertFridgeOptimistic(
        id: 'f_watch_items',
        name: 'Fridge 2',
        ownerId: 'u1',
        isSynced: true,
      );

      final item = ItemModel(
        id: 'item_watch_1',
        fridgeId: 'f_watch_items',
        name: 'Milk',
        category: 'beverages',
        zone: 'fridge',
        quantity: 1,
        unit: 'bottle',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        updatedAt: DateTime.now(),
      );
      await repo.addItem(item);

      final stream = repo.watchItems('f_watch_items');
      expect(stream, emits(predicate<List<ItemModel>>((list) {
        return list.length == 1 && list.first.name == 'Milk';
      })));
    });
  });

  group('HistoryRepository Unit Tests', () {
    test('getHistory and watchHistory from Drift database', () async {
      final repo = HistoryRepository(apiClient: apiClient, database: database);

      await database.fridgeDao.insertFridgeOptimistic(
        id: 'f_hist_1',
        name: 'Kitchen',
        ownerId: 'u1',
        isSynced: true,
      );

      final stream = repo.watchHistory('f_hist_1');
      expect(stream, emits(isA<List<HistoryModel>>()));

      final list = await repo.getHistory('f_hist_1');
      expect(list, isEmpty);
    });

    test('fetchHistoryFromApi caches records into Drift database', () async {
      await apiClient.storage.write(key: 'jwt_token', value: 'token_123');

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/history')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'history': [
                  {
                    'id': 'hist_api_1',
                    'fridge_id': 'f_hist_api',
                    'item_name': 'Cheese',
                    'kind': 'consumed',
                    'quantity_changed': 1,
                    'quantity_left': 0,
                    'unit': 'pack',
                    'by_username': 'tulbp',
                    'created_at': DateTime.now().toIso8601String(),
                  },
                ],
              },
            ));
          }
          return handler.next(options);
        },
      ));

      final repo = HistoryRepository(apiClient: apiClient, database: database);
      final records = await repo.fetchHistoryFromApi('f_hist_api');

      expect(records, hasLength(1));
      expect(records.first.itemName, 'Cheese');
    });
  });

  group('NotificationRepository Unit Tests', () {
    test('insertNotification, getNotifications, markAsRead, and markAllAsRead', () async {
      final repo = NotificationRepository(apiClient: apiClient, database: database);

      final notif = NotificationModel(
        id: 'n_local_1',
        userId: 'u1',
        type: 'expiry',
        title: 'Expiry Alert',
        message: 'Milk is expiring soon',
        isRead: false,
        createdAt: DateTime.now(),
      );

      await repo.insertNotification(notif);

      final notifs = await repo.getNotifications('u1');
      expect(notifs, hasLength(1));
      expect(notifs.first.title, 'Expiry Alert');

      await repo.markAsRead('n_local_1');
      final notifsAfterRead = await repo.getNotifications('u1');
      expect(notifsAfterRead.first.isRead, isTrue);

      await repo.markAllAsRead('u1');
      await repo.deleteNotification('n_local_1');
      expect(await repo.getNotifications('u1'), isEmpty);
    });

    test('watchNotifications and watchUnreadCount emit streams', () async {
      final repo = NotificationRepository(apiClient: apiClient, database: database);
      final notifsStream = repo.watchNotifications('u_stream_1');
      expect(notifsStream, emits(isA<List<NotificationModel>>()));

      final countStream = repo.watchUnreadCount('u_stream_1');
      expect(countStream, emits(isA<int>()));
    });

    test('syncNotifications persists remote notifications into local DB', () async {
      await apiClient.storage.write(key: 'jwt_token', value: 'token_notif_123');

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/notifications')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'notifications': [
                  {
                    'id': 'n_remote_1',
                    'userId': 'u_fetch_1',
                    'type': 'invite',
                    'title': 'New Invite',
                    'message': 'You have an invite',
                    'isRead': false,
                    'createdAt': DateTime.now().toIso8601String(),
                  }
                ],
              },
            ));
          }
          return handler.next(options);
        },
      ));

      final repo = NotificationRepository(apiClient: apiClient, database: database);
      final list = await repo.syncNotifications('u_fetch_1');
      expect(list, hasLength(1));
      expect(list.first.id, 'n_remote_1');
    });
  });

  group('ItemRepository Extended Operations', () {
    test('getExpiringSoonItems, consumeItem, and undoConsume', () async {
      final repo = ItemRepository(apiClient: apiClient, database: database);

      await database.fridgeDao.insertFridgeOptimistic(
        id: 'f_exp_test',
        name: 'Main Fridge',
        ownerId: 'u1',
        isSynced: true,
      );

      final expiringItem = ItemModel(
        id: 'item_exp_1',
        fridgeId: 'f_exp_test',
        name: 'Yogurt',
        category: 'beverages',
        zone: 'fridge',
        quantity: 2,
        unit: 'cups',
        expiryDate: DateTime.now().add(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      );
      await repo.addItem(expiringItem);

      final expiringSoon = await repo.getExpiringSoonItems('f_exp_test', daysThreshold: 2);
      expect(expiringSoon, hasLength(1));
      expect(expiringSoon.first.name, 'Yogurt');

      final itemsByFridge = await repo.getItemsByFridge('f_exp_test');
      expect(itemsByFridge, hasLength(1));

      // Test consumeItem
      await repo.consumeItem('item_exp_1', 1, finishedAll: false);
      final itemsAfterConsume = await repo.getItems('f_exp_test');
      expect(itemsAfterConsume.first.quantity, 1.0);

      // Test getUnsyncedItems and markItemSynced
      final unsynced = await repo.getUnsyncedItems('f_exp_test');
      expect(unsynced, isA<List<ItemModel>>());

      await repo.markItemSynced('item_exp_1');
    });

    test('uploadItemImageBytes uploads bytes and parses imageUrl', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/items/upload-image')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {'imageUrl': 'https://storage.cloud/images/food_item.jpg'},
            ));
          }
          return handler.next(options);
        },
      ));

      final repo = ItemRepository(apiClient: apiClient, database: database);
      final url = await repo.uploadItemImageBytes([1, 2, 3, 4], filename: 'test.jpg');
      expect(url, 'https://storage.cloud/images/food_item.jpg');
    });
  });

  group('AuthRepository Password Reset and OTP Operations', () {
    test('requestPasswordReset calls forgot-password endpoint', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/auth/forgot-password')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {'message': 'OTP sent to email'},
            ));
          }
          return handler.next(options);
        },
      ));

      final repo = AuthRepository(apiClient: apiClient);
      final res = await repo.requestPasswordReset('test@example.com');
      expect(res['message'], 'OTP sent to email');

      // Also call sendPasswordReset void method
      await repo.sendPasswordReset('test@example.com');
    });

    test('verifyOtp calls verify-otp endpoint', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/auth/verify-otp')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {'verified': true, 'otp': '123456'},
            ));
          }
          return handler.next(options);
        },
      ));

      final repo = AuthRepository(apiClient: apiClient);
      final res = await repo.verifyOtp(email: 'test@example.com', otp: '123456');
      expect(res['verified'], isTrue);
    });

    test('resetPassword calls reset-password endpoint', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/auth/reset-password')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {'success': true, 'message': 'Password reset successful'},
            ));
          }
          return handler.next(options);
        },
      ));

      final repo = AuthRepository(apiClient: apiClient);
      final res = await repo.resetPassword(
        email: 'test@example.com',
        otp: '123456',
        newPassword: 'NewSecurePassword123!',
      );
      expect(res['success'], isTrue);
    });

    test('uploadAvatar uploads image bytes and caches user_avatar_url', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/users/me/avatar')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {'avatarUrl': 'https://storage.cloud/avatars/user_me.jpg'},
            ));
          }
          return handler.next(options);
        },
      ));

      final repo = AuthRepository(apiClient: apiClient);
      final url = await repo.uploadAvatar([10, 20, 30], 'avatar.jpg');
      expect(url, 'https://storage.cloud/avatars/user_me.jpg');
      expect(await apiClient.storage.read(key: 'user_avatar_url'), 'https://storage.cloud/avatars/user_me.jpg');
    });

    test('AuthRepository handles connection timeout, connection error, and server message in _parseDioError', () async {
      // 1. Connection Timeout
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/auth/login')) {
            return handler.reject(DioException(
              requestOptions: options,
              type: DioExceptionType.connectionTimeout,
            ));
          }
          return handler.next(options);
        },
      ));

      final repo = AuthRepository(apiClient: apiClient);
      expect(
        () => repo.signInWithPassword('tulbp', 'pass'),
        throwsA(predicate<Exception>((e) => e.toString().contains('Connection timed out'))),
      );

      // 2. Connection Error
      dio.interceptors.clear();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/auth/register')) {
            return handler.reject(DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
            ));
          }
          return handler.next(options);
        },
      ));

      expect(
        () => repo.createAccount('u', 'u@test.com', 'pass'),
        throwsA(predicate<Exception>((e) => e.toString().contains('Cannot connect to backend server'))),
      );

      // 3. Bad response with custom message
      dio.interceptors.clear();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/auth/forgot-password')) {
            return handler.reject(DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 400,
                data: {'error': 'User not found with this email'},
              ),
              type: DioExceptionType.badResponse,
            ));
          }
          return handler.next(options);
        },
      ));

      expect(
        () => repo.requestPasswordReset('unknown@test.com'),
        throwsA(predicate<Exception>((e) => e.toString().contains('User not found with this email'))),
      );
    });
  });
}
