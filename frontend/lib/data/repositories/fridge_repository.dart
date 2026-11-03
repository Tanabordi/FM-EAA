import '../models/fridge_model.dart';
import '../remote/api_client.dart';

// TODO(repo fridge): Implement CRUD and offline-first caching for fridges
class FridgeRepository {
  final ApiClient apiClient;

  FridgeRepository({required this.apiClient});

  Future<List<FridgeModel>> getFridges() async {
    // TODO: Read from Drift local SQLite, trigger background sync
    return [];
  }

  Future<FridgeModel> createFridge(String name, String description) async {
    // TODO: Insert into Drift with is_synced = false, queue sync
    throw UnimplementedError();
  }

  Future<void> updateFridge(String id, String name, String description) async {
    // TODO: Update Drift with is_synced = false
  }

  Future<void> deleteFridge(String id) async {
    // TODO: Delete from Drift, mark deleted for server sync
  }
}

