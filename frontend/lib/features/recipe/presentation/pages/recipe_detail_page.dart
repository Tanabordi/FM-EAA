import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../data/models/recipe_model.dart';
import '../../../history/providers/history_provider.dart';
import '../../../../data/repositories/item_repository.dart';
import '../../../../data/models/item_model.dart';
import '../../../item/presentation/widgets/mark_consumed_sheet.dart';

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
    // Look up matching item in the current fridge inventory
    ItemModel? matchingItem;
    try {
      final itemRepo = ref.read(itemRepositoryProvider);
      final items = await itemRepo.getItems(widget.fridgeId);
      final searchKey = widget.recipe.expiringIngredient.toLowerCase();
      matchingItem = items.cast<ItemModel?>().firstWhere(
            (i) =>
                i != null &&
                (i.name.toLowerCase().contains(searchKey) ||
                    searchKey.contains(i.name.toLowerCase())),
            orElse: () => null,
          );
    } catch (_) {}

    if (!mounted) return;

    final availablePieces = matchingItem?.quantity ?? 1.0;
    final itemName = matchingItem?.name ?? widget.recipe.expiringIngredient;
    final unit = matchingItem != null && matchingItem.unit.isNotEmpty
        ? (matchingItem.unit.contains('punnet')
            ? 'pieces'
            : (matchingItem.unit.contains('bag')
                ? 'bag'
                : (matchingItem.unit.contains('bottle') ? 'bottle' : matchingItem.unit)))
        : 'portion';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => MarkConsumedSheet(
        itemName: itemName,
        availablePieces: availablePieces > 0 ? availablePieces : 1.0,
        unit: unit,
        hideGeminiShortcut: true,
        onConsumed: (amount, finishedAll) async {
          Navigator.pop(sheetContext);
          await _processConsumption(matchingItem, amount, finishedAll);
        },
      ),
    );
  }

  Future<void> _processConsumption(
    ItemModel? matchingItem,
    double amount,
    bool finishedAll,
  ) async {
    final itemName = matchingItem?.name ?? widget.recipe.expiringIngredient;
    final unit = matchingItem?.unit ?? 'portion';
    final isCompletelyFinished =
        finishedAll || (matchingItem != null && matchingItem.quantity - amount <= 0);

    // 1. Record consumed entry into History database for HistoryPage
    try {
      await ref.read(historyRepositoryProvider).recordConsumedItem(
            fridgeId: widget.fridgeId,
            itemName: '${widget.recipe.title} ($itemName)',
            category: matchingItem?.category ?? 'meals',
            zone: matchingItem?.zone ?? 'fridge',
            imagePath: widget.recipe.imageUrl,
            quantity: amount,
            quantityLeft: matchingItem != null
                ? (isCompletelyFinished
                    ? 0.0
                    : (matchingItem.quantity - amount).clamp(0.0, double.infinity))
                : 0.0,
            unit: unit,
            byUsername: 'alex.lee',
          );
    } catch (_) {}

    // 2. Also deduct from fridge inventory if matching ingredient item exists
    if (matchingItem != null) {
      try {
        final itemRepo = ref.read(itemRepositoryProvider);
        await itemRepo.consumeItem(
          matchingItem.id,
          amount,
          finishedAll: isCompletelyFinished,
        );
      } catch (_) {}
    }

    if (widget.onMarkConsumed != null) {
      widget.onMarkConsumed!();
    }

    if (!mounted) return;

    // 3. Show feedback SnackBar
    final feedbackText = isCompletelyFinished
        ? '✨ Finished all $itemName! Recorded to History.'
        : '✨ Consumed ${amount.toInt()} $unit of $itemName! Recorded to History.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(feedbackText),
        duration: const Duration(seconds: 3),
      ),
    );

    // 4. Navigate back to Fridge Detail page (/fridges/${widget.fridgeId}) e.g. "Kitchen"
    try {
      context.go('/fridges/${widget.fridgeId}');
    } catch (_) {
      try {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      } catch (_) {}
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
            // Top App Bar matching other screens via unified AppTopBar
            AppTopBar(
              title: 'Recipe',
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
