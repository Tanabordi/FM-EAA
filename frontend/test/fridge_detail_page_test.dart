import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/features/fridge_detail/presentation/pages/fridge_detail_page.dart';
import 'package:fm_eaa/features/search/presentation/pages/search_page.dart';

void main() {
  group('FridgeDetailPage (Screen #9) Widget Tests', () {
    testWidgets('Renders top bar, floating search, circular category chips, and tabs', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FridgeDetailPage(fridgeId: 'fridge_kitchen'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top title and search
      expect(find.text('Kitchen'), findsOneWidget);
      expect(find.text('Search for items'), findsOneWidget);

      // Circular category chips
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Proteins'), findsOneWidget);
      expect(find.text('Veggies'), findsOneWidget);
      expect(find.text('Beverages'), findsOneWidget);
      expect(find.text('Meals'), findsOneWidget);
      expect(find.text('Sauces'), findsOneWidget);

      // Tabs: Fridge | Freezer
      expect(find.text('Fridge'), findsOneWidget);
      expect(find.text('Freezer'), findsOneWidget);

      // Section header
      expect(find.text('Your food'), findsOneWidget);

      // Items in Fridge zone (Default All)
      expect(find.text('Baby spinach'), findsOneWidget);
      expect(find.text('Strawberries'), findsOneWidget);
      expect(find.text('Avocados'), findsOneWidget);
      expect(find.text('Whole milk'), findsOneWidget);

      // Status Badges & Days remaining text
      expect(find.text('Expired'), findsWidgets);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('Use soon'), findsWidgets);
      expect(find.text('2 days left'), findsWidgets);
      expect(find.text('Fresh'), findsWidgets);
      expect(find.text('5 days left'), findsOneWidget);
      expect(find.text('7 days left'), findsOneWidget);
    });

    testWidgets('Clicking each category chip displays its exact 4 items matching Figma mockups', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FridgeDetailPage(fridgeId: 'fridge_kitchen'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Click Proteins -> Chicken Breasts, Eggs, Salmon Fillets, Firm Tofu
      await tester.tap(find.text('Proteins'));
      await tester.pumpAndSettle();
      expect(find.text('Chicken Breasts'), findsOneWidget);
      expect(find.text('Eggs'), findsOneWidget);
      expect(find.text('Salmon Fillets'), findsOneWidget);
      expect(find.text('Firm Tofu'), findsOneWidget);

      // 2. Click Veggies -> Baby spinach, Strawberries, Avocados, Cherry Tomatoes
      await tester.tap(find.text('Veggies'));
      await tester.pumpAndSettle();
      expect(find.text('Baby spinach'), findsOneWidget);
      expect(find.text('Strawberries'), findsOneWidget);
      expect(find.text('Avocados'), findsOneWidget);
      expect(find.text('Cherry Tomatoes'), findsOneWidget);

      // 3. Click Beverages -> Whole milk, Orange Juice, Cold Brew Coffee, Kombucha
      await tester.tap(find.text('Beverages'));
      await tester.pumpAndSettle();
      expect(find.text('Whole milk'), findsOneWidget);
      expect(find.text('Orange Juice'), findsOneWidget);
      expect(find.text('Cold Brew Coffee'), findsOneWidget);
      expect(find.text('Kombucha'), findsOneWidget);

      // 4. Click Meals -> Microwave Lasagna, Frozen Pizza, Pork Dumplings, Chicken Nuggets
      await tester.tap(find.text('Meals'));
      await tester.pumpAndSettle();
      expect(find.text('Microwave Lasagna'), findsOneWidget);
      expect(find.text('Frozen Pizza'), findsOneWidget);
      expect(find.text('Pork Dumplings'), findsOneWidget);
      expect(find.text('Chicken Nuggets'), findsOneWidget);

      // 5. Click Sauces -> Soy Sauce, Mayonnaise, Sriracha Sauce, Olive Oil
      await tester.tap(find.text('Sauces'));
      await tester.pumpAndSettle();
      expect(find.text('Soy Sauce'), findsOneWidget);
      expect(find.text('Mayonnaise'), findsOneWidget);
      expect(find.text('Sriracha Sauce'), findsOneWidget);
      expect(find.text('Olive Oil'), findsOneWidget);

      // 6. Click All -> Returns to overview
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(find.text('Baby spinach'), findsOneWidget);
      expect(find.text('Strawberries'), findsOneWidget);
    });

    testWidgets('Switches between Fridge and Freezer tabs', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FridgeDetailPage(fridgeId: 'fridge_kitchen'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially on Fridge tab
      expect(find.text('Baby spinach'), findsOneWidget);
      expect(find.text('Pork Tenderloin'), findsNothing);

      // Tap Freezer tab
      await tester.tap(find.text('Freezer'));
      await tester.pumpAndSettle();

      // Now on Freezer tab
      expect(find.text('Pork Tenderloin'), findsOneWidget);
      expect(find.text('Salmon Fillet'), findsOneWidget);
      expect(find.text('Baby spinach'), findsNothing);
    });
  });

  group('SearchPage (Screen #10) Widget Tests', () {
    testWidgets('Searches items across the fridge and displays results', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SearchPage(fridgeId: 'fridge_kitchen'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search query 'spinach'
      await tester.enterText(find.byType(TextField), 'spinach');
      await tester.pumpAndSettle();

      expect(find.text('Results for "spinach"'), findsOneWidget);
      expect(find.text('Baby spinach (Veggies)'), findsOneWidget);

      // Clear search
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Results for "spinach"'), findsNothing);
    });

    testWidgets('Shows no items found when search query matches nothing', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SearchPage(fridgeId: 'fridge_kitchen'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'nonexistent_food_xyz');
      await tester.pumpAndSettle();

      expect(find.text('No items found'), findsOneWidget);
    });
  });
}
