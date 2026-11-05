import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/local/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('FridgeDao Unit Tests', () {
    test('full optimistic fridge lifecycle', () async {
      final dao = db.fridgeDao;

      // Insert fridges
      await dao.insertFridgeOptimistic(
        id: 'fridge_1',
        name: 'Home Fridge',
        description: 'Kitchen primary',
        ownerId: 'user_1',
      );
      await dao.insertFridgeOptimistic(
        id: 'fridge_2',
        name: 'Office Fridge',
        description: 'Work drinks',
        ownerId: 'user_1',
      );

      // Query all
      final allFridges = await dao.getAllFridges();
      expect(allFridges.length, 2);

      // Query by ID
      final fridge1 = await dao.getFridgeById('fridge_1');
      expect(fridge1?.name, 'Home Fridge');
      expect(fridge1?.isSynced, isFalse);

      // Streams
      expect(dao.watchAllFridges(), emits(hasLength(2)));
      expect(dao.watchFridgeById('fridge_1'), emits(isNotNull));

      // Update
      final updated = await dao.updateFridgeOptimistic(
        id: 'fridge_1',
        name: 'Updated Home Fridge',
        description: 'New desc',
      );
      expect(updated, isTrue);

      final rechecked = await dao.getFridgeById('fridge_1');
      expect(rechecked?.name, 'Updated Home Fridge');

      // Unsynced fridges
      final unsynced = await dao.getUnsyncedFridges();
      expect(unsynced.length, 2);

      // Mark synced
      await dao.markFridgeSynced('fridge_1');
      final unsyncedAfter = await dao.getUnsyncedFridges();
      expect(unsyncedAfter.length, 1);
      expect(unsyncedAfter.first.id, 'fridge_2');

      // Upsert from remote
      await dao.upsertFridgesFromRemote([
        FridgeEntry(
          id: 'fridge_remote_1',
          name: 'Remote Fridge',
          description: 'Cloud sync',
          ownerId: 'user_2',
          isSynced: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);
      final withRemote = await dao.getAllFridges();
      expect(withRemote.length, 3);

      // Delete
      await dao.deleteFridge('fridge_2');
      final finalFridges = await dao.getAllFridges();
      expect(finalFridges.length, 2);
    });
  });

  group('ItemDao Unit Tests', () {
    test('full optimistic item lifecycle and queries', () async {
      final dao = db.itemDao;
      final now = DateTime.now();

      // Insert items
      await dao.insertItemOptimistic(
        id: 'item_1',
        fridgeId: 'fridge_a',
        name: 'Fresh Milk',
        category: 'beverages',
        zone: 'fridge',
        quantity: 2.0,
        unit: 'bottle',
        expiryDate: now.add(const Duration(days: 1)),
      );

      await dao.insertItemOptimistic(
        id: 'item_2',
        fridgeId: 'fridge_a',
        name: 'Frozen Berries',
        category: 'veggies',
        zone: 'freezer',
        quantity: 500.0,
        unit: 'g',
        expiryDate: now.add(const Duration(days: 60)),
      );

      await dao.insertItemOptimistic(
        id: 'item_3',
        fridgeId: 'fridge_b',
        name: 'Cheddar Cheese',
        category: 'proteins',
        zone: 'fridge',
        quantity: 1.0,
        unit: 'pack',
        expiryDate: now.subtract(const Duration(days: 2)), // Expired
      );

      // Get items by fridge
      final fridgeAItems = await dao.getItemsByFridge('fridge_a');
      expect(fridgeAItems.length, 2);

      final fridgeAWithFilter = await dao.getItemsByFridge(
        'fridge_a',
        category: 'beverages',
        zone: 'fridge',
      );
      expect(fridgeAWithFilter.length, 1);
      expect(fridgeAWithFilter.first.name, 'Fresh Milk');

      // Streams
      expect(dao.watchItemsByFridge('fridge_a'), emits(hasLength(2)));
      expect(dao.watchItemById('item_1'), emits(isNotNull));

      // Active count
      final countA = await dao.getActiveItemCount('fridge_a');
      expect(countA, 2);

      // Update item
      final updated = await dao.updateItemOptimistic(
        id: 'item_1',
        name: 'Almond Milk',
        category: 'beverages',
        zone: 'fridge',
        quantity: 1.5,
        unit: 'bottle',
        expiryDate: now.add(const Duration(days: 5)),
      );
      expect(updated, isTrue);

      final item1 = await dao.getItemById('item_1');
      expect(item1?.name, 'Almond Milk');
      expect(item1?.quantity, 1.5);

      // Expiring soon items (threshold = 6 days)
      final expiring = await dao.getExpiringSoonItems('fridge_a', daysThreshold: 6);
      expect(expiring.length, 1);
      expect(expiring.first.id, 'item_1');

      // Soft delete
      await dao.softDeleteItem('item_2');
      final countAfterSoft = await dao.getActiveItemCount('fridge_a');
      expect(countAfterSoft, 1);

      // Permanent delete
      await dao.deleteItem('item_2');
      final item2Recheck = await dao.getItemById('item_2');
      expect(item2Recheck, isNull);

      // Unsynced items
      final unsynced = await dao.getUnsyncedItems('fridge_a');
      expect(unsynced.length, 1);

      final allUnsynced = await dao.getAllUnsyncedItems();
      expect(allUnsynced.length, 2);

      await dao.markItemSynced('item_1');
      final unsyncedAfter = await dao.getUnsyncedItems('fridge_a');
      expect(unsyncedAfter.isEmpty, isTrue);

      // Upsert from remote
      await dao.upsertItemsFromRemote([
        ItemEntry(
          id: 'item_remote_1',
          fridgeId: 'fridge_a',
          name: 'Remote Tofu',
          category: 'proteins',
          zone: 'fridge',
          quantity: 2.0,
          unit: 'pack',
          expiryDate: now.add(const Duration(days: 7)),
          isSynced: true,
          isDeleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);
      final countWithRemote = await dao.getActiveItemCount('fridge_a');
      expect(countWithRemote, 2);
    });

    test('item consumption, undo consume, and audit history flow', () async {
      final dao = db.itemDao;
      final now = DateTime.now();

      await dao.insertItemOptimistic(
        id: 'item_c1',
        fridgeId: 'fridge_c',
        name: 'Eggs',
        category: 'proteins',
        zone: 'fridge',
        quantity: 10.0,
        unit: 'pieces',
        expiryDate: now.add(const Duration(days: 14)),
      );

      // Partial consume: 4 eggs
      await dao.consumeItemOptimistic(
        itemId: 'item_c1',
        amount: 4.0,
        finishedAll: false,
        userId: 'tester',
      );

      final afterPartial = await dao.getItemById('item_c1');
      expect(afterPartial?.quantity, 6.0);

      final historyList = await dao.getHistoryByFridge('fridge_c');
      expect(historyList.length, 1);
      expect(historyList.first.quantityChanged, 4.0);
      expect(historyList.first.quantityLeft, 6.0);
      expect(historyList.first.kind, 'consumed');

      // Undo consume
      await dao.undoConsume(historyList.first.id);
      final afterUndo = await dao.getItemById('item_c1');
      expect(afterUndo?.quantity, 10.0);

      // Total consume: finish all
      await dao.consumeItemOptimistic(
        itemId: 'item_c1',
        amount: 10.0,
        finishedAll: true,
        userId: 'tester',
      );

      final afterFinished = await dao.getItemById('item_c1');
      expect(afterFinished, isNull); // soft deleted (isDeleted: true)

      final historyAfterFinish = await dao.getHistoryByFridge('fridge_c');
      expect(historyAfterFinish.length, 1);
      expect(historyAfterFinish.first.quantityLeft, 0.0);

      // History Streams & item by ID
      expect(dao.watchHistoryByFridge('fridge_c'), emits(hasLength(1)));
      final histItem = await dao.getHistoryItemById(historyAfterFinish.first.id);
      expect(histItem?.itemName, 'Eggs');

      // Record Expired History
      await dao.recordExpiredHistory(
        id: 'hist_exp_1',
        fridgeId: 'fridge_c',
        itemId: 'item_c2',
        itemName: 'Old Spinach',
        category: 'veggies',
        zone: 'fridge',
        quantityChanged: 1.0,
      );

      final historyWithExpired = await dao.getHistoryByFridge('fridge_c');
      expect(historyWithExpired.length, 2);

      // Delete single history item
      await dao.deleteHistoryItem('hist_exp_1');
      final historyAfterDelete = await dao.getHistoryByFridge('fridge_c');
      expect(historyAfterDelete.length, 1);

      // Clear history by kind
      await dao.clearHistoryByFridge('fridge_c', kind: 'consumed');
      final historyCleared = await dao.getHistoryByFridge('fridge_c');
      expect(historyCleared.isEmpty, isTrue);
    });

    test('autoRecordExpiredItems automatically records past due items', () async {
      final dao = db.itemDao;
      final yesterday = DateTime.now().subtract(const Duration(days: 2));

      await dao.insertItemOptimistic(
        id: 'item_exp_auto',
        fridgeId: 'fridge_exp',
        name: 'Expired Yogurt',
        category: 'beverages',
        zone: 'fridge',
        quantity: 1.0,
        unit: 'cup',
        expiryDate: yesterday,
      );

      await dao.autoRecordExpiredItems('fridge_exp');
      final hist = await dao.getHistoryByFridge('fridge_exp', kind: 'expired');
      expect(hist.length, 1);
      expect(hist.first.itemName, 'Expired Yogurt');
      expect(hist.first.kind, 'expired');
    });
  });

  group('AppDatabase Notifications & Helper Methods Unit Tests', () {
    test('notification storage, read status, count streams, and purge', () async {
      final userId = 'user_test_notifs';

      // Insert notifications
      await db.insertNotification(
        id: 'n_1',
        userId: userId,
        type: 'item_expired',
        payloadJson: '{"title":"Item Expired","message":"Your milk has expired"}',
      );
      await db.insertNotification(
        id: 'n_2',
        userId: userId,
        type: 'item_added',
        payloadJson: '{"title":"New Item","message":"Eggs added"}',
      );

      final notifs = await db.getNotifications(userId);
      expect(notifs.length, 2);

      // Streams
      expect(db.watchNotifications(userId), emits(hasLength(2)));
      expect(db.watchUnreadNotificationCount(userId), emits(2));

      // Mark single read
      await db.markNotificationAsRead('n_1');
      expect(db.watchUnreadNotificationCount(userId), emits(1));

      // Mark all read
      await db.markAllNotificationsAsRead(userId);
      expect(db.watchUnreadNotificationCount(userId), emits(0));

      // Delete single
      await db.deleteNotification('n_1');
      final afterDelete = await db.getNotifications(userId);
      expect(afterDelete.length, 1);

      // Purge and clear
      await db.purgeDemoNotifications();
      await db.clearNotifications(userId);
      final finalNotifs = await db.getNotifications(userId);
      expect(finalNotifs.isEmpty, isTrue);
    });

    test('AppDatabaseSkeleton helper bridge methods', () async {
      // Insert unsynced item
      await db.itemDao.insertItemOptimistic(
        id: 'bridge_item_1',
        fridgeId: 'fridge_b',
        name: 'Bridge Bread',
        category: 'meals',
        zone: 'fridge',
        quantity: 1.0,
        unit: 'pack',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        isSynced: false,
      );

      final unsynced = await db.getUnsyncedItems('fridge_b');
      expect(unsynced.length, 1);
      expect(unsynced.first['name'], 'Bridge Bread');

      await db.markItemSynced('bridge_item_1');
      final unsyncedAfter = await db.getUnsyncedItems('fridge_b');
      expect(unsyncedAfter.isEmpty, isTrue);

      // Upsert remote item and remote deletion
      await db.upsertRemoteItem({
        'id': 'bridge_item_2',
        'fridgeId': 'fridge_b',
        'name': 'Remote Salad',
        'category': 'veggies',
        'zone': 'fridge',
        'quantity': 2.0,
        'unit': 'bowl',
        'expiryDate': DateTime.now().add(const Duration(days: 4)).toIso8601String(),
        'isDeleted': false,
      });

      final item2 = await db.itemDao.getItemById('bridge_item_2');
      expect(item2?.name, 'Remote Salad');

      await db.upsertRemoteItem({
        'id': 'bridge_item_2',
        'isDeleted': true,
      });
      final item2Deleted = await db.itemDao.getItemById('bridge_item_2');
      expect(item2Deleted, isNull);

      await db.cleanOldConsumedHistory();
    });

    test('watchItemsByFridge and undoConsume re-insert and table definitions', () async {
      // 1. Table getters coverage
      expect(db.users.id.name, 'id');
      expect(db.users.username.name, 'username');
      expect(db.users.email.name, 'email');
      expect(db.users.passwordHash.name, 'password_hash');
      expect(db.users.googleId.name, 'google_id');
      expect(db.users.avatarUrl.name, 'avatar_url');
      expect(db.users.createdAt.name, 'created_at');
      expect(db.users.updatedAt.name, 'updated_at');

      expect(db.fridgesTable.id.name, 'id');
      expect(db.fridgesTable.name.name, 'name');
      expect(db.fridgesTable.description.name, 'description');
      expect(db.fridgesTable.ownerId.name, 'owner_id');
      expect(db.fridgesTable.isSynced.name, 'is_synced');

      expect(db.fridgeMembers.fridgeId.name, 'fridge_id');
      expect(db.fridgeMembers.userId.name, 'user_id');
      expect(db.fridgeMembers.role.name, 'role');

      expect(db.itemsTable.id.name, 'id');
      expect(db.itemsTable.name.name, 'name');
      expect(db.itemsTable.category.name, 'category');
      expect(db.itemsTable.zone.name, 'zone');
      expect(db.itemsTable.quantity.name, 'quantity');
      expect(db.itemsTable.unit.name, 'unit');
      expect(db.itemsTable.expiryDate.name, 'expiry_date');
      expect(db.itemsTable.imagePath.name, 'image_path');
      expect(db.itemsTable.isSynced.name, 'is_synced');
      expect(db.itemsTable.isDeleted.name, 'is_deleted');

      expect(db.itemHistory.kind.name, 'kind');
      expect(db.notifications.type.name, 'type');

      // 2. watchItemsByFridge with zone, category, and searchQuery
      await db.itemDao.insertItemOptimistic(
        id: 'filter_test_1',
        fridgeId: 'fridge_filter',
        name: 'Organic Whole Milk',
        category: 'dairy',
        zone: 'fridge',
        quantity: 1,
        unit: 'bottle',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
      );

      final filteredStream = db.itemDao.watchItemsByFridge(
        'fridge_filter',
        zone: 'fridge',
        category: 'dairy',
        searchQuery: 'Milk',
      );
      final items = await filteredStream.first;
      expect(items.length, 1);
      expect(items.first.name, 'Organic Whole Milk');

      // 3. undoConsume when item was completely removed
      await db.into(db.itemHistory).insert(
        ItemHistoryCompanion.insert(
          id: 'hist_reinsert_1',
          fridgeId: 'fridge_filter',
          itemId: const Value('item_reinsert_juice'),
          itemName: 'Reinsert Juice',
          category: const Value('beverages'),
          zone: const Value('door'),
          quantityChanged: 2.0,
          unit: const Value('cup'),
          byUserId: 'user_1',
          expiryDate: Value(DateTime.now().add(const Duration(days: 5))),
          kind: 'consumed',
        ),
      );

      await db.itemDao.undoConsume('hist_reinsert_1');
      final reinserted = await db.itemDao.getItemById('item_reinsert_juice');
      expect(reinserted, isNotNull);
      expect(reinserted?.name, 'Reinsert Juice');
    });
  });
}
