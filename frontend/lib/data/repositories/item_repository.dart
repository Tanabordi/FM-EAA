import '../models/item_model.dart';
import '../remote/api_client.dart';

// TODO(repo item): Implement item CRUD, consumption, and Gemini Vision scan
class ItemRepository {
  final ApiClient apiClient;

  ItemRepository({required this.apiClient});

  Future<List<ItemModel>> getItems(String fridgeId, {String? category, String? zone}) async {
    // TODO: Query from local Drift table where fridgeId == fridgeId
    return [];
  }

  Future<ItemModel> addItem(ItemModel item) async {
    // TODO: Insert into Drift with is_synced = false
    throw UnimplementedError();
  }

  Future<void> updateItem(ItemModel item) async {
    // TODO: Update Drift with is_synced = false
  }

  Future<void> deleteItem(String itemId) async {
    // TODO: Delete from Drift
  }

  Future<void> consumeItem(String itemId, double amount, {bool finishedAll = false}) async {
    // TODO: Update item quantity or remove, insert history record into Drift
  }

  Future<void> undoConsume(String historyId) async {
    // TODO: Restore item and delete history record
  }

  Future<Map<String, dynamic>> scanLabelWithAi(String imagePath) async {
    // TODO: Upload image to POST /api/ai/scan-label and return parsed fields
    throw UnimplementedError();
  }
}

