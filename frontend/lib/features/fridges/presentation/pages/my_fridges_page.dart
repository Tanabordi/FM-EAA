import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/fridge_card.dart';
import '../widgets/edit_fridge_sheet.dart';
import '../../providers/fridges_provider.dart';

// TODO(screen #5 My Fridges): หัวข้อ "My Fridges", ไอคอนแจ้งเตือน + ตั้งค่า, "A fresh look at what's inside.", แบนเนอร์สรุป ("A little check, a lot less waste: N items need your attention today"), "Your fridges" + จำนวนตู้, การ์ดตู้ 2 คอลัมน์: ไอคอนตู้, เมนู ⋮, ชื่อตู้ (เช่น Studio / Kitchen), คำอธิบาย (เช่น 2nd floor / 1st floor), จำนวนของ (Empty / 35 Items), ป้าย Personal หรือ "N members", FAB เพิ่มตู้
class MyFridgesPage extends ConsumerWidget {
  const MyFridgesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fridges = ref.watch(fridgesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Fridges', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "A fresh look at what's inside.",
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 16),
              ),
              const SizedBox(height: 16),
              // Summary Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'A little check, a lot less waste: 3 items need your attention today',
                        style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your fridges (${fridges.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 2-Column Grid of Fridges
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: fridges.length,
                itemBuilder: (context, index) {
                  final fridge = fridges[index];
                  return FridgeCard(
                    name: fridge.name,
                    description: fridge.description,
                    itemsCountText: '35 Items',
                    isPersonal: fridge.isPersonal,
                    memberCount: fridge.memberCount,
                    onTap: () => context.push('/fridges/${fridge.id}'),
                    onMoreOptions: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (_) => EditFridgeSheet(fridge: fridge),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        onPressed: () => context.push('/fridges/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
