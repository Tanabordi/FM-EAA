import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/remote/api_client.dart';
import 'package:fm_eaa/data/repositories/ai_repository.dart';
import 'package:fm_eaa/shared/utils/environment.dart';

void main() {
  late Dio dio;
  late ApiClient apiClient;

  setUp(() {
    dio = Dio();
    apiClient = ApiClient(customDio: dio);
    setTestEnvironmentOverride(null);
  });

  tearDown(() {
    setTestEnvironmentOverride(null);
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
      const original = AiScanResult(
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
      expect(AiRepository.detectCategory('Milk'), 'beverages');
      expect(AiRepository.detectCategory('Iced Latte'), 'beverages');
      expect(AiRepository.detectCategory('Orange Juice'), 'beverages');
      expect(AiRepository.detectCategory('Mineral Water'), 'beverages');
      expect(AiRepository.detectCategory('Green Tea'), 'beverages');
      expect(AiRepository.detectCategory('นมสด'), 'beverages');
    });

    test('detects sauce keywords', () {
      expect(AiRepository.detectCategory('Tomato Ketchup'), 'sauces');
      expect(AiRepository.detectCategory('Soy Sauce'), 'sauces');
      expect(AiRepository.detectCategory('Salad Dressing'), 'sauces');
      expect(AiRepository.detectCategory('Mayonnaise'), 'sauces');
      expect(AiRepository.detectCategory('น้ำปลา'), 'sauces');
    });

    test('detects veggie and fruit keywords', () {
      expect(AiRepository.detectCategory('Carrots'), 'veggies');
      expect(AiRepository.detectCategory('Apples'), 'veggies');
      expect(AiRepository.detectCategory('Spinach'), 'veggies');
      expect(AiRepository.detectCategory('Garlic'), 'veggies');
      expect(AiRepository.detectCategory('เห็ดหอม'), 'veggies');
    });

    test('detects meal keywords', () {
      expect(AiRepository.detectCategory('Ramen Noodles'), 'meals');
      expect(AiRepository.detectCategory('Fried Rice'), 'meals');
      expect(AiRepository.detectCategory('Curry'), 'meals');
      expect(AiRepository.detectCategory('Sandwich'), 'meals');
      expect(AiRepository.detectCategory('ข้าวผัด'), 'meals');
    });

    test('defaults to proteins for meat, poultry, seafood, or unknown', () {
      expect(AiRepository.detectCategory('Chicken Breast'), 'proteins');
      expect(AiRepository.detectCategory('Pork Loin'), 'proteins');
      expect(AiRepository.detectCategory('Salmon Fillet'), 'proteins');
      expect(AiRepository.detectCategory('Tofu'), 'proteins');
      expect(AiRepository.detectCategory('Eggs'), 'proteins');
      expect(AiRepository.detectCategory('Unknown Item XYZ'), 'proteins');
    });
  });

  group('AiRepository estimateShelfLife Unit Tests', () {
    test('estimates proteins shelf life in fridge and freezer', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final chickenFridge = AiRepository.estimateShelfLife('Chicken Breast', category: 'proteins', storage: 'Fridge');
      expect(chickenFridge.difference(today).inDays, 3);

      final chickenFreezer = AiRepository.estimateShelfLife('Chicken Breast', category: 'proteins', storage: 'Freezer');
      expect(chickenFreezer.difference(today).inDays, 90);

      final porkFridge = AiRepository.estimateShelfLife('Pork', category: 'proteins', storage: 'Fridge');
      expect(porkFridge.difference(today).inDays, 3);

      final fishFridge = AiRepository.estimateShelfLife('Salmon', category: 'proteins', storage: 'Fridge');
      expect(fishFridge.difference(today).inDays, 2);

      final eggFridge = AiRepository.estimateShelfLife('Eggs', category: 'proteins', storage: 'Fridge');
      expect(eggFridge.difference(today).inDays, 21);

      final tofuFridge = AiRepository.estimateShelfLife('Tofu', category: 'proteins', storage: 'Fridge');
      expect(tofuFridge.difference(today).inDays, 5);
    });

    test('estimates veggies shelf life in fridge and freezer', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final spinachFridge = AiRepository.estimateShelfLife('Spinach', category: 'veggies', storage: 'Fridge');
      expect(spinachFridge.difference(today).inDays, 5);

      final carrotsFridge = AiRepository.estimateShelfLife('Carrots', category: 'veggies', storage: 'Fridge');
      expect(carrotsFridge.difference(today).inDays, 14);

      final applesFridge = AiRepository.estimateShelfLife('Apples', category: 'veggies', storage: 'Fridge');
      expect(applesFridge.difference(today).inDays, 14);

      final berriesFridge = AiRepository.estimateShelfLife('Strawberries', category: 'veggies', storage: 'Fridge');
      expect(berriesFridge.difference(today).inDays, 4);

      final bananasFridge = AiRepository.estimateShelfLife('Bananas', category: 'veggies', storage: 'Fridge');
      expect(bananasFridge.difference(today).inDays, 4);
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

  group('AiRepository Smart Fallback Recipes for all categories', () {
    test('exercises fallback recipe generator across all categories, languages, and offsets', () async {
      final repo = AiRepository(apiClient: apiClient);

      // Beverages
      final bevEn = await repo.getSuggestedRecipes('Milk', category: 'beverages', language: 'en', offset: 0);
      expect(bevEn.recipes, isNotEmpty);
      final bevTh = await repo.getSuggestedRecipes('นมสด', category: 'beverages', language: 'th', offset: 1);
      expect(bevTh.recipes, isNotEmpty);

      // Sauces
      final sauceEn = await repo.getSuggestedRecipes('Ketchup', category: 'sauces', language: 'en', offset: 0);
      expect(sauceEn.recipes, isNotEmpty);
      final sauceTh = await repo.getSuggestedRecipes('ซีอิ๊วขาว', category: 'sauces', language: 'th', offset: 1);
      expect(sauceTh.recipes, isNotEmpty);

      // Meals
      final mealEn = await repo.getSuggestedRecipes('Fried Rice', category: 'meals', language: 'en', offset: 0);
      expect(mealEn.recipes, isNotEmpty);
      final mealTh = await repo.getSuggestedRecipes('ข้าวผัด', category: 'meals', language: 'th', offset: 1);
      expect(mealTh.recipes, isNotEmpty);

      // Veggies
      final vegEn = await repo.getSuggestedRecipes('Carrot', category: 'veggies', language: 'en', offset: 0);
      expect(vegEn.recipes, isNotEmpty);
      final vegTh = await repo.getSuggestedRecipes('แครอท', category: 'veggies', language: 'th', offset: 1);
      expect(vegTh.recipes, isNotEmpty);

      // Proteins
      final protEn = await repo.getSuggestedRecipes('Pork', category: 'proteins', language: 'en', offset: 0);
      expect(protEn.recipes, isNotEmpty);
      final protTh = await repo.getSuggestedRecipes('หมู', category: 'proteins', language: 'th', offset: 2);
      expect(protTh.recipes, isNotEmpty);
    });
  });

  group('AiRepository Remote API Scanning Tests with Interceptor', () {
    test('scanLabelBytes handles successful food recognition from API', () async {
      setTestEnvironmentOverride(false);

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/ai/scan-label')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'is_food': true,
                    'foodName': 'ดัชมิลล์ นมสด',
                    'expiryDate': '2026-11-28',
                    'category': 'Beverages',
                    'storage': 'Fridge',
                    'unit': 'bottle',
                    'confidence': 0.96,
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final repo = AiRepository(apiClient: apiClient);
      final result = await repo.scanLabelBytes(Uint8List.fromList([1, 2, 3]), language: 'th');
      expect(result.isDetected, isTrue);
      expect(result.foodName, 'ดัชมิลล์ นมสด');
      expect(result.category, 'Beverages');
      expect(result.unit, 'bottle');
    });

    test('scanLabelBytes handles non-food response from API', () async {
      setTestEnvironmentOverride(false);

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'is_food': false,
                  'foodName': null,
                },
              ),
            );
          },
        ),
      );

      final repo = AiRepository(apiClient: apiClient);
      final result = await repo.scanLabelBytes(Uint8List.fromList([1, 2, 3]));
      expect(result.isDetected, isFalse);
      expect(result.isFood, isFalse);
    });

    test('scanExpiryBytes handles expiry_only response from API', () async {
      setTestEnvironmentOverride(false);

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'expiryDate': '2027-02-15',
                  'confidence': 0.95,
                },
              ),
            );
          },
        ),
      );

      final repo = AiRepository(apiClient: apiClient);
      final date = await repo.scanExpiryBytes(Uint8List.fromList([1, 2, 3]));
      expect(date, DateTime(2027, 2, 15));
    });

    test('getSuggestedRecipes receives valid recipe payload from API', () async {
      setTestEnvironmentOverride(false);

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/ai/recipes')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'recipes': [
                      {
                        'id': 'api_r1',
                        'title': 'Garlic Salmon',
                        'description': 'Delicious grilled salmon',
                        'cookingTime': '15 mins',
                        'difficulty': 'Easy',
                        'dishType': 'stir_fry',
                        'expiringIngredient': 'Salmon',
                        'imageUrl': 'https://example.com/salmon.jpg',
                        'ingredients': ['Salmon', 'Garlic'],
                        'steps': ['Pan sear salmon', 'Add garlic'],
                      }
                    ],
                    'usedDailyQuota': 2,
                    'maxDailyQuota': 3,
                    'remainingDailyQuota': 1,
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final repo = AiRepository(apiClient: apiClient);
      final res = await repo.getSuggestedRecipes('Salmon', category: 'proteins', language: 'en');
      expect(res.recipes, hasLength(1));
      expect(res.recipes.first.title, 'Garlic Salmon');
      expect(res.usedDailyQuota, 2);
      expect(res.remainingDailyQuota, 1);
      expect(res.isFromAi, isTrue);
    });

    test('getSuggestedRecipes gracefully handles API 429 quota exhaustion', () async {
      setTestEnvironmentOverride(false);

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 429,
                  data: {'error': 'Quota exceeded'},
                ),
              ),
            );
          },
        ),
      );

      final repo = AiRepository(apiClient: apiClient);
      expect(
        () => repo.getSuggestedRecipes('Pork', category: 'proteins', language: 'en'),
        throwsA(isA<Exception>()),
      );
    });

    test('scanLabel and scanExpiryDate with real File handling and Dio responses', () async {
      setTestEnvironmentOverride(false);

      final tempDir = Directory.systemTemp.createTempSync('ai_test');
      final testFile = File('${tempDir.path}/test_strawberries.jpg');
      testFile.writeAsBytesSync(Uint8List.fromList([1, 2, 3, 4]));

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('scan-label')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'is_food': true,
                    'foodName': 'Strawberries',
                    'category': 'fruits',
                    'expiryDate': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
                  },
                ),
              );
            }
            if (options.path.contains('scan-expiry')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'expiryDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final repo = AiRepository(apiClient: apiClient);
      final labelRes = await repo.scanLabel(testFile, language: 'en');
      expect(labelRes.foodName, 'Strawberries');
      expect(labelRes.isFood, isTrue);

      final expRes = await repo.scanExpiryDate(testFile, language: 'en');
      expect(expRes, isNotNull);

      tempDir.deleteSync(recursive: true);
    });
  });
}
