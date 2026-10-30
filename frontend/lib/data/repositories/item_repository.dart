import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/app_database.dart';
import '../models/item_model.dart';
import '../remote/api_client.dart';

class ItemRepository {
  final ApiClient apiClient;
  final AppDatabase database;

  ItemRepository({
    required this.apiClient,
    required this.database,
  });

  /// Optimistic Stream: Watches items for a fridge from Drift SQLite
  Stream<List<ItemModel>> watchItems(
    String fridgeId, {
    String? category,
    String? zone,
    String? searchQuery,
  }) {
    return database.itemDao
        .watchItemsByFridge(
          fridgeId,
          category: category,
          zone: zone,
          searchQuery: searchQuery,
        )
        .map((entries) => entries.map(ItemModel.fromEntry).toList());
  }

  /// Get items for a fridge from Drift SQLite
  Future<List<ItemModel>> getItems(
    String fridgeId, {
    String? category,
    String? zone,
  }) async {
    final entries = await database.itemDao.getItemsByFridge(
      fridgeId,
      category: category,
      zone: zone,
    );
    return entries.map(ItemModel.fromEntry).toList();
  }

  /// Optimistic Add: Inserts into Drift SQLite with is_synced = false immediately
  Future<ItemModel> addItem(ItemModel item) async {
    await database.itemDao.insertItemOptimistic(
      id: item.id,
      fridgeId: item.fridgeId,
      name: item.name,
      category: item.category,
      zone: item.zone,
      quantity: item.quantity,
      unit: item.unit,
      expiryDate: item.expiryDate,
      imagePath: item.imagePath,
      isSynced: false, // Optimistic UI: marked false
    );
    return item;
  }

  /// Optimistic Update: Updates Drift SQLite with is_synced = false immediately
  Future<void> updateItem(ItemModel item) async {
    await database.itemDao.updateItemOptimistic(
      id: item.id,
      name: item.name,
      category: item.category,
      zone: item.zone,
      quantity: item.quantity,
      unit: item.unit,
      expiryDate: item.expiryDate,
      imagePath: item.imagePath,
      isSynced: false, // Optimistic UI
    );
  }

  /// Optimistic Delete: Deletes item from Drift SQLite immediately
  Future<void> deleteItem(String itemId) async {
    await database.itemDao.deleteItem(itemId);
  }

  /// Optimistic Consume: Deducts quantity or deletes from Drift SQLite, records history with is_synced = false
  Future<void> consumeItem(
    String itemId,
    double amount, {
    bool finishedAll = false,
    String userId = 'user_1',
  }) async {
    await database.itemDao.consumeItemOptimistic(
      itemId: itemId,
      amount: amount,
      finishedAll: finishedAll,
      userId: userId,
    );
  }

  /// Undo consume: Restores item quantity and deletes history record
  Future<void> undoConsume(String historyId) async {
    await database.itemDao.undoConsume(historyId);
  }

  /// Get unsynced items
  Future<List<ItemModel>> getUnsyncedItems(String fridgeId) async {
    final entries = await database.itemDao.getUnsyncedItems(fridgeId);
    return entries.map(ItemModel.fromEntry).toList();
  }

  /// Mark item as synced
  Future<void> markItemSynced(String id) async {
    await database.itemDao.markItemSynced(id);
  }

  /// AI Vision Scan Label (forwarded to API)
  Future<Map<String, dynamic>> scanLabelWithAi(String imagePath) async {
    throw UnimplementedError('AI scan label requires backend endpoint');
  }
}

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ItemRepository(apiClient: ApiClient(), database: db);
});
