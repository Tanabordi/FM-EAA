import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/core/theme/freshness_colors.dart';
import 'package:fm_eaa/data/models/item_model.dart';

void main() {
  group('Expiry Utils and Freshness Status Tests', () {
    test('Calculates Fresh status when expiry date is > 2 days away', () {
      final item = ItemModel(
        id: 'item_1',
        fridgeId: 'fridge_1',
        name: 'Apples',
        category: 'veggies',
        zone: 'fridge',
        quantity: 4,
        unit: 'pieces',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        updatedAt: DateTime.now(),
      );

      expect(item.status, FreshnessStatus.fresh);
      expect(item.statusText, '5 days left');
    });

    test('Calculates Use soon status when expiry date is <= 2 days away', () {
      final item = ItemModel(
        id: 'item_2',
        fridgeId: 'fridge_1',
        name: 'Milk',
        category: 'beverages',
        zone: 'fridge',
        quantity: 1,
        unit: 'bottle',
        expiryDate: DateTime.now().add(const Duration(days: 2)),
        updatedAt: DateTime.now(),
      );

      expect(item.status, FreshnessStatus.useSoon);
      expect(item.statusText, '2 days left');
    });

    test('Calculates Expired status when expiry date is in the past', () {
      final item = ItemModel(
        id: 'item_3',
        fridgeId: 'fridge_1',
        name: 'Yogurt',
        category: 'meals',
        zone: 'fridge',
        quantity: 1,
        unit: 'cup',
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      );

      expect(item.status, FreshnessStatus.expired);
      expect(item.statusText, 'Yesterday');
    });
  });
}

