import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/mobile_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/category_chips.dart';
import '../../../../shared/widgets/item_card.dart';
import '../../providers/fridge_detail_provider.dart';

class FridgeDetailPage extends ConsumerStatefulWidget {
  final String fridgeId;

  const FridgeDetailPage({super.key, required this.fridgeId});

  @override
  ConsumerState<FridgeDetailPage> createState() => _FridgeDetailPageState();
}

class _FridgeDetailPageState extends ConsumerState<FridgeDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      final newZone = _tabController.index == 0 ? 'fridge' : 'freezer';
      if (ref.read(fridgeDetailFilterProvider).zone != newZone) {
        ref.read(fridgeDetailFilterProvider.notifier).setZone(newZone);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(fridgeDetailFilterProvider);
    final items = ref.watch(fridgeItemsProvider(widget.fridgeId));

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF3), // Figma exact background #F6FBF3
      body: SafeArea(
        child: Column(
          children: [
            // Top Status Bar: 9:41, Signal, Wifi, Battery matching Figma mockup
            const MobileStatusBar(),
            // Top App Bar
            _buildAppBar(context),
            // Floating Pill Search Bar with Shadow
            _buildSearchBar(context),
            const SizedBox(height: 2),
            // Circular Category Chips (All, Proteins, Veggies, Beverages, Meals, Sauces)
            CategoryChips(
              selectedCategory: filter.category,
              onSelected: (cat) {
                ref.read(fridgeDetailFilterProvider.notifier).setCategory(cat);
              },
            ),
            const SizedBox(height: 2),
            // Fridge | Freezer Tabs
            _buildTabs(),
            // Food Items Section Header ("Your food" & "N items")
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your food',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A201C),
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    '${items.length} items',
                    style: const TextStyle(
                      color: Color(0xFF5C665F),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Items List
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 74, top: 2),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final displayQuantity = item.unit.contains('·') || item.unit.contains('pieces')
                            ? '${item.quantity > 0 ? (item.quantity == item.quantity.toInt() ? item.quantity.toInt() : item.quantity) : ''} ${item.unit}'.trim()
                            : '${item.quantity == item.quantity.toInt() ? item.quantity.toInt() : item.quantity} ${item.unit}';

                        return ItemCard(
                          name: item.name,
                          quantityText: displayQuantity,
                          status: item.status,
                          statusText: item.statusText,
                          imagePath: item.imagePath,
                          onTap: () => context.push('/fridges/${widget.fridgeId}/items/${item.id}'),
                        );
                      },
                    ),
            ),
            // iOS Bottom Home Indicator Bar matching screenshot
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Center(
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A201C),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 58,
        height: 58,
        margin: const EdgeInsets.only(bottom: 16, right: 4),
        child: FloatingActionButton(
          elevation: 4,
          backgroundColor: const Color(0xFF2E6A44), // Figma exact dark green
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onPressed: () => context.push('/fridges/${widget.fridgeId}/items/add'),
          child: const Icon(Icons.add, size: 30),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          // Back button matching Image 2
          const AppBackButton(),
          const SizedBox(width: 12),
          // Fridge Name Title
          const Expanded(
            child: Text(
              'Kitchen',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A201C),
                letterSpacing: -0.5,
              ),
            ),
          ),
          // Top Action Buttons (Family, History, Notifications, Settings)
          _buildActionIcon(
            icon: Icons.people_outline_rounded,
            onTap: () => context.push('/fridges/${widget.fridgeId}/family'),
          ),
          const SizedBox(width: 8),
          _buildActionIcon(
            icon: Icons.history_rounded,
            onTap: () => context.push('/fridges/${widget.fridgeId}/history'),
          ),
          const SizedBox(width: 8),
          _buildActionIcon(
            icon: Icons.notifications_none_rounded,
            onTap: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
          _buildActionIcon(
            icon: Icons.settings_outlined,
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFFEAEFE8),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 19, color: const Color(0xFF2C3A2F)),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFEAEFE8), // Figma exact background #EAEFE8
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x45000000), // Prominent deep drop shadow matching Image 2
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () {
              context.push('/fridges/${widget.fridgeId}/search');
            },
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 18, right: 12),
                  child: Icon(Icons.search, color: Color(0xFF3A4A3E), size: 22),
                ),
                Expanded(
                  child: Text(
                    _searchController.text.isNotEmpty
                        ? _searchController.text
                        : 'Search for items',
                    style: TextStyle(
                      color: _searchController.text.isNotEmpty
                          ? const Color(0xFF1A201C)
                          : const Color(0xFF4A5A4E),
                      fontSize: 15,
                      fontWeight: _searchController.text.isNotEmpty
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _searchController.clear();
                        ref.read(fridgeDetailFilterProvider.notifier).setSearchQuery('');
                      },
                      child: Center(
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDFE4DC),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 15,
                            color: Color(0xFF414942),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Thin baseline border across tabs
        Container(
          height: 1.2,
          color: const Color(0xFFD7E2D5),
        ),
        TabBar(
          controller: _tabController,
          onTap: (index) {
            ref.read(fridgeDetailFilterProvider.notifier).setZone(
                  index == 0 ? 'fridge' : 'freezer',
                );
          },
          indicatorColor: const Color(0xFF2E6A44), // Figma exact green indicator
          indicatorWeight: 3.5,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: const Color(0xFF1A201C),
          unselectedLabelColor: const Color(0xFF5C665F),
          labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Fridge'),
            Tab(text: 'Freezer'),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFF94A3B8)),
            SizedBox(height: 12),
            Text(
              'No items found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Try changing filters or add a new food item',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}
