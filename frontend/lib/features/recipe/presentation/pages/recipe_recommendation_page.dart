import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../data/models/recipe_model.dart';
import '../../../../data/repositories/item_repository.dart';
import '../../../../data/repositories/ai_repository.dart';
import 'recipe_detail_page.dart';

/// Screen #25: AI Suggested Recipes Page
/// Generates 3 recipes per request focused on selected ingredient,
/// with 10 requests/day limit, usage counter in button (e.g. Regenerate (1/10)),
/// and 3-second button cooldown.
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
  List<RecipeModel> _recipes = [];
  bool _isRegenerating = false;

  // Daily Quota Tracking (Max: 10/day)
  int _usedCount = 1;
  static const int _maxDailyQuota = 10;

  // Anti-Spam Cooldown (3 seconds)
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _currentIngredient = widget.initialIngredient.trim().isEmpty
        ? 'Strawberries'
        : widget.initialIngredient;

    // Load initial recipes immediately from fallback
    _loadInitialFallback();

    // Load persisted quota and query fresh AI recipes
    _loadDailyQuota();

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

  Future<void> _loadDailyQuota() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final savedDate = prefs.getString('gemini_recipe_date');
      if (savedDate == today) {
        final savedCount = prefs.getInt('gemini_recipe_count') ?? 1;
        if (mounted) {
          setState(() {
            _usedCount = savedCount;
          });
        }
      } else {
        await prefs.setString('gemini_recipe_date', today);
        await prefs.setInt('gemini_recipe_count', 1);
      }
    } catch (_) {}
  }

  Future<void> _saveDailyQuota(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      await prefs.setString('gemini_recipe_date', today);
      await prefs.setInt('gemini_recipe_count', count);
    } catch (_) {}
  }

  void _loadInitialFallback() {
    _recipes = _getQuickLocalRecipes(_currentIngredient).take(3).toList();
  }

  List<RecipeModel> _getQuickLocalRecipes(String ingredient) {
    final lower = ingredient.toLowerCase();
    if (lower.contains('spinach')) {
      return [
        const RecipeModel(
          id: 'spinach_pasta',
          title: 'Creamy Garlic Spinach Pasta',
          description: 'A comforting, creamy garlic pasta loaded with tender wilted spinach.',
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
          description: 'Crisp baby spinach paired with fresh sweet strawberries and balsamic dressing.',
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
          description: 'A refreshing energy boost packed with fresh nutrients and banana.',
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
          description: 'Crisp sourdough topped with velvety seasoned avocado mash and a runny poached egg.',
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
          description: 'A colorful mix of creamy avocado cubes and sweet strawberries on bed of greens.',
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
          description: 'Fresh chunky guacamole with lime, cilantro, and ripe avocado.',
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
          description: 'Fluffy golden hotcakes topped with fresh sweet strawberries and maple syrup.',
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
          description: 'Creamy yogurt blended with sweet ripe strawberries and honey.',
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
          description: 'Tossed greens with sweet strawberries, avocado chunks, and balsamic glaze.',
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

    // Default for any custom ingredient like "แครอท" or "ค็อกเทลรมควัน"
    return [
      RecipeModel(
        id: 'recipe_local_1',
        title: 'ผัดกระเทียมพริกไทย$ingredient',
        description: 'หอมกลิ่นกระเทียมพริกไทย ทำง่าย รสชาติกลมกล่อม',
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
        description: 'ไข่เจียวฟูนุ่มกรอบนอกนุ่มใน เข้ากันได้อย่างลงตัว',
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
        description: 'เปลี่ยนข้าวสวยและวัตถุดิบเหลือให้เป็นมื้ออร่อยง่ายๆ',
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
      final result = await aiRepo.getSuggestedRecipes(
        _currentIngredient,
        offset: 0,
      );

      if (result.recipes.isNotEmpty && mounted) {
        setState(() {
          _recipes = result.recipes;
          _usedCount = result.usedDailyQuota;
        });
        _saveDailyQuota(_usedCount);
      }
    } catch (e) {
      if (mounted && e.toString().contains('วันนี้คุณ')) {
        setState(() {
          _usedCount = _maxDailyQuota;
        });
        _saveDailyQuota(_maxDailyQuota);
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
        content: Text('วันนี้คุณใช้โควตาครบ 10 ครั้งแล้ว ลองเลือกเมนูที่แนะนำไปทำอาหารอร่อยๆ กันก่อนนะ! ✨'),
        backgroundColor: Color(0xFFFA8B28),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _onRegenerate() async {
    // Check if daily quota is reached (10/10)
    if (_usedCount >= _maxDailyQuota) {
      _showDailyLimitAlert();
      return;
    }

    // Prevent spam if cooling down or currently regenerating
    if (_cooldownSeconds > 0 || _isRegenerating) return;

    // Start 3-second button cooldown
    _startCooldown();

    setState(() {
      _isRegenerating = true;
    });

    try {
      final aiRepo = ref.read(aiRepositoryProvider);
      final result = await aiRepo.getSuggestedRecipes(
        _currentIngredient,
        offset: _usedCount,
      );

      if (!mounted) return;

      setState(() {
        _recipes = result.recipes;
        _usedCount = result.usedDailyQuota;
        _isRegenerating = false;
      });

      _saveDailyQuota(_usedCount);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ Gemini AI สุ่ม 3 เมนูใหม่เรียบร้อย! (ใช้ไปแล้ว $_usedCount/$_maxDailyQuota ครั้ง)'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRegenerating = false;
      });

      if (e.toString().contains('วันนี้คุณ')) {
        setState(() {
          _usedCount = _maxDailyQuota;
        });
        _saveDailyQuota(_maxDailyQuota);
        _showDailyLimitAlert();
      } else {
        // Local fallback rotation
        setState(() {
          _usedCount = (_usedCount + 1).clamp(1, _maxDailyQuota);
          _recipes = List.from(_recipes.reversed);
        });
        _saveDailyQuota(_usedCount);
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
    final isQuotaFull = _usedCount >= _maxDailyQuota;

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
                                'Gemini AI is crafting 3 fresh recipes...',
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
                    // Regenerate Button with Usage Counter and Cooldown
                    Center(
                      child: isQuotaFull
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE4E9E2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.block,
                                    color: Color(0xFF8A938A),
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Regenerate (10/10 - ครบโควตาวันนี้แล้ว)',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF8A938A),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : InkWell(
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
                                        'Regenerate (${_cooldownSeconds}s) · ($_usedCount/$_maxDailyQuota)',
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
                                      Text(
                                        'Regenerate ($_usedCount/$_maxDailyQuota)',
                                        style: const TextStyle(
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
