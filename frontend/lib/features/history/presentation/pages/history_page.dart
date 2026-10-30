import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/freshness_colors.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../providers/history_provider.dart';

// TODO(screen #17 History): แท็บ Consumed | Expired; ข้อความ "Consumed is auto-deleted after 30 days", ปุ่ม "Clear All" (แดง + ถังขยะ); จัดกลุ่มตามวัน ("Today · 29 Oct", "Yesterday · 28 Oct"); แถว: รูป, ชื่อ, "-1 bottle (1 left) • by @alex.lee • 29 Oct • 08:30 AM", ป้าย Consumed, ปุ่มลบรายการ. แท็บ Expired มีโครงเดียวกัน (ไม่ได้ตรวจเนื้อหาละเอียด)
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final historyList = ref.watch(historyItemsProvider(widget.fridgeId));

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: FreshnessColors.danger),
            icon: const Icon(Icons.delete_sweep_outlined, size: 20),
            label: const Text('Clear All'),
            onPressed: () {
              // TODO(history clear): Clear history records matching active tab
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'Consumed'),
            Tab(text: 'Expired'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: theme.colorScheme.surfaceContainer,
              child: Text(
                'Consumed is auto-deleted after 30 days',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Consumed Tab
                  _buildHistoryList(context, historyList.where((h) => h.isConsumed).toList()),
                  // Expired Tab
                  _buildHistoryList(context, historyList.where((h) => !h.isConsumed).toList()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List items) {
    if (items.isEmpty) {
      return const Center(child: Text('No history records'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fastfood, color: Colors.grey),
          ),
          title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            '-${item.quantityChanged.toInt()} ${item.unit} (${item.quantityLeft.toInt()} left) • by @${item.byUsername}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              // TODO(history delete_item): Delete single history record
            },
          ),
        );
      },
    );
  }
}
