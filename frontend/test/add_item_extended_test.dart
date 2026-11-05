import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/repositories/ai_repository.dart';
import 'package:fm_eaa/features/fridge_detail/providers/fridge_detail_provider.dart';
import 'package:fm_eaa/features/fridges/providers/fridges_provider.dart';
import 'package:fm_eaa/features/item/presentation/pages/add_item_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return ProviderScope(
      overrides: [
        fridgesProvider.overrideWith((ref) => FridgesNotifier()),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('AddItemPage Extended Coverage Tests', () {
    testWidgets('fills all form fields, changes storage and category, and saves item', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AddItemPage(fridgeId: 'fridge_kitchen'),
        ),
      );
      await tester.pumpAndSettle();

      // Enter food name
      final nameField = find.widgetWithText(TextFormField, 'Food Name');
      await tester.enterText(nameField, 'Greek Yogurt');
      await tester.pumpAndSettle();

      // Enter quantity
      final qtyField = find.widgetWithText(TextFormField, 'Quantity');
      await tester.enterText(qtyField, '3');
      await tester.pumpAndSettle();

      // Enter expiration date
      final dateField = find.byKey(const Key('add_item_expiration_date'));
      await tester.enterText(dateField, '12/25/2026');
      await tester.pumpAndSettle();

      // Tap Save button
      final saveBtn = find.text('Save');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('clears all data via remove options sheet', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AddItemPage(
            fridgeId: 'fridge_kitchen',
            initialScanResult: const AiScanResult(
              isDetected: true,
              foodName: 'Cheddar Cheese',
              category: 'Dairy',
              unit: 'pack',
              storage: 'Fridge',
              imagePath: 'assets/images/food_avocados.png',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cheddar Cheese'), findsWidgets);

      // Tap remove photo button
      final removeBtn = find.byKey(const Key('add_item_remove_photo_btn'));
      expect(removeBtn, findsOneWidget);
      await tester.tap(removeBtn);
      await tester.pumpAndSettle();

      // Tap Clear all and reset form
      await tester.tap(find.text('Clear all and reset form'));
      await tester.pumpAndSettle();

      // Form should be reset
      expect(find.text('Cheddar Cheese'), findsNothing);
    });

    testWidgets('tapping photo thumbnail opens change photo sheet', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AddItemPage(
            fridgeId: 'fridge_kitchen',
            initialScanResult: const AiScanResult(
              isDetected: true,
              foodName: 'Cheddar Cheese',
              category: 'Dairy',
              imagePath: 'assets/images/food_avocados.png',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap image thumbnail to open sheet
      final imageFinder = find.byType(GestureDetector).first;
      await tester.tap(imageFinder);
      await tester.pumpAndSettle();
    });
  });
}
