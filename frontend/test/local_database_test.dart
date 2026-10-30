import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/local/app_database.dart';
import 'package:fm_eaa/data/models/item_model.dart';
import 'package:fm_eaa/data/remote/api_client.dart';
import 'package:fm_eaa/data/repositories/fridge_repository.dart';
import 'package:fm_eaa/data/repositories/item_repository.dart';

void main() {
  late AppDatabase db;
  late FridgeDao fridgeDao;
  late ItemDao itemDao;

  setUp(() {
    // Initialize an in-memory SQLite database instance for isolated testing
    db = AppDatabase(NativeDatabase.memory());
    fridgeDao = db.fridgeDao;
    itemDao = db.itemDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('1. FridgesTable & FridgeDao Tests', () {
    test('insertFridgeOptimistic saves to SQLite with is_synced = false', () async {
      await fridgeDao.insertFridgeOptimistic(
        id: 'fridge_test_1',
        name: 'Kitchen Fridge',
        description: 'First floor main kitchen',
        ownerId: 'user_123',
        isSynced: false, // Optimistic UI
      );

      final fridge = await fridgeDao.getFridgeById('fridge_test_1');
      expect(fridge, isNotNull);
      expect(fridge!.name, 'Kitchen Fridge');
      expect(fridge.description, 'First floor main kitchen');
      expect(fridge.ownerId, 'user_123');
      expect(fridge.isSynced, false, reason: 'Optimistic UI must store is_synced = false initially');
    });

    test('updateFridgeOptimistic modifies data and sets is_synced = false', () async {
      await fridgeDao.insertFridgeOptimistic(
        id: 'fridge_test_2',
        name: 'Old Name',
        ownerId: 'user_123',
        isSynced: true,
      );

      final updated = await fridgeDao.updateFridgeOptimistic(
        id: 'fridge_test_2',
        name: 'New Kitchen Name',
        description: 'Updated description',
        isSynced: false, // Optimistic local edit
      );

      expect(updated, true);
      final fridge = await fridgeDao.getFridgeById('fridge_test_2');
      expect(fridge!.name, 'New Kitchen Name');
      expect(fridge.description, 'Updated description');
      expect(fridge.isSynced, false);
    });

    test('getUnsyncedFridges and markFridgeSynced', () async {
      await fridgeDao.insertFridgeOptimistic(
        id: 'fridge_unsynced',
        name: 'Unsynced Fridge',
        ownerId: 'user_1',
        isSynced: false,
      );
      await fridgeDao.insertFridgeOptimistic(
        id: 'fridge_synced',
        name: 'Synced Fridge',
        ownerId: 'user_1',
        isSynced: true,
      );

      var unsynced = await fridgeDao.getUnsyncedFridges();
      expect(unsynced.length, 1);
      expect(unsynced.first.id, 'fridge_unsynced');

      // Now sync it
      await fridgeDao.markFridgeSynced('fridge_unsynced');
      unsynced = await fridgeDao.getUnsyncedFridges();
      expect(unsynced.isEmpty, true, reason: 'After markFridgeSynced, list should be empty');
    });

    test('watchAllFridges emits reactive updates when data changes', () async {
      final initial = await fridgeDao.watchAllFridges().first;
      expect(initial, isEmpty);

      // Trigger change
      await fridgeDao.insertFridgeOptimistic(
        id: 'fridge_stream_1',
        name: 'Stream Fridge',
        ownerId: 'user_1',
      );

      final updated = await fridgeDao.watchAllFridges().first;
      expect(updated.length, 1);
      expect(updated.first.name, 'Stream Fridge');
    });

    test('deleteFridge removes fridge from SQLite', () async {
      await fridgeDao.insertFridgeOptimistic(
        id: 'fridge_to_delete',
        name: 'To Delete',
        ownerId: 'user_1',
      );

      await fridgeDao.deleteFridge('fridge_to_delete');
      final fridge = await fridgeDao.getFridgeById('fridge_to_delete');
      expect(fridge, isNull);
    });
  });

  group('2. ItemsTable & ItemDao Tests', () {
    test('insertItemOptimistic saves item to SQLite with is_synced = false', () async {
      final expiry = DateTime.now().add(const Duration(days: 7));
      await itemDao.insertItemOptimistic(
        id: 'item_1',
        fridgeId: 'fridge_kitchen',
        name: 'Fresh Milk',
        category: 'beverages',
        zone: 'fridge',
        quantity: 2.0,
        unit: 'bottles',
        expiryDate: expiry,
        isSynced: false,
      );

      final item = await itemDao.getItemById('item_1');
      expect(item, isNotNull);
      expect(item!.name, 'Fresh Milk');
      expect(item.category, 'beverages');
      expect(item.zone, 'fridge');
      expect(item.quantity, 2.0);
      expect(item.unit, 'bottles');
      expect(item.isSynced, false, reason: 'Optimistic UI must set is_synced = false');
    });

    test('watchItemsByFridge filters by category, zone, and search query', () async {
      final now = DateTime.now();

      await itemDao.insertItemOptimistic(
        id: 'item_beef',
        fridgeId: 'fridge_1',
        name: 'Beef Steak',
        category: 'proteins',
        zone: 'freezer',
        quantity: 1,
        unit: 'kg',
        expiryDate: now.add(const Duration(days: 30)),
      );
      await itemDao.insertItemOptimistic(
        id: 'item_apple',
        fridgeId: 'fridge_1',
        name: 'Green Apple',
        category: 'veggies',
        zone: 'fridge',
        quantity: 5,
        unit: 'pieces',
        expiryDate: now.add(const Duration(days: 5)),
      );
      await itemDao.insertItemOptimistic(
        id: 'item_cabbage',
        fridgeId: 'fridge_1',
        name: 'Cabbage',
        category: 'veggies',
        zone: 'fridge',
        quantity: 1,
        unit: 'head',
        expiryDate: now.add(const Duration(days: 2)),
      );

      // Filter by zone = freezer
      final freezerItems = await itemDao.getItemsByFridge('fridge_1', zone: 'freezer');
      expect(freezerItems.length, 1);
      expect(freezerItems.first.name, 'Beef Steak');

      // Filter by category = veggies
      final veggieItems = await itemDao.getItemsByFridge('fridge_1', category: 'veggies');
      expect(veggieItems.length, 2);

      // Search keyword
      final searchResults = await itemDao.watchItemsByFridge('fridge_1', searchQuery: 'apple').first;
      expect(searchResults.length, 1);
      expect(searchResults.first.name, 'Green Apple');
    });

    test('getExpiringSoonItems finds items within threshold days', () async {
      final now = DateTime.now();
      await itemDao.insertItemOptimistic(
        id: 'item_soon',
        fridgeId: 'fridge_1',
        name: 'Yogurt',
        category: 'beverages',
        zone: 'fridge',
        quantity: 1,
        unit: 'cup',
        expiryDate: now.add(const Duration(days: 1)),
      );
      await itemDao.insertItemOptimistic(
        id: 'item_far',
        fridgeId: 'fridge_1',
        name: 'Frozen Peas',
        category: 'veggies',
        zone: 'freezer',
        quantity: 1,
        unit: 'bag',
        expiryDate: now.add(const Duration(days: 90)),
      );

      final expiring = await itemDao.getExpiringSoonItems('fridge_1', daysThreshold: 2);
      expect(expiring.length, 1);
      expect(expiring.first.name, 'Yogurt');
    });
  });

  group('3. Consume Flow & History Audit Tests', () {
    test('consumeItemOptimistic partial deduction records to ItemHistory', () async {
      await itemDao.insertItemOptimistic(
        id: 'item_eggs',
        fridgeId: 'fridge_1',
        name: 'Organic Eggs',
        category: 'proteins',
        zone: 'fridge',
        quantity: 10.0,
        unit: 'eggs',
        expiryDate: DateTime.now().add(const Duration(days: 10)),
      );

      // Consume 4 eggs
      await itemDao.consumeItemOptimistic(
        itemId: 'item_eggs',
        amount: 4.0,
        userId: 'user_1',
      );

      // Check item in ItemsTable
      final item = await itemDao.getItemById('item_eggs');
      expect(item, isNotNull);
      expect(item!.quantity, 6.0);
      expect(item.isSynced, false, reason: 'Deduction must mark is_synced = false');

      // Check audit record in ItemHistory table
      final historyList = await (db.select(db.itemHistory)).get();
      expect(historyList.length, 1);
      final entry = historyList.first;
      expect(entry.itemName, 'Organic Eggs');
      expect(entry.quantityChanged, 4.0);
      expect(entry.quantityLeft, 6.0);
      expect(entry.kind, 'consumed');
    });

    test('consumeItemOptimistic finishedAll removes item from ItemsTable', () async {
      await itemDao.insertItemOptimistic(
        id: 'item_cake',
        fridgeId: 'fridge_1',
        name: 'Matcha Cake',
        category: 'meals',
        zone: 'fridge',
        quantity: 1.0,
        unit: 'box',
        expiryDate: DateTime.now().add(const Duration(days: 1)),
      );

      // Consume completely
      await itemDao.consumeItemOptimistic(
        itemId: 'item_cake',
        amount: 1.0,
        finishedAll: true,
        userId: 'user_1',
      );

      // Verify item deleted from active items table
      final item = await itemDao.getItemById('item_cake');
      expect(item, isNull);

      // Verify history recorded
      final historyList = await (db.select(db.itemHistory)).get();
      expect(historyList.any((h) => h.itemName == 'Matcha Cake' && h.quantityLeft == 0.0), true);
    });

    test('undoConsume restores item quantity and deletes history entry', () async {
      await itemDao.insertItemOptimistic(
        id: 'item_bread',
        fridgeId: 'fridge_1',
        name: 'Whole Wheat Bread',
        category: 'meals',
        zone: 'fridge',
        quantity: 5.0,
        unit: 'slices',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
      );

      await itemDao.consumeItemOptimistic(
        itemId: 'item_bread',
        amount: 2.0,
        userId: 'user_1',
      );

      final historyList = await (db.select(db.itemHistory)).get();
      expect(historyList.length, 1);
      final historyId = historyList.first.id;

      // Now undo
      await itemDao.undoConsume(historyId);

      // Check item restored to 5.0
      final item = await itemDao.getItemById('item_bread');
      expect(item!.quantity, 5.0);

      // History entry removed
      final remainingHist = await (db.select(db.itemHistory)).get();
      expect(remainingHist.isEmpty, true);
    });
  });

  group('4. Repositories & Optimistic UI Integration Tests', () {
    test('FridgeRepository creates fridge with is_synced = false immediately', () async {
      final repo = FridgeRepository(apiClient: ApiClient(), database: db);

      final fridge = await repo.createFridge('Studio Mini Fridge', 'Basement corner');
      expect(fridge.name, 'Studio Mini Fridge');
      expect(fridge.isSynced, false);

      // Verify persistent in SQLite
      final inDb = await db.fridgeDao.getFridgeById(fridge.id);
      expect(inDb, isNotNull);
      expect(inDb!.isSynced, false);
    });

    test('ItemRepository adds item with is_synced = false immediately', () async {
      final repo = ItemRepository(apiClient: ApiClient(), database: db);

      final itemModel = ItemModel(
        id: 'item_repo_1',
        fridgeId: 'fridge_1',
        name: 'Orange Juice',
        category: 'beverages',
        zone: 'fridge',
        quantity: 1.0,
        unit: 'carton',
        expiryDate: DateTime.now().add(const Duration(days: 4)),
        updatedAt: DateTime.now(),
      );

      await repo.addItem(itemModel);

      // Verify in SQLite
      final inDb = await db.itemDao.getItemById('item_repo_1');
      expect(inDb, isNotNull);
      expect(inDb!.isSynced, false);
      expect(inDb.name, 'Orange Juice');
    });

    test('AppDatabase implements AppDatabaseSkeleton for SyncEngine compatibility', () async {
      await itemDao.insertItemOptimistic(
        id: 'unsynced_1',
        fridgeId: 'fridge_sync',
        name: 'Milk',
        category: 'beverages',
        zone: 'fridge',
        quantity: 1,
        unit: 'bottle',
        expiryDate: DateTime.now().add(const Duration(days: 2)),
        isSynced: false,
      );

      final unsynced = await db.getUnsyncedItems('fridge_sync');
      expect(unsynced.length, 1);
      expect(unsynced.first['id'], 'unsynced_1');
      expect(unsynced.first['is_synced'], 0);

      // Mark synced
      await db.markItemSynced('unsynced_1');
      final afterSync = await db.getUnsyncedItems('fridge_sync');
      expect(afterSync.isEmpty, true);
    });
  });
}
