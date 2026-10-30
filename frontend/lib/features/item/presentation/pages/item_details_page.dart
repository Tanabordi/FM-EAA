import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/freshness_colors.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../widgets/delete_item_dialog.dart';
import '../widgets/mark_consumed_sheet.dart';

// TODO(screen #12 Item details): ปุ่มแก้ไข (ไอคอนดินสอ) มุมขวาบน, รูปใหญ่, ชื่อ, "1 punnet · 250 g", ป้ายสถานะ ("Use soon in 2 Days"), tags (หมวด เช่น Veggies, โซน เช่น Fridge), ปุ่ม "Mark as Consumed", ปุ่ม "Delete Item" (แดง)
class ItemDetailsPage extends StatelessWidget {
  final String fridgeId;
  final String itemId;

  const ItemDetailsPage({super.key, required this.fridgeId, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF3),
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: 'Item Details',
              actions: [
                AppTopBarAction(
                  icon: Icons.edit_outlined,
                  onTap: () => context.push('/fridges/$fridgeId/items/$itemId/edit'),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Large Image Placeholder
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Icon(Icons.fastfood, size: 72, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Avocados',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '1 punnet · 250 g',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge(
                  status: FreshnessStatus.useSoon,
                  customLabel: 'Use soon in 2 Days',
                ),
              ),
              const SizedBox(height: 16),
              // Category and Zone Tags
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: const Text('Veggies'),
                    backgroundColor: theme.colorScheme.surfaceContainer,
                    shape: const StadiumBorder(),
                  ),
                  Chip(
                    label: const Text('Fridge'),
                    backgroundColor: theme.colorScheme.surfaceContainer,
                    shape: const StadiumBorder(),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              PrimaryButton(
                label: 'Mark as Consumed',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (_) => MarkConsumedSheet(
                      itemName: 'Avocados',
                      availablePieces: 2,
                      unit: 'pieces',
                      onConsumed: (amount, finishedAll) {
                        Navigator.pop(context); // close sheet
                        context.pop(); // back to list
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Avocados marked as consumed'),
                            action: SnackBarAction(label: 'Undo', onPressed: () {}),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: FreshnessColors.danger),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => DeleteItemDialog(itemId: itemId),
                  );
                },
                child: const Text('Delete Item', style: TextStyle(fontWeight: FontWeight.bold)),
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
}
