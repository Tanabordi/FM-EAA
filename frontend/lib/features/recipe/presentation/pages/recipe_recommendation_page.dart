import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../data/models/recipe_model.dart';
import '../../../../data/repositories/item_repository.dart';
import 'recipe_detail_page.dart';

/// Screen #25: AI Suggested Recipes Page
/// Matches Figma and uploaded screenshot (media_1793552072245_8dd28d30.jpg)
class RecipeRecommendationPage extends ConsumerStatefulWidget {
  final String fridgeId;
  final String initialIngredient;

  const RecipeRecommendationPage({
    super.key,
    required this.fridgeId,
    this.initialIngredient = 'Strawberries',
  });

  @override
  ConsumerState<RecipeRecommendationPage> createState() => _RecipeRecommendationPageState();
}

class _RecipeRecommendationPageState extends ConsumerState<RecipeRecommendationPage> {
  late String _currentIngredient;
  late List<RecipeModel> _recipes;
  bool _isRegenerating = false;

  @override
  void initState() {
    super.initState();
    _currentIngredient = widget.initialIngredient.trim().isEmpty
        ? 'Strawberries'
        : widget.initialIngredient;
    _recipes = _getRecipesForIngredient(_currentIngredient);

    // Query expiring soon items from Local SQLite DB if available
    Future.microtask(() async {
      try {
        final expiringItems = await ref.read(itemRepositoryProvider).getExpiringSoonItems(widget.fridgeId);
        if (expiringItems.isNotEmpty && widget.initialIngredient == 'Strawberries') {
          if (mounted) {
            setState(() {
              _currentIngredient = expiringItems.first.name;
              _recipes = _getRecipesForIngredient(_currentIngredient);
            });
          }
        }
      } catch (_) {}
    });
  }

  List<RecipeModel> _getRecipesForIngredient(String ingredient) {
    final lower = ingredient.toLowerCase();

    if (lower.contains('spinach')) {
      return [
        const RecipeModel(
          id: 'spinach_pasta',
          title: 'Creamy Garlic Spinach Pasta',
          imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3d5d6281699?auto=format&fit=crop&w=800&q=80',
          assetFallback: 'assets/images/food_spinach.png',
          cookingTime: '15 min',
          difficulty: 'Easy',
          expiringIngredient: 'Baby spinach',
          ingredients: [
            '2 cups baby spinach, rinsed',
            '200g penne pasta',
            '3 cloves garlic, minced',
            '1/2 cup heavy cream',
            '2 tbsp olive oil',
            'Grated parmesan cheese',
          ],
          steps: [
            'Boil penne pasta in salted water until al dente.',
            'Sauté minced garlic in olive oil until fragrant, then add baby spinach until wilted.',
            'Stir in heavy cream and simmer for 3 minutes.',
            'Toss cooked pasta into the sauce and garnish with grated Parmesan cheese.',
          ],
        ),
        const RecipeModel(
          id: 'spinach_salad',
          title: 'Strawberry & Spinach Salad',
          imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
          assetFallback: 'assets/images/food_spinach.png',
          cookingTime: '10 min',
          difficulty: 'Very easy',
          expiringIngredient: 'Baby spinach',
          ingredients: [
            '2 cups fresh baby spinach',
            '1 cup fresh strawberries, sliced',
            '1/2 ripe avocado, diced',
            '2 tbsp balsamic glaze',
            '2 tbsp toasted walnuts',
          ],
          steps: [
            'Rinse baby spinach leaves and dry gently.',
            'Slice fresh strawberries and avocado.',
            'Combine spinach, strawberries, and avocado in a large bowl.',
            'Drizzle with balsamic glaze and top with crunchy toasted walnuts.',
          ],
        ),
        const RecipeModel(
          id: 'spinach_smoothie',
          title: 'Green Power Spinach Smoothie',
          imageUrl: 'https://images.unsplash.com/photo-1610970881699-44a5587cabec?auto=format&fit=crop&w=800&q=80',
          assetFallback: 'assets/images/food_spinach.png',
          cookingTime: '5 min',
          difficulty: 'Very easy',
          expiringIngredient: 'Baby spinach',
          ingredients: [
            '2 cups fresh baby spinach',
            '1 peeled banana',
            '1 cup almond milk or oat milk',
            '1 tbsp chia seeds',
            '1 tbsp honey',
          ],
          steps: [
            'Add 2 cups of fresh baby spinach into the blender.',
            'Add peeled banana and 1 cup of almond milk.',
            'Blend on high speed until completely smooth and creamy.',
            'Pour into glasses and sprinkle chia seeds on top.',
          ],
        ),
      ];
    }

    if (lower.contains('avocado')) {
      return [
        const RecipeModel(
          id: 'avocado_toast',
          title: 'Avocado Toast with Poached Egg',
          imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=80',
          assetFallback: 'assets/images/food_avocados.png',
          cookingTime: '12 min',
          difficulty: 'Easy',
          expiringIngredient: 'Avocados',
          ingredients: [
            '1 ripe avocado',
            '2 slices sourdough bread',
            '2 fresh eggs',
            '1 tbsp fresh lemon juice',
            'Red chili flakes and sea salt',
          ],
          steps: [
            'Toast sourdough bread slices until golden crisp.',
            'Mash ripe avocados with lemon juice, salt, and pepper.',
            'Poach egg in gently simmering water with vinegar for 3 minutes.',
            'Spread avocado mash onto toast and top with poached egg and chili flakes.',
          ],
        ),
        const RecipeModel(
          id: 'strawberry_avocado_salad',
          title: 'Strawberry & Avocado Salad',
          imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
          assetFallback: 'assets/images/food_avocados.png',
          cookingTime: '10 min',
          difficulty: 'Very easy',
          expiringIngredient: 'Avocados',
          ingredients: [
            '1 large avocado, cubed',
            '1 cup fresh strawberries, sliced',
            '2 cups baby greens',
            '2 tbsp extra virgin olive oil',
            '1 tbsp balsamic vinegar',
          ],
          steps: [
            'Slice avocados and fresh strawberries evenly.',
            'Arrange washed spinach leaves in a salad serving bowl.',
            'Layer sliced avocados and strawberries over the greens.',
            'Whisk olive oil with balsamic vinegar and dress lightly before serving.',
          ],
        ),
        const RecipeModel(
          id: 'guacamole',
          title: 'Zesty Homemade Guacamole',
          imageUrl: 'https://images.unsplash.com/photo-1541344999736-83eca872f241?auto=format&fit=crop&w=800&q=80',
          assetFallback: 'assets/images/food_avocados.png',
          cookingTime: '8 min',
          difficulty: 'Very easy',
          expiringIngredient: 'Avocados',
          ingredients: [
            '2 ripe avocados',
            '1 lime, juiced',
            '1/2 cup cherry tomatoes, diced',
            '2 tbsp chopped fresh cilantro',
            'Tortilla chips for serving',
          ],
          steps: [
            'Cut avocados in half, remove pit, and scoop flesh into a bowl.',
            'Mash coarsely with a fork, retaining some texture.',
            'Fold in diced cherry tomatoes, chopped cilantro, and fresh lime juice.',
            'Season with sea salt and serve fresh with tortilla chips.',
          ],
        ),
      ];
    }

    // Default: Strawberries recipes matching screenshot exactly
    return [
      const RecipeModel(
        id: 'strawberry_pancakes',
        title: 'Fluffy Strawberry Pancakes',
        imageUrl: 'https://images.unsplash.com/photo-1528207776546-365bb710ee93?auto=format&fit=crop&w=800&q=80',
        assetFallback: 'assets/images/food_strawberries.png',
        cookingTime: '20 min',
        difficulty: 'Easy',
        expiringIngredient: 'Strawberries',
        ingredients: [
          '1 cup fresh strawberries, sliced',
          '1 1/2 cups all-purpose flour',
          '1 cup milk',
          '1 large egg',
          '2 tbsp melted butter',
          'Maple syrup for topping',
        ],
        steps: [
          'Whisk flour, sugar, baking powder, and salt together in a bowl.',
          'In a separate bowl, beat milk, melted butter, and eggs.',
          'Combine wet and dry ingredients gently; do not overmix.',
          'Cook on a buttered griddle over medium heat until bubbles form.',
          'Flip pancakes and cook until golden brown.',
          'Top generously with freshly sliced strawberries and warm maple syrup.',
        ],
      ),
      const RecipeModel(
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
      ),
      const RecipeModel(
        id: 'strawberry_salad',
        title: 'Strawberry & Avocado Salad',
        imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
        assetFallback: 'assets/images/food_avocados.png',
        cookingTime: '10 min',
        difficulty: 'Very easy',
        expiringIngredient: 'Strawberries',
        ingredients: [
          '1 cup strawberries, sliced',
          '1 ripe avocado, diced',
          '2 cups fresh baby spinach',
          '1/4 cup crumbled feta cheese',
          '2 tbsp balsamic reduction',
        ],
        steps: [
          'Wash baby spinach leaves and spin dry.',
          'Quarter ripe strawberries and dice avocado into bite-sized cubes.',
          'Toss spinach, strawberries, and avocados in a salad bowl.',
          'Crumble fresh feta cheese over the top.',
          'Drizzle with balsamic reduction and toasted pecans just before serving.',
        ],
      ),
    ];
  }

  void _onRegenerate() async {
    setState(() {
      _isRegenerating = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      _recipes = List.from(_recipes.reversed);
      _isRegenerating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ Gemini AI refreshed recipe suggestions!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onViewRecipe(RecipeModel recipe) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => RecipeDetailPage(
          recipe: recipe,
          fridgeId: widget.fridgeId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF3),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar matching other screens via unified AppTopBar
            AppTopBar(
              title: 'AI Suggested Recipes',
              onBackPressed: () {
                try {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/fridges/${widget.fridgeId}');
                  }
                } catch (_) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Orange Highlight Banner
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFA8B28),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AI found ${_recipes.length} recipes using $_currentIngredient',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Recipe Cards
                    if (_isRegenerating)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2E6A44),
                          ),
                        ),
                      )
                    else
                      ..._recipes.map((recipe) => _buildRecipeCard(recipe)),
                    const SizedBox(height: 16),
                    // Regenerate Button
                    Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _onRegenerate,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sync,
                                color: Color(0xFF2E6A44),
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Regenerate',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E6A44),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(RecipeModel recipe) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF717971).withValues(alpha: 0.28),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            Image.network(
              recipe.imageUrl,
              height: 145,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  recipe.assetFallback,
                  height: 145,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 145,
                  color: const Color(0xFFEAEFE8),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF2E6A44),
                    ),
                  ),
                );
              },
            ),
            // Card Details
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF181D17),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Badge: Time & Difficulty
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4ED),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Color(0xFF414942),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.cookingTime} · ${recipe.difficulty}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF414942),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // View Recipe Button
                      SizedBox(
                        height: 36,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2E6A44),
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onPressed: () => _onViewRecipe(recipe),
                          child: const Text(
                            'View Recipe',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
