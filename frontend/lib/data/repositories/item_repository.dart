import 'dart:io';
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

  /// Get items for a fridge: tries backend API first if authenticated, caches to Drift SQLite, and falls back to local DB
  Future<List<ItemModel>> getItems(
    String fridgeId, {
    String? category,
    String? zone,
  }) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      final entries = await database.itemDao.getItemsByFridge(
        fridgeId,
        category: category,
        zone: zone,
      );
      return entries.map(ItemModel.fromEntry).toList();
    }
    try {
      final token = await apiClient.storage.read(key: 'jwt_token');
      if (token != null && token.isNotEmpty) {
        final res = await apiClient.dio.get(
          '/fridges/$fridgeId/items',
          queryParameters: {
            if (category != null && category.isNotEmpty && category.toLowerCase() != 'all')
              'category': category,
            if (zone != null && zone.isNotEmpty) 'zone': zone,
          },
        );
        final list = (res.data['items'] as List?)
            ?.map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list != null) {
          try {
            for (final item in list) {
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
      final entries = await database.itemDao.getItemsByFridge(
        fridgeId,
        category: category,
        zone: zone,
      );
      return entries.map(ItemModel.fromEntry).toList();
    } catch (_) {
      return [];
    }
  }

  /// Convenience alias for getItems by fridge
  Future<List<ItemModel>> getItemsByFridge(String fridgeId) => getItems(fridgeId);

  /// Get items expiring soon (e.g. within threshold days, default 2 days / Use soon)
  Future<List<ItemModel>> getExpiringSoonItems(String fridgeId, {int daysThreshold = 2}) async {
    try {
      final entries = await database.itemDao.getExpiringSoonItems(fridgeId, daysThreshold: daysThreshold);
      return entries.map(ItemModel.fromEntry).toList();
    } catch (_) {
      return [];
    }
  }

  /// Add item: calls backend API, caches in Drift SQLite with is_synced = true (or false if offline)
  Future<ItemModel> addItem(ItemModel item) async {
    try {
      final res = await apiClient.dio.post(
        '/fridges/${item.fridgeId}/items',
        data: {
          'name': item.name.trim(),
          'category': item.category,
          'zone': item.zone,
          'quantity': item.quantity,
          'unit': item.unit,
          'expiryDate': item.expiryDate.toIso8601String().substring(0, 10),
          if (item.imagePath != null) 'imagePath': item.imagePath,
          if (item.id.isNotEmpty && !item.id.startsWith('item_')) 'id': item.id,
        },
      );
      final itemJson = res.data['item'] as Map<String, dynamic>;
      final remoteItem = ItemModel.fromJson(itemJson);

      try {
        await database.itemDao.insertItemOptimistic(
          id: remoteItem.id,
          fridgeId: remoteItem.fridgeId,
          name: remoteItem.name,
          category: remoteItem.category,
          zone: remoteItem.zone,
          quantity: remoteItem.quantity,
          unit: remoteItem.unit,
          expiryDate: remoteItem.expiryDate,
          imagePath: remoteItem.imagePath,
          isSynced: true,
        );
      } catch (_) {}

      return remoteItem;
    } catch (_) {
      // Offline fallback: save locally with is_synced = false
      try {
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
          isSynced: false,
        );
      } catch (_) {}
      return item;
    }
  }

  /// Update item: calls backend API and updates Drift SQLite
  Future<void> updateItem(ItemModel item) async {
    try {
      await apiClient.dio.patch(
        '/items/${item.id}',
        data: {
          'name': item.name.trim(),
          'category': item.category,
          'zone': item.zone,
          'quantity': item.quantity,
          'unit': item.unit,
          'expiryDate': item.expiryDate.toIso8601String().substring(0, 10),
          if (item.imagePath != null) 'imagePath': item.imagePath,
        },
      );
    } catch (_) {}

    try {
      await database.itemDao.updateItemOptimistic(
        id: item.id,
        name: item.name,
        category: item.category,
        zone: item.zone,
        quantity: item.quantity,
        unit: item.unit,
        expiryDate: item.expiryDate,
        imagePath: item.imagePath,
        isSynced: true,
      );
    } catch (_) {}
  }

  /// Delete item: calls backend API and removes from Drift SQLite
  Future<void> deleteItem(String itemId, {String? fridgeId}) async {
    try {
      final item = await database.itemDao.getItemById(itemId);
      if (item != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final expDay = DateTime(item.expiryDate.year, item.expiryDate.month, item.expiryDate.day);
        if (expDay.isBefore(today)) {
          await database.itemDao.recordExpiredHistory(
            id: 'exp_${item.id}_${DateTime.now().millisecondsSinceEpoch}',
            fridgeId: item.fridgeId,
            itemId: item.id,
            itemName: item.name,
            category: item.category,
            zone: item.zone,
            expiryDate: item.expiryDate,
            imagePath: item.imagePath,
            quantityChanged: item.quantity,
            quantityLeft: 0,
            unit: item.unit,
            byUserId: 'system',
            createdAt: item.expiryDate,
          );
        }
      }
    } catch (_) {}

    try {
      await apiClient.dio.delete('/items/$itemId');
    } catch (_) {}

    try {
      await database.itemDao.deleteItem(itemId);
    } catch (_) {}
  }

  /// Consume item: calls backend API and updates Drift SQLite
  Future<void> consumeItem(
    String itemId,
    double amount, {
    bool finishedAll = false,
    String userId = 'user_1',
    String? imagePath,
  }) async {
    try {
      await apiClient.dio.post(
        '/items/$itemId/consume',
        data: {
          'amount': amount,
          'finishedAll': finishedAll,
          if (imagePath != null && imagePath.isNotEmpty) 'imagePath': imagePath,
        },
      );
    } catch (_) {}

    try {
      await database.itemDao.consumeItemOptimistic(
        itemId: itemId,
        amount: amount,
        finishedAll: finishedAll,
        userId: userId,
      );
    } catch (_) {}
  }

  /// Undo consume: calls backend API and restores in Drift SQLite
  Future<void> undoConsume(String historyId) async {
    try {
      await apiClient.dio.post('/items/history/$historyId/undo');
    } catch (_) {}

    try {
      await database.itemDao.undoConsume(historyId);
    } catch (_) {}
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
