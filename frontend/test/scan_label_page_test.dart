import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/remote/api_client.dart';
import 'package:fm_eaa/data/repositories/ai_repository.dart';
import 'package:fm_eaa/features/item/presentation/pages/scan_label_page.dart';
import 'package:fm_eaa/features/item/presentation/pages/add_item_page.dart';

class FakeAiRepository extends AiRepository {
  FakeAiRepository() : super(apiClient: ApiClient());

  @override
  Future<AiScanResult> scanLabelBytes(Uint8List bytes, {String? filename, String language = 'en'}) async {
    return AiScanResult(
      isDetected: true,
      foodName: 'Almond Milk',
      expiryDate: DateTime(2026, 11, 20),
      category: 'Beverages',
      unit: 'bottle',
      storage: 'Fridge',
    );
  }

  @override
  Future<AiScanResult> scanLabel(File imageFile, {String language = 'en'}) async {
    return AiScanResult(
      isDetected: true,
      foodName: 'Almond Milk',
      expiryDate: DateTime(2026, 11, 20),
      category: 'Beverages',
      unit: 'bottle',
      storage: 'Fridge',
    );
  }
}

class NonFoodAiRepository extends AiRepository {
  NonFoodAiRepository() : super(apiClient: ApiClient());

  @override
  Future<AiScanResult> scanLabelBytes(Uint8List bytes, {String? filename, String language = 'en'}) async {
    return AiScanResult.notDetected(
      message: 'No food label or ingredients detected in image',
      isFood: false,
    );
  }

  @override
  Future<AiScanResult> scanLabel(File imageFile, {String language = 'en'}) async {
    return AiScanResult.notDetected(
      message: 'No food label or ingredients detected in image',
      isFood: false,
    );
  }
}

class MissingExpiryAiRepository extends AiRepository {
  MissingExpiryAiRepository() : super(apiClient: ApiClient());

  @override
  Future<AiScanResult> scanLabelBytes(Uint8List bytes, {String? filename, String language = 'en'}) async {
    return const AiScanResult(
      isDetected: true,
      isFood: true,
      foodName: 'Sprite Zero Sugar',
      expiryDate: null,
      category: 'Beverages',
      unit: 'bottle',
      storage: 'Fridge',
    );
  }

  @override
  Future<AiScanResult> scanLabel(File imageFile, {String language = 'en'}) async {
    return const AiScanResult(
      isDetected: true,
      isFood: true,
      foodName: 'Sprite Zero Sugar',
      expiryDate: null,
      category: 'Beverages',
      unit: 'bottle',
      storage: 'Fridge',
    );
  }

  @override
  Future<DateTime?> scanExpiryDate(File imageFile, {String language = 'en'}) async {
    return DateTime(2027, 8, 15);
  }

  @override
  Future<DateTime?> scanExpiryBytes(Uint8List bytes, {String? filename, String language = 'en'}) async {
    return DateTime(2027, 8, 15);
  }
}

void main() {
  testWidgets('ScanLabelPage renders viewfinder, instructions, and controls', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ScanLabelPage(fridgeId: 'fridge_1'),
        ),
      ),
    );

    expect(find.text('AI Label Scanner'), findsOneWidget);
    expect(find.textContaining('Align food packaging label'), findsOneWidget);
    expect(find.byKey(const Key('scan_label_camera_btn')), findsOneWidget);
    expect(find.byKey(const Key('scan_label_gallery_btn')), findsOneWidget);
    // Analyze button appears after an image is captured or selected
    expect(find.byKey(const Key('scan_label_analyze_btn')), findsNothing);
  });

  testWidgets('Toggling torch icon switches state', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ScanLabelPage(fridgeId: 'fridge_1'),
        ),
      ),
    );

    final torchBtn = find.byTooltip('Toggle Flash');
    expect(torchBtn, findsOneWidget);

    await tester.tap(torchBtn);
    await tester.pump();

    // Verify it stays responsive
    expect(find.text('AI Label Scanner'), findsOneWidget);
  });

  testWidgets('Analyzing image shows result card and supports autofill callback', (tester) async {
    final fakeRepo = FakeAiRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await Navigator.push<AiScanResult>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScanLabelPage(fridgeId: 'fridge_1'),
                  ),
                );
              },
              child: const Text('Launch Scanner'),
            ),
          ),
        ),
      ),
    );

    // Launch scanner
    await tester.tap(find.text('Launch Scanner'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('AI Label Scanner'), findsOneWidget);

    // Pick photo from gallery
    await tester.tap(find.byKey(const Key('scan_label_gallery_btn')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap analyze button
    final analyzeBtn = find.byKey(const Key('scan_label_analyze_btn'));
    expect(analyzeBtn, findsOneWidget);
    await tester.tap(analyzeBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Result card appears with Almond Milk
    expect(find.text('Almond Milk'), findsOneWidget);

    // Tap autofill button
    final autofillBtn = find.byKey(const Key('scan_label_autofill_btn'));
    expect(autofillBtn, findsOneWidget);
    await tester.tap(autofillBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('AddItemPage with initialScanResult properly autofills fields and image', (tester) async {
    final scanResult = AiScanResult(
      isDetected: true,
      foodName: 'Organic Greek Yogurt',
      expiryDate: DateTime(2026, 11, 28),
      category: 'Proteins',
      unit: 'punnet',
      storage: 'Fridge',
      imagePath: 'assets/images/food_avocados.png',
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AddItemPage(
            fridgeId: 'fridge_1',
            initialScanResult: scanResult,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Organic Greek Yogurt'), findsOneWidget);
    expect(find.text('Proteins'), findsOneWidget);
  });

  testWidgets('Non-food scan (e.g. face photo) blocks autofill and shows warning message', (tester) async {
    final fakeRepo = NonFoodAiRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: ScanLabelPage(fridgeId: 'fridge_1'),
        ),
      ),
    );

    // Pick photo
    await tester.tap(find.byKey(const Key('scan_label_gallery_btn')));
    await tester.pumpAndSettle();

    // Tap analyze
    await tester.tap(find.byKey(const Key('scan_label_analyze_btn')));
    await tester.pumpAndSettle();

    // Must show warning: No food label or ingredients detected
    expect(find.text('No food label or ingredients detected'), findsOneWidget);

    // Autofill button MUST NOT exist!
    expect(find.byKey(const Key('scan_label_autofill_btn')), findsNothing);

    // Retake button appears instead
    expect(find.text('Retake Food Photo'), findsOneWidget);
  });

  testWidgets('Two-Step scan appears when initial photo has no expiry date and supports step 2 expiry capture', (tester) async {
    final fakeRepo = MissingExpiryAiRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: ScanLabelPage(fridgeId: 'fridge_1'),
        ),
      ),
    );

    // Pick photo 1
    await tester.tap(find.byKey(const Key('scan_label_gallery_btn')));
    await tester.pumpAndSettle();

    // Tap analyze
    await tester.tap(find.byKey(const Key('scan_label_analyze_btn')));
    await tester.pumpAndSettle();

    // Food name is found
    expect(find.text('Sprite Zero Sugar'), findsOneWidget);
    // Expiry shows not specified
    expect(find.textContaining('Not specified'), findsOneWidget);

    // Step 2 expiry scan button MUST be visible!
    final step2Btn = find.byKey(const Key('scan_label_step2_expiry_btn'));
    expect(step2Btn, findsOneWidget);

    // Tap step 2 expiry scan
    await tester.tap(step2Btn);
    await tester.pumpAndSettle();

    // Expiry date is now extracted and populated!
    expect(find.textContaining('15/8/2027'), findsOneWidget);

    // Now standard autofill button is available
    expect(find.text('Autofill Form Details'), findsOneWidget);
  });

  test('AiRepository.estimateShelfLife calculates biological shelf life correctly', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Proteins: fresh pork in fridge (3 days) vs freezer (90 days)
    final porkFridge = AiRepository.estimateShelfLife('Ground Pork', category: 'Proteins', storage: 'Fridge');
    expect(porkFridge.difference(today).inDays, equals(3));

    final porkFreezer = AiRepository.estimateShelfLife('Ground Pork', category: 'Proteins', storage: 'Freezer');
    expect(porkFreezer.difference(today).inDays, equals(90));

    // Seafood: fresh fish in fridge (2 days)
    final fishFridge = AiRepository.estimateShelfLife('Fresh Salmon', category: 'Proteins', storage: 'Fridge');
    expect(fishFridge.difference(today).inDays, equals(2));

    // Veggies: leafy greens (5 days) vs freezer (180 days)
    final spinachFridge = AiRepository.estimateShelfLife('Spinach', category: 'Veggies', storage: 'Fridge');
    expect(spinachFridge.difference(today).inDays, equals(5));

    final spinachFreezer = AiRepository.estimateShelfLife('Spinach', category: 'Veggies', storage: 'Freezer');
    expect(spinachFreezer.difference(today).inDays, equals(180));

    // Milk: 7 days
    final milkFridge = AiRepository.estimateShelfLife('Fresh Milk', category: 'Beverages', storage: 'Fridge');
    expect(milkFridge.difference(today).inDays, equals(7));
  });

  testWidgets('AddItemPage auto-recalibrates expiry when storage changes if isAiEstimated is true', (tester) async {
    final now = DateTime.now();
    final initialFridgeExpiry = DateTime(now.year, now.month, now.day).add(const Duration(days: 3));

    final scanResult = AiScanResult(
      isDetected: true,
      foodName: 'Minced Pork',
      expiryDate: initialFridgeExpiry,
      category: 'Proteins',
      unit: 'pack',
      storage: 'Fridge',
      isAiEstimated: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AddItemPage(
            fridgeId: 'fridge_1',
            initialScanResult: scanResult,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final m = initialFridgeExpiry.month.toString().padLeft(2, '0');
    final d = initialFridgeExpiry.day.toString().padLeft(2, '0');
    final expectedFridgeStr = '$m/$d/${initialFridgeExpiry.year}';

    final dateFieldFinder = find.byKey(const Key('add_item_expiration_date'));
    expect(find.descendant(of: dateFieldFinder, matching: find.text(expectedFridgeStr)), findsOneWidget);

    // Switch storage from 'Fridge' to 'Freezer'
    final storageDropdownFinder = find.byType(DropdownButtonFormField<String>).last;
    await tester.tap(storageDropdownFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Freezer').last);
    await tester.pumpAndSettle();

    // Verify expiry updated to freezer shelf life (90 days)
    final expectedFreezerExpiry = DateTime(now.year, now.month, now.day).add(const Duration(days: 90));
    final fM = expectedFreezerExpiry.month.toString().padLeft(2, '0');
    final fD = expectedFreezerExpiry.day.toString().padLeft(2, '0');
    final expectedFreezerStr = '$fM/$fD/${expectedFreezerExpiry.year}';

    expect(find.descendant(of: dateFieldFinder, matching: find.text(expectedFreezerStr)), findsOneWidget);
    expect(find.textContaining('Recalculated shelf life for Freezer'), findsOneWidget);

    // Manual user edit: user enters custom date
    await tester.enterText(dateFieldFinder, '12/31/2026');
    await tester.pumpAndSettle();

    // Switch storage back to 'Fridge'
    await tester.tap(storageDropdownFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fridge').last);
    await tester.pumpAndSettle();

    // Must NOT overwrite user's manual date!
    expect(find.descendant(of: dateFieldFinder, matching: find.text('12/31/2026')), findsOneWidget);
  });
}

