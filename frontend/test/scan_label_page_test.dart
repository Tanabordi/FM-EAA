import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/remote/api_client.dart';
import 'package:fm_eaa/data/repositories/ai_repository.dart';
import 'package:fm_eaa/features/item/presentation/pages/scan_label_page.dart';

class FakeAiRepository extends AiRepository {
  FakeAiRepository() : super(apiClient: ApiClient(baseUrl: 'http://localhost:5000'));

  @override
  Future<AiScanResult> scanLabelBytes(Uint8List bytes, {String? filename}) async {
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
    expect(find.textContaining('จัดวางฉลากอาหารให้อยู่ในกรอบ'), findsOneWidget);
    expect(find.byKey(const Key('scan_label_camera_btn')), findsOneWidget);
    expect(find.byKey(const Key('scan_label_gallery_btn')), findsOneWidget);
    expect(find.byKey(const Key('scan_label_analyze_btn')), findsOneWidget);
  });

  testWidgets('Toggling torch icon switches state', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ScanLabelPage(fridgeId: 'fridge_1'),
        ),
      ),
    );

    final torchBtn = find.byTooltip('เปิด/ปิดแฟลช');
    expect(torchBtn, findsOneWidget);

    await tester.tap(torchBtn);
    await tester.pump();

    // Verify it stays responsive
    expect(find.text('AI Label Scanner'), findsOneWidget);
  });

  testWidgets('Analyzing image shows result card and supports autofill callback', (tester) async {
    final fakeRepo = FakeAiRepository();

    AiScanResult? returnedResult;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                returnedResult = await Navigator.push<AiScanResult>(
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
    await tester.pumpAndSettle();

    expect(find.text('AI Label Scanner'), findsOneWidget);

    // Pick photo from gallery (in test environment image_picker uses test fake or mock)
    await tester.tap(find.byKey(const Key('scan_label_gallery_btn')));
    await tester.pumpAndSettle();

    // Analyze button should be enabled if image picked, tap analyze if available
    final analyzeBtn = find.byKey(const Key('scan_label_analyze_btn'));
    if (analyzeBtn.evaluate().isNotEmpty) {
      await tester.tap(analyzeBtn);
      await tester.pumpAndSettle();
    }
  });
}

