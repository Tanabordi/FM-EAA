import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/local/app_database.dart';
import 'package:fm_eaa/features/recipe/presentation/pages/recipe_recommendation_page.dart';
import 'package:fm_eaa/shared/widgets/app_top_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestableWidget(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        ...overrides,
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('RecipeRecommendationPage Extended Coverage Tests', () {
    testWidgets('renders local recipes for Avocados', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const RecipeRecommendationPage(
            fridgeId: 'f1',
            initialIngredient: 'Avocados',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Avocado Toast with Poached Egg'), findsOneWidget);
      expect(find.text('Strawberry & Avocado Salad'), findsOneWidget);
      expect(find.text('Zesty Homemade Guacamole'), findsOneWidget);
    });

    testWidgets('renders fallback recipes for beverage category (Cold Brew)', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const RecipeRecommendationPage(
            fridgeId: 'f1',
            initialIngredient: 'Cold Brew',
            category: 'beverages',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Cold Brew'), findsWidgets);
      expect(find.textContaining('Pancakes'), findsOneWidget);
    });

    testWidgets('renders fallback recipes for sauces category (Chili Sauce)', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const RecipeRecommendationPage(
            fridgeId: 'f1',
            initialIngredient: 'Chili Sauce',
            category: 'sauces',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Chili Sauce'), findsWidgets);
      expect(find.textContaining('Glazed Pan-Sear'), findsOneWidget);
    });

    testWidgets('renders fallback recipes for meals category (Spaghetti)', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const RecipeRecommendationPage(
            fridgeId: 'f1',
            initialIngredient: 'Spaghetti',
            category: 'meals',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Spaghetti'), findsWidgets);
    });

    testWidgets('tapping View Recipe opens recipe detail and navigates back', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const RecipeRecommendationPage(
            fridgeId: 'f1',
            initialIngredient: 'Avocados',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final viewRecipeBtn = find.text('View Recipe').first;
      await tester.ensureVisible(viewRecipeBtn);
      await tester.tap(viewRecipeBtn);
      await tester.pumpAndSettle();

      // We are now on detail page
      expect(find.text('Ingredients'), findsOneWidget);

      // Tap back button
      final backBtn = find.byType(IconButton).first;
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      // Back on recommendation page
      expect(find.text('AI Suggested Recipes'), findsOneWidget);
    });

    testWidgets('tapping back button on AppTopBar pops', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () {
                  Navigator.of(ctx).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RecipeRecommendationPage(
                        fridgeId: 'f1',
                        initialIngredient: 'Avocados',
                      ),
                    ),
                  );
                },
                child: const Text('Open Page'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Page'));
      await tester.pumpAndSettle();

      expect(find.text('AI Suggested Recipes'), findsOneWidget);

      final topBarBack = find.descendant(
        of: find.byType(AppTopBar),
        matching: find.byType(IconButton),
      );
      await tester.tap(topBarBack);
      await tester.pumpAndSettle();

      expect(find.text('Open Page'), findsOneWidget);
    });

    testWidgets('handles regenerate button tap', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const RecipeRecommendationPage(
            fridgeId: 'f1',
            initialIngredient: 'Avocados',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final regenBtn = find.textContaining('Regenerate');
      expect(regenBtn, findsOneWidget);
      await tester.ensureVisible(regenBtn);
      await tester.tap(regenBtn);
      await tester.pump();

      // Pump through async and snackbar
      await tester.pump(const Duration(seconds: 4));
    });
  });
}

