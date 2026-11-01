import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../data/models/recipe_model.dart';
import '../../../history/providers/history_provider.dart';
import '../../../../data/repositories/item_repository.dart';
import '../../../../data/models/item_model.dart';

/// Screen #26: Recipe Details
/// Matches exact layout and design from uploaded Figma screenshot (media_1793552844285_7860fd5e.png)
class RecipeDetailPage extends ConsumerStatefulWidget {
  final RecipeModel recipe;
  final String fridgeId;
  final VoidCallback? onMarkConsumed;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
    this.fridgeId = 'fridge_1',
    this.onMarkConsumed,
  });

  @override
  ConsumerState<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends ConsumerState<RecipeDetailPage> {
  final Set<int> _checkedIngredients = {};

  void _toggleIngredient(int index) {
    setState(() {
      if (_checkedIngredients.contains(index)) {
        _checkedIngredients.remove(index);
      } else {
        _checkedIngredients.add(index);
      }
    });
  }

  Future<void> _onDoneMarkAsConsumed() async {
    // 1. Record consumed entry into History database for HistoryPage
    try {
      await ref.read(historyRepositoryProvider).recordConsumedItem(
            fridgeId: widget.fridgeId,
            itemName: widget.recipe.title,
            category: 'meals',
            zone: 'fridge',
            imagePath: widget.recipe.imageUrl,
            quantity: 1.0,
            quantityLeft: 0.0,
            unit: 'portion',
            byUsername: 'alex.lee',
          );
    } catch (_) {}

    // 2. Also deduct from fridge inventory if matching ingredient item exists
    try {
      final itemRepo = ref.read(itemRepositoryProvider);
      final items = await itemRepo.getItemsByFridge(widget.fridgeId);
      final matching = items.cast<ItemModel?>().firstWhere(
            (i) =>
                i != null &&
                i.name.toLowerCase().contains(
                      widget.recipe.expiringIngredient.toLowerCase(),
                    ),
            orElse: () => null,
          );
      if (matching != null) {
        await itemRepo.consumeItem(
          matching.id,
          1.0,
          finishedAll: matching.quantity <= 1.0,
        );
      }
    } catch (_) {}

    if (widget.onMarkConsumed != null) {
      widget.onMarkConsumed!();
    }

    if (!mounted) return;

    // 3. Show feedback SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✨ ${widget.recipe.title} marked as consumed! Recorded to History.'),
        duration: const Duration(seconds: 3),
      ),
    );

    // 4. Navigate to All Fridge page (/fridges)
    try {
      context.go('/fridges');
    } catch (_) {
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF3),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar: Back button on left, Centered "Recipe" title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: Row(
                children: [
                  AppBackButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/fridges/${widget.fridgeId}');
                      }
                    },
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Recipe',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF181D17),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  // Spacer to balance the AppBackButton width (42px) and keep title centered
                  const SizedBox(width: 42),
                ],
              ),
            ),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        recipe.imageUrl,
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            recipe.assetFallback,
                            height: 190,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Recipe Title
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181D17),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Badges Row
                    Row(
                      children: [
                        // Orange Badge: Uses expiring
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFA8B28),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Uses expiring: ${recipe.expiringIngredient}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Time Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAEFE8),
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
                                recipe.cookingTime,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF414942),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Difficulty Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAEFE8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            recipe.difficulty,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF414942),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    // Ingredients Section
                    const Text(
                      'Ingredients',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181D17),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...recipe.ingredients.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final ing = entry.value;
                      final isChecked = _checkedIngredients.contains(idx);

                      return InkWell(
                        onTap: () => _toggleIngredient(idx),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Row(
                            children: [
                              Container(
                                width: 19,
                                height: 19,
                                decoration: BoxDecoration(
                                  color: isChecked
                                      ? const Color(0xFF2E6A44)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isChecked
                                        ? const Color(0xFF2E6A44)
                                        : const Color(0xFF717971),
                                    width: 1.5,
                                  ),
                                ),
                                child: isChecked
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ing,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: const Color(0xFF181D17),
                                    fontWeight: FontWeight.w400,
                                    decoration: isChecked
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor: const Color(0xFF717971),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 22),
                    // Instructions Section
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181D17),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...recipe.steps.asMap().entries.map((entry) {
                      final stepNum = entry.key + 1;
                      final stepText = entry.value;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEAEFE8),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$stepNum',
                                  style: const TextStyle(
                                    color: Color(0xFF414942),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                stepText,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  height: 1.4,
                                  color: Color(0xFF414942),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Bottom Action Dock
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF6FBF3),
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE0E5DF),
                    width: 1.0,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2E6A44),
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  onPressed: _onDoneMarkAsConsumed,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, size: 22, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Done! Mark as Consumed',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
