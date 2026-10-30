import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/models/fridge_model.dart';
import 'package:fm_eaa/features/fridges/presentation/pages/add_fridge_page.dart';
import 'package:fm_eaa/features/fridges/presentation/pages/my_fridges_page.dart';
import 'package:fm_eaa/features/fridges/presentation/widgets/cute_fridge_illustration.dart';
import 'package:fm_eaa/features/fridges/presentation/widgets/delete_fridge_dialog.dart';
import 'package:fm_eaa/features/fridges/presentation/widgets/edit_fridge_sheet.dart';
import 'package:fm_eaa/features/fridges/providers/fridges_provider.dart';

void main() {
  group('FridgeModel Unit Tests', () {
    test('Calculates isPersonal correctly', () {
      final personalFridge = FridgeModel(
        id: '1',
        name: 'Studio',
        ownerId: 'u1',
        memberCount: 1,
        updatedAt: DateTime.now(),
      );
      expect(personalFridge.isPersonal, isTrue);

      final sharedFridge = FridgeModel(
        id: '2',
        name: 'Family',
        ownerId: 'u1',
        memberCount: 3,
        updatedAt: DateTime.now(),
      );
      expect(sharedFridge.isPersonal, isFalse);
    });

    test('Formats itemsCountText correctly', () {
      final emptyFridge = FridgeModel(
        id: '1',
        name: 'Empty Fridge',
        ownerId: 'u1',
        itemCount: 0,
        updatedAt: DateTime.now(),
      );
      expect(emptyFridge.itemsCountText, 'Empty');

      final filledFridge = FridgeModel(
        id: '2',
        name: 'Full Fridge',
        ownerId: 'u1',
        itemCount: 35,
        updatedAt: DateTime.now(),
      );
      expect(filledFridge.itemsCountText, '35 Items');
    });

    test('copyWith updates specified fields', () {
      final original = FridgeModel(
        id: 'f1',
        name: 'Old Name',
        description: 'Old Desc',
        ownerId: 'u1',
        memberCount: 2,
        itemCount: 5,
        updatedAt: DateTime.now(),
      );

      final updated = original.copyWith(
        name: 'New Name',
        description: 'New Desc',
      );

      expect(updated.id, 'f1');
      expect(updated.name, 'New Name');
      expect(updated.description, 'New Desc');
      expect(updated.memberCount, 2);
      expect(updated.itemCount, 5);
    });
  });

  group('FridgesNotifier Unit Tests', () {
    test('supports startEmpty, add, update, remove, and loadMockData', () {
      final notifier = FridgesNotifier(startEmpty: true);
      expect(notifier.state.isEmpty, isTrue);

      // Load mock data
      notifier.loadMockData();
      expect(notifier.state.length, 2);

      // Add
      notifier.addFridge('Office Fridge', '3rd floor');
      expect(notifier.state.length, 3);
      final added = notifier.state.last;
      expect(added.name, 'Office Fridge');
      expect(added.description, '3rd floor');

      // Update
      notifier.updateFridge(added.id, 'Office Mini Fridge', '4th floor');
      final updated = notifier.state.firstWhere((f) => f.id == added.id);
      expect(updated.name, 'Office Mini Fridge');
      expect(updated.description, '4th floor');

      // Remove
      notifier.removeFridge(added.id);
      expect(notifier.state.length, 2);

      // Clear all
      notifier.clearAll();
      expect(notifier.state.isEmpty, isTrue);
    });
  });

  group('Screens #5–8 Widget Tests', () {
    testWidgets('Screen #5 Empty State (Image 1): renders cute fridge, text, and Add First Fridge button', (tester) async {
      final container = ProviderContainer(
        overrides: [
          fridgesProvider.overrideWith((ref) => FridgesNotifier(startEmpty: true)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: MyFridgesPage(),
          ),
        ),
      );

      // Verify title
      expect(find.text('My Fridges'), findsOneWidget);

      // Verify empty state elements (Image 1)
      expect(find.byType(CuteFridgeIllustration), findsOneWidget);
      expect(find.text('No fridges yet'), findsOneWidget);
      expect(find.text('Create your first fridge space to start\ntracking your food'), findsOneWidget);
      expect(find.text('Add First Fridge'), findsOneWidget);

      // Verify NO FAB when empty
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('Screen #5 Populated State (Image 2 / 10): renders banner, header, and 2-column grid cards', (tester) async {
      final container = ProviderContainer();
      container.read(fridgesProvider.notifier).loadMockData();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: MyFridgesPage(),
          ),
        ),
      );

      // Verify header & banner (Image 2 / 10)
      expect(find.text('My Fridges'), findsOneWidget);
      expect(find.text("A fresh look at what's inside."), findsOneWidget);
      expect(find.text('A little check, a lot less waste'), findsOneWidget);
      expect(find.text('2 items need your attention today'), findsOneWidget);

      // Verify section header & cards
      expect(find.text('Your fridges'), findsOneWidget);
      expect(find.text('2 fridges'), findsOneWidget);
      expect(find.text('Studio'), findsOneWidget);
      expect(find.text('Kitchen'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('2 members'), findsOneWidget);

      // Verify FAB exists in populated state
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Screen #6: AddFridgePage validates required name field', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddFridgePage(),
          ),
        ),
      );

      expect(find.text('Add New Fridge'), findsOneWidget);
      expect(find.text('Fridge Name'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);

      // Tap Create Fridge without typing name
      await tester.tap(find.text('Create Fridge'));
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.text('Please enter a fridge name'), findsOneWidget);

      // Enter name and clear error
      await tester.enterText(find.byType(TextField).first, 'New Living Room Fridge');
      await tester.pumpAndSettle();
      expect(find.text('Please enter a fridge name'), findsNothing);
    });

    testWidgets('Screen #7: EditFridgeSheet pre-fills fields and updates fridge', (tester) async {
      final container = ProviderContainer();
      container.read(fridgesProvider.notifier).loadMockData();
      final targetFridge = container.read(fridgesProvider).first;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: EditFridgeSheet(fridge: targetFridge),
            ),
          ),
        ),
      );

      // Verify pre-filled data
      expect(find.text('Edit Fridge'), findsOneWidget);
      expect(find.text(targetFridge.name), findsOneWidget);
      expect(find.text(targetFridge.description), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Delete Fridge'), findsOneWidget);

      // Edit name
      await tester.enterText(find.byType(TextField).first, 'Updated Studio Fridge');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Check updated in container
      final updated = container.read(fridgesProvider).firstWhere((f) => f.id == targetFridge.id);
      expect(updated.name, 'Updated Studio Fridge');
    });

    testWidgets('Screen #8: DeleteFridgeDialog confirms deletion and removes fridge', (tester) async {
      final container = ProviderContainer();
      container.read(fridgesProvider.notifier).loadMockData();
      final targetFridge = container.read(fridgesProvider).first;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: DeleteFridgeDialog(
                fridgeId: targetFridge.id,
                fridgeName: targetFridge.name,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Delete Fridge?'), findsOneWidget);
      expect(find.text('This action cannot be undone'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Tap Delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Check removed from container
      expect(container.read(fridgesProvider).any((f) => f.id == targetFridge.id), isFalse);
    });

    testWidgets('Full flow: MyFridgesPage -> EditFridgeSheet -> DeleteFridgeDialog opens successfully', (tester) async {
      final container = ProviderContainer();
      container.read(fridgesProvider.notifier).loadMockData();
      final targetFridge = container.read(fridgesProvider).first;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: MyFridgesPage(),
          ),
        ),
      );

      // Verify MyFridgesPage is loaded
      expect(find.text('My Fridges'), findsOneWidget);

      // Tap 3-dots more options on first fridge card
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      // Verify Edit Fridge bottom sheet is opened
      expect(find.text('Edit Fridge'), findsOneWidget);
      expect(find.text('Update your fridge details.'), findsOneWidget);
      expect(find.text('Delete Fridge'), findsOneWidget);

      // Tap 'Delete Fridge' button in bottom sheet
      await tester.tap(find.text('Delete Fridge'));
      await tester.pumpAndSettle();

      // Verify Delete Fridge? dialog is displayed!
      expect(find.text('Delete Fridge?'), findsOneWidget);
      expect(find.text('This action cannot be undone'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Tap 'Delete' in dialog to delete fridge
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify fridge removed from state
      expect(container.read(fridgesProvider).any((f) => f.id == targetFridge.id), isFalse);
    });
  });
}
