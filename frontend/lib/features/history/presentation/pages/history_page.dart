import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/theme/freshness_colors.dart';
import '../../../../data/models/history_model.dart';
import '../../../../data/models/item_model.dart';
import '../../providers/history_provider.dart';
import '../../../../shared/widgets/app_back_button.dart';

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

  Future<void> _confirmClearAll(int count) async {
    final isTh = ref.read(localeProvider).languageCode == 'th';
    final tabName = _tabController.index == 0
        ? (isTh ? 'บริโภคแล้ว' : 'Consumed')
        : (isTh ? 'หมดอายุ' : 'Expired');

    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isTh ? 'ไม่มีประวัติ$tabNameให้ล้าง' : 'No $_currentTabLabel history to clear.')),
      );
      return;
    }

    final isExpired = _currentKind == 'expired';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isTh ? 'ล้างประวัติ$tabNameทั้งหมด?' : 'Clear All $_currentTabLabel History?'),
        content: Text(
          isExpired
              ? (isTh
                  ? 'คุณแน่ใจหรือไม่ว่าต้องการล้างประวัติหมดอายุทั้งหมดสำหรับตู้เย็นนี้? การดำเนินการนี้จะลบรายการที่หมดอายุออกจากตู้เย็นของคุณด้วย และไม่สามารถยกเลิกได้'
                  : 'Are you sure you want to clear all expired records for this fridge? This will also remove these expired items from your fridge inventory. This action cannot be undone.')
              : (isTh
                  ? 'คุณแน่ใจหรือไม่ว่าต้องการล้างประวัติการบริโภคทั้งหมดสำหรับตู้เย็นนี้? การดำเนินการนี้จะลบเฉพาะประวัติและไม่กระทบต่อตู้เย็นของคุณ และไม่สามารถยกเลิกได้'
                  : 'Are you sure you want to clear all consumed records for this fridge? This will only remove the records from your history and does not affect your fridge inventory. This action cannot be undone.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isTh ? 'ยกเลิก' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: FreshnessColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isTh ? 'ล้างทั้งหมด' : 'Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(historyControllerProvider.notifier).clearHistory(
            widget.fridgeId,
            kind: _currentKind,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isTh ? 'ล้างประวัติ$tabNameทั้งหมดเรียบร้อยแล้ว' : 'All $_currentTabLabel history records cleared.')),
      );
    }
  }

  Future<void> _confirmDeleteSingle(HistoryModel item) async {
    final isTh = ref.read(localeProvider).languageCode == 'th';
    final isExpired = item.isExpired;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isTh
              ? (isExpired ? 'ลบรายการหมดอายุ' : 'ลบบันทึกการบริโภค')
              : (isExpired ? 'Delete Expired Item' : 'Delete Consumption Record'),
        ),
        content: Text(
          isExpired
              ? (isTh
                  ? 'ลบ "${item.itemName}" ออกจากประวัติและตู้เย็นของคุณหรือไม่? การดำเนินการนี้จะลบรายการนี้ออกจากตู้เย็นด้วย'
                  : 'Remove "${item.itemName}" from history and your fridge? This will also remove the item from your fridge inventory.')
              : (isTh
                  ? 'ลบ "${item.itemName}" ออกจากประวัติการบริโภคหรือไม่? การดำเนินการนี้จะลบเฉพาะบันทึกนี้เท่านั้น'
                  : 'Remove "${item.itemName}" from consumption history? This will only remove the record from your history.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isTh ? 'ยกเลิก' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: FreshnessColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isTh ? 'ลบ' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(historyControllerProvider.notifier).deleteItem(item.id, fridgeId: widget.fridgeId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isExpired
                ? (isTh ? 'ลบ "${item.itemName}" ออกจากประวัติและตู้เย็นแล้ว' : 'Removed "${item.itemName}" from history and fridge.')
                : (isTh ? 'ลบ "${item.itemName}" ออกจากประวัติการบริโภคแล้ว' : 'Removed "${item.itemName}" from consumption history.'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(historyStreamProvider(widget.fridgeId));
    final isTh = ref.watch(localeProvider).languageCode == 'th';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leadingWidth: 68,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: AppBackButton(),
        ),
        title: Text(
          isTh ? 'ประวัติ' : 'History',
          style: const TextStyle(
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
              tabs: [
                Tab(text: isTh ? 'บริโภคแล้ว' : 'Consumed'),
                Tab(text: isTh ? 'หมดอายุ' : 'Expired'),
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
                              ? (isTh ? 'ประวัติการบริโภคจะถูกลบอัตโนมัติหลังจาก 30 วัน' : 'Consumed is auto-deleted after 30 days')
                              : (isTh ? 'ประวัติหมดอายุจะถูกลบอัตโนมัติหลังจาก 30 วัน' : 'Expired is auto-deleted after 30 days'),
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B726B)),
                        ),
                      ),
                      InkWell(
                        onTap: () => _confirmClearAll(currentCount),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isTh ? 'ล้างทั้งหมด' : 'Clear All',
                                style: const TextStyle(
                                  color: Color(0xFFB91C1C),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
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
                      _buildHistoryList(context, consumedItems, isConsumedTab: true, isTh: isTh),
                      // Expired Tab
                      _buildHistoryList(context, expiredItems, isConsumedTab: false, isTh: isTh),
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
    bool isTh = false,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFEAEFE8),
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
              isConsumedTab
                  ? (isTh ? 'ไม่มีประวัติการบริโภค' : 'No Consumed History')
                  : (isTh ? 'ไม่มีประวัติหมดอายุ' : 'No Expired History'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              isConsumedTab
                  ? (isTh ? 'รายการอาหารที่ถูกบริโภคจะแสดงที่นี่' : 'Items consumed from your fridge will appear here.')
                  : (isTh ? 'รายการอาหารที่หมดอายุจะแสดงที่นี่' : 'Expired items will appear here.'),
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
            ...groupItems.map((item) => _buildCard(context, item, isTh)),
            const SizedBox(height: 6),
          ],
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, HistoryModel item, [bool isTh = false]) {
    final qtyChanged = item.quantityChanged == item.quantityChanged.toInt()
        ? item.quantityChanged.toInt().toString()
        : item.quantityChanged.toString();
    final qtyLeft = item.quantityLeft == item.quantityLeft.toInt()
        ? item.quantityLeft.toInt().toString()
        : item.quantityLeft.toString();

    final timeStr = DateFormat('hh:mm a').format(item.createdAt);
    final dateStr = DateFormat('d MMM').format(item.createdAt);
    final localizedUnit = ItemModel.localizeUnit(item.unit, isTh);

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
              child: _buildFoodThumbnail(item),
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
                if (item.isConsumed) ...[
                  Text(
                    isTh
                        ? '-$qtyChanged $localizedUnit (เหลือ $qtyLeft) • โดย @${item.byUsername}'
                        : '-$qtyChanged ${item.unit} ($qtyLeft left) • by @${item.byUsername}',
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
                ] else ...[
                  Text(
                    isTh
                        ? '$qtyChanged $localizedUnit หมดอายุ'
                        : '$qtyChanged ${item.unit} expired',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF555F55),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isTh
                        ? '• หมดอายุเมื่อ $dateStr • $timeStr'
                        : '• Expired on $dateStr • $timeStr',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF555F55),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _buildStatusBadge(item.isConsumed, isTh),
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
            onPressed: () => _confirmDeleteSingle(item),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodThumbnail(HistoryModel item) {
    final imagePath = item.imagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackThumbnail(item),
        );
      } else if (imagePath.startsWith('assets/')) {
        return Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackThumbnail(item),
        );
      } else if (!kIsWeb) {
        return Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackThumbnail(item),
        );
      }
    }

    final guessedAsset = _guessAssetByName(item.itemName);
    if (guessedAsset != null) {
      return Image.asset(
        guessedAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackThumbnail(item),
      );
    }

    return _buildFallbackThumbnail(item);
  }

  String? _guessAssetByName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('avocado')) return 'assets/images/food_avocados.png';
    if (lower.contains('spinach') || lower.contains('cabbage') || lower.contains('veggie')) {
      return 'assets/images/food_spinach.png';
    }
    if (lower.contains('strawberr') || lower.contains('berry') || lower.contains('fruit')) {
      return 'assets/images/food_strawberries.png';
    }
    if (lower.contains('tomato')) return 'assets/images/food_cherry_tomatoes.png';
    if (lower.contains('chicken') || lower.contains('meat') || lower.contains('beef') || lower.contains('pork')) {
      return 'assets/images/food_chicken_breasts.png';
    }
    if (lower.contains('egg')) return 'assets/images/food_eggs.png';
    if (lower.contains('salmon') || lower.contains('fish') || lower.contains('seafood')) {
      return 'assets/images/food_salmon_fillets.png';
    }
    if (lower.contains('tofu')) return 'assets/images/food_firm_tofu.png';
    if (lower.contains('whole milk')) return 'assets/images/food_whole_milk.png';
    if (lower.contains('milk') || lower.contains('dairy') || lower.contains('yogurt')) {
      return 'assets/images/food_milk.png';
    }
    if (lower.contains('pizza')) return 'assets/images/food_pizza.png';
    if (lower.contains('lasagna') || lower.contains('pasta')) return 'assets/images/food_lasagna.png';
    if (lower.contains('dumpling')) return 'assets/images/food_dumplings.png';
    if (lower.contains('nugget')) return 'assets/images/food_nuggets.png';
    if (lower.contains('juice') || lower.contains('orange')) return 'assets/images/food_orange_juice.png';
    if (lower.contains('cold brew') || lower.contains('coffee')) return 'assets/images/food_cold_brew.png';
    if (lower.contains('kombucha')) return 'assets/images/food_kombucha.png';
    if (lower.contains('olive oil') || lower.contains('oil')) return 'assets/images/food_olive_oil.png';
    if (lower.contains('soy sauce') || lower.contains('sauce')) return 'assets/images/food_soy_sauce.png';
    if (lower.contains('mayo')) return 'assets/images/food_mayo.png';
    if (lower.contains('sriracha') || lower.contains('chili')) return 'assets/images/food_sriracha.png';
    return null;
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

  Widget _buildStatusBadge(bool isConsumed, [bool isTh = false]) {
    if (isConsumed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF435343), // Figma dark charcoal/olive capsule
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, size: 13, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              isTh ? 'บริโภคแล้ว' : 'Consumed',
              style: const TextStyle(
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 13, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              isTh ? 'หมดอายุแล้ว' : 'Expired',
              style: const TextStyle(
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
