import 'package:drift/drift.dart';

// Table 1: Users
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text().withLength(min: 1, max: 50)();
  TextColumn get email => text()();
  TextColumn get passwordHash => text().nullable()();
  TextColumn get googleId => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// Table 2: Fridges (Multiple Fridges per User)
class Fridges extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  TextColumn get ownerId => text()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// Table 3: FridgeMembers
class FridgeMembers extends Table {
  TextColumn get fridgeId => text()();
  TextColumn get userId => text()();
  TextColumn get role => text().withDefault(const Constant('member'))(); // owner | member
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {fridgeId, userId};
}

// Table 4: FridgeInvites
class FridgeInvites extends Table {
  TextColumn get id => text()();
  TextColumn get fridgeId => text()();
  TextColumn get fromUserId => text()();
  TextColumn get toUserId => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending | accepted | declined
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// Table 5: Items
// Category: proteins | veggies | beverages | meals | sauces
// Zone: fridge | freezer
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get fridgeId => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get zone => text()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  TextColumn get unit => text().withDefault(const Constant('pieces'))();
  DateTimeColumn get expiryDate => dateTime()();
  TextColumn get imagePath => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// Table 6: ItemHistory
// TODO(database history): Automatically delete consumed records older than 30 days
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

// Table 7: Notifications
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

/// DAO Skeleton for Drift Database
/// TODO(drift generation): Run `dart run build_runner build` when entity classes are compiled
class AppDatabaseSkeleton {
  // Placeholder methods for DAOs
  Future<List<Map<String, dynamic>>> getUnsyncedItems(String fridgeId) async {
    // TODO: Query Items where isSynced == false and fridgeId == fridgeId
    return [];
  }

  Future<void> markItemSynced(String itemId) async {
    // TODO: Update Items set isSynced = true where id = itemId
  }

  Future<void> cleanOldConsumedHistory() async {
    // TODO: Delete from ItemHistory where kind = 'consumed' and createdAt < (now - 30 days)
  }
}

