import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/freshness_colors.dart';
import '../../../../data/models/history_model.dart';
import '../../providers/history_provider.dart';

class HistoryPage extends ConsumerStatefulWidget {
  final String fridgeId;

  const HistoryPage({super.key, required this.fridgeId});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    // Auto-clean consumed records older than 30 days
    Future.microtask(() {
      if (mounted) {
        ref.read(historyControllerProvider.notifier).cleanOldConsumedHistory();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _currentKind => _tabController.index == 0 ? 'consumed' : 'expired';
  String get _currentTabLabel => _tabController.index == 0 ? 'Consumed' : 'Expired';

  Future<void> _confirmClearAll(BuildContext context, int count) async {
    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No $_currentTabLabel history to clear.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Clear All $_currentTabLabel History?'),
        content: Text(
          'Are you sure you want to clear all $_currentTabLabel records for this fridge? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: FreshnessColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(historyControllerProvider.notifier).clearHistory(
            widget.fridgeId,
            kind: _currentKind,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('All $_currentTabLabel history records cleared.')),
        );
      }
    }
  }

  Future<void> _confirmDeleteSingle(BuildContext context, HistoryModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete History Record'),
        content: Text('Remove "${item.itemName}" from history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: FreshnessColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(historyControllerProvider.notifier).deleteItem(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed "${item.itemName}" from history.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(historyStreamProvider(widget.fridgeId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withValues(alpha: 0.12), width: 1.2),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
        title: const Text(
          'History',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: const Color(0xFF2E6A44),
              indicatorWeight: 2.5,
              dividerColor: Colors.transparent,
              labelColor: const Color(0xFF2E6A44),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              unselectedLabelColor: const Color(0xFF717971),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              tabs: const [
                Tab(text: 'Consumed'),
                Tab(text: 'Expired'),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading history: $err')),
          data: (allHistory) {
            final consumedItems = allHistory.where((h) => h.isConsumed).toList();
            final expiredItems = allHistory.where((h) => !h.isConsumed).toList();
            final currentCount = _tabController.index == 0 ? consumedItems.length : expiredItems.length;

            return Column(
              children: [
                // Info banner + Clear All row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 15,
                        color: Color(0xFF6B726B),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _tabController.index == 0
                              ? 'Consumed is auto-deleted after 30 days'
                              : 'Expired is auto-deleted after 30 days',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B726B)),
                        ),
                      ),
                      InkWell(
                        onTap: () => _confirmClearAll(context, currentCount),
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Clear All',
                                style: TextStyle(
                                  color: Color(0xFFB91C1C),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.delete_outline,
                                color: Color(0xFFB91C1C),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Consumed Tab
                      _buildHistoryList(context, consumedItems, isConsumedTab: true),
                      // Expired Tab
                      _buildHistoryList(context, expiredItems, isConsumedTab: false),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    List<HistoryModel> items, {
    required bool isConsumedTab,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEAEFE8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isConsumedTab ? Icons.restaurant_outlined : Icons.alarm_off_outlined,
                size: 44,
                color: const Color(0xFF717971),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isConsumedTab ? 'No Consumed History' : 'No Expired History',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              isConsumedTab
                  ? 'Items consumed from your fridge will appear here.'
                  : 'Expired items will appear here.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF717971)),
            ),
          ],
        ),
      );
    }

    final grouped = _groupByDay(items);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: grouped.keys.length,
      itemBuilder: (context, groupIndex) {
        final dateKey = grouped.keys.elementAt(groupIndex);
        final groupItems = grouped[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                dateKey,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E332D),
                ),
              ),
            ),
            ...groupItems.map((item) => _buildCard(context, item)),
            const SizedBox(height: 6),
          ],
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, HistoryModel item) {
    final qtyChanged = item.quantityChanged == item.quantityChanged.toInt()
        ? item.quantityChanged.toInt().toString()
        : item.quantityChanged.toString();
    final qtyLeft = item.quantityLeft == item.quantityLeft.toInt()
        ? item.quantityLeft.toInt().toString()
        : item.quantityLeft.toString();

    final timeStr = DateFormat('hh:mm a').format(item.createdAt);
    final dateStr = DateFormat('d MMM').format(item.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEFE8), // Figma card background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Food Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 70,
              height: 70,
              child: item.imagePath != null && item.imagePath!.startsWith('http')
                  ? Image.network(
                      item.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildFallbackThumbnail(item),
                    )
                  : _buildFallbackThumbnail(item),
            ),
          ),
          const SizedBox(width: 14),
          // Info Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.itemName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF181D18),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '-$qtyChanged ${item.unit} ($qtyLeft left) • by @${item.byUsername}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF555F55),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '• $dateStr • $timeStr',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF555F55),
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatusBadge(item.isConsumed),
              ],
            ),
          ),
          // Delete single action button (Red Trash Icon)
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFB91C1C),
              size: 22,
            ),
            tooltip: 'Delete record',
            onPressed: () => _confirmDeleteSingle(context, item),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackThumbnail(HistoryModel item) {
    IconData iconData = Icons.fastfood_outlined;
    final nameLower = item.itemName.toLowerCase();

    if (nameLower.contains('milk') || nameLower.contains('yogurt')) {
      iconData = Icons.local_cafe_outlined;
    } else if (nameLower.contains('spinach') || nameLower.contains('avocado')) {
      iconData = Icons.eco_outlined;
    } else if (nameLower.contains('strawberr') || nameLower.contains('fruit')) {
      iconData = Icons.apple_outlined;
    } else if (nameLower.contains('egg') || nameLower.contains('meat')) {
      iconData = Icons.lunch_dining_outlined;
    }

    return Container(
      color: Colors.white,
      child: Icon(
        iconData,
        size: 32,
        color: const Color(0xFF717971),
      ),
    );
  }

  Widget _buildStatusBadge(bool isConsumed) {
    if (isConsumed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF435343), // Figma dark charcoal/olive capsule
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 13, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Consumed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEA3A3D), // Figma red capsule
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 13, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Expired',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
  }

  Map<String, List<HistoryModel>> _groupByDay(List<HistoryModel> items) {
    final Map<String, List<HistoryModel>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final oneWeekAgo = today.subtract(const Duration(days: 7));

    for (final item in items) {
      final itemDate = DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day);
      String key;

      if (itemDate == today) {
        key = 'Today · ${DateFormat('d MMM').format(item.createdAt)}';
      } else if (itemDate == yesterday) {
        key = 'Yesterday · ${DateFormat('d MMM').format(item.createdAt)}';
      } else if (itemDate.isAfter(oneWeekAgo)) {
        key = 'This Week';
      } else {
        key = DateFormat('d MMM yyyy').format(item.createdAt);
      }

      groups.putIfAbsent(key, () => []).add(item);
    }

    return groups;
  }
}
