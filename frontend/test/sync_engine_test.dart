import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/local/app_database.dart';
import 'package:fm_eaa/data/remote/api_client.dart';
import 'package:fm_eaa/sync/connectivity_watcher.dart';
import 'package:fm_eaa/sync/sync_engine.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FakeAppDatabase extends AppDatabaseSkeleton {
  final List<Map<String, dynamic>> unsyncedItems;
  final List<String> markedSyncedIds = [];
  final List<Map<String, dynamic>> upsertedRemoteItems = [];

  FakeAppDatabase({List<Map<String, dynamic>>? unsynced})
      : unsyncedItems = unsynced ?? [];

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedItems(String fridgeId) async {
    return unsyncedItems;
  }

  @override
  Future<void> markItemSynced(String itemId) async {
    markedSyncedIds.add(itemId);
  }

  @override
  Future<void> upsertRemoteItem(Map<String, dynamic> item) async {
    upsertedRemoteItems.add(item);
  }
}

void main() {
  group('SyncEngine Unit Tests', () {
    test('Initializes correctly and isSyncing defaults to false', () {
      final db = FakeAppDatabase();
      final client = ApiClient();
      final engine = SyncEngine(apiClient: client, database: db);

      expect(engine.isSyncing, false);
    });

    test('syncFridge completes gracefully when there are no unsynced items', () async {
      final db = FakeAppDatabase(unsynced: []);
      final client = ApiClient();
      final engine = SyncEngine(apiClient: client, database: db);

      final result = await engine.syncFridge('fridge_kitchen');
      expect(result, true);
      expect(engine.isSyncing, false);
      expect(db.markedSyncedIds, isEmpty);
    });

    test('syncFridge sends batched items and marks them as synced on 200 OK', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/sync')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'success': true,
                    'server_items': [
                      {
                        'id': 'remote_item_1',
                        'fridge_id': 'fridge_1',
                        'name': 'Remote Salmon',
                        'category': 'proteins',
                        'zone': 'fridge',
                        'quantity': 2.0,
                        'unit': 'pieces',
                        'expiry_date': '2026-11-15',
                        'updated_at': '2026-11-04T12:00:00.000Z',
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

      final db = FakeAppDatabase(
        unsynced: [
          {
            'id': 'local_item_1',
            'fridge_id': 'fridge_1',
            'name': 'Local Chicken',
            'category': 'proteins',
            'zone': 'fridge',
            'quantity': 1.0,
            'unit': 'kg',
            'expiry_date': '2026-11-08',
            'updated_at': '2026-11-04T10:00:00.000Z',
          }
        ],
      );

      final client = ApiClient(customDio: dio);
      final engine = SyncEngine(apiClient: client, database: db);

      final success = await engine.syncFridge('fridge_1');
      expect(success, true);
      expect(engine.isSyncing, false);
      // Verify local item was marked as synced
      expect(db.markedSyncedIds, contains('local_item_1'));
      // Verify remote item was upserted into local DB
      expect(db.upsertedRemoteItems, hasLength(1));
      expect(db.upsertedRemoteItems.first['name'], 'Remote Salmon');
    });

    test('syncFridge handles network errors gracefully without crashing', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                error: 'Network unreachable',
              ),
            );
          },
        ),
      );

      final db = FakeAppDatabase(
        unsynced: [
          {'id': 'item_err', 'name': 'Fail Item'}
        ],
      );

      final client = ApiClient(customDio: dio);
      final engine = SyncEngine(apiClient: client, database: db);

      final success = await engine.syncFridge('fridge_1');
      expect(success, false);
      expect(engine.isSyncing, false);
      expect(db.markedSyncedIds, isEmpty);
    });

    test('syncAllFridges synchronizes multiple fridges sequentially', () async {
      final syncedFridges = <String>[];
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final data = options.data as Map<String, dynamic>;
            syncedFridges.add(data['fridge_id'] as String);
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true, 'server_items': []},
              ),
            );
          },
        ),
      );

      final db = FakeAppDatabase(
        unsynced: [
          {'id': 'item_1'}
        ],
      );

      final client = ApiClient(customDio: dio);
      final engine = SyncEngine(apiClient: client, database: db);

      await engine.syncAllFridges(['fridge_1', 'fridge_2']);
      expect(syncedFridges, containsAll(['fridge_1', 'fridge_2']));
    });

    test('setupAutoSync automatically syncs when connectivity is restored', () async {
      final controller = StreamController<List<ConnectivityResult>>();
      final watcher = ConnectivityWatcher(
        check: () async => [ConnectivityResult.none],
        changes: () => controller.stream,
      );

      final completer = Completer<void>();
      final dio = Dio();
      var syncCallCount = 0;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            syncCallCount++;
            if (!completer.isCompleted) completer.complete();
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true, 'server_items': []},
              ),
            );
          },
        ),
      );

      final db = FakeAppDatabase();
      final client = ApiClient(customDio: dio);
      final engine = SyncEngine(apiClient: client, database: db);

      engine.setupAutoSync(
        connectivityWatcher: watcher,
        getActiveFridgeIds: () async => ['fridge_auto_1'],
      );

      // Yield microtask so watcher initializes checkOnline()
      await Future<void>.delayed(Duration.zero);

      // Trigger transition from offline to online
      controller.add([ConnectivityResult.wifi]);
      await completer.future.timeout(const Duration(seconds: 3));

      expect(syncCallCount, 1);

      engine.dispose();
      await controller.close();
    });
  });
}
