import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/core/l10n/locale_provider.dart';
import 'package:fm_eaa/core/theme/app_theme.dart';
import 'package:fm_eaa/data/models/item_model.dart';
import 'package:fm_eaa/features/fridge_detail/providers/fridge_detail_provider.dart';
import 'package:fm_eaa/features/item/presentation/pages/edit_item_page.dart';
import 'package:fm_eaa/features/item/presentation/pages/item_details_page.dart';

class _TestLocaleNotifier extends LocaleNotifier {
  _TestLocaleNotifier(String code) {
    state = Locale(code);
  }
}

void main() {
  final now = DateTime.now();
  final testItem = ItemModel(
    id: 'item_strawberry',
    fridgeId: 'fridge_test',
    name: 'Fresh Strawberries',
    category: 'veggies',
    zone: 'fridge',
    quantity: 2.0,
    unit: 'punnet · 250 g',
    expiryDate: now.add(const Duration(days: 3)),
    imagePath: 'assets/images/food_strawberries.png',
    updatedAt: now,
  );

  Widget createTestWidget({
    required Widget child,
    Locale locale = const Locale('en'),
  }) {
    return ProviderScope(
      overrides: [
        localeProvider.overrideWith((ref) => _TestLocaleNotifier(locale.languageCode)),
        fridgeItemsProvider('fridge_test').overrideWith(
          (ref) => FridgeItemsNotifier('fridge_test')
            ..addItem(testItem),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  group('ItemDetailsPage Widget Tests', () {
    testWidgets('renders item details header, name, badges, and action buttons', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          child: const ItemDetailsPage(
            fridgeId: 'fridge_test',
            itemId: 'item_strawberry',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('item details'), findsOneWidget);
      expect(find.text('Fresh Strawberries'), findsOneWidget);
      expect(find.text('2 punnet · 250 g'), findsOneWidget);
      expect(find.text('Mark as Consumed'), findsOneWidget);
      expect(find.text('Delete Item'), findsOneWidget);
    });

    testWidgets('renders Thai localization correctly', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('th'),
          child: const ItemDetailsPage(
            fridgeId: 'fridge_test',
            itemId: 'item_strawberry',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('รายละเอียดวัตถุดิบ'), findsOneWidget);
      expect(find.text('บันทึกว่าบริโภคแล้ว'), findsOneWidget);
      expect(find.text('ลบรายการ'), findsOneWidget);
    });

    testWidgets('tapping Mark as Consumed opens sheet', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          child: const ItemDetailsPage(
            fridgeId: 'fridge_test',
            itemId: 'item_strawberry',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mark as Consumed'));
      await tester.pumpAndSettle();

      // MarkConsumedSheet should be rendered
      expect(find.text('Finished all'), findsOneWidget);
    });

    testWidgets('tapping Delete Item opens DeleteItemDialog', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          child: const ItemDetailsPage(
            fridgeId: 'fridge_test',
            itemId: 'item_strawberry',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete Item'));
      await tester.pumpAndSettle();

      // DeleteItemDialog should be rendered
      expect(find.text('This action cannot be undone'), findsOneWidget);
    });
  });

  group('EditItemPage Widget Tests', () {
    testWidgets('renders form pre-filled with item data', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          child: const EditItemPage(
            fridgeId: 'fridge_test',
            itemId: 'item_strawberry',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fresh Strawberries'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('shows validation error when name is empty', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          child: const EditItemPage(
            fridgeId: 'fridge_test',
            itemId: 'item_strawberry',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Clear the name field
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, '');
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Food name is required'), findsOneWidget);
    });
  });
}
