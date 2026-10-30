import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/app_database.dart';
import '../models/fridge_model.dart';
import '../remote/api_client.dart';

class FridgeRepository {
  final ApiClient apiClient;
  final AppDatabase database;

  FridgeRepository({
    required this.apiClient,
    required this.database,
  });

  /// Optimistic Stream: Watches all fridges directly from local SQLite (Drift)
  Stream<List<FridgeModel>> watchFridges() {
    return database.fridgeDao.watchAllFridges().map((entries) {
      return entries.map(FridgeModel.fromEntry).toList();
    });
  }

  /// Get all fridges from local SQLite
  Future<List<FridgeModel>> getFridges() async {
    final entries = await database.fridgeDao.getAllFridges();
    return entries.map(FridgeModel.fromEntry).toList();
  }

  /// Optimistic Create: Inserts into Drift SQLite with is_synced = false immediately
  Future<FridgeModel> createFridge(
    String name,
    String description, {
    String ownerId = 'user_1',
  }) async {
    final id = 'fridge_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    await database.fridgeDao.insertFridgeOptimistic(
      id: id,
      name: name,
      description: description,
      ownerId: ownerId,
      isSynced: false, // Optimistic UI: marked false until synced
    );

    return FridgeModel(
      id: id,
      name: name,
      description: description,
      ownerId: ownerId,
      isSynced: false,
      updatedAt: now,
      memberCount: 1,
    );
  }

  /// Optimistic Update: Updates Drift SQLite with is_synced = false immediately
  Future<void> updateFridge(String id, String name, String description) async {
    await database.fridgeDao.updateFridgeOptimistic(
      id: id,
      name: name,
      description: description,
      isSynced: false, // Optimistic UI
    );
  }

  /// Optimistic Delete: Removes fridge from local SQLite immediately
  Future<void> deleteFridge(String id) async {
    await database.fridgeDao.deleteFridge(id);
  }

  /// Query all unsynced fridges
  Future<List<FridgeModel>> getUnsyncedFridges() async {
    final entries = await database.fridgeDao.getUnsyncedFridges();
    return entries.map(FridgeModel.fromEntry).toList();
  }

  /// Mark fridge as synced
  Future<void> markFridgeSynced(String id) async {
    await database.fridgeDao.markFridgeSynced(id);
  }
}

final fridgeRepositoryProvider = Provider<FridgeRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return FridgeRepository(apiClient: ApiClient(), database: db);
});
