import 'package:drift/drift.dart';
import '../local/app_database.dart';
import '../models/history_model.dart';
import '../remote/api_client.dart';

class HistoryRepository {
  final ApiClient apiClient;
  final AppDatabase database;

  HistoryRepository({
    required this.apiClient,
    required this.database,
  });

  /// Optimistic Stream: Watches history audit records from Drift SQLite
  Stream<List<HistoryModel>> watchHistory(String fridgeId, {String? kind}) {
    return database.itemDao
        .watchHistoryByFridge(fridgeId, kind: kind)
        .map((entries) => entries.map(HistoryModel.fromEntry).toList());
  }

  /// Get history records for a fridge from Drift SQLite
  Future<List<HistoryModel>> getHistory(String fridgeId, [String? kind]) async {
    final entries = await database.itemDao.getHistoryByFridge(fridgeId, kind: kind);
    return entries.map(HistoryModel.fromEntry).toList();
  }

  /// Optimistic Delete: Deletes a single history record immediately
  Future<void> deleteHistoryItem(String historyId) async {
    await database.itemDao.deleteHistoryItem(historyId);
  }

  /// Clear history for a fridge (optionally filtered by kind: consumed or expired)
  Future<void> clearHistory(String fridgeId, [String? kind]) async {
    await database.itemDao.clearHistoryByFridge(fridgeId, kind: kind);
  }

  /// Clean old consumed history (auto-deleted after 30 days)
  Future<void> cleanOldConsumedHistory() async {
    await database.cleanOldConsumedHistory();
  }

  /// Record an expired item into history audit log
  Future<void> recordExpiredItem({
    required String fridgeId,
    String? itemId,
    required String itemName,
    String? category,
    String? zone,
    DateTime? expiryDate,
    String? imagePath,
    required double quantity,
    String unit = 'pieces',
    String byUsername = 'system',
    DateTime? createdAt,
  }) async {
    await database.itemDao.recordExpiredHistory(
      id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
      fridgeId: fridgeId,
      itemId: itemId,
      itemName: itemName,
      category: category,
      zone: zone,
      expiryDate: expiryDate,
      imagePath: imagePath,
      quantityChanged: quantity,
      quantityLeft: 0.0,
      unit: unit,
      byUserId: byUsername,
      createdAt: createdAt,
    );
  }

  /// Seed initial demo history records matching Figma prototype if empty
  Future<void> seedInitialDataIfEmpty(String fridgeId) async {
    final existing = await database.itemDao.getHistoryByFridge(fridgeId);
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeekDate = today.subtract(const Duration(days: 3));

    // Consumed #1: Whole milk (Today 08:30 AM)
    await database.itemDao.into(database.itemDao.itemHistory).insert(
      ItemHistoryCompanion.insert(
        id: 'hist_demo_milk_consumed',
        fridgeId: fridgeId,
        itemId: const Value('item_milk'),
        itemName: 'Whole milk',
        category: const Value('beverages'),
        zone: const Value('fridge'),
        imagePath: const Value('https://images.unsplash.com/photo-1550583724-b2692b85b150?w=150'),
        kind: 'consumed',
        quantityChanged: 1,
        quantityLeft: const Value(1),
        unit: const Value('bottle'),
        byUserId: 'alex.lee',
        createdAt: Value(DateTime(today.year, today.month, today.day, 8, 30)),
      ),
    );

    // Consumed #2: Avocados (Today 11:15 AM)
    await database.itemDao.into(database.itemDao.itemHistory).insert(
      ItemHistoryCompanion.insert(
        id: 'hist_demo_avocados_consumed',
        fridgeId: fridgeId,
        itemId: const Value('item_avocados'),
        itemName: 'Avocados',
        category: const Value('veggies'),
        zone: const Value('fridge'),
        imagePath: const Value('https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=150'),
        kind: 'consumed',
        quantityChanged: 1,
        quantityLeft: const Value(1),
        unit: const Value('piece'),
        byUserId: 'sarah',
        createdAt: Value(DateTime(today.year, today.month, today.day, 11, 15)),
      ),
    );

    // Consumed #3: Strawberries (Yesterday 04:30 PM)
    await database.itemDao.into(database.itemDao.itemHistory).insert(
      ItemHistoryCompanion.insert(
        id: 'hist_demo_strawberries_consumed',
        fridgeId: fridgeId,
        itemId: const Value('item_strawberries'),
        itemName: 'Strawberries',
        category: const Value('veggies'),
        zone: const Value('fridge'),
        imagePath: const Value('https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=150'),
        kind: 'consumed',
        quantityChanged: 1,
        quantityLeft: const Value(0),
        unit: const Value('punnet'),
        byUserId: 'alex.lee',
        createdAt: Value(DateTime(yesterday.year, yesterday.month, yesterday.day, 16, 30)),
      ),
    );

    // Expired #1: Baby spinach (Today 07:00 AM)
    await database.itemDao.into(database.itemDao.itemHistory).insert(
      ItemHistoryCompanion.insert(
        id: 'hist_demo_spinach_expired',
        fridgeId: fridgeId,
        itemId: const Value('item_spinach'),
        itemName: 'Baby spinach',
        category: const Value('veggies'),
        zone: const Value('fridge'),
        imagePath: const Value('https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=150'),
        kind: 'expired',
        quantityChanged: 1,
        quantityLeft: const Value(0),
        unit: const Value('bag'),
        byUserId: 'sarah',
        createdAt: Value(DateTime(today.year, today.month, today.day, 7, 0)),
      ),
    );

    // Expired #2: Whole milk (This Week / 3 days ago 02:15 PM)
    await database.itemDao.into(database.itemDao.itemHistory).insert(
      ItemHistoryCompanion.insert(
        id: 'hist_demo_milk_expired',
        fridgeId: fridgeId,
        itemId: const Value('item_milk'),
        itemName: 'Whole milk',
        category: const Value('beverages'),
        zone: const Value('fridge'),
        imagePath: const Value('https://images.unsplash.com/photo-1550583724-b2692b85b150?w=150'),
        kind: 'expired',
        quantityChanged: 1,
        quantityLeft: const Value(0),
        unit: const Value('bottle'),
        byUserId: 'alex.lee',
        createdAt: Value(DateTime(thisWeekDate.year, thisWeekDate.month, thisWeekDate.day, 14, 15)),
      ),
    );
  }
}
