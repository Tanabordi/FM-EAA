import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// =======================================================================
// Table 1: Users
// =======================================================================
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text().withLength(min: 1, max: 50)();
  TextColumn get email => text()();
  TextColumn get passwordHash => text().nullable()();
  TextColumn get googleId => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// =======================================================================
// Table 2: FridgesTable (Multiple Fridges per User)
// =======================================================================
@DataClassName('FridgeEntry')
class FridgesTable extends Table {
  @override
  String get tableName => 'fridges';

  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  TextColumn get ownerId => text()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

typedef Fridges = FridgesTable;

// =======================================================================
// Table 3: FridgeMembers (Shared Fridge Roles: owner | member)
// =======================================================================
class FridgeMembers extends Table {
  TextColumn get fridgeId => text()();
  TextColumn get userId => text()();
  TextColumn get role => text().withDefault(const Constant('member'))(); // owner | member
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {fridgeId, userId};
}

// =======================================================================
// Table 4: FridgeInvites (status: pending | accepted | declined)
// =======================================================================
class FridgeInvites extends Table {
  TextColumn get id => text()();
  TextColumn get fridgeId => text()();
  TextColumn get fromUserId => text()();
  TextColumn get toUserId => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending | accepted | declined
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// =======================================================================
// Table 5: ItemsTable (Inventory Items bound to a specific fridge)
// =======================================================================
@DataClassName('ItemEntry')
class ItemsTable extends Table {
  @override
  String get tableName => 'items';

  TextColumn get id => text()();
  TextColumn get fridgeId => text()();
  TextColumn get name => text()();
  TextColumn get category => text()(); // proteins | veggies | beverages | meals | sauces
  TextColumn get zone => text()(); // fridge | freezer
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  TextColumn get unit => text().withDefault(const Constant('pieces'))();
  DateTimeColumn get expiryDate => dateTime()();
  TextColumn get imagePath => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

typedef Items = ItemsTable;

// =======================================================================
// Table 6: ItemHistory (Audit Log for Consumed & Expired items)
// =======================================================================
class ItemHistory extends Table {
  TextColumn get id => text()();
  TextColumn get fridgeId => text()();
  TextColumn get itemId => text().nullable()();
  TextColumn get itemName => text()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get kind => text()(); // consumed | expired
  RealColumn get quantityChanged => real()();
  RealColumn get quantityLeft => real().withDefault(const Constant(0.0))();
  TextColumn get unit => text().withDefault(const Constant('pieces'))();
  TextColumn get byUserId => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// =======================================================================
// Table 7: Notifications (In-app notifications)
// =======================================================================
class Notifications extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get type => text()(); // invite | expiry
  TextColumn get payloadJson => text().nullable()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// =======================================================================
// DAO: FridgeDao (Data Access Object for FridgesTable)
// =======================================================================
@DriftAccessor(tables: [FridgesTable, FridgeMembers])
class FridgeDao extends DatabaseAccessor<AppDatabase> with _$FridgeDaoMixin {
  FridgeDao(super.db);

  /// Watch all fridges as a reactive stream (Optimistic UI updates automatically)
  Stream<List<FridgeEntry>> watchAllFridges() {
    return (select(fridgesTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  /// Get all fridges
  Future<List<FridgeEntry>> getAllFridges() {
    return (select(fridgesTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// Get single fridge by id
  Future<FridgeEntry?> getFridgeById(String id) {
    return (select(fridgesTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Watch single fridge by id
  Stream<FridgeEntry?> watchFridgeById(String id) {
    return (select(fridgesTable)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Optimistic insert: Save immediately to local DB with is_synced = false
  Future<int> insertFridgeOptimistic({
    required String id,
    required String name,
    String? description,
    required String ownerId,
    bool isSynced = false,
  }) {
    return into(fridgesTable).insert(
      FridgesTableCompanion.insert(
        id: id,
        name: name,
        description: Value(description),
        ownerId: ownerId,
        isSynced: Value(isSynced),
        updatedAt: Value(DateTime.now()),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Optimistic update: Save modifications locally immediately with is_synced = false
  Future<bool> updateFridgeOptimistic({
    required String id,
    String? name,
    String? description,
    bool isSynced = false,
  }) async {
    final companion = FridgesTableCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      description: description != null ? Value(description) : const Value.absent(),
      isSynced: Value(isSynced),
      updatedAt: Value(DateTime.now()),
    );
    final count = await (update(fridgesTable)..where((t) => t.id.equals(id))).write(companion);
    return count > 0;
  }

  /// Delete fridge locally
  Future<int> deleteFridge(String id) {
    return (delete(fridgesTable)..where((t) => t.id.equals(id))).go();
  }

  /// Query all unsynced fridges for background sync
  Future<List<FridgeEntry>> getUnsyncedFridges() {
    return (select(fridgesTable)..where((t) => t.isSynced.equals(false))).get();
  }

  /// Mark fridge as synced after successful server sync
  Future<int> markFridgeSynced(String id) {
    return (update(fridgesTable)..where((t) => t.id.equals(id))).write(
      const FridgesTableCompanion(isSynced: Value(true)),
    );
  }

  /// Upsert remote fridges (with isSynced = true)
  Future<void> upsertFridgesFromRemote(List<FridgeEntry> fridges) async {
    await batch((batch) {
      batch.insertAll(
        fridgesTable,
        fridges.map((f) => f.toCompanion(true)),
        mode: InsertMode.insertOrReplace,
      );
    });
  }
}

// =======================================================================
// DAO: ItemDao (Data Access Object for ItemsTable)
// =======================================================================
@DriftAccessor(tables: [ItemsTable, ItemHistory])
class ItemDao extends DatabaseAccessor<AppDatabase> with _$ItemDaoMixin {
  ItemDao(super.db);

  /// Watch items for a fridge with optional category, zone, or search filters (Reactive Stream)
  Stream<List<ItemEntry>> watchItemsByFridge(
    String fridgeId, {
    String? category,
    String? zone,
    String? searchQuery,
  }) {
    final query = select(itemsTable)..where((t) => t.fridgeId.equals(fridgeId));

    if (zone != null && zone.isNotEmpty) {
      query.where((t) => t.zone.equals(zone));
    }

    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      query.where((t) => t.category.lower().equals(category.toLowerCase()));
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query.where((t) => t.name.lower().like('%${searchQuery.trim().toLowerCase()}%'));
    }

    query.orderBy([
      (t) => OrderingTerm(expression: t.expiryDate, mode: OrderingMode.asc),
      (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
    ]);

    return query.watch();
  }

  /// Get items for a fridge
  Future<List<ItemEntry>> getItemsByFridge(
    String fridgeId, {
    String? category,
    String? zone,
  }) {
    final query = select(itemsTable)..where((t) => t.fridgeId.equals(fridgeId));

    if (zone != null && zone.isNotEmpty) {
      query.where((t) => t.zone.equals(zone));
    }

    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      query.where((t) => t.category.lower().equals(category.toLowerCase()));
    }

    query.orderBy([
      (t) => OrderingTerm(expression: t.expiryDate, mode: OrderingMode.asc),
    ]);

    return query.get();
  }

  /// Get single item by id
  Future<ItemEntry?> getItemById(String id) {
    return (select(itemsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Watch single item by id
  Stream<ItemEntry?> watchItemById(String id) {
    return (select(itemsTable)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Optimistic insert: Save item immediately to SQLite with is_synced = false
  Future<int> insertItemOptimistic({
    required String id,
    required String fridgeId,
    required String name,
    required String category,
    required String zone,
    required double quantity,
    required String unit,
    required DateTime expiryDate,
    String? imagePath,
    bool isSynced = false,
  }) {
    return into(itemsTable).insert(
      ItemsTableCompanion.insert(
        id: id,
        fridgeId: fridgeId,
        name: name,
        category: category,
        zone: zone,
        quantity: Value(quantity),
        unit: Value(unit),
        expiryDate: expiryDate,
        imagePath: Value(imagePath),
        isSynced: Value(isSynced),
        updatedAt: Value(DateTime.now()),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Optimistic update: Update item immediately in SQLite with is_synced = false
  Future<bool> updateItemOptimistic({
    required String id,
    String? name,
    String? category,
    String? zone,
    double? quantity,
    String? unit,
    DateTime? expiryDate,
    String? imagePath,
    bool isSynced = false,
  }) async {
    final companion = ItemsTableCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      category: category != null ? Value(category) : const Value.absent(),
      zone: zone != null ? Value(zone) : const Value.absent(),
      quantity: quantity != null ? Value(quantity) : const Value.absent(),
      unit: unit != null ? Value(unit) : const Value.absent(),
      expiryDate: expiryDate != null ? Value(expiryDate) : const Value.absent(),
      imagePath: imagePath != null ? Value(imagePath) : const Value.absent(),
      isSynced: Value(isSynced),
      updatedAt: Value(DateTime.now()),
    );
    final count = await (update(itemsTable)..where((t) => t.id.equals(id))).write(companion);
    return count > 0;
  }

  /// Delete item locally
  Future<int> deleteItem(String id) {
    return (delete(itemsTable)..where((t) => t.id.equals(id))).go();
  }

  /// Optimistic consume: Deducts quantity or removes item, records to item_history
  Future<void> consumeItemOptimistic({
    required String itemId,
    required double amount,
    bool finishedAll = false,
    String userId = 'user_1',
  }) async {
    final item = await getItemById(itemId);
    if (item == null) return;

    final double newQuantity = item.quantity - amount;
    final bool shouldRemove = finishedAll || newQuantity <= 0;

    await transaction(() async {
      if (shouldRemove) {
        await (delete(itemsTable)..where((t) => t.id.equals(itemId))).go();
      } else {
        await (update(itemsTable)..where((t) => t.id.equals(itemId))).write(
          ItemsTableCompanion(
            quantity: Value(newQuantity),
            isSynced: const Value(false),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      // Record to audit log in item_history
      await into(itemHistory).insert(
        ItemHistoryCompanion.insert(
          id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
          fridgeId: item.fridgeId,
          itemId: Value(itemId),
          itemName: item.name,
          imagePath: Value(item.imagePath),
          kind: 'consumed',
          quantityChanged: amount,
          quantityLeft: Value(shouldRemove ? 0.0 : newQuantity),
          unit: Value(item.unit),
          byUserId: userId,
          createdAt: Value(DateTime.now()),
        ),
      );
    });
  }

  /// Undo consume: Restores item quantity and deletes history record
  Future<void> undoConsume(String historyId) async {
    final hist = await (select(itemHistory)..where((t) => t.id.equals(historyId))).getSingleOrNull();
    if (hist == null) return;

    await transaction(() async {
      if (hist.itemId != null) {
        final existingItem = await getItemById(hist.itemId!);
        if (existingItem != null) {
          await (update(itemsTable)..where((t) => t.id.equals(hist.itemId!))).write(
            ItemsTableCompanion(
              quantity: Value(existingItem.quantity + hist.quantityChanged),
              isSynced: const Value(false),
              updatedAt: Value(DateTime.now()),
            ),
          );
        } else {
          // Re-insert item if it was completely removed
          await into(itemsTable).insert(
            ItemsTableCompanion.insert(
              id: hist.itemId!,
              fridgeId: hist.fridgeId,
              name: hist.itemName,
              category: 'meals',
              zone: 'fridge',
              quantity: Value(hist.quantityChanged),
              unit: Value(hist.unit),
              expiryDate: DateTime.now().add(const Duration(days: 3)),
              imagePath: Value(hist.imagePath),
              isSynced: const Value(false),
              updatedAt: Value(DateTime.now()),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      }
      await (delete(itemHistory)..where((t) => t.id.equals(historyId))).go();
    });
  }

  /// Get unsynced items in a fridge (where is_synced == false)
  Future<List<ItemEntry>> getUnsyncedItems(String fridgeId) {
    return (select(itemsTable)
          ..where((t) => t.fridgeId.equals(fridgeId) & t.isSynced.equals(false)))
        .get();
  }

  /// Get all unsynced items across all fridges
  Future<List<ItemEntry>> getAllUnsyncedItems() {
    return (select(itemsTable)..where((t) => t.isSynced.equals(false))).get();
  }

  /// Mark item as synced
  Future<int> markItemSynced(String id) {
    return (update(itemsTable)..where((t) => t.id.equals(id))).write(
      const ItemsTableCompanion(isSynced: Value(true)),
    );
  }

  /// Get items expiring soon (e.g. within threshold days)
  Future<List<ItemEntry>> getExpiringSoonItems(String fridgeId, {int daysThreshold = 2}) {
    final now = DateTime.now();
    final thresholdDate = DateTime(now.year, now.month, now.day).add(Duration(days: daysThreshold + 1));
    return (select(itemsTable)
          ..where((t) => t.fridgeId.equals(fridgeId) & t.expiryDate.isSmallerOrEqualValue(thresholdDate))
          ..orderBy([(t) => OrderingTerm(expression: t.expiryDate, mode: OrderingMode.asc)]))
        .get();
  }
}

// =======================================================================
// DAO Skeleton (Maintained for backward compatibility with tests)
// =======================================================================
class AppDatabaseSkeleton {
  Future<List<Map<String, dynamic>>> getUnsyncedItems(String fridgeId) async => [];
  Future<void> markItemSynced(String itemId) async {}
  Future<void> cleanOldConsumedHistory() async {}
}

// =======================================================================
// Main AppDatabase
// =======================================================================
@DriftDatabase(
  tables: [
    Users,
    FridgesTable,
    FridgeMembers,
    FridgeInvites,
    ItemsTable,
    ItemHistory,
    Notifications,
  ],
  daos: [
    FridgeDao,
    ItemDao,
  ],
)
class AppDatabase extends _$AppDatabase implements AppDatabaseSkeleton {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedItems(String fridgeId) async {
    final items = await itemDao.getUnsyncedItems(fridgeId);
    return items.map((i) => {
      'id': i.id,
      'fridge_id': i.fridgeId,
      'name': i.name,
      'category': i.category,
      'zone': i.zone,
      'quantity': i.quantity,
      'unit': i.unit,
      'expiry_date': i.expiryDate.toIso8601String(),
      'image_path': i.imagePath,
      'is_synced': i.isSynced ? 1 : 0,
      'updated_at': i.updatedAt.toIso8601String(),
    }).toList();
  }

  @override
  Future<void> markItemSynced(String itemId) async {
    await itemDao.markItemSynced(itemId);
  }

  @override
  Future<void> cleanOldConsumedHistory() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    await (delete(itemHistory)
          ..where((t) => t.kind.equals('consumed') & t.createdAt.isSmallerThanValue(cutoff)))
        .go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fm_eaa.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// Riverpod Provider for AppDatabase
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
