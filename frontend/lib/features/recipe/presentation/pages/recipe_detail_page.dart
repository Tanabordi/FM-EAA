import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../data/models/recipe_model.dart';

/// Screen #26: Recipe Details
class RecipeDetailPage extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF3),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: Row(
                children: [
                  AppBackButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Recipe Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF181D17),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        recipe.imageUrl,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            recipe.assetFallback,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181D17),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Badges (Cooking time & Difficulty)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4ED),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time, size: 15, color: Color(0xFF414942)),
                              const SizedBox(width: 5),
                              Text(
                                recipe.cookingTime,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF414942),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4ED),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            recipe.difficulty,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF414942),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Ingredients from Fridge Section
                    const Text(
                      'Ingredients from Fridge',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181D17),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...recipe.ingredientsFromFridge.map((ing) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, size: 18, color: Color(0xFF2E6A44)),
                              const SizedBox(width: 8),
                              Text(
                                ing,
                                style: const TextStyle(fontSize: 15, color: Color(0xFF181D17)),
                              ),
                            ],
                          ),
                        )),
                    if (recipe.extraPantryIngredients.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Pantry Staples Needed',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF181D17),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...recipe.extraPantryIngredients.map((ing) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.circle_outlined, size: 16, color: Color(0xFF717971)),
                                const SizedBox(width: 8),
                                Text(
                                  ing,
                                  style: const TextStyle(fontSize: 15, color: Color(0xFF414942)),
                                ),
                              ],
                            ),
                          )),
                    ],
                    const SizedBox(height: 20),
                    // Instructions
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181D17),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...recipe.steps.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final step = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E6A44),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$idx',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                step,
                                style: const TextStyle(fontSize: 14.5, height: 1.4, color: Color(0xFF181D17)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 28),
                    // Cook This Recipe Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2E6A44),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Starting recipe: ${recipe.title}!'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text('Cook This Recipe'),
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
}
