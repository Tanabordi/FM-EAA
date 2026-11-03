import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/features/fridge_detail/providers/fridge_detail_provider.dart';
import 'package:fm_eaa/features/item/presentation/pages/add_item_page.dart';
import 'package:fm_eaa/features/item/presentation/pages/edit_item_page.dart';
import 'package:fm_eaa/features/item/presentation/pages/item_details_page.dart';
import 'package:fm_eaa/features/item/presentation/widgets/delete_item_dialog.dart';
import 'package:fm_eaa/features/item/presentation/widgets/finish_all_snackbar.dart';
import 'package:fm_eaa/features/item/presentation/widgets/mark_consumed_sheet.dart';

void main() {
  group('Screens #11-16: Ingredient Form and Consumption Flow Tests', () {
    testWidgets('Screen #11: AddItemPage renders all form elements and separate AI Scan card and button', (tester) async {
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

    testWidgets('Screen #11: Tapping analyze without photo does nothing; requires photo first', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddItemPage(fridgeId: 'fridge_kitchen'),
          ),
        ),
      );

      // Tapping analyze before photo is loaded does NOT populate form ("ถ้ายังไม่ใส่รูปกดวิเคราะห์จะไม่เกิดอะไรขึ้น")
      await tester.tap(find.text('ให้ Gemini AI Vision Engine วิเคราะห์'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Avocados'), findsNothing);
      expect(find.text('Scan Label with AI'), findsOneWidget);

      // Tapping Save before analyzing or inputting data does NOT save ("ถ้ายังไม่วิเคราะห์หรือยังไม่ได้ใส่อะไรลงไปไม่สามารถsaveได้ หรือกดไม่ไปนั่นเอง")
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.text('Add items'), findsOneWidget); // still on Add items page, does not pop
    });

    testWidgets('Screen #11: Tapping Scan Label with AI card opens 2 options (Camera/Gallery), loads image, analyzes on button tap, and X clears all data', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddItemPage(fridgeId: 'fridge_kitchen'),
          ),
        ),
      );

      // Verify Scan Label with AI card is visible and tappable
      expect(find.text('Scan Label with AI'), findsOneWidget);
      await tester.tap(find.text('Scan Label with AI'));
      await tester.pumpAndSettle();

      // Check bottom sheet options: exactly 2 options from user request
      expect(find.text('Take Photo with Camera'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);
      expect(find.text('Demo AI Scan (Sample Avocados)'), findsNothing);

      // Tap Choose from Gallery in sheet
      await tester.tap(find.text('Choose from Gallery'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Image is loaded, but form fields are NOT populated yet before analysis
      expect(find.text('Photo Loaded'), findsOneWidget);
      expect(find.text('Photo Selected'), findsOneWidget);
      expect(find.text('Avocados'), findsNothing);

      // Now tap "ให้ Gemini AI Vision Engine วิเคราะห์"
      await tester.tap(find.text('ให้ Gemini AI Vision Engine วิเคราะห์'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Form fields should NOW be populated ("กดวิเคราะห์ข้อมูลถึงมา")
      expect(find.text('Avocados'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('pieces'), findsOneWidget);
      expect(find.text('Fridge'), findsOneWidget);

      // Now test: "ถ้ากด กากบาทออกข้อมูลทั้งหมดในหน้า add itemก้จะหายหมดเหมือนกัน"
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Image and all fields must be cleared
      expect(find.text('Scan Label with AI'), findsOneWidget);
      expect(find.text('Avocados'), findsNothing);
      expect(find.text('Photo Loaded'), findsNothing);

      // User can choose new photo and analyze again ("ถ้าหากจะใส่รูปต้องเลือกรูปที่ใส่ใหม่ได้และกดวิเคราะห์ใหม่ได้")
      await tester.tap(find.text('Scan Label with AI'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Take Photo with Camera'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('Photo Loaded'), findsOneWidget);
      await tester.tap(find.text('ให้ Gemini AI Vision Engine วิเคราะห์'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Avocados'), findsOneWidget);

      // Now tap Save to add the analyzed item to the fridge
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
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

      // Tap camera button to open change photo bottom sheet
      await tester.tap(find.byIcon(Icons.camera_alt_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Change Item Photo'), findsOneWidget);
      expect(find.text('Take Photo with Camera'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);

      // Tap Choose from Gallery in sheet
      await tester.tap(find.text('Choose from Gallery'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Tap Save
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
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
      expect(find.text('ให้ Gemini AI แนะนำเมนูอาหาร'), findsOneWidget);

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

    testWidgets('Screen #16: DeleteItemDialog renders matching title, subtitle, Cancel and red Delete button', (tester) async {
      bool deleteConfirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => DeleteItemDialog(
                      itemId: 'item_strawberries',
                      itemName: 'Strawberries',
                      onConfirm: () {
                        deleteConfirmed = true;
                      },
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify exact text from mockup image
      expect(find.text('Delete Strawberries?'), findsOneWidget);
      expect(find.text('This action cannot be undone'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Tap Delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deleteConfirmed, true);
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

    testWidgets('Screen #11: AddItemPage shows inline validation error on Save without input and discard dialog on back with unsaved edits', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddItemPage(fridgeId: 'fridge_kitchen'),
          ),
        ),
      );

      // Tap Save without entering any food name
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify inline error matching Image 2
      expect(find.text('Food name is required'), findsOneWidget);

      // Type food name
      await tester.enterText(find.byType(TextField).first, 'Organic Eggs');
      await tester.pumpAndSettle();
      expect(find.text('Food name is required'), findsNothing);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify Discard changes dialog matching Image 1
      expect(find.text('Discard changes?'), findsOneWidget);
      expect(find.text('You have unsaved changes. Are you sure you want to discard them?'), findsOneWidget);
      expect(find.text('Keep editing'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);

      // Tap Keep editing
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsNothing);
      expect(find.text('Add items'), findsOneWidget);

      // Tap back again and tap Discard
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
    });

    testWidgets('Screen #13: EditItemPage shows inline validation error on Save with empty name and discard dialog on back with unsaved edits', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: EditItemPage(fridgeId: 'fridge_kitchen', itemId: 'item_strawberries'),
          ),
        ),
      );

      expect(find.text('Edit Item details'), findsOneWidget);

      // Clear food name and tap Save
      await tester.enterText(find.byType(TextField).first, '');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.text('Food name is required'), findsOneWidget);

      // Modify food name and tap back
      await tester.enterText(find.byType(TextField).first, 'Fresh Strawberries');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify Discard changes dialog matching Image 1
      expect(find.text('Discard changes?'), findsOneWidget);
      expect(find.text('You have unsaved changes. Are you sure you want to discard them?'), findsOneWidget);
      expect(find.text('Keep editing'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);

      // Tap Keep editing
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsNothing);
      expect(find.text('Edit Item details'), findsOneWidget);

      // Tap back and Discard
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
    });
  });
}
