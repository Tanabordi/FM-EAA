import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fm_eaa/data/local/app_database.dart';
import 'package:fm_eaa/features/recipe/data/models/recipe_model.dart';
import 'package:fm_eaa/features/recipe/presentation/pages/recipe_recommendation_page.dart';
import 'package:fm_eaa/features/recipe/presentation/pages/recipe_detail_page.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Screen #25: AI Suggested Recipes Tests', () {
    testWidgets('renders top bar, 6 recipe cards, and regenerate button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: RecipeRecommendationPage(
              fridgeId: 'fridge_1',
              initialIngredient: 'Strawberries',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top bar
      expect(find.text('AI Suggested Recipes'), findsOneWidget);

      // Recipe Cards
      expect(find.text('Fluffy Strawberry Pancakes'), findsOneWidget);
      expect(find.text('Strawberry Yogurt Smoothie'), findsOneWidget);
      expect(find.text('Strawberry & Avocado Salad'), findsOneWidget);

      // Badges
      expect(find.text('20 min · Easy'), findsOneWidget);
      expect(find.text('10 mins · Very easy'), findsOneWidget);
      expect(find.text('10 min · Very easy'), findsWidgets);

      // View Recipe buttons
      expect(find.text('View Recipe'), findsWidgets);

      // Regenerate button
      expect(find.textContaining('Regenerate'), findsOneWidget);
      expect(find.byIcon(Icons.sync_rounded), findsOneWidget);
    });

    testWidgets('renders recipes dynamically when ingredient is Baby spinach', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: RecipeRecommendationPage(
              fridgeId: 'fridge_1',
              initialIngredient: 'Baby spinach',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Creamy Garlic Spinach Pasta'), findsOneWidget);
      expect(find.text('Strawberry & Spinach Salad'), findsOneWidget);
      expect(find.text('Green Power Spinach Smoothie'), findsOneWidget);
    });

    testWidgets('renders relevant recipes when ingredient is sausage (ค็อกเทลรมควัน)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: RecipeRecommendationPage(
              fridgeId: 'fridge_1',
              initialIngredient: 'ค็อกเทลรมควัน',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Stir-fried Smoked Cocktail Sausage with Garlic & Pepper'), findsOneWidget);
      expect(find.text('Golden Fluffy Omelet with Smoked Cocktail Sausage'), findsOneWidget);
      expect(find.text('Classic Fried Rice with Smoked Cocktail Sausage'), findsOneWidget);
    });

    testWidgets('renders beverage-appropriate recipes for Beverages category and avoids savory stir-fry', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: RecipeRecommendationPage(
              fridgeId: 'fridge_1',
              initialIngredient: 'Cold Brew Coffee',
              category: 'beverages',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Beverage recipes should be suggested
      expect(find.textContaining('Splash'), findsOneWidget);
      expect(find.textContaining('Smoothie'), findsOneWidget);
      expect(find.textContaining('Pancakes'), findsOneWidget);

      // Savory fried rice / garlic stir fry must NOT appear for beverages
      expect(find.textContaining('Stir-fried Cold Brew Coffee with Garlic'), findsNothing);
      expect(find.textContaining('Classic Fried Rice with Cold Brew Coffee'), findsNothing);
    });

    testWidgets('renders sauce-appropriate recipes for Sauces category', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: RecipeRecommendationPage(
              fridgeId: 'fridge_1',
              initialIngredient: 'BBQ Sauce',
              category: 'sauces',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Golden Glazed Pan-Sear with BBQ Sauce'), findsOneWidget);
      expect(find.textContaining('Quick Tossed Garlic Pasta with BBQ Sauce'), findsOneWidget);
    });

    testWidgets('triggers cooldown and locks on regenerate button tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: RecipeRecommendationPage(
              fridgeId: 'fridge_1',
              initialIngredient: 'ค็อกเทลรมควัน',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.textContaining('Regenerate'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Regenerate (1/3'), findsOneWidget);
      await tester.tap(find.textContaining('Regenerate'));
      await tester.pump();

      // Button enters cooldown or loading state
      expect(find.textContaining('Regenerate ('), findsOneWidget);

      // Advance time by 4 seconds
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.textContaining('Regenerate'), findsOneWidget);
    });

    testWidgets('persists recipes and regenerate count per ingredient when navigating away and back', (tester) async {
      // 1. Visit recipe recommendations for 'Cheddar Cheese'
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: RecipeRecommendationPage(
              fridgeId: 'fridge_1',
              initialIngredient: 'Cheddar Cheese',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Regenerate (1/3)'), findsOneWidget);

      // Tap regenerate once -> becomes 2/3
      await tester.ensureVisible(find.textContaining('Regenerate'));
      await tester.tap(find.textContaining('Regenerate'));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.textContaining('Regenerate (2/3)'), findsOneWidget);

      // 2. Navigate away and re-open 'Cheddar Cheese' -> count MUST remain 2/3!
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: RecipeRecommendationPage(
              fridgeId: 'fridge_1',
              initialIngredient: 'Cheddar Cheese',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Must NOT increment to 3/3 on entry; must retain 2/3!
      expect(find.textContaining('Regenerate (2/3)'), findsOneWidget);

      // 3. Open a DIFFERENT ingredient ('Avocados') -> must start fresh independently
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: RecipeRecommendationPage(
              fridgeId: 'fridge_1',
              initialIngredient: 'Avocados',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.textContaining('Regenerate'));
      expect(find.textContaining('Regenerate (1/3)'), findsOneWidget);
    });
  });

  group('Screen #26: Recipe Details Tests', () {
    testWidgets('renders exact layout from Figma screenshot (Recipe title, tags, ingredients checklist, instructions, Done! Mark as Consumed button)', (tester) async {
      const smoothieRecipe = RecipeModel(
        id: 'strawberry_smoothie',
        title: 'Strawberry Yogurt Smoothie',
        imageUrl: 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?auto=format&fit=crop&w=800&q=80',
        assetFallback: 'assets/images/food_strawberries.png',
        cookingTime: '10 mins',
        difficulty: 'Very easy',
        expiringIngredient: 'Strawberries',
        ingredients: [
          '1 cup strawberries, hulled',
          '1/2 cup plain yogurt',
          '1/2 cup milk',
          '1 tsp honey',
          'Ice cubes (optional)',
        ],
        steps: [
          'Add strawberries, yogurt, milk, and honey to a blender.',
          'Blend until smooth and creamy.',
          'Add ice cubes if you want a thicker, colder smoothie.',
          'Blend again until the ice is fully crushed, then pour and serve.',
        ],
      );

      bool markedConsumed = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: MaterialApp(
            home: RecipeDetailPage(
              recipe: smoothieRecipe,
              onMarkConsumed: () {
                markedConsumed = true;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Top bar title
      expect(find.text('Recipe'), findsOneWidget);

      // Recipe Title
      expect(find.text('Strawberry Yogurt Smoothie'), findsOneWidget);

      // Tags
      expect(find.text('Uses expiring: Strawberries'), findsOneWidget);
      expect(find.text('10 mins'), findsOneWidget);
      expect(find.text('Very easy'), findsOneWidget);

      // Ingredients Section
      expect(find.text('Ingredients'), findsOneWidget);
      expect(find.text('1 cup strawberries, hulled'), findsOneWidget);
      expect(find.text('1/2 cup plain yogurt'), findsOneWidget);
      expect(find.text('1/2 cup milk'), findsOneWidget);
      expect(find.text('1 tsp honey'), findsOneWidget);
      expect(find.text('Ice cubes (optional)'), findsOneWidget);

      // Instructions Section
      expect(find.text('Instructions'), findsOneWidget);
      expect(find.text('Add strawberries, yogurt, milk, and honey to a blender.'), findsOneWidget);
      expect(find.text('Blend until smooth and creamy.'), findsOneWidget);
      expect(find.text('Add ice cubes if you want a thicker, colder smoothie.'), findsOneWidget);
      expect(find.text('Blend again until the ice is fully crushed, then pour and serve.'), findsOneWidget);

      // Bottom Button
      expect(find.text('Done! Mark as Consumed'), findsOneWidget);
      await tester.tap(find.text('Done! Mark as Consumed'));
      await tester.pumpAndSettle();

      // Opens MarkConsumedSheet with stepper and Confirm button
      expect(find.text('How much did you consume?'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Finished all'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(markedConsumed, true);
    });
  });
}
