import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/models/item_model.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/category_chips.dart';
import '../../../../shared/widgets/item_card.dart';
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
  Timer? _snackbarTimer;
  bool _showConsumedSnackbar = false;
  String _consumedItemName = 'Whole milk';

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

    // Automatically animate/pop up the consumed SnackBar after 600ms matching mockup
    _snackbarTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showConsumedSnackbar = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _snackbarTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _onUndo() {
    ref.read(fridgeItemsProvider(widget.fridgeId).notifier).undoConsume();
    setState(() {
      _showConsumedSnackbar = false;
    });
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
          setState(() {
            _consumedItemName = item.name;
            _showConsumedSnackbar = true;
          });
        },
      ),
    );
  }

  Widget _buildTopActionIcon({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: Color(0xFFEAEFE8),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF181D17), size: 20),
        padding: EdgeInsets.zero,
        onPressed: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: const Color(0xFFF6FBF3),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Header Row matching mockup
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    children: [
                      const AppBackButton(),
                      const SizedBox(width: 14),
                      const Text(
                        'Kitchen',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF181D17),
                        ),
                      ),
                      const Spacer(),
                      _buildTopActionIcon(
                        icon: Icons.group_outlined,
                        onTap: () => context.push('/fridges/${widget.fridgeId}/family?name=Kitchen'),
                      ),
                      const SizedBox(width: 6),
                      _buildTopActionIcon(
                        icon: Icons.history,
                        onTap: () => context.push('/fridges/${widget.fridgeId}/history'),
                      ),
                      const SizedBox(width: 6),
                      _buildTopActionIcon(
                        icon: Icons.notifications_none,
                        onTap: () => context.push('/notifications'),
                      ),
                      const SizedBox(width: 6),
                      _buildTopActionIcon(
                        icon: Icons.settings_outlined,
                        onTap: () => context.push('/settings'),
                      ),
                    ],
                  ),
                ),
                // Search Bar with subtle shadow
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: InkWell(
                    onTap: () => context.push('/fridges/${widget.fridgeId}/search'),
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAEFE8),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Color(0xFF414941)),
                          SizedBox(width: 8),
                          Text(
                            'Search for items',
                            style: TextStyle(color: Color(0xFF414941), fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
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
                  indicatorColor: const Color(0xFF2E6A44),
                  labelColor: const Color(0xFF2E6A44),
                  unselectedLabelColor: const Color(0xFF717971),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Fridge'),
                    Tab(text: 'Freezer'),
                  ],
                ),
                // Food Items Section Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your food',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF181D17),
                        ),
                      ),
                      Text(
                        '${items.length} items',
                        style: const TextStyle(
                          color: Color(0xFF414941),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Food Items List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
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
                          if (consumedItem != null && mounted) {
                            setState(() {
                              _consumedItemName = consumedItem.name;
                              _showConsumedSnackbar = true;
                            });
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

            // Floating Action Button (+) positioned above SnackBar matching mockup
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              bottom: _showConsumedSnackbar ? 86 : 24,
              right: 16,
              child: GestureDetector(
                onTap: () => context.push('/fridges/${widget.fridgeId}/items/add'),
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E6A44),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.20),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),

            // Floating Consumed SnackBar popping up at bottom matching mockup
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              bottom: _showConsumedSnackbar ? 24 : -80,
              left: 12,
              right: 12,
              child: Container(
                height: 49,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF181D17),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$_consumedItemName marked as consumed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: _onUndo,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          'Undo',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
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
}
