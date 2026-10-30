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
            // Top App Bar
            _buildAppBar(context),
            // Floating Pill Search Bar with Shadow
            _buildSearchBar(context),
            const SizedBox(height: 4),
            // Circular Category Chips (All, Proteins, Veggies, Beverages, Meals, Sauces)
            CategoryChips(
              selectedCategory: filter.category,
              onSelected: (cat) {
                ref.read(fridgeDetailFilterProvider.notifier).setCategory(cat);
              },
            ),
            const SizedBox(height: 4),
            // Fridge | Freezer Tabs
            _buildTabs(),
            // Food Items Section Header ("Your food" & "N items")
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
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
                      padding: const EdgeInsets.only(bottom: 84, top: 2),
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
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 58,
        height: 58,
        margin: const EdgeInsets.only(bottom: 8, right: 4),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // Back button in rounded square outline
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFFD9E2D7), width: 1.2),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1B241E)),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  context.pop();
                } else {
                  context.go('/fridges');
                }
              },
            ),
          ),
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
            tooltip: 'Family',
            onTap: () => context.push('/fridges/${widget.fridgeId}/family'),
          ),
          const SizedBox(width: 6),
          _buildActionIcon(
            icon: Icons.history_rounded,
            tooltip: 'History',
            onTap: () => context.push('/fridges/${widget.fridgeId}/history'),
          ),
          const SizedBox(width: 6),
          _buildActionIcon(
            icon: Icons.notifications_none_rounded,
            tooltip: 'Notifications',
            onTap: () => context.push('/notifications'),
          ),
          const SizedBox(width: 6),
          _buildActionIcon(
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  IconButton(
                    icon: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD0DDD0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 14, color: Color(0xFF334155)),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(fridgeDetailFilterProvider.notifier).setSearchQuery('');
                    },
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
