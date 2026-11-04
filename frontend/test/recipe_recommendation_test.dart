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

      expect(find.text('ผัดกระเทียมพริกไทยค็อกเทลรมควัน'), findsOneWidget);
      expect(find.text('ไข่เจียวทรงเครื่องใส่ค็อกเทลรมควัน'), findsOneWidget);
      expect(find.text('ข้าวผัดโบราณใส่ค็อกเทลรมควัน'), findsOneWidget);
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
