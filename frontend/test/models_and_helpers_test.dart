import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/core/theme/freshness_colors.dart';
import 'package:fm_eaa/data/local/app_database.dart';
import 'package:fm_eaa/data/models/fridge_model.dart';
import 'package:fm_eaa/data/models/history_model.dart';
import 'package:fm_eaa/data/models/item_model.dart';
import 'package:fm_eaa/data/models/notification_model.dart';
import 'package:fm_eaa/data/models/user_model.dart';
import 'package:fm_eaa/features/family/domain/models/family_member.dart';
import 'package:fm_eaa/features/recipe/data/models/recipe_model.dart';
import 'package:fm_eaa/shared/utils/food_asset_helper.dart';

class _FakeNotificationEntry {
  final String id;
  final String userId;
  final String type;
  final bool isRead;
  final String? payloadJson;
  final DateTime createdAt;

  _FakeNotificationEntry({
    required this.id,
    required this.userId,
    required this.type,
    required this.isRead,
    this.payloadJson,
    required this.createdAt,
  });
}

void main() {
  group('FoodAssetHelper Unit Tests', () {
    test('resolves protein assets correctly', () {
      expect(getFoodAssetFallback('Cocktail Sausage'), 'assets/images/food_chicken_breasts.png');
      expect(getFoodAssetFallback('ไส้กรอกค็อกเทล'), 'assets/images/food_chicken_breasts.png');
      expect(getFoodAssetFallback('Chicken Breast'), 'assets/images/food_chicken_breasts.png');
      expect(getFoodAssetFallback('หมูบด'), 'assets/images/food_chicken_breasts.png');
      expect(getFoodAssetFallback('Beef Steak'), 'assets/images/food_chicken_breasts.png');
      expect(getFoodAssetFallback('Fresh Eggs'), 'assets/images/food_eggs.png');
      expect(getFoodAssetFallback('ไข่เป็ด'), 'assets/images/food_eggs.png');
      expect(getFoodAssetFallback('Salmon Fillet'), 'assets/images/food_salmon_fillets.png');
      expect(getFoodAssetFallback('กุ้งสด'), 'assets/images/food_salmon_fillets.png');
      expect(getFoodAssetFallback('Firm Tofu'), 'assets/images/food_firm_tofu.png');
      expect(getFoodAssetFallback('เต้าหู้ขาว'), 'assets/images/food_firm_tofu.png');
      expect(getFoodAssetFallback('Crispy Nuggets'), 'assets/images/food_nuggets.png');
      expect(getFoodAssetFallback('Dimsum Dumpling'), 'assets/images/food_dumplings.png');
      expect(getFoodAssetFallback('เกี๊ยวซ่า'), 'assets/images/food_dumplings.png');
    });

    test('resolves veggies and fruits assets correctly', () {
      expect(getFoodAssetFallback('Cherry Tomato'), 'assets/images/food_cherry_tomatoes.png');
      expect(getFoodAssetFallback('มะเขือเทศ'), 'assets/images/food_cherry_tomatoes.png');
      expect(getFoodAssetFallback('Fresh Strawberries'), 'assets/images/food_strawberries.png');
      expect(getFoodAssetFallback('สตรอว์เบอร์รี'), 'assets/images/food_strawberries.png');
      expect(getFoodAssetFallback('Green Spinach'), 'assets/images/food_spinach.png');
      expect(getFoodAssetFallback('ผักกาดหอม'), 'assets/images/food_spinach.png');
      expect(getFoodAssetFallback('Avocado'), 'assets/images/food_avocados.png');
      expect(getFoodAssetFallback('กล้วยหอม'), 'assets/images/food_avocados.png');
      expect(getFoodAssetFallback('Fresh Apple'), 'assets/images/food_avocados.png');
      expect(getFoodAssetFallback('ผลไม้รวม'), 'assets/images/food_avocados.png');
    });

    test('resolves beverages correctly', () {
      expect(getFoodAssetFallback('Coca Cola Can'), 'assets/images/food_cold_brew.png');
      expect(getFoodAssetFallback('Cold Brew Coffee'), 'assets/images/food_cold_brew.png');
      expect(getFoodAssetFallback('กาแฟเย็น'), 'assets/images/food_cold_brew.png');
      expect(getFoodAssetFallback('น้ำแข็ง'), 'assets/images/food_cold_brew.png');
      expect(getFoodAssetFallback('Fresh Orange'), 'assets/images/food_orange_juice.png');
      expect(getFoodAssetFallback('น้ำส้มแท้'), 'assets/images/food_orange_juice.png');
      expect(getFoodAssetFallback('Whole Milk'), 'assets/images/food_whole_milk.png');
      expect(getFoodAssetFallback('นมสดเมจิ'), 'assets/images/food_whole_milk.png');
      expect(getFoodAssetFallback('Green Tea'), 'assets/images/food_kombucha.png');
      expect(getFoodAssetFallback('ชาเขียว'), 'assets/images/food_kombucha.png');
      expect(getFoodAssetFallback('น้ำดื่ม'), 'assets/images/food_kombucha.png');
    });

    test('resolves sauces correctly', () {
      expect(getFoodAssetFallback('Mayonnaise'), 'assets/images/food_mayo.png');
      expect(getFoodAssetFallback('น้ำสลัดงา'), 'assets/images/food_mayo.png');
      expect(getFoodAssetFallback('Soy Sauce'), 'assets/images/food_soy_sauce.png');
      expect(getFoodAssetFallback('ซีอิ๊วขาว'), 'assets/images/food_soy_sauce.png');
      expect(getFoodAssetFallback('Fish Sauce', category: 'sauces'), 'assets/images/food_salmon_fillets.png');
      expect(getFoodAssetFallback('Sriracha'), 'assets/images/food_sriracha.png');
      expect(getFoodAssetFallback('พริกป่น'), 'assets/images/food_sriracha.png');
      expect(getFoodAssetFallback('Olive Oil'), 'assets/images/food_olive_oil.png');
      expect(getFoodAssetFallback('น้ำมันพืช'), 'assets/images/food_olive_oil.png');
    });

    test('resolves meals and bakery correctly', () {
      expect(getFoodAssetFallback('Pizza'), 'assets/images/food_pizza.png');
      expect(getFoodAssetFallback('พิซซ่าซีฟู้ด'), 'assets/images/food_pizza.png');
      expect(getFoodAssetFallback('Lasagna'), 'assets/images/food_lasagna.png');
      expect(getFoodAssetFallback('Pasta Carbonara'), 'assets/images/food_lasagna.png');
      expect(getFoodAssetFallback('Noodles'), 'assets/images/food_lasagna.png');
      expect(getFoodAssetFallback('ข้าวสวย'), 'assets/images/food_lasagna.png');
    });

    test('falls back to category-level when name does not match', () {
      expect(getFoodAssetFallback('Unknown Item', category: 'proteins'), 'assets/images/food_chicken_breasts.png');
      expect(getFoodAssetFallback('Unknown Item', category: 'veggies'), 'assets/images/food_spinach.png');
      expect(getFoodAssetFallback('Unknown Item', category: 'beverages'), 'assets/images/food_whole_milk.png');
      expect(getFoodAssetFallback('Unknown Item', category: 'sauces'), 'assets/images/food_sriracha.png');
      expect(getFoodAssetFallback('Unknown Item', category: 'meals'), 'assets/images/food_lasagna.png');
      expect(getFoodAssetFallback('Completely Generic Item', category: 'other'), 'assets/images/food_avocados.png');
    });
  });

  group('ItemModel Unit Tests', () {
    final now = DateTime.now();

    test('calculates status and days until expiry correctly', () {
      final expiredItem = ItemModel(
        id: '1',
        fridgeId: 'f1',
        name: 'Old Milk',
        category: 'beverages',
        zone: 'fridge',
        quantity: 1,
        unit: 'bottle',
        expiryDate: now.subtract(const Duration(days: 3)),
        updatedAt: now,
      );
      expect(expiredItem.status, FreshnessStatus.expired);
      expect(expiredItem.statusText, contains('days ago'));
      expect(expiredItem.localizedStatusText(true), contains('วันที่แล้ว'));
      expect(expiredItem.detailStatusLabel, contains('Expired'));
      expect(expiredItem.localizedDetailStatusLabel(true), contains('หมดอายุ'));

      final useSoonItem = ItemModel(
        id: '2',
        fridgeId: 'f1',
        name: 'Fresh Bread',
        category: 'meals',
        zone: 'fridge',
        quantity: 2,
        unit: 'pcs',
        expiryDate: now.add(const Duration(days: 1)),
        updatedAt: now,
      );
      expect(useSoonItem.status, FreshnessStatus.useSoon);
      expect(useSoonItem.statusText, '1 day left');
      expect(useSoonItem.localizedStatusText(true), 'เหลืออีก 1 วัน');
      expect(useSoonItem.detailStatusLabel, 'Use soon in 1 Day');
      expect(useSoonItem.localizedDetailStatusLabel(true), 'ควรบริโภคใน 1 วัน');

      final freshItem = ItemModel(
        id: '3',
        fridgeId: 'f1',
        name: 'Eggs',
        category: 'proteins',
        zone: 'fridge',
        quantity: 10,
        unit: 'pieces',
        expiryDate: now.add(const Duration(days: 10)),
        updatedAt: now,
      );
      expect(freshItem.status, FreshnessStatus.fresh);
      expect(freshItem.statusText, '10 days left');
      expect(freshItem.localizedStatusText(true), 'เหลืออีก 10 วัน');
      expect(freshItem.detailStatusLabel, 'Fresh in 10 Days');
      expect(freshItem.localizedDetailStatusLabel(true), 'สดใหม่อีก 10 วัน');
    });

    test('handles special edge cases for today and yesterday', () {
      final todayItem = ItemModel(
        id: 't1',
        fridgeId: 'f1',
        name: 'Tofu',
        category: 'proteins',
        zone: 'fridge',
        quantity: 1,
        unit: 'piece',
        expiryDate: DateTime(now.year, now.month, now.day),
        updatedAt: now,
      );
      expect(todayItem.statusText, 'Expires today');
      expect(todayItem.localizedStatusText(true), 'หมดอายุวันนี้');
      expect(todayItem.detailStatusLabel, 'Expires today');
      expect(todayItem.localizedDetailStatusLabel(true), 'หมดอายุวันนี้');

      final yesterdayItem = ItemModel(
        id: 'y1',
        fridgeId: 'f1',
        name: 'Yogurt',
        category: 'beverages',
        zone: 'fridge',
        quantity: 1,
        unit: 'cup',
        expiryDate: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)),
        updatedAt: now,
      );
      expect(yesterdayItem.statusText, 'Yesterday');
      expect(yesterdayItem.localizedStatusText(true), 'เมื่อวานนี้');
      expect(yesterdayItem.detailStatusLabel, 'Expired yesterday');
      expect(yesterdayItem.localizedDetailStatusLabel(true), 'หมดอายุเมื่อวานนี้');
    });

    test('translates food and category names accurately', () {
      expect(ItemModel.getThaiFoodName('raw shrimp'), 'กุ้งสด');
      expect(ItemModel.getThaiFoodName('Chicken Breast'), 'อกไก่');
      expect(ItemModel.getThaiFoodName('Eggs'), 'ไข่ไก่');
      expect(ItemModel.getThaiFoodName('Smoked sausage'), 'ไส้กรอกรมควัน');
      expect(ItemModel.getThaiFoodName('Custom Unknown Product'), 'Custom Unknown Product');
      expect(ItemModel.getThaiFoodName(''), '');

      expect(ItemModel.getThaiCategoryName('proteins'), 'โปรตีน');
      expect(ItemModel.getThaiCategoryName('veggies'), 'ผักผลไม้');
      expect(ItemModel.getThaiCategoryName('beverages'), 'เครื่องดื่ม');
      expect(ItemModel.getThaiCategoryName('meals'), 'อาหาร');
      expect(ItemModel.getThaiCategoryName('sauces'), 'ซอส');
      expect(ItemModel.getThaiCategoryName('other'), 'other');
    });

    test('localizes units and formats quantity strings', () {
      expect(ItemModel.localizeUnit('pieces', true), 'ชิ้น');
      expect(ItemModel.localizeUnit('bottle', true), 'ขวด');
      expect(ItemModel.localizeUnit('bag', true), 'ถุง');
      expect(ItemModel.localizeUnit('box', true), 'กล่อง');
      expect(ItemModel.localizeUnit('can', true), 'กระป๋อง');
      expect(ItemModel.localizeUnit('pack', true), 'แพ็ค');
      expect(ItemModel.localizeUnit('punnet', true), 'ตะกร้า');
      expect(ItemModel.localizeUnit('kg', true), 'kg');
      expect(ItemModel.localizeUnit('pieces', false), 'pieces');

      final item = ItemModel(
        id: 'q1',
        fridgeId: 'f1',
        name: 'Sausage',
        category: 'proteins',
        zone: 'fridge',
        quantity: 2.0,
        unit: 'pack',
        expiryDate: now.add(const Duration(days: 5)),
        updatedAt: now,
      );
      expect(item.formattedQuantity, '2 pack');
      expect(item.formattedQuantityLocalized(true), '2 แพ็ค');
      expect(item.localizedName(true), 'Sausage');
    });

    test('JSON serialization, copyWith, and fromEntry work seamlessly', () {
      final original = ItemModel(
        id: 'item_101',
        fridgeId: 'fridge_202',
        name: 'Wagyu Beef Steak',
        category: 'proteins',
        zone: 'freezer',
        quantity: 2.5,
        unit: 'kg',
        expiryDate: DateTime(2026, 12, 31),
        imagePath: 'https://storage/image.jpg',
        isSynced: true,
        isDeleted: false,
        updatedAt: DateTime(2026, 11, 1),
      );

      final json = original.toJson();
      expect(json['id'], 'item_101');
      expect(json['fridge_id'], 'fridge_202');
      expect(json['name'], 'Wagyu Beef Steak');
      expect(json['quantity'], 2.5);
      expect(json['is_synced'], 1);
      expect(json['is_deleted'], 0);

      final deserialized = ItemModel.fromJson(json);
      expect(deserialized.id, original.id);
      expect(deserialized.name, original.name);
      expect(deserialized.quantity, 2.5);
      expect(deserialized.zone, 'freezer');
      expect(deserialized.isSynced, isTrue);

      final updated = original.copyWith(
        quantity: 3.0,
        name: 'Premium Wagyu Beef',
        isSynced: false,
      );
      expect(updated.quantity, 3.0);
      expect(updated.name, 'Premium Wagyu Beef');
      expect(updated.isSynced, isFalse);
      expect(updated.id, original.id);

      final db = AppDatabase(NativeDatabase.memory());
      final entry = ItemEntry(
        id: 'entry_1',
        fridgeId: 'f1',
        name: 'Apple',
        category: 'veggies',
        zone: 'fridge',
        quantity: 5,
        unit: 'pieces',
        expiryDate: now,
        isSynced: true,
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      );
      final fromEntry = ItemModel.fromEntry(entry);
      expect(fromEntry.id, 'entry_1');
      expect(fromEntry.name, 'Apple');
      db.close();
    });
  });

  group('FridgeModel Unit Tests', () {
    final now = DateTime.now();

    test('personal status, owner checks, and items count formatting', () {
      final personalFridge = FridgeModel(
        id: 'f1',
        name: 'My Room Fridge',
        ownerId: 'u1',
        role: 'owner',
        memberCount: 1,
        itemCount: 0,
        updatedAt: now,
      );
      expect(personalFridge.isPersonal, isTrue);
      expect(personalFridge.isOwner, isTrue);
      expect(personalFridge.isUserOwner('u1'), isTrue);
      expect(personalFridge.isUserOwner('u2'), isTrue); // because role is owner
      expect(personalFridge.itemsCountText, 'Empty');

      final sharedFridge = FridgeModel(
        id: 'f2',
        name: 'Family Kitchen Fridge',
        ownerId: 'u1',
        role: 'member',
        memberCount: 4,
        itemCount: 1,
        updatedAt: now,
      );
      expect(sharedFridge.isPersonal, isFalse);
      expect(sharedFridge.isOwner, isFalse);
      expect(sharedFridge.isUserOwner('u1'), isTrue);
      expect(sharedFridge.isUserOwner('u2'), isFalse);
      expect(sharedFridge.itemsCountText, '1 Item');

      final multiItemFridge = sharedFridge.copyWith(itemCount: 5);
      expect(multiItemFridge.itemsCountText, '5 Items');
    });

    test('JSON serialization, copyWith, and fromEntry', () {
      final fridge = FridgeModel(
        id: 'fridge_abc',
        name: 'Cool Fridge',
        description: 'Office 2nd floor',
        ownerId: 'user_boss',
        role: 'owner',
        memberCount: 3,
        itemCount: 12,
        updatedAt: DateTime(2026, 11, 2),
      );

      final json = {
        'id': 'fridge_abc',
        'name': 'Cool Fridge',
        'description': 'Office 2nd floor',
        'owner_id': 'user_boss',
        'userRole': 'owner',
        'member_count': 3,
        'item_count': 12,
        'updated_at': '2026-11-02T10:00:00.000Z',
      };
      final deserialized = FridgeModel.fromJson(json);
      expect(deserialized.id, fridge.id);
      expect(deserialized.name, fridge.name);
      expect(deserialized.memberCount, 3);
      expect(deserialized.itemCount, 12);

      final modified = fridge.copyWith(name: 'Updated Name', memberCount: 5);
      expect(modified.name, 'Updated Name');
      expect(modified.memberCount, 5);
      expect(modified.id, fridge.id);

      final db = AppDatabase(NativeDatabase.memory());
      final entry = FridgeEntry(
        id: 'fe_1',
        name: 'Entry Fridge',
        ownerId: 'owner_1',
        isSynced: true,
        createdAt: now,
        updatedAt: now,
      );
      final fromEntry = FridgeModel.fromEntry(entry, memberCount: 2, itemCount: 8);
      expect(fromEntry.name, 'Entry Fridge');
      expect(fromEntry.memberCount, 2);
      expect(fromEntry.itemCount, 8);
      db.close();
    });
  });

  group('HistoryModel Unit Tests', () {
    final now = DateTime.now();

    test('isConsumed and isExpired getters', () {
      final consumed = HistoryModel(
        id: 'h1',
        fridgeId: 'f1',
        itemName: 'Yogurt',
        kind: 'consumed',
        quantityChanged: 1,
        quantityLeft: 0,
        unit: 'cup',
        byUsername: 'tulbp',
        createdAt: now,
      );
      expect(consumed.isConsumed, isTrue);
      expect(consumed.isExpired, isFalse);

      final expired = HistoryModel(
        id: 'h2',
        fridgeId: 'f1',
        itemName: 'Milk',
        kind: 'expired',
        quantityChanged: 1,
        quantityLeft: 0,
        unit: 'bottle',
        byUsername: 'system',
        createdAt: now,
      );
      expect(expired.isConsumed, isFalse);
      expect(expired.isExpired, isTrue);
    });

    test('JSON serialization and fromEntry', () {
      final item = HistoryModel(
        id: 'hist_123',
        fridgeId: 'fridge_456',
        itemId: 'item_789',
        itemName: 'Steak',
        imagePath: '/path/to/img.png',
        kind: 'consumed',
        quantityChanged: 2,
        quantityLeft: 1,
        unit: 'pieces',
        byUsername: 'john_doe',
        createdAt: DateTime(2026, 11, 4),
      );

      final json = item.toJson();
      expect(json['id'], 'hist_123');
      expect(json['item_name'], 'Steak');
      expect(json['kind'], 'consumed');

      final fromJson = HistoryModel.fromJson(json);
      expect(fromJson.id, item.id);
      expect(fromJson.itemName, item.itemName);
      expect(fromJson.quantityChanged, 2.0);

      final db = AppDatabase(NativeDatabase.memory());
      final entry = ItemHistoryData(
        id: 'he_1',
        fridgeId: 'f1',
        itemName: 'Pizza',
        kind: 'consumed',
        quantityChanged: 1,
        quantityLeft: 0,
        unit: 'piece',
        byUserId: '@chef_wansai',
        createdAt: now,
      );
      final fromEntry = HistoryModel.fromEntry(entry);
      expect(fromEntry.byUsername, 'chef_wansai'); // stripped @ prefix
      expect(fromEntry.itemName, 'Pizza');
      db.close();
    });
  });

  group('NotificationModel Unit Tests', () {
    final now = DateTime.now();

    test('getters for various notification types', () {
      final invite = NotificationModel(
        id: 'n1',
        userId: 'u1',
        type: 'invite',
        title: 'Fridge Invitation',
        message: 'You have been invited',
        createdAt: now,
      );
      expect(invite.isInvite, isTrue);
      expect(invite.isExpiry, isFalse);
      expect(invite.isItemAction, isFalse);

      final added = NotificationModel(
        id: 'n2',
        userId: 'u1',
        type: 'item_added',
        title: 'New Item Added',
        message: 'Tul added "Milk" (1 bottle) to "Kitchen"',
        createdAt: now,
      );
      expect(added.isItemAdded, isTrue);
      expect(added.isItemAction, isTrue);

      final consumed = NotificationModel(
        id: 'n3',
        userId: 'u1',
        type: 'item_consumed',
        title: 'Item Consumed',
        message: 'Tul ate 1 of "Apple" in "Kitchen" (2 left)',
        createdAt: now,
      );
      expect(consumed.isItemConsumed, isTrue);
      expect(consumed.isItemAction, isTrue);

      final deleted = NotificationModel(
        id: 'n4',
        userId: 'u1',
        type: 'item_deleted',
        title: 'Item Removed',
        message: 'Tul removed "Bread" from "Kitchen"',
        createdAt: now,
      );
      expect(deleted.isItemDeleted, isTrue);
      expect(deleted.isItemAction, isTrue);

      final memberJoined = NotificationModel(
        id: 'n5',
        userId: 'u1',
        type: 'member_joined',
        title: 'New Member Joined',
        message: 'Alex joined Kitchen',
        createdAt: now,
      );
      expect(memberJoined.isMemberJoined, isTrue);
      expect(memberJoined.isItemAction, isFalse);
    });

    test('localizes titles into Thai correctly', () {
      expect(NotificationModel.localizeTitleStatic('New Item Added', true), '🥬 เพิ่มรายการอาหารใหม่');
      expect(NotificationModel.localizeTitleStatic('Item Consumed', true), '🍽️ รับประทานอาหารแล้ว');
      expect(NotificationModel.localizeTitleStatic('Item Removed', true), '🗑️ นำรายการอาหารออกแล้ว');
      expect(NotificationModel.localizeTitleStatic('New Member Joined', true), '👥 สมาชิกใหม่เข้าร่วม');
      expect(NotificationModel.localizeTitleStatic('Fridge Invitation', true), '📩 คำเชิญเข้าร่วมตู้เย็น');
      expect(NotificationModel.localizeTitleStatic('Expiry Warning', true), '⚠️ แจ้งเตือนอาหารใกล้หมดอายุ');
      expect(NotificationModel.localizeTitleStatic('New Item Added', false), 'New Item Added');
    });

    test('localizes messages into Thai patterns correctly', () {
      const msg1 = 'Tul added "strawberries" (12 punnet) to "Kitchen"';
      final localized1 = NotificationModel.localizeMessageStatic(msg1, true);
      expect(localized1, contains('Tul เพิ่ม "strawberries"'));
      expect(localized1, contains('ในตู้ "Kitchen"'));

      const msg2 = 'Alex ate 1 punnet of "strawberries" in "Kitchen" (7 left)';
      final localized2 = NotificationModel.localizeMessageStatic(msg2, true);
      expect(localized2, contains('Alex'));

      const msg3 = 'wansai finished all "strawberries" in "Kitchen"';
      expect(NotificationModel.localizeMessageStatic(msg3, true), 'wansai รับประทาน "strawberries" ทั้งหมด ในตู้ "Kitchen"');

      const msg4 = 'wansai removed "strawberries" from "Kitchen"';
      expect(NotificationModel.localizeMessageStatic(msg4, true), 'wansai นำ "strawberries" ออกจากตู้ "Kitchen"');

      const msg5 = 'wansai joined "Kitchen" (invited by Tul)';
      expect(NotificationModel.localizeMessageStatic(msg5, true), 'wansai เข้าร่วมตู้ "Kitchen" (ได้รับคำเชิญจาก Tul)');

      const msg6 = 'Tul invited you to join "Kitchen"';
      expect(NotificationModel.localizeMessageStatic(msg6, true), 'Tul เชิญคุณเข้าร่วมตู้ "Kitchen"');

      const msg7 = '"Milk" in "Kitchen" expires in 2 days';
      expect(NotificationModel.localizeMessageStatic(msg7, true), '"Milk" ในตู้ "Kitchen" จะหมดอายุใน 2 วัน');

      const msg8 = '"Milk" in "Kitchen" expires today';
      expect(NotificationModel.localizeMessageStatic(msg8, true), '"Milk" ในตู้ "Kitchen" จะหมดอายุวันนี้');

      const msgFallback = 'Item has 5 bottles and 2 cans left';
      expect(NotificationModel.localizeMessageStatic(msgFallback, true), contains('ขวด'));

      expect(NotificationModel.localizeMessageStatic(msg1, false), msg1);
    });

    test('NotificationModel.fromEntry handles payloadJson and timestamps', () {
      final entry = _FakeNotificationEntry(
        id: 'ne_1',
        userId: 'u1',
        type: 'invite',
        isRead: false,
        payloadJson: '{"title":"Custom Title","message":"Hello","fridge_id":"f1","sub_type":"item_added"}',
        createdAt: DateTime.now(),
      );

      final model = NotificationModel.fromEntry(entry);
      expect(model.title, 'Custom Title');
      expect(model.type, 'item_added');
      expect(model.fridgeId, 'f1');
    });

    test('JSON serialization and copyWith', () {
      final notif = NotificationModel(
        id: 'notif_100',
        userId: 'user_200',
        type: 'expiry',
        title: '⏰ Expiry Alert',
        message: 'Your milk expires in 1 day',
        fridgeId: 'fridge_1',
        itemId: 'item_1',
        isRead: false,
        createdAt: DateTime(2026, 11, 5, 12, 0),
      );

      final json = {
        'id': 'notif_100',
        'userId': 'user_200',
        'type': 'expiry',
        'title': '⏰ Expiry Alert',
        'message': 'Your milk expires in 1 day',
        'fridgeId': 'fridge_1',
        'itemId': 'item_1',
        'isRead': false,
        'createdAt': '2026-11-05T12:00:00.000Z',
      };
      final parsed = NotificationModel.fromJson(json);
      expect(parsed.id, notif.id);
      expect(parsed.isRead, isFalse);
      expect(parsed.type, 'expiry');

      final readNotif = notif.copyWith(isRead: true);
      expect(readNotif.isRead, isTrue);
      expect(readNotif.id, notif.id);
    });

    test('NotificationModel handles auto-titles, future timestamps, and various JSON formats', () {
      final now = DateTime.now();
      final futureDate = now.add(const Duration(hours: 1));

      // Test future timestamp offset correction
      final entryFuture = _FakeNotificationEntry(
        id: 'ne_future',
        userId: 'u1',
        type: 'item_consumed',
        isRead: false,
        payloadJson: '{"message":"Consumed cheese"}',
        createdAt: futureDate,
      );
      final modelFuture = NotificationModel.fromEntry(entryFuture);
      expect(modelFuture.title, 'Item Consumed');
      expect(modelFuture.createdAt.isBefore(now.add(const Duration(minutes: 6))), isTrue);

      // Test fallback titles for all sub_types
      for (final t in ['member_joined', 'item_deleted', 'invite', 'unknown_type']) {
        final e = _FakeNotificationEntry(
          id: 'ne_$t',
          userId: 'u1',
          type: t,
          isRead: true,
          payloadJson: '{}',
          createdAt: now,
        );
        final m = NotificationModel.fromEntry(e);
        expect(m.title, isNotEmpty);
      }

      // Test fromJson with integer is_read and payload object
      final jsonObj = {
        'id': 'notif_obj_1',
        'is_read': 1,
        'type': 'invite',
        'payload': {
          'title': 'Custom Invite',
          'message': 'Come join',
          'fridge_id': 'f_obj',
          'invite_id': 'inv_obj',
        },
        'created_at': futureDate.toIso8601String(),
      };
      final mJson = NotificationModel.fromJson(jsonObj);
      expect(mJson.isRead, isTrue);
      expect(mJson.fridgeId, 'f_obj');
      expect(mJson.inviteId, 'inv_obj');

      // Test fromJson with null createdAt and default title
      final minimalJson = {'id': 'notif_min', 'type': 'item_added'};
      final mMin = NotificationModel.fromJson(minimalJson);
      expect(mMin.title, 'New Item Added');
      expect(mMin.isRead, isFalse);
    });
  });

  group('UserModel Unit Tests', () {
    test('JSON serialization and copyWith avatar clearance', () {
      final user = UserModel(
        id: 'u101',
        username: 'tulbp',
        email: 'tulbp@example.com',
        avatarUrl: 'https://avatar.png',
        updatedAt: DateTime(2026, 11, 1),
      );

      final json = user.toJson();
      expect(json['id'], 'u101');
      expect(json['username'], 'tulbp');
      expect(json['email'], 'tulbp@example.com');

      final fromJson = UserModel.fromJson(json);
      expect(fromJson.id, user.id);
      expect(fromJson.username, user.username);
      expect(fromJson.avatarUrl, 'https://avatar.png');

      final clearedAvatarUser = user.copyWith(clearAvatar: true);
      expect(clearedAvatarUser.avatarUrl, isNull);

      final updatedUsername = user.copyWith(username: 'new_tulbp');
      expect(updatedUsername.username, 'new_tulbp');
      expect(updatedUsername.avatarUrl, 'https://avatar.png');
    });
  });

  group('RecipeModel Unit Tests', () {
    test('localization for cooking time and difficulty', () {
      const recipe = RecipeModel(
        id: 'r1',
        title: 'Strawberry Shortcake',
        cookingTime: '25 mins',
        difficulty: 'Easy',
        imageUrl: 'https://img.jpg',
        assetFallback: 'assets/images/food_lasagna.png',
        expiringIngredient: 'Strawberries',
        ingredients: ['Strawberries', 'Flour', 'Sugar'],
        steps: ['Mix ingredients', 'Bake at 180C'],
      );

      expect(recipe.localizedCookingTime(true), '25 นาที');
      expect(recipe.localizedCookingTime(false), '25 mins');
      expect(recipe.localizedDifficulty(true), 'ง่าย');
      expect(recipe.localizedDifficulty(false), 'Easy');
      expect(recipe.localizedExpiringIngredient(true), 'สตรอว์เบอร์รี');

      final json = recipe.toJson();
      expect(json['title'], 'Strawberry Shortcake');
      expect(json['ingredients'], hasLength(3));

      final fromJson = RecipeModel.fromJson(json);
      expect(fromJson.title, recipe.title);
      expect(fromJson.steps, hasLength(2));
    });
  });

  group('FamilyMemberItem and UserSearchResult Unit Tests', () {
    test('FamilyMemberItem serialization and role checking', () {
      const owner = FamilyMemberItem(
        id: 'm1',
        name: 'Tul',
        role: 'Owner',
        isOwner: true,
        avatarUrl: 'https://avatar.com',
        email: 'tul@test.com',
      );
      expect(owner.isOwner, isTrue);
      expect(owner.role, 'Owner');

      final json = owner.toJson();
      expect(json['role'], 'Owner');

      final parsed = FamilyMemberItem.fromJson({
        'id': 'm2',
        'username': 'Alex',
        'role': 'member',
        'avatar_url': 'https://alex.png',
      });
      expect(parsed.isOwner, isFalse);
      expect(parsed.role, 'Member');
      expect(parsed.name, 'Alex');
    });

    test('UserSearchResult serialization', () {
      final json = {
        'id': 'u202',
        'username': 'bob',
        'status': 'available',
        'avatarUrl': 'https://bob.png',
        'email': 'bob@test.com',
      };
      final result = UserSearchResult.fromJson(json);
      expect(result.id, 'u202');
      expect(result.username, 'bob');
      expect(result.status, 'available');
    });
  });
}
