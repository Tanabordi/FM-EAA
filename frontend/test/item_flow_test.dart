import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/features/fridge_detail/providers/fridge_detail_provider.dart';
import 'package:fm_eaa/features/item/presentation/pages/add_item_page.dart';
import 'package:fm_eaa/features/item/presentation/pages/edit_item_page.dart';
import 'package:fm_eaa/features/item/presentation/pages/item_details_page.dart';
import 'package:fm_eaa/features/item/presentation/widgets/finish_all_snackbar.dart';
import 'package:fm_eaa/features/item/presentation/widgets/mark_consumed_sheet.dart';

void main() {
  group('Screens #11-16: Ingredient Form and Consumption Flow Tests', () {
    testWidgets('Screen #11: AddItemPage renders all form elements and AI Scan card', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddItemPage(fridgeId: 'fridge_kitchen'),
          ),
        ),
      );

      // Verify Header
      expect(find.text('Add items'), findsOneWidget);

      // Verify AI scan card and Gemini button
      expect(find.text('Scan Label with AI'), findsOneWidget);
      expect(find.text("Capture the label. We'll fill in the details."), findsOneWidget);
      expect(find.text('ให้ Gemini AI Vision Engine วิเคราะห์'), findsOneWidget);

      // Verify Form inputs
      expect(find.text('Food Name'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Quantity'), findsOneWidget);
      expect(find.text('Unit'), findsOneWidget);
      expect(find.text('Storage Location'), findsOneWidget);
      expect(find.text('Expiration Date'), findsOneWidget);
      expect(find.text('Use-by or best-before date'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('Screen #11: Tapping Gemini AI button populates form fields with detected food', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddItemPage(fridgeId: 'fridge_kitchen'),
          ),
        ),
      );

      // Tap Gemini AI Vision Engine button
      await tester.tap(find.text('ให้ Gemini AI Vision Engine วิเคราะห์'));
      await tester.pump();

      // Check fields are populated
      expect(find.text('Avocados'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('pieces'), findsOneWidget);
      expect(find.text('Fridge'), findsOneWidget);
    });

    testWidgets('Screen #12: ItemDetailsPage renders title, badge, tags, and action buttons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ItemDetailsPage(fridgeId: 'fridge_kitchen', itemId: 'item_strawberries'),
          ),
        ),
      );

      // Verify Title & Header
      expect(find.text('item details'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);

      // Verify Item info
      expect(find.text('Strawberries'), findsOneWidget);
      expect(find.text('Veggies'), findsOneWidget);
      expect(find.text('Fridge'), findsOneWidget);

      // Verify Action buttons
      expect(find.text('Mark as Consumed'), findsOneWidget);
      expect(find.text('Delete Item'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('Screen #13: EditItemPage renders pre-filled form with camera button and Save', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: EditItemPage(fridgeId: 'fridge_kitchen', itemId: 'item_strawberries'),
          ),
        ),
      );

      expect(find.text('Edit Item details'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
      expect(find.text('Strawberries'), findsOneWidget);
      expect(find.text('Veggies'), findsOneWidget);
      expect(find.text('Fridge'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('Screens #14 & #15: MarkConsumedSheet renders stepper, Confirm, and Finished all buttons', (tester) async {
      double? consumedAmount;
      bool? isFinishedAll;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkConsumedSheet(
              itemName: 'Avocados',
              availablePieces: 2,
              unit: 'pieces',
              onConsumed: (amount, finishedAll) {
                consumedAmount = amount;
                isFinishedAll = finishedAll;
              },
            ),
          ),
        ),
      );

      expect(find.text('How much did you consume?'), findsOneWidget);
      expect(find.text('Avocados · 2 pieces in fridge'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('of 2 pieces'), findsOneWidget);

      // Test Stepper [+]
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);

      // Test Confirm Button
      await tester.tap(find.text('Confirm'));
      expect(consumedAmount, 2.0);
      expect(isFinishedAll, false);

      // Test Finished all Button
      await tester.tap(find.text('Finished all'));
      expect(consumedAmount, 2.0);
      expect(isFinishedAll, true);
    });

    testWidgets('Screen #16: FinishAllSnackbar displays consumed confirmation and Undo restores item', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(fridgeItemsProvider('fridge_kitchen').notifier);

      final initialCount = container.read(fridgeItemsProvider('fridge_kitchen')).length;

      // Consume 'Whole milk' completely
      notifier.consumeItem('item_milk', 1, true);

      final countAfterConsume = container.read(fridgeItemsProvider('fridge_kitchen')).length;
      expect(countAfterConsume, initialCount - 1);
      expect(container.read(fridgeItemsProvider('fridge_kitchen')).any((it) => it.id == 'item_milk'), false);

      // Render SnackBar with Undo
      bool undoClicked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  FinishAllSnackbar.show(
                    context,
                    itemName: 'Whole milk',
                    onUndo: () {
                      undoClicked = true;
                      notifier.undoConsume();
                    },
                  );
                },
                child: const Text('Show SnackBar'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show SnackBar'));
      await tester.pumpAndSettle();

      // Verify SnackBar content
      expect(find.text('Whole milk marked as consumed'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      // Tap Undo
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(undoClicked, true);
      // Item restored!
      final countAfterUndo = container.read(fridgeItemsProvider('fridge_kitchen')).length;
      expect(countAfterUndo, initialCount);
      expect(container.read(fridgeItemsProvider('fridge_kitchen')).any((it) => it.id == 'item_milk'), true);
    });
  });
}
