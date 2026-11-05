import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/local/app_database.dart';
import 'package:fm_eaa/data/models/item_model.dart';
import 'package:fm_eaa/data/remote/api_client.dart';
import 'package:fm_eaa/data/repositories/item_repository.dart';
import 'package:fm_eaa/shared/utils/environment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Dio dio;
  late ApiClient apiClient;
  late ItemRepository repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:5000/api'));
    apiClient = ApiClient(customDio: dio);
    repository = ItemRepository(apiClient: apiClient, database: db);

    // Create a fridge in database
    await db.fridgeDao.insertFridgeOptimistic(
      id: 'f1',
      name: 'Kitchen Fridge',
      ownerId: 'user_1',
    );
  });

  tearDown(() async {
    setTestEnvironmentOverride(null);
    await db.close();
  });

  group('ItemRepository Unit Tests', () {
    test('watchItems emits item list from local Drift SQLite', () async {
      await db.itemDao.insertItemOptimistic(
        id: 'i1',
        fridgeId: 'f1',
        name: 'Fresh Apples',
        category: 'fruits',
        zone: 'fridge',
        quantity: 5,
        unit: 'pieces',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
      );

      final stream = repository.watchItems('f1');
      final list = await stream.first;
      expect(list.length, 1);
      expect(list.first.name, 'Fresh Apples');
    });

    test('getItems fetches from remote API and reconciles with local database', () async {
      setTestEnvironmentOverride(false);

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/fridges/f1/items')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'items': [
                      {
                        'id': 'remote_item_1',
                        'fridgeId': 'f1',
                        'name': 'Greek Yogurt',
                        'category': 'dairy',
                        'zone': 'fridge',
                        'quantity': 2,
                        'unit': 'cups',
                        'expiryDate': '2026-12-01T00:00:00.000Z',
                      }
                    ],
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final items = await repository.getItems('f1');
      expect(items.length, 1);
      expect(items.first.name, 'Greek Yogurt');

      // Verify cached in database
      final local = await db.itemDao.getItemById('remote_item_1');
      expect(local, isNotNull);
      expect(local!.name, 'Greek Yogurt');
    });

    test('getItems falls back to local DB when remote API fails', () async {
      setTestEnvironmentOverride(false);

      await db.itemDao.insertItemOptimistic(
        id: 'local_only',
        fridgeId: 'f1',
        name: 'Local Eggs',
        category: 'proteins',
        zone: 'fridge',
        quantity: 12,
        unit: 'eggs',
        expiryDate: DateTime.now().add(const Duration(days: 10)),
      );

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
          },
        ),
      );

      final items = await repository.getItems('f1');
      expect(items.length, 1);
      expect(items.first.name, 'Local Eggs');
    });

    test('addItem creates item remotely and caches as synced', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/fridges/f1/items')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 201,
                  data: {
                    'item': {
                      'id': 'new_item_id',
                      'fridgeId': 'f1',
                      'name': 'Organic Milk',
                      'category': 'beverages',
                      'zone': 'fridge',
                      'quantity': 1,
                      'unit': 'bottles',
                      'expiryDate': '2026-11-20T00:00:00.000Z',
                    },
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final toAdd = ItemModel(
        id: '',
        fridgeId: 'f1',
        name: 'Organic Milk',
        category: 'beverages',
        zone: 'fridge',
        quantity: 1,
        unit: 'bottles',
        expiryDate: DateTime(2026, 11, 20),
        updatedAt: DateTime.now(),
      );

      final added = await repository.addItem(toAdd);
      expect(added.id, 'new_item_id');

      final cached = await db.itemDao.getItemById('new_item_id');
      expect(cached, isNotNull);
      expect(cached!.isSynced, isTrue);
    });

    test('addItem falls back to local unsynced save on network failure', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionTimeout,
              ),
            );
          },
        ),
      );

      final offlineItem = ItemModel(
        id: 'offline_123',
        fridgeId: 'f1',
        name: 'Offline Cheddar',
        category: 'dairy',
        zone: 'fridge',
        quantity: 1,
        unit: 'pack',
        expiryDate: DateTime(2026, 11, 25),
        updatedAt: DateTime.now(),
      );

      final result = await repository.addItem(offlineItem);
      expect(result.id, 'offline_123');

      final cached = await db.itemDao.getItemById('offline_123');
      expect(cached, isNotNull);
      expect(cached!.isSynced, isFalse);
    });

    test('updateItem updates remotely and in local database', () async {
      await db.itemDao.insertItemOptimistic(
        id: 'up_item',
        fridgeId: 'f1',
        name: 'Butter',
        category: 'dairy',
        zone: 'fridge',
        quantity: 1,
        unit: 'pack',
        expiryDate: DateTime.now().add(const Duration(days: 14)),
      );

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/items/up_item')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true},
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final updated = ItemModel(
        id: 'up_item',
        fridgeId: 'f1',
        name: 'Salted Butter',
        category: 'dairy',
        zone: 'fridge',
        quantity: 2,
        unit: 'packs',
        expiryDate: DateTime.now().add(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      );

      await repository.updateItem(updated);
      final cached = await db.itemDao.getItemById('up_item');
      expect(cached!.name, 'Salted Butter');
      expect(cached.quantity, 2);
      expect(cached.isSynced, isTrue);
    });

    test('deleteItem removes item remotely and locally', () async {
      await db.itemDao.insertItemOptimistic(
        id: 'del_item',
        fridgeId: 'f1',
        name: 'Old Bread',
        category: 'bakery',
        zone: 'pantry',
        quantity: 1,
        unit: 'loaf',
        expiryDate: DateTime.now().add(const Duration(days: 2)),
      );

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/items/del_item')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'success': true},
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      await repository.deleteItem('del_item', fridgeId: 'f1');
      final cached = await db.itemDao.getItemById('del_item');
      expect(cached, isNull);
    });

    test('consumeItem and undoConsume call API and update local DB', () async {
      await db.itemDao.insertItemOptimistic(
        id: 'cons_item',
        fridgeId: 'f1',
        name: 'Ice Cream',
        category: 'sweets',
        zone: 'freezer',
        quantity: 3,
        unit: 'pints',
        expiryDate: DateTime.now().add(const Duration(days: 30)),
      );

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true},
              ),
            );
          },
        ),
      );

      await repository.consumeItem('cons_item', 1, finishedAll: false);
      final itemAfter = await db.itemDao.getItemById('cons_item');
      expect(itemAfter!.quantity, 2);

      await repository.undoConsume('mock_hist_id');
    });

    test('uploadItemImageBytes uploads bytes and returns image URL', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/items/upload-image')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'imageUrl': 'https://storage.oracle.com/items/food_123.jpg'},
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final url = await repository.uploadItemImageBytes([10, 20, 30], filename: 'food.jpg');
      expect(url, 'https://storage.oracle.com/items/food_123.jpg');
    });

    test('getExpiringSoonItems, getUnsyncedItems and markItemSynced', () async {
      await db.itemDao.insertItemOptimistic(
        id: 'soon_item',
        fridgeId: 'f1',
        name: 'Salmon',
        category: 'proteins',
        zone: 'fridge',
        quantity: 1,
        unit: 'fillet',
        expiryDate: DateTime.now().add(const Duration(hours: 12)),
        isSynced: false,
      );

      final soon = await repository.getExpiringSoonItems('f1', daysThreshold: 2);
      expect(soon.length, 1);
      expect(soon.first.name, 'Salmon');

      final unsynced = await repository.getUnsyncedItems('f1');
      expect(unsynced.length, 1);

      await repository.markItemSynced('soon_item');
      final afterSync = await repository.getUnsyncedItems('f1');
      expect(afterSync.length, 0);
    });

    test('deleteItem with expired item records expired history and handles file upload', () async {
      // Expired item
      final expiredDate = DateTime.now().subtract(const Duration(days: 2));
      await db.itemDao.insertItemOptimistic(
        id: 'expired_item_1',
        fridgeId: 'f1',
        name: 'Old Yogurt',
        category: 'dairy',
        zone: 'fridge',
        quantity: 1,
        unit: 'cup',
        expiryDate: expiredDate,
      );

      await repository.deleteItem('expired_item_1');
      final hist = await db.itemDao.getHistoryByFridge('f1', kind: 'expired');
      expect(hist.length, 1);
      expect(hist.first.itemName, 'Old Yogurt');

      // scanLabelWithAi throws UnimplementedError
      expect(
        () => repository.scanLabelWithAi('dummy.jpg'),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
