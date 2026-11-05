import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/remote/api_client.dart';
import 'package:fm_eaa/data/repositories/ai_repository.dart';

void main() {
  late Dio dio;
  late ApiClient apiClient;

  setUp(() {
    dio = Dio();
    apiClient = ApiClient(customDio: dio);
  });

  group('AiScanResult & RecipeSuggestionResult Unit Tests', () {
    test('AiScanResult.notDetected factory', () {
      final notDetected = AiScanResult.notDetected(
        imagePath: '/path/test.jpg',
        message: 'No label',
        isFood: false,
      );
      expect(notDetected.isDetected, isFalse);
      expect(notDetected.isFood, isFalse);
      expect(notDetected.confidence, 0.0);
      expect(notDetected.message, 'No label');
      expect(notDetected.imagePath, '/path/test.jpg');
    });

    test('AiScanResult copyWith', () {
      final original = const AiScanResult(
        foodName: 'Milk',
        category: 'beverages',
        confidence: 0.95,
      );
      final copied = original.copyWith(
        foodName: 'Almond Milk',
        confidence: 0.99,
      );
      expect(copied.foodName, 'Almond Milk');
      expect(copied.category, 'beverages');
      expect(copied.confidence, 0.99);
    });

    test('RecipeSuggestionResult default values', () {
      const result = RecipeSuggestionResult(recipes: []);
      expect(result.recipes, isEmpty);
      expect(result.usedDailyQuota, 1);
      expect(result.maxDailyQuota, 3);
      expect(result.remainingDailyQuota, 2);
      expect(result.isFromAi, isTrue);
    });
  });

  group('AiRepository detectCategory Unit Tests', () {
    test('explicit categories take precedence', () {
      expect(AiRepository.detectCategory('random text', 'proteins'), 'proteins');
      expect(AiRepository.detectCategory('random text', 'veggies'), 'veggies');
      expect(AiRepository.detectCategory('random text', 'beverages'), 'beverages');
      expect(AiRepository.detectCategory('random text', 'meals'), 'meals');
      expect(AiRepository.detectCategory('random text', 'sauces'), 'sauces');
    });

    test('detects beverage keywords', () {
      expect(AiRepository.detectCategory('Whole Milk'), 'beverages');
      expect(AiRepository.detectCategory('Cold Brew Coffee'), 'beverages');
      expect(AiRepository.detectCategory('ชาเขียวมัทฉะ'), 'beverages');
      expect(AiRepository.detectCategory('น้ำส้มคั้น'), 'beverages');
      expect(AiRepository.detectCategory('น้ำเปล่า'), 'beverages');
    });

    test('detects sauce keywords', () {
      expect(AiRepository.detectCategory('Mayonnaise dip'), 'sauces');
      expect(AiRepository.detectCategory('ซอสมะเขือเทศโรซ่า'), 'sauces');
      expect(AiRepository.detectCategory('น้ำปลาแท้'), 'sauces');
      expect(AiRepository.detectCategory('ซีอิ๊วขาว'), 'sauces');
      expect(AiRepository.detectCategory('Strawberry Jam'), 'sauces');
    });

    test('detects veggie and fruit keywords', () {
      expect(AiRepository.detectCategory('Spinach Leaves'), 'veggies');
      expect(AiRepository.detectCategory('มะเขือเทศเชอรี่'), 'veggies');
      expect(AiRepository.detectCategory('Fresh Strawberries'), 'veggies');
      expect(AiRepository.detectCategory('กล้วยหอมทอง'), 'veggies');
      expect(AiRepository.detectCategory('Carrots'), 'veggies');
      expect(AiRepository.detectCategory('แตงกวาญี่ปุ่น'), 'veggies');
    });

    test('detects meal keywords', () {
      expect(AiRepository.detectCategory('Spaghetti Bolognese'), 'meals');
      expect(AiRepository.detectCategory('ข้าวผัดกระเพรา'), 'meals');
      expect(AiRepository.detectCategory('Whole wheat bread'), 'meals');
      expect(AiRepository.detectCategory('Pizza Margherita'), 'meals');
      expect(AiRepository.detectCategory('ก๋วยเตี๋ยวเรือ'), 'meals');
    });

    test('defaults to proteins for meat, poultry, seafood, or unknown', () {
      expect(AiRepository.detectCategory('Chicken Breast'), 'proteins');
      expect(AiRepository.detectCategory('Pork Belly'), 'proteins');
      expect(AiRepository.detectCategory('Salmon Fillet'), 'proteins');
      expect(AiRepository.detectCategory('Tofu'), 'proteins');
      expect(AiRepository.detectCategory('Unknown Item'), 'proteins');
    });
  });

  group('AiRepository estimateShelfLife Unit Tests', () {
    test('estimates proteins shelf life in fridge and freezer', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final freshFish = AiRepository.estimateShelfLife('Salmon', category: 'proteins', storage: 'Fridge');
      expect(freshFish.difference(today).inDays, 2);

      final eggs = AiRepository.estimateShelfLife('Eggs', category: 'proteins', storage: 'Fridge');
      expect(eggs.difference(today).inDays, 21);

      final sausage = AiRepository.estimateShelfLife('Sausage', category: 'proteins', storage: 'Fridge');
      expect(sausage.difference(today).inDays, 7);

      final tofu = AiRepository.estimateShelfLife('Tofu', category: 'proteins', storage: 'Fridge');
      expect(tofu.difference(today).inDays, 5);

      final chicken = AiRepository.estimateShelfLife('Chicken', category: 'proteins', storage: 'Fridge');
      expect(chicken.difference(today).inDays, 3);

      final frozenMeat = AiRepository.estimateShelfLife('Beef', category: 'proteins', storage: 'Freezer');
      expect(frozenMeat.difference(today).inDays, 90);
    });

    test('estimates veggies shelf life in fridge and freezer', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final spinach = AiRepository.estimateShelfLife('Spinach', category: 'veggies', storage: 'Fridge');
      expect(spinach.difference(today).inDays, 5);

      final berries = AiRepository.estimateShelfLife('Strawberry', category: 'veggies', storage: 'Fridge');
      expect(berries.difference(today).inDays, 4);

      final apple = AiRepository.estimateShelfLife('Apple', category: 'veggies', storage: 'Fridge');
      expect(apple.difference(today).inDays, 14);

      final tomato = AiRepository.estimateShelfLife('Tomato', category: 'veggies', storage: 'Fridge');
      expect(tomato.difference(today).inDays, 7);

      final frozenVeg = AiRepository.estimateShelfLife('Broccoli', category: 'veggies', storage: 'Freezer');
      expect(frozenVeg.difference(today).inDays, 180);
    });

    test('estimates beverages shelf life', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final milk = AiRepository.estimateShelfLife('Fresh Milk', category: 'beverages', storage: 'Fridge');
      expect(milk.difference(today).inDays, 7);

      final juice = AiRepository.estimateShelfLife('Orange Juice', category: 'beverages', storage: 'Fridge');
      expect(juice.difference(today).inDays, 5);

      final water = AiRepository.estimateShelfLife('Drinking Water', category: 'beverages', storage: 'Fridge');
      expect(water.difference(today).inDays, 30);
    });

    test('estimates meals and sauces shelf life', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final bread = AiRepository.estimateShelfLife('Bread', category: 'meals', storage: 'Fridge');
      expect(bread.difference(today).inDays, 5);

      final noodles = AiRepository.estimateShelfLife('Noodles', category: 'meals', storage: 'Fridge');
      expect(noodles.difference(today).inDays, 90);

      final cookedMeal = AiRepository.estimateShelfLife('Curry', category: 'meals', storage: 'Fridge');
      expect(cookedMeal.difference(today).inDays, 3);

      final mayo = AiRepository.estimateShelfLife('Mayonnaise', category: 'sauces', storage: 'Fridge');
      expect(mayo.difference(today).inDays, 30);

      final soySauce = AiRepository.estimateShelfLife('Soy Sauce', category: 'sauces', storage: 'Fridge');
      expect(soySauce.difference(today).inDays, 90);
    });
  });

  group('AiRepository translateThaiToEnglish Unit Tests', () {
    test('translates common Thai ingredients to English', () {
      expect(AiRepository.translateThaiToEnglish('ค็อกเทลรมควัน'), 'Smoked Cocktail Sausage');
      expect(AiRepository.translateThaiToEnglish('อกไก่'), 'Chicken Breast');
      expect(AiRepository.translateThaiToEnglish('หมูสับ'), 'Minced Pork');
      expect(AiRepository.translateThaiToEnglish('ไข่ไก่'), 'Eggs');
      expect(AiRepository.translateThaiToEnglish('สตรอว์เบอร์รี'), 'Strawberries');
      expect(AiRepository.translateThaiToEnglish('แอปเปิ้ล'), 'Apples');
      expect(AiRepository.translateThaiToEnglish('กุ้งสด'), 'Shrimp');
      expect(AiRepository.translateThaiToEnglish(''), '');
      expect(AiRepository.translateThaiToEnglish('Custom Item'), 'Custom Item');
    });
  });

  group('AiRepository getSuggestedRecipes Unit Tests', () {
    test('generates fallback recipes when offline or testing', () async {
      final repo = AiRepository(apiClient: apiClient);
      final res = await repo.getSuggestedRecipes('Strawberries', language: 'en');

      expect(res.recipes, isNotEmpty);
      expect(res.usedDailyQuota, 1);
      expect(res.maxDailyQuota, 3);
      expect(res.isFromAi, isFalse);

      final resTh = await repo.getSuggestedRecipes('ไข่ไก่', language: 'th');
      expect(resTh.recipes, isNotEmpty);
    });

    test('scanExpiryBytes returns estimate in test environment', () async {
      final repo = AiRepository(apiClient: apiClient);
      final expiry = await repo.scanExpiryBytes(Uint8List.fromList([1, 2, 3]));
      expect(expiry, isNotNull);
    });
  });
}
