import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../data/models/recipe_model.dart';
import '../../../../data/repositories/item_repository.dart';
import '../../../../data/repositories/ai_repository.dart';
import 'recipe_detail_page.dart';

/// Screen #25: AI Suggested Recipes Page
/// Features smart batching (6 recipes fetched, instant 0s swap on 1st regenerate),
/// 3-second cooldown anti-spam protection, and polite daily quota messaging.
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
  List<RecipeModel> _cachedBatch = [];
  List<RecipeModel> _recipes = [];
  int _currentBatchIndex = 0; // 0 = showing items 0-2, 1 = showing items 3-5
  int _generationCount = 0;
  bool _isRegenerating = false;

  // Anti-Spam Cooldown (3 seconds)
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _currentIngredient = widget.initialIngredient.trim().isEmpty
        ? 'Strawberries'
        : widget.initialIngredient;

    // Load initial recipes immediately from smart fallback / cache
    _loadInitialFallback();

    // Query fridge items and fetch fresh AI recipes if applicable
    Future.microtask(() async {
      try {
        final itemRepo = ref.read(itemRepositoryProvider);
        final expiringItems = await itemRepo.getExpiringSoonItems(widget.fridgeId);
        if (expiringItems.isNotEmpty && widget.initialIngredient == 'Strawberries') {
          if (mounted) {
            setState(() {
              _currentIngredient = expiringItems.first.name;
            });
          }
        }

        await _fetchRecipesFromAi();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _loadInitialFallback() {
    _cachedBatch = _getQuickLocalRecipes(_currentIngredient);
    _recipes = _cachedBatch.take(3).toList();
  }

  List<RecipeModel> _getQuickLocalRecipes(String ingredient) {
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

    if (lower.contains('strawberr')) {
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

    // Default for any custom ingredient like "ค็อกเทลรมควัน"
    return [
      RecipeModel(
        id: 'recipe_local_1',
        title: 'ผัดกระเทียมพริกไทย$ingredient',
        imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80',
        assetFallback: 'assets/images/food_lasagna.png',
        cookingTime: '10 min',
        difficulty: 'Very easy',
        expiringIngredient: ingredient,
        ingredients: [ingredient, 'กระเทียมสับ', 'ซีอิ๊วขาว', 'น้ำมันพืช', 'พริกไทย'],
        steps: ['ผัดกระเทียมจนหอม', 'ใส่$ingredientผัดให้สุก', 'ปรุงรสพร้อมเสิร์ฟ'],
      ),
      RecipeModel(
        id: 'recipe_local_2',
        title: 'ไข่เจียวทรงเครื่องใส่$ingredient',
        imageUrl: 'https://images.unsplash.com/photo-1510693206972-df098062cb71?auto=format&fit=crop&w=800&q=80',
        assetFallback: 'assets/images/food_eggs.png',
        cookingTime: '10 min',
        difficulty: 'Very easy',
        expiringIngredient: ingredient,
        ingredients: [ingredient, 'ไข่ไก่ 2 ฟอง', 'ซีอิ๊วขาว', 'น้ำมันพืช'],
        steps: ['ตีไข่ผสมกับ$ingredient', 'ทอดในกระทะร้อนจนเหลืองฟู'],
      ),
      RecipeModel(
        id: 'recipe_local_3',
        title: 'ข้าวผัดโบราณใส่$ingredient',
        imageUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=800&q=80',
        assetFallback: 'assets/images/food_lasagna.png',
        cookingTime: '15 min',
        difficulty: 'Easy',
        expiringIngredient: ingredient,
        ingredients: [ingredient, 'ข้าวสวย 1 จาน', 'ไข่ไก่ 1 ฟอง', 'ซีอิ๊วขาว'],
        steps: ['ผัดไข่พอสุก', 'ใส่ข้าวสวยและ$ingredient ผัดไฟแรงจนหอม'],
      ),
    ];
  }

  Future<void> _fetchRecipesFromAi() async {
    try {
      final aiRepo = ref.read(aiRepositoryProvider);
      final results = await aiRepo.getSuggestedRecipes(
        _currentIngredient,
      );

      if (results.isNotEmpty && mounted) {
        setState(() {
          _cachedBatch = results;
          _currentBatchIndex = 0;
          _recipes = _cachedBatch.take(3).toList();
        });
      }
    } catch (e) {
      if (mounted && e.toString().contains('วันนี้คุณได้ไอเดีย')) {
        _showDailyLimitAlert();
      }
    }
  }

  void _startCooldown() {
    setState(() {
      _cooldownSeconds = 3;
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() {
          _cooldownSeconds = 0;
        });
      } else {
        setState(() {
          _cooldownSeconds--;
        });
      }
    });
  }

  void _showDailyLimitAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('วันนี้คุณได้ไอเดียไปเยอะแล้ว ลองเลือกเมนูที่แนะนำไปทำอาหารอร่อยๆ กันก่อนนะ! ✨'),
        backgroundColor: Color(0xFFFA8B28),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _onRegenerate() async {
    // Prevent spam if cooling down or currently regenerating
    if (_cooldownSeconds > 0 || _isRegenerating) return;

    // Start 3-second button cooldown immediately (Technique 2)
    _startCooldown();

    // Technique 1: 0-second instant swap from pre-fetched 6 recipes batch!
    if (_currentBatchIndex == 0 && _cachedBatch.length > 3) {
      setState(() {
        _currentBatchIndex = 1;
        _recipes = _cachedBatch.sublist(3, _cachedBatch.length.clamp(3, 6));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚡ สลับ 3 เมนูสำรองทันที (0s)! ประหยัดโควตา'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF2E6A44),
        ),
      );
      return;
    }

    // If already showed the backup 3 recipes, call Gemini AI to fetch next fresh batch of 6
    setState(() {
      _isRegenerating = true;
    });

    try {
      final aiRepo = ref.read(aiRepositoryProvider);

      _generationCount++;
      final freshResults = await aiRepo.getSuggestedRecipes(
        _currentIngredient,
        offset: _generationCount,
      );

      if (!mounted) return;

      setState(() {
        _cachedBatch = freshResults;
        _currentBatchIndex = 0;
        _recipes = _cachedBatch.take(3).toList();
        _isRegenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Gemini AI คิดไอเดียชุดใหม่ 6 เมนูเรียบร้อย!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRegenerating = false;
      });

      if (e.toString().contains('วันนี้คุณได้ไอเดีย')) {
        _showDailyLimitAlert();
      } else {
        // Fallback swap
        setState(() {
          _recipes = List.from(_recipes.reversed);
        });
      }
    }
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
                    const SizedBox(height: 8),
                    // Recipe Cards or Loading Shimmer
                    if (_isRegenerating)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF2E6A44),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Gemini AI is crafting delicious recipes...',
                                style: TextStyle(
                                  color: Color(0xFF414942),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._recipes.map((recipe) => _buildRecipeCard(recipe)),
                    const SizedBox(height: 16),
                    // Regenerate Button with Cooldown feedback
                    Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: (_cooldownSeconds > 0 || _isRegenerating) ? null : _onRegenerate,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_cooldownSeconds > 0) ...[
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF717971),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Regenerate (${_cooldownSeconds}s)',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF717971),
                                  ),
                                ),
                              ] else ...[
                                const Icon(
                                  Icons.sync,
                                  color: Color(0xFF2E6A44),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Regenerate',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2E6A44),
                                  ),
                                ),
                              ],
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
                  if (recipe.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      recipe.description,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF414942),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
