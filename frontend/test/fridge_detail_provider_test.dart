import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/models/item_model.dart';
import 'package:fm_eaa/features/fridge_detail/providers/fridge_detail_provider.dart';

void main() {
  group('FridgeFilterNotifier Unit Tests', () {
    test('default state and setters', () {
      final notifier = FridgeFilterNotifier();
      expect(notifier.state.category, 'All');
      expect(notifier.state.zone, 'fridge');
      expect(notifier.state.searchQuery, '');

      notifier.setCategory('beverages');
      expect(notifier.state.category, 'beverages');

      notifier.setZone('freezer');
      expect(notifier.state.zone, 'freezer');

      notifier.setSearchQuery('Milk');
      expect(notifier.state.searchQuery, 'Milk');
    });
  });

  group('FridgeItemsNotifier Unit Tests', () {
    late FridgeItemsNotifier notifier;
    final now = DateTime.now();

    setUp(() {
      notifier = FridgeItemsNotifier('custom_test_fridge');
    });

    tearDown(() {
      notifier.dispose();
    });

    test('addItem and updateItem modify state correctly', () async {
      final item1 = ItemModel(
        id: 'item_t1',
        fridgeId: 'custom_test_fridge',
        name: 'Orange Juice',
        category: 'beverages',
        zone: 'fridge',
        quantity: 2.0,
        unit: 'bottle',
        expiryDate: now.add(const Duration(days: 7)),
        updatedAt: now,
      );

      await notifier.addItem(item1);
      expect(notifier.state.any((it) => it.id == 'item_t1'), isTrue);
      expect(notifier.state.firstWhere((it) => it.id == 'item_t1').quantity, 2.0);

      // Update
      final updated = item1.copyWith(name: 'Fresh Orange Juice', quantity: 3.0);
      await notifier.updateItem(updated);
      expect(notifier.state.firstWhere((it) => it.id == 'item_t1').name, 'Fresh Orange Juice');
      expect(notifier.state.firstWhere((it) => it.id == 'item_t1').quantity, 3.0);
    });

    test('consumeItem partial, undoConsume, and complete consumption', () async {
      final item2 = ItemModel(
        id: 'item_t2',
        fridgeId: 'custom_test_fridge',
        name: 'Apples',
        category: 'veggies',
        zone: 'fridge',
        quantity: 5.0,
        unit: 'pieces',
        expiryDate: now.add(const Duration(days: 10)),
        updatedAt: now,
      );

      await notifier.addItem(item2);

      // Partial consumption (2 pieces)
      await notifier.consumeItem('item_t2', 2.0, false);
      expect(notifier.state.firstWhere((it) => it.id == 'item_t2').quantity, 3.0);

      // Undo consume
      await notifier.undoConsume();
      expect(notifier.state.firstWhere((it) => it.id == 'item_t2').quantity, 5.0);

      // Complete consumption (finishedAll = true)
      await notifier.consumeItem('item_t2', 5.0, true);
      expect(notifier.state.any((it) => it.id == 'item_t2'), isFalse);

      // Undo finishedAll
      await notifier.undoConsume();
      expect(notifier.state.any((it) => it.id == 'item_t2'), isTrue);
      expect(notifier.state.firstWhere((it) => it.id == 'item_t2').quantity, 5.0);
    });

    test('removeExpiredItems and deleteItem purge items from list', () async {
      final freshItem = ItemModel(
        id: 'item_fresh',
        fridgeId: 'custom_test_fridge',
        name: 'Fresh Milk',
        category: 'beverages',
        zone: 'fridge',
        quantity: 1.0,
        unit: 'bottle',
        expiryDate: now.add(const Duration(days: 5)),
        updatedAt: now,
      );

      final expiredItem = ItemModel(
        id: 'item_old',
        fridgeId: 'custom_test_fridge',
        name: 'Old Yogurt',
        category: 'beverages',
        zone: 'fridge',
        quantity: 1.0,
        unit: 'cup',
        expiryDate: now.subtract(const Duration(days: 3)),
        updatedAt: now,
      );

      await notifier.addItem(freshItem);
      await notifier.addItem(expiredItem);

      expect(notifier.state.any((it) => it.id == 'item_old'), isTrue);
      notifier.removeExpiredItems();
      expect(notifier.state.any((it) => it.id == 'item_old'), isFalse);
      expect(notifier.state.any((it) => it.id == 'item_fresh'), isTrue);

      // Delete fresh item
      await notifier.deleteItem('item_fresh');
      expect(notifier.state.any((it) => it.id == 'item_fresh'), isFalse);
    });
  });
}
