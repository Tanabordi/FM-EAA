import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/recipe/presentation/pages/recipe_recommendation_page.dart';

void main() {
  group('Screen #25: AI Suggested Recipes Tests', () {
    testWidgets('renders top bar, orange highlight banner, 3 recipe cards, and regenerate button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RecipeRecommendationPage(
              fridgeId: 'fridge_1',
              initialIngredient: 'Strawberries',
            ),
          ),
        ),
      );
      await tester.pump();

      // Top bar
      expect(find.text('AI Suggested Recipes'), findsOneWidget);

      // Orange banner
      expect(find.text('AI found 3 recipes using Strawberries'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);

      // Recipe Cards
      expect(find.text('Fluffy Strawberry Pancakes'), findsOneWidget);
      expect(find.text('Strawberry & Banana Smoothie'), findsOneWidget);
      expect(find.text('Strawberry & Avocado Salad'), findsOneWidget);

      // Badges
      expect(find.text('20 min · Easy'), findsOneWidget);
      expect(find.text('5 min · Very easy'), findsOneWidget);
      expect(find.text('10 min · Very easy'), findsOneWidget);

      // View Recipe buttons
      expect(find.text('View Recipe'), findsNWidgets(3));

      // Regenerate button
      expect(find.text('Regenerate'), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('renders recipes dynamically when ingredient is Baby spinach', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RecipeRecommendationPage(
              fridgeId: 'fridge_1',
              initialIngredient: 'Baby spinach',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('AI found 3 recipes using Baby spinach'), findsOneWidget);
      expect(find.text('Creamy Garlic Spinach Pasta'), findsOneWidget);
      expect(find.text('Strawberry & Spinach Salad'), findsOneWidget);
      expect(find.text('Green Power Spinach Smoothie'), findsOneWidget);
    });
  });
}
