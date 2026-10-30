import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/local/app_database.dart';
import 'package:fm_eaa/data/remote/api_client.dart';
import 'package:fm_eaa/sync/sync_engine.dart';

void main() {
  group('SyncEngine Unit Tests', () {
    test('Initializes correctly and isSyncing defaults to false', () {
      final db = AppDatabaseSkeleton();
      final client = ApiClient();
      final engine = SyncEngine(apiClient: client, database: db);

      expect(engine.isSyncing, false);
    });

    test('syncFridge completes gracefully when there are no unsynced items', () async {
      final db = AppDatabaseSkeleton();
      final client = ApiClient();
      final engine = SyncEngine(apiClient: client, database: db);

      await engine.syncFridge('fridge_kitchen');
      expect(engine.isSyncing, false);
    });
  });
}

