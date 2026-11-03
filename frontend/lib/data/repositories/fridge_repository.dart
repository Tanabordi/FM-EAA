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

  /// Get all fridges: tries backend API first if authenticated, caches to Drift SQLite, and falls back to local DB
  Future<List<FridgeModel>> getFridges() async {
    try {
      final token = await apiClient.storage.read(key: 'jwt_token');
      if (token != null && token.isNotEmpty) {
        final res = await apiClient.dio.get('/fridges');
        final list = (res.data['fridges'] as List?)
            ?.map((e) => FridgeModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list != null) {
          // Cache to local Drift database safely
          try {
            for (final f in list) {
              await database.fridgeDao.insertFridgeOptimistic(
                id: f.id,
                name: f.name,
                description: f.description,
                ownerId: f.ownerId,
                isSynced: true,
              );
            }
          } catch (_) {}
          return list;
        }
      }
    } catch (_) {
      // Fallback to local SQLite if network is offline or unauthenticated
    }
    try {
      final entries = await database.fridgeDao.getAllFridges();
      return entries.map(FridgeModel.fromEntry).toList();
    } catch (_) {
      return [];
    }
  }

  /// Create Fridge: calls backend API, persists to Drift SQLite as synced
  Future<FridgeModel> createFridge(
    String name,
    String description, {
    String? id,
    String ownerId = 'user_1',
  }) async {
    try {
      final res = await apiClient.dio.post(
        '/fridges',
        data: {
          'name': name.trim(),
          'description': description.trim(),
          if (id != null) 'id': id,
        },
      );
      final fridgeJson = res.data['fridge'] as Map<String, dynamic>;
      final model = FridgeModel.fromJson(fridgeJson);

      try {
        await database.fridgeDao.insertFridgeOptimistic(
          id: model.id,
          name: model.name,
          description: model.description,
          ownerId: model.ownerId,
          isSynced: true,
        );
      } catch (_) {}

      return model;
    } catch (_) {
      // Offline fallback: save locally as unsynced
      final fridgeId = id ?? 'fridge_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();

      try {
        await database.fridgeDao.insertFridgeOptimistic(
          id: fridgeId,
          name: name,
          description: description,
          ownerId: ownerId,
          isSynced: false,
        );
      } catch (_) {}

      return FridgeModel(
        id: fridgeId,
        name: name,
        description: description,
        ownerId: ownerId,
        isSynced: false,
        updatedAt: now,
        memberCount: 1,
      );
    }
  }

  /// Update Fridge: calls backend API and updates local Drift SQLite
  Future<void> updateFridge(String id, String name, String description) async {
    try {
      await apiClient.dio.patch(
        '/fridges/$id',
        data: {
          'name': name.trim(),
          'description': description.trim(),
        },
      );
    } catch (_) {}

    try {
      await database.fridgeDao.updateFridgeOptimistic(
        id: id,
        name: name,
        description: description,
        isSynced: true,
      );
    } catch (_) {}
  }

  /// Delete Fridge: calls backend API and removes from local SQLite
  Future<void> deleteFridge(String id) async {
    try {
      await apiClient.dio.delete('/fridges/$id');
    } catch (_) {}

    try {
      await database.fridgeDao.deleteFridge(id);
    } catch (_) {}
  }

  /// Query all unsynced fridges
  Future<List<FridgeModel>> getUnsyncedFridges() async {
    try {
      final entries = await database.fridgeDao.getUnsyncedFridges();
      return entries.map(FridgeModel.fromEntry).toList();
    } catch (_) {
      return [];
    }
  }

  /// Mark fridge as synced
  Future<void> markFridgeSynced(String id) async {
    try {
      await database.fridgeDao.markFridgeSynced(id);
    } catch (_) {}
  }
}

final fridgeRepositoryProvider = Provider<FridgeRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return FridgeRepository(apiClient: ApiClient(), database: db);
});
