import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/models/item_model.dart';
import '../../../../shared/widgets/category_chips.dart';
import '../../../../shared/widgets/item_card.dart';
import '../../../item/presentation/widgets/finish_all_snackbar.dart';
import '../../../item/presentation/widgets/mark_consumed_sheet.dart';
import '../../providers/fridge_detail_provider.dart';

// TODO(screen #9 Fridge Detail): แถบหัว: ย้อนกลับ, ชื่อตู้, ไอคอน 4 ตัว = Family, History, Notifications, Settings; ช่องค้นหา "Search for items"; chips หมวดแบบวงกลม All / Proteins / Veggies / Beverages / Meals / Sauces; แท็บ Fridge | Freezer; หัวข้อ "Your food" + "N items"; การ์ดวัตถุดิบ: รูป, ชื่อ, ปริมาณ+หน่วย (เช่น "1 bag · 150 g", "2 pieces"), ป้ายสถานะ + ข้อความ (Yesterday / 2 days left / 5 days left); FAB เพิ่มของ. เฟรมของแต่ละหมวด x โซนอีก 10 เฟรม (Protein, Veggies, Beverages, Meals, Sauces) เป็นแค่ state กรองของหน้านี้ ไม่ใช่หน้าใหม่
class FridgeDetailPage extends ConsumerStatefulWidget {
  final String fridgeId;

  const FridgeDetailPage({super.key, required this.fridgeId});

  @override
  ConsumerState<FridgeDetailPage> createState() => _FridgeDetailPageState();
}

class _FridgeDetailPageState extends ConsumerState<FridgeDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(fridgeDetailFilterProvider.notifier).setZone(
              _tabController.index == 0 ? 'fridge' : 'freezer',
            );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showMarkConsumedSheet(BuildContext context, ItemModel item) {
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
          Navigator.pop(sheetContext);
          ref.read(fridgeItemsProvider(widget.fridgeId).notifier).consumeItem(item.id, amount, finishedAll);
          FinishAllSnackbar.show(
            context,
            itemName: item.name,
            onUndo: () {
              ref.read(fridgeItemsProvider(widget.fridgeId).notifier).undoConsume();
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filter = ref.watch(fridgeDetailFilterProvider);
    final allItems = ref.watch(fridgeItemsProvider(widget.fridgeId));

    // Filter items based on selected category and zone
    final items = allItems.where((item) {
      final matchesZone = item.zone == filter.zone;
      final matchesCategory = filter.category == 'All' ||
          item.category.toLowerCase() == filter.category.toLowerCase();
      return matchesZone && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/fridges');
            }
          },
        ),
        title: const Text('Kitchen', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_outlined),
            onPressed: () => context.push('/fridges/${widget.fridgeId}/family?name=Kitchen'),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/fridges/${widget.fridgeId}/history'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: InkWell(
                onTap: () => context.push('/fridges/${widget.fridgeId}/search'),
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        'Search for items',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Circular Category Chips
            CategoryChips(
              selectedCategory: filter.category,
              onSelected: (cat) {
                ref.read(fridgeDetailFilterProvider.notifier).setCategory(cat);
              },
            ),
            // Tabs: Fridge | Freezer
            TabBar(
              controller: _tabController,
              indicatorColor: theme.colorScheme.primary,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.outline,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Fridge'),
                Tab(text: 'Freezer'),
              ],
            ),
            // Food Items Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Your food', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    '${items.length} items',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ItemCard(
                    name: item.name,
                    quantityText: '${item.quantity.toInt()} ${item.unit}',
                    status: item.status,
                    statusText: item.statusText,
                    imagePath: item.imagePath,
                    onTap: () async {
                      final consumedItem = await context.push<ItemModel?>('/fridges/${widget.fridgeId}/items/${item.id}');
                      if (consumedItem != null && context.mounted) {
                        FinishAllSnackbar.show(
                          context,
                          itemName: consumedItem.name,
                          onUndo: () {
                            ref.read(fridgeItemsProvider(widget.fridgeId).notifier).undoConsume();
                          },
                        );
                      }
                    },
                    onLongPress: () {
                      _showMarkConsumedSheet(context, item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E6A44),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => context.push('/fridges/${widget.fridgeId}/items/add'),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
