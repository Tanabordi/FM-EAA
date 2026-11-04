import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/app_database.dart';
import '../data/remote/api_client.dart';
import 'connectivity_watcher.dart';

/// Offline-First Synchronization Engine
/// Handles background batched sync with Oracle Cloud using Last-Write-Wins (LWW).
class SyncEngine {
  final ApiClient apiClient;
  final AppDatabaseSkeleton database;
  bool _isSyncing = false;
  StreamSubscription<void>? _connectivitySub;

  SyncEngine({required this.apiClient, required this.database});

  bool get isSyncing => _isSyncing;

  /// Synchronize a specific fridge's items with the cloud backend using Last-Write-Wins (LWW).
  ///
  /// If [force] is true, sends a sync request even if there are no local unsynced items,
  /// allowing the client to pull remote deltas/updates from family members.
  Future<bool> syncFridge(String fridgeId, {bool force = false}) async {
    if (_isSyncing) return false;
    _isSyncing = true;

    try {
      // 1. Fetch unsynced items from Drift database where is_synced == false
      final unsynced = await database.getUnsyncedItems(fridgeId);
      if (unsynced.isEmpty && !force) {
        _isSyncing = false;
        return true;
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

      // 3. Process response (200 OK)
      if (response.statusCode == 200 && response.data != null) {
        // Mark client items as synced locally
        for (final item in unsynced) {
          final id = item['id'] as String?;
          if (id != null) {
            await database.markItemSynced(id);
          }
        }

        // Apply remote deltas / server items if present
        final data = response.data;
        final serverItems = data['server_items'] ?? data['serverItems'];
        if (serverItems is List) {
          for (final raw in serverItems) {
            if (raw is Map<String, dynamic>) {
              await database.upsertRemoteItem(raw);
            } else if (raw is Map) {
              await database.upsertRemoteItem(Map<String, dynamic>.from(raw));
            }
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      // Offline or network error: keep is_synced = false for next retry
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// Synchronize all given fridges sequentially.
  Future<void> syncAllFridges(List<String> fridgeIds, {bool force = false}) async {
    for (final fridgeId in fridgeIds) {
      await syncFridge(fridgeId, force: force);
    }
  }

  /// Attach auto-sync listener when device comes back online.
  void setupAutoSync({
    required ConnectivityWatcher connectivityWatcher,
    required Future<List<String>> Function() getActiveFridgeIds,
  }) {
    _connectivitySub?.cancel();
    _connectivitySub = connectivityWatcher.onBackOnline.listen((_) async {
      final fridgeIds = await getActiveFridgeIds();
      if (fridgeIds.isNotEmpty) {
        await syncAllFridges(fridgeIds, force: true);
      }
    });
  }

  /// Dispose any active listeners.
  void dispose() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }
}

/// Riverpod provider for SyncEngine
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final client = ApiClient();
  final engine = SyncEngine(apiClient: client, database: db);
  ref.onDispose(engine.dispose);
  return engine;
});
