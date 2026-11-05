import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/models/item_model.dart';
import 'package:fm_eaa/data/models/notification_model.dart';

void main() {
  group('Food Name Language Preservation Tests', () {
    test('ItemModel.localizedName preserves English food name in both EN and TH modes', () {
      final item = ItemModel(
        id: '1',
        fridgeId: 'fridge_1',
        name: 'Baby Cocktail Sausage',
        category: 'proteins',
        zone: 'fridge',
        quantity: 1,
        unit: 'pack',
        expiryDate: DateTime.now().add(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      );

      // In English mode (isTh = false)
      expect(item.localizedName(false), 'Baby Cocktail Sausage');
      // In Thai mode (isTh = true) -> MUST NOT TRANSLATE TO THAI
      expect(item.localizedName(true), 'Baby Cocktail Sausage');
    });

    test('ItemModel.localizedName preserves Thai food name in both EN and TH modes', () {
      final item = ItemModel(
        id: '2',
        fridgeId: 'fridge_1',
        name: 'ดัชมิล โยเกิร์ต',
        category: 'beverages',
        zone: 'fridge',
        quantity: 1,
        unit: 'punnet',
        expiryDate: DateTime.now().add(const Duration(days: 8)),
        updatedAt: DateTime.now(),
      );

      // In English mode (isTh = false) -> MUST NOT TRANSLATE TO ENGLISH
      expect(item.localizedName(false), 'ดัชมิล โยเกิร์ต');
      // In Thai mode (isTh = true)
      expect(item.localizedName(true), 'ดัชมิล โยเกิร์ต');
    });

    test('ItemModel.localizedName preserves dictionary-listed items without translation', () {
      final beef = ItemModel(
        id: '3',
        fridgeId: 'fridge_1',
        name: 'Beef Steak',
        category: 'proteins',
        zone: 'freezer',
        quantity: 2,
        unit: 'pieces',
        expiryDate: DateTime.now().add(const Duration(days: 90)),
        updatedAt: DateTime.now(),
      );

      expect(beef.localizedName(false), 'Beef Steak');
      expect(beef.localizedName(true), 'Beef Steak'); // NOT "สเต็กเนื้อวัว"
    });

    test('ItemModel unit localization still works properly while food name is untouched', () {
      final item = ItemModel(
        id: '4',
        fridgeId: 'fridge_1',
        name: 'Ice Cubes',
        category: 'meals',
        zone: 'freezer',
        quantity: 1,
        unit: 'pieces',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        updatedAt: DateTime.now(),
      );

      expect(item.formattedQuantityLocalized(false), '1 pieces');
      expect(item.formattedQuantityLocalized(true), '1 ชิ้น');
      expect(item.localizedName(true), 'Ice Cubes');
    });

    test('NotificationModel preserves food names inside notification messages', () {
      const rawAdd = 'wansai added "Beef Steak" (2 pieces) to "Ulnwza"';
      final thAdd = NotificationModel.localizeMessageStatic(rawAdd, true);
      expect(thAdd, 'wansai เพิ่ม "Beef Steak" (2 ชิ้น) ในตู้ "Ulnwza"');

      const rawThaiAdd = 'wansai added "ดัชมิล โยเกิร์ต" (1 punnet) to "Ulnwza"';
      final thThaiAdd = NotificationModel.localizeMessageStatic(rawThaiAdd, true);
      expect(thThaiAdd, 'wansai เพิ่ม "ดัชมิล โยเกิร์ต" (1 ตะกร้า) ในตู้ "Ulnwza"');

      const rawAte = 'RRR ate 1 pack of "Baby Cocktail Sausage" in "Ulnwza" (2 pack left)';
      final thAte = NotificationModel.localizeMessageStatic(rawAte, true);
      expect(thAte, 'RRR รับประทาน "Baby Cocktail Sausage" 1 แพ็ค ในตู้ "Ulnwza" (เหลือ 2 แพ็ค)');
    });
  });
}
