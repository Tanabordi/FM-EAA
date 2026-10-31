import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/freshness_colors.dart';
import '../../../../data/models/item_model.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../fridge_detail/providers/fridge_detail_provider.dart';
import '../widgets/delete_item_dialog.dart';
import '../widgets/finish_all_snackbar.dart';
import '../widgets/mark_consumed_sheet.dart';

/// Screen #12 Item details:
/// Header with AppBackButton, 'item details' title, green edit icon button.
/// Food photo, food name, quantity & unit, status badge, tags (Category, Storage),
/// 'Mark as Consumed' button, and solid red 'Delete Item' button.
class ItemDetailsPage extends ConsumerWidget {
  final String fridgeId;
  final String itemId;

  const ItemDetailsPage({
    super.key,
    required this.fridgeId,
    required this.itemId,
  });

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(fridgeItemsProvider(fridgeId));
    final item = items.firstWhere(
      (it) => it.id == itemId,
      orElse: () => ItemModel(
        id: itemId,
        fridgeId: fridgeId,
        name: 'Strawberries',
        category: 'veggies',
        zone: 'fridge',
        quantity: 1,
        unit: 'punnet · 250 g',
        expiryDate: DateTime.now().add(const Duration(days: 2)),
        imagePath: 'assets/images/food_strawberries.png',
        updatedAt: DateTime.now(),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF3),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'item details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181D17),
                      ),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E6A44),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 22),
                      padding: EdgeInsets.zero,
                      onPressed: () => context.push('/fridges/$fridgeId/items/$itemId/edit'),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Large Food Photo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        height: 240,
                        color: const Color(0xFFEAEFE8),
                        child: item.imagePath != null && item.imagePath!.isNotEmpty
                            ? Image.asset(
                                item.imagePath!,
                                width: double.infinity,
                                height: 240,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.fastfood, size: 72, color: Colors.grey),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.fastfood, size: 72, color: Colors.grey),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Item Name
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181D17),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Quantity and Unit Subtitle
                    Text(
                      '${item.quantity.toInt()} ${item.unit}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF414941),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Status Badge
                    Align(
                      alignment: Alignment.centerLeft,
                      child: StatusBadge(
                        status: item.status,
                        customLabel: item.status == FreshnessStatus.useSoon
                            ? 'Use soon in 2 Days'
                            : item.statusText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category and Zone Tags
                    Wrap(
                      spacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAEFE8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.eco_outlined, size: 16, color: Color(0xFF181D17)),
                              const SizedBox(width: 6),
                              Text(
                                _capitalize(item.category),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF181D17),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAEFE8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _capitalize(item.zone),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF181D17),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    // Mark as Consumed Button
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2E6A44),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          _showMarkConsumedSheet(context, ref, item);
                        },
                        child: const Text('Mark as Consumed'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Delete Item Button (Solid red with trash icon)
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFB71C1C),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: const Icon(Icons.delete_outline, size: 20),
                        label: const Text('Delete Item'),
                        onPressed: () {
                          _confirmDelete(context, ref, item);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMarkConsumedSheet(BuildContext context, WidgetRef ref, ItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => MarkConsumedSheet(
        itemName: item.name,
        availablePieces: item.quantity,
        unit: item.unit.contains('punnet')
            ? 'pieces'
            : (item.unit.contains('bag')
                ? 'bag'
                : (item.unit.contains('bottle') ? 'bottle' : 'pieces')),
        onConsumed: (amount, finishedAll) {
          Navigator.pop(sheetContext); // Close sheet
          ref.read(fridgeItemsProvider(fridgeId).notifier).consumeItem(item.id, amount, finishedAll);
          if (context.canPop()) {
            context.pop(); // Return to fridge detail page
          }
          FinishAllSnackbar.show(
            context,
            itemName: item.name,
            onUndo: () {
              ref.read(fridgeItemsProvider(fridgeId).notifier).undoConsume();
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ItemModel item) {
    showDialog(
      context: context,
      builder: (_) => DeleteItemDialog(
        itemId: item.id,
        onConfirm: () {
          ref.read(fridgeItemsProvider(fridgeId).notifier).deleteItem(item.id);
          if (context.canPop()) {
            context.pop();
          }
        },
      ),
    );
  }
}
