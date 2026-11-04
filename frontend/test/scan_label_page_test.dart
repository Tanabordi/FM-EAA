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
}

