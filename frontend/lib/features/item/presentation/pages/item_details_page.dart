import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../data/models/item_model.dart';
import '../../../../shared/utils/food_asset_helper.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/category_chips.dart';
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

  String _getThaiCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'proteins':
        return 'โปรตีน';
      case 'veggies':
      case 'vegetables':
        return 'ผักและผลไม้';
      case 'beverages':
      case 'drinks':
        return 'เครื่องดื่ม';
      case 'meals':
        return 'อาหารปรุงสำเร็จ';
      case 'sauces':
      case 'condiments':
      case 'spices':
        return 'เครื่องปรุงและซอส';
      case 'dairy':
        return 'นมและเนย';
      case 'fruits':
        return 'ผลไม้';
      case 'meat':
        return 'เนื้อสัตว์';
      case 'seafood':
        return 'อาหารทะเล';
      case 'bakery':
        return 'เบเกอรี่';
      case 'snacks':
        return 'ของว่าง';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTh = ref.watch(localeProvider).languageCode == 'th';
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

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
                  Expanded(
                    child: Text(
                      isTh ? 'รายละเอียดวัตถุดิบ' : 'item details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.edit_outlined, color: theme.colorScheme.onPrimary, size: 22),
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
                        color: theme.colorScheme.surfaceContainer,
                        child: _buildDetailImage(item),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Item Name
                    Text(
                      item.localizedName(isTh),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Quantity and Unit Subtitle
                    Text(
                      item.formattedQuantityLocalized(isTh),
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
                        customLabel: isTh ? item.localizedDetailStatusLabel(true) : item.detailStatusLabel,
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
                            color: theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CategoryIcon(
                                category: item.category,
                                size: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isTh ? _getThaiCategoryLabel(item.category) : _capitalize(item.category),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isTh
                                ? (item.zone.toLowerCase() == 'freezer' ? 'ช่องแช่แข็ง' : 'ช่องแช่เย็น')
                                : _capitalize(item.zone),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
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
                          _showMarkConsumedSheet(context, ref, item, isTh);
                        },
                        child: Text(isTh ? 'บันทึกว่าบริโภคแล้ว' : 'Mark as Consumed'),
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
                        label: Text(isTh ? 'ลบรายการ' : 'Delete Item'),
                        onPressed: () {
                          _confirmDelete(context, ref, item, isTh);
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

  void _showMarkConsumedSheet(BuildContext context, WidgetRef ref, ItemModel item, bool isTh) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => MarkConsumedSheet(
        itemName: item.localizedName(isTh),
        availablePieces: item.quantity,
        unit: item.unit.contains('punnet')
            ? 'pieces'
            : (item.unit.contains('bag')
                ? 'bag'
                : (item.unit.contains('bottle') ? 'bottle' : 'pieces')),
        onRecommendRecipe: () {
          Navigator.pop(sheetContext);
          context.push('/fridges/$fridgeId/recipes?ingredient=${Uri.encodeComponent(item.localizedName(isTh))}&category=${Uri.encodeComponent(item.category)}');
        },
        onConsumed: (amount, finishedAll) {
          Navigator.pop(sheetContext); // Close sheet
          ref.read(fridgeItemsProvider(fridgeId).notifier).consumeItem(item.id, amount, finishedAll);
          if (context.canPop()) {
            context.pop(item); // Always return to fridge detail page with the consumed item
          } else {
            try {
              context.go('/fridges/$fridgeId');
            } catch (_) {}
            FinishAllSnackbar.show(context, itemName: item.localizedName(isTh));
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ItemModel item, bool isTh) {
    showDialog(
      context: context,
      builder: (_) => DeleteItemDialog(
        itemId: item.id,
        itemName: item.localizedName(isTh),
        onConfirm: () {
          ref.read(fridgeItemsProvider(fridgeId).notifier).deleteItem(item.id);
          if (context.canPop()) {
            context.pop();
          }
        },
      ),
    );
  }

  Widget _buildDetailAssetFallback(ItemModel item) {
    final assetPath = getFoodAssetFallback(item.name, category: item.category);
    return Image.asset(
      assetPath,
      width: double.infinity,
      height: 240,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.fastfood, size: 72, color: Colors.grey),
      ),
    );
  }

  Widget _buildDetailImage(ItemModel item) {
    final imagePath = item.imagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        return Image.network(
          imagePath,
          width: double.infinity,
          height: 240,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDetailAssetFallback(item),
        );
      } else if (imagePath.startsWith('assets/')) {
        return Image.asset(
          imagePath,
          width: double.infinity,
          height: 240,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDetailAssetFallback(item),
        );
      } else if (!kIsWeb) {
        try {
          final file = File(imagePath);
          if (file.existsSync()) {
            return Image.file(
              file,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildDetailAssetFallback(item),
            );
          }
        } catch (_) {}
      }
    }
    return _buildDetailAssetFallback(item);
  }
}
