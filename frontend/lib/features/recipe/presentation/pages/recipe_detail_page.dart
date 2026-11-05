import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../data/models/recipe_model.dart';
import '../../../history/providers/history_provider.dart';
import '../../../../data/repositories/item_repository.dart';
import '../../../../data/models/item_model.dart';
import '../../../../core/l10n/locale_provider.dart';
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

  bool get _isTh {
    try {
      return ref.read(localeProvider).languageCode == 'th';
    } catch (_) {
      try {
        return Localizations.localeOf(context).languageCode == 'th';
      } catch (_) {
        return false;
      }
    }
  }

  bool _isThRead() {
    try {
      return ref.read(localeProvider).languageCode == 'th';
    } catch (_) {
      try {
        return Localizations.localeOf(context).languageCode == 'th';
      } catch (_) {
        return false;
      }
    }
  }

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
    final isTh = _isThRead();
    final locUnit = ItemModel.localizeUnit(unit, isTh);
    final feedbackText = isCompletelyFinished
        ? (isTh ? '✨ บริโภค $itemName หมดแล้ว! บันทึกลงในประวัติเรียบร้อย' : '✨ Finished all $itemName! Recorded to History.')
        : (isTh ? '✨ บริโภค $itemName ไป ${amount.toInt()} $locUnit! บันทึกลงในประวัติเรียบร้อย' : '✨ Consumed ${amount.toInt()} $unit of $itemName! Recorded to History.');

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

  String _localizeRecipeText(String text, bool isTh) {
    if (!isTh || text.isEmpty) return text;
    var result = text;
    for (final entry in ItemModel.foodEnToThai.entries) {
      if (result.toLowerCase().contains(entry.key)) {
        result = result.replaceAll(RegExp(RegExp.escape(entry.key), caseSensitive: false), entry.value);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final isTh = _isTh;
    final recipe = widget.recipe;

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar matching other screens via unified AppTopBar
            AppTopBar(
              title: isTh ? 'สูตรอาหาร' : 'Recipe',
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
                      _localizeRecipeText(recipe.title, isTh),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Badges Row
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Orange Badge: Uses expiring
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFA8B28),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isTh
                                ? 'ใช้วัตถุดิบใกล้หมดอายุ: ${recipe.localizedExpiringIngredient(true)}'
                                : 'Uses expiring: ${recipe.expiringIngredient}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Time Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                recipe.localizedCookingTime(isTh),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Difficulty Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            recipe.localizedDifficulty(isTh),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    // Ingredients Section
                    Text(
                      isTh ? 'วัตถุดิบที่ต้องใช้' : 'Ingredients',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
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
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isChecked
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outline,
                                    width: 1.5,
                                  ),
                                ),
                                child: isChecked
                                    ? Icon(
                                        Icons.check,
                                        size: 14,
                                        color: theme.colorScheme.onPrimary,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _localizeRecipeText(ing, isTh),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w400,
                                    decoration: isChecked
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor: theme.colorScheme.onSurfaceVariant,
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
                    Text(
                      isTh ? 'วิธีทำทีละขั้นตอน' : 'Instructions',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
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
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$stepNum',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _localizeRecipeText(stepText, isTh),
                                style: TextStyle(
                                  fontSize: 14.5,
                                  height: 1.4,
                                  color: theme.colorScheme.onSurfaceVariant,
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
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 1.0,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  onPressed: _onDoneMarkAsConsumed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, size: 22, color: theme.colorScheme.onPrimary),
                      const SizedBox(width: 8),
                      Text(
                        isTh ? 'ทำเสร็จแล้ว! บันทึกว่ารับประทานแล้ว' : 'Done! Mark as Consumed',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
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
