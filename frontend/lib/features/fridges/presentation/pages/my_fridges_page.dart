import '../../../../shared/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/fridge_card.dart';
import '../widgets/edit_fridge_sheet.dart';
import '../../providers/fridges_provider.dart';

// Screen #5 My Fridges: Header "My Fridges", Notifications + Settings circular icons, summary banner, 2-column fridge cards, FAB
class MyFridgesPage extends ConsumerWidget {
  const MyFridgesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fridges = ref.watch(fridgesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF3), // Figma exact background #F6FBF3
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar: AppTopBar
            AppTopBar(
              title: 'My Fridges',
              showBackButton: false,
              actions: [
                AppTopBarAction(
                  icon: Icons.notifications_none_rounded,
                  onTap: () => context.push('/notifications'),
                ),
                AppTopBarAction(
                  icon: Icons.settings_outlined,
                  onTap: () => context.push('/settings'),
                ),
              ],
            ),
            // Body Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "A fresh look at what's inside.",
                      style: TextStyle(color: Color(0xFF5C665F), fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 14),
                    // Summary Banner Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAEFE8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Text('✨', style: TextStyle(fontSize: 24)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'A little check, a lot less waste: 3 items need your attention today',
                              style: TextStyle(
                                color: Color(0xFF1A201C),
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your fridges (${fridges.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: Color(0xFF1A201C),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(bottom: 16, right: 16),
        child: FloatingActionButton(
          elevation: 4,
          backgroundColor: const Color(0xFF2E6A44),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          onPressed: () => context.push('/fridges/add'),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

}
