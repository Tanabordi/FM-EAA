import '../data/local/app_database.dart';
import '../data/remote/api_client.dart';

/// Offline-First Synchronization Engine
/// Handles background batched sync with Oracle Cloud using Last-Write-Wins (LWW).
class SyncEngine {
  final ApiClient apiClient;
  final AppDatabaseSkeleton database;
  bool _isSyncing = false;

  SyncEngine({required this.apiClient, required this.database});

  bool get isSyncing => _isSyncing;

  Future<void> syncFridge(String fridgeId) async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // 1. Fetch unsynced items from Drift database where is_synced == false
      final unsynced = await database.getUnsyncedItems(fridgeId);
      if (unsynced.isEmpty) {
        _isSyncing = false;
        return;
      }

      // 2. Post batched sync request to backend POST /api/sync
      final response = await apiClient.dio.post(
        '/sync',
        data: {
          'fridge_id': fridgeId,
          'client_timestamp': DateTime.now().toIso8601String(),
          'items': unsynced,
        },
      );

      // 3. Mark items as synced locally if successful (200 OK)
      if (response.statusCode == 200) {
        for (final item in unsynced) {
          final id = item['id'] as String;
          await database.markItemSynced(id);
        }
      }
    } catch (e) {
      // Offline or server not ready, keep is_synced = false for next retry
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> syncAllFridges(List<String> fridgeIds) async {
    for (final fridgeId in fridgeIds) {
      await syncFridge(fridgeId);
    }
  }
}

