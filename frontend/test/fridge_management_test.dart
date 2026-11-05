import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/models/fridge_model.dart';
import 'package:fm_eaa/data/models/user_model.dart';
import 'package:fm_eaa/features/auth/providers/auth_provider.dart';
import 'package:fm_eaa/features/fridges/presentation/pages/add_fridge_page.dart';
import 'package:fm_eaa/features/fridges/presentation/pages/my_fridges_page.dart';
import 'package:fm_eaa/features/fridges/presentation/widgets/cute_fridge_illustration.dart';
import 'package:fm_eaa/features/fridges/presentation/widgets/delete_fridge_dialog.dart';
import 'package:fm_eaa/features/fridges/presentation/widgets/edit_fridge_sheet.dart';
import 'package:fm_eaa/features/fridges/presentation/widgets/leave_fridge_dialog.dart';
import 'package:fm_eaa/features/fridges/providers/fridges_provider.dart';
import 'package:fm_eaa/data/remote/api_client.dart';
import 'package:fm_eaa/data/repositories/auth_repository.dart';
import 'package:fm_eaa/shared/widgets/fridge_card.dart';

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(AuthState initialState)
      : super(AuthRepository(apiClient: ApiClient())) {
    state = initialState;
  }
}

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

    test('Calculates isUserOwner and isOwner correctly', () {
      final ownerFridge = FridgeModel(
        id: '1',
        name: 'My Fridge',
        ownerId: 'u1',
        role: 'owner',
        updatedAt: DateTime.now(),
      );
      expect(ownerFridge.isOwner, isTrue);
      expect(ownerFridge.isUserOwner('u1'), isTrue);
      expect(ownerFridge.isUserOwner('u2'), isTrue);

      final memberFridge = FridgeModel(
        id: '2',
        name: 'Shared Fridge',
        ownerId: 'u1',
        role: 'member',
        updatedAt: DateTime.now(),
      );
      expect(memberFridge.isOwner, isFalse);
      expect(memberFridge.isUserOwner('u1'), isTrue);
      expect(memberFridge.isUserOwner('u2'), isFalse);
    });
  });

  group('FridgesNotifier Unit Tests', () {
    test('supports startEmpty, add, update, remove, and loadMockData', () {
      final notifier = FridgesNotifier(null, true);
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
          fridgesProvider.overrideWith((ref) => FridgesNotifier(null, true)),
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
      final container = ProviderContainer(
        overrides: [
          fridgesProvider.overrideWith((ref) => FridgesNotifier(null, false)),
        ],
      );
      addTearDown(container.dispose);
      container.read(fridgesProvider.notifier).loadMockData();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: MyFridgesPage(),
          ),
        ),
      );

      // Verify header (Image 2 / 10)
      expect(find.text('My Fridges'), findsOneWidget);
      expect(find.text("A fresh look at what's inside."), findsOneWidget);

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

    testWidgets('Screen #6: AddFridgePage validates required name field (1-15 chars) and description (0-100 chars)', (tester) async {
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

      // Verify required validation error
      expect(find.text('Fridge name is required'), findsOneWidget);

      // Test exceeding 15 chars
      await tester.enterText(find.byType(TextField).first, 'Super Long Name For Fridge 12345');
      await tester.tap(find.text('Create Fridge'));
      await tester.pumpAndSettle();
      expect(find.text('Fridge name must not exceed 15 characters'), findsOneWidget);

      // Enter valid name (1-15 chars)
      await tester.enterText(find.byType(TextField).first, 'Living Room');
      await tester.pumpAndSettle();
      expect(find.text('Fridge name is required'), findsNothing);
      expect(find.text('Fridge name must not exceed 15 characters'), findsNothing);

      // Test description exceeding 100 chars
      final longDesc = 'a' * 105;
      await tester.enterText(find.byType(TextField).last, longDesc);
      await tester.tap(find.text('Create Fridge'));
      await tester.pumpAndSettle();
      expect(find.text('Description must not exceed 100 characters'), findsOneWidget);
    });

    testWidgets('Screen #6: AddFridgePage shows Discard changes dialog on back with unsaved edits', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddFridgePage(),
          ),
        ),
      );

      // Type some unsaved changes
      await tester.enterText(find.byType(TextField).first, 'Kitchen Fridge');
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify Discard changes dialog
      expect(find.text('Discard changes?'), findsOneWidget);
      expect(find.text('You have unsaved changes. Are you sure you want to discard them?'), findsOneWidget);
      expect(find.text('Keep editing'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);

      // Tap Keep editing
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsNothing);
      expect(find.text('Add New Fridge'), findsOneWidget);

      // Tap back again and tap Discard
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
    });

    testWidgets('Screen #7: EditFridgeSheet pre-fills fields and updates fridge', (tester) async {
      final container = ProviderContainer(
        overrides: [
          fridgesProvider.overrideWith((ref) => FridgesNotifier(null, false)),
        ],
      );
      addTearDown(container.dispose);
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

      // Edit name to valid length (1-15 chars)
      await tester.enterText(find.byType(TextField).first, 'Studio Fridge');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Check updated in container
      final updated = container.read(fridgesProvider).firstWhere((f) => f.id == targetFridge.id);
      expect(updated.name, 'Studio Fridge');
    });

    testWidgets('Screen #7: EditFridgeSheet validates required name (1-15 chars), desc (0-100 chars), and shows Discard dialog on close icon', (tester) async {
      final container = ProviderContainer(
        overrides: [
          fridgesProvider.overrideWith((ref) => FridgesNotifier(null, false)),
        ],
      );
      addTearDown(container.dispose);
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

      // Clear name and tap Save
      await tester.enterText(find.byType(TextField).first, '');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Fridge name is required'), findsOneWidget);

      // Name > 15 chars
      await tester.enterText(find.byType(TextField).first, 'Super Long Name For Fridge 12345');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Fridge name must not exceed 15 characters'), findsOneWidget);

      // Description > 100 chars
      final longDesc = 'b' * 105;
      await tester.enterText(find.byType(TextField).last, longDesc);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Description must not exceed 100 characters'), findsOneWidget);

      // Tap close button (Icons.close) with unsaved changes
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verify Discard changes dialog
      expect(find.text('Discard changes?'), findsOneWidget);
      expect(find.text('You have unsaved changes. Are you sure you want to discard them?'), findsOneWidget);
      expect(find.text('Keep editing'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);

      // Tap Keep editing
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsNothing);
      expect(find.text('Edit Fridge'), findsOneWidget);

      // Tap close again and Discard
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
    });

    testWidgets('Screen #8: DeleteFridgeDialog confirms deletion and removes fridge', (tester) async {
      final container = ProviderContainer(
        overrides: [
          fridgesProvider.overrideWith((ref) => FridgesNotifier(null, false)),
        ],
      );
      addTearDown(container.dispose);
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
      final container = ProviderContainer(
        overrides: [
          fridgesProvider.overrideWith((ref) => FridgesNotifier(null, false)),
        ],
      );
      addTearDown(container.dispose);
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

    testWidgets('FridgeCard: hides 3-dots more options when onMoreOptions is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FridgeCard(
              name: 'Member Fridge',
              description: 'Shared with me',
              itemsCountText: '5 Items',
              memberCount: 3,
              isPersonal: false,
              onMoreOptions: null,
            ),
          ),
        ),
      );

      expect(find.text('Member Fridge'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets('FridgeCard: shows 3-dots more options when onMoreOptions is provided', (tester) async {
      bool moreTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FridgeCard(
              name: 'Owner Fridge',
              description: 'My fridge',
              itemsCountText: '2 Items',
              memberCount: 1,
              onMoreOptions: () => moreTapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      await tester.tap(find.byIcon(Icons.more_vert));
      expect(moreTapped, isTrue);
    });

    testWidgets('MyFridgesPage: non-owner fridge hides 3-dots button and long-press opens LeaveFridgeDialog', (tester) async {
      final memberFridge = FridgeModel(
        id: 'shared_1',
        name: 'Roommate Fridge',
        description: 'Living room',
        ownerId: 'owner_user_id',
        role: 'member',
        memberCount: 2,
        itemCount: 4,
        updatedAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          fridgesProvider.overrideWith((ref) {
            final notifier = FridgesNotifier(null, false);
            notifier.state = [memberFridge];
            return notifier;
          }),
          authProvider.overrideWith((ref) => FakeAuthNotifier(
            AuthState(
              isAuthenticated: true,
              user: UserModel(
                id: 'current_user_id',
                username: 'MemberUser',
                email: 'mem@test.com',
                updatedAt: DateTime.now(),
              ),
            ),
          )),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: MyFridgesPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify fridge is displayed
      expect(find.text('Roommate Fridge'), findsOneWidget);

      // Verify NO 3-dots more_vert icon is rendered for non-owner
      expect(find.byIcon(Icons.more_vert), findsNothing);

      // Long press on fridge card
      await tester.longPress(find.text('Roommate Fridge'));
      await tester.pumpAndSettle();

      // Verify LeaveFridgeDialog is shown (not DeleteFridgeDialog)
      expect(find.byType(LeaveFridgeDialog), findsOneWidget);
      expect(find.text('Leave Fridge?'), findsOneWidget);
      expect(find.textContaining('You will lose access to its items'), findsOneWidget);
      expect(find.text('Leave'), findsOneWidget);
      expect(find.text('Delete Fridge?'), findsNothing);
    });
  });
}

