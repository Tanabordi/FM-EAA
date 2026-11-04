import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/fridge_card.dart';
import '../widgets/cute_fridge_illustration.dart';
import '../widgets/edit_fridge_sheet.dart';
import '../widgets/delete_fridge_dialog.dart';
import '../widgets/leave_fridge_dialog.dart';
import '../../providers/fridges_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../notifications/providers/notifications_provider.dart';
import '../../../fridge_detail/providers/fridge_detail_provider.dart';

/// Screen #5: My Fridges (Supports both Empty State [Image 1] and Populated State [Image 2 / 10])
class MyFridgesPage extends ConsumerStatefulWidget {
  const MyFridgesPage({super.key});

  @override
  ConsumerState<MyFridgesPage> createState() => _MyFridgesPageState();
}

class _MyFridgesPageState extends ConsumerState<MyFridgesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (ref.read(authProvider).user == null) {
        await ref.read(authProvider.notifier).restoreSession();
      }
      ref.read(fridgesProvider.notifier).loadFridges();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && next.user != null) {
        ref.read(fridgesProvider.notifier).loadFridges();
      } else if (!next.isAuthenticated) {
        try {
          ref.read(routerProvider).go('/sign-in');
        } catch (_) {
          try {
            context.go('/sign-in');
          } catch (_) {}
        }
      }
    });

    final fridges = ref.watch(fridgesProvider);
    final unreadNotifs = ref.watch(unreadNotificationCountProvider).value ?? 0;
    final theme = Theme.of(context);
    final isEmpty = fridges.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF3),
      body: SafeArea(
        child: isEmpty
            ? _buildEmptyState(context, unreadNotifs)
            : _buildPopulatedState(context, ref, fridges, theme, unreadNotifs),
      ),
      floatingActionButton: isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 4.0, bottom: 8.0),
              child: SizedBox(
                width: 56,
                height: 56,
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFF2E6A44),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tooltip: 'Add Fridge',
                  onPressed: () => context.push('/fridges/add'),
                  child: const Icon(Icons.add, size: 28),
                ),
              ),
            ),
    );
  }

  /// Screen #5 Empty State (Image 1: 100% pixel-perfect match to Figma)
  Widget _buildEmptyState(BuildContext context, int unreadNotifs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Top header row: "My Fridges" + Bell & Settings circle buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'My Fridges',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Color(0xFF181D18),
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  _buildCircleActionButton(
                    icon: Icons.notifications_outlined,
                    tooltip: 'Notifications',
                    badgeCount: unreadNotifs,
                    onPressed: () => context.push('/notifications'),
                  ),
                  const SizedBox(width: 10),
                  _buildCircleActionButton(
                    icon: Icons.settings_outlined,
                    tooltip: 'Settings',
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(flex: 3),
          const Center(
            child: CuteFridgeIllustration(size: 240),
          ),
          const SizedBox(height: 32),
          const Text(
            'No fridges yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF181D18),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Create your first fridge space to start\ntracking your food',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              color: Color(0xFF414942),
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(flex: 4),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 20, color: Colors.white),
              label: const Text(
                'Add First Fridge',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E6A44),
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              onPressed: () => context.push('/fridges/add'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Screen #5 Populated State (Image 2 / 10: 100% pixel-perfect match to Figma)
  Widget _buildPopulatedState(
    BuildContext context,
    WidgetRef ref,
    List dynamicFridges,
    ThemeData theme,
    int unreadNotifs,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Top row: "My Fridges" + Bell & Settings circle buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'My Fridges',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Color(0xFF181D18),
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  _buildCircleActionButton(
                    icon: Icons.notifications_outlined,
                    tooltip: 'Notifications',
                    badgeCount: unreadNotifs,
                    onPressed: () => context.push('/notifications'),
                  ),
                  const SizedBox(width: 10),
                  _buildCircleActionButton(
                    icon: Icons.settings_outlined,
                    tooltip: 'Settings',
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "A fresh look at what's inside.",
            style: TextStyle(
              color: Color(0xFF414942),
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),
          // Section header: "Your fridges" + "N fridges"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Your fridges',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF181D18),
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                '${dynamicFridges.length} fridges',
                style: const TextStyle(
                  color: Color(0xFF414942),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF414942),
                ),
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
              childAspectRatio: 0.82,
            ),
            itemCount: dynamicFridges.length,
            itemBuilder: (context, index) {
              final fridge = dynamicFridges[index];
              return Consumer(
                builder: (context, ref, _) {
                  final liveItems = ref.watch(fridgeItemsProvider(fridge.id));
                  final isMock = fridge.id == 'fridge_kitchen' ||
                      fridge.id == 'fridge_studio' ||
                      fridge.id == 'fridge_demo' ||
                      fridge.id == 'fridge_main' ||
                      fridge.id == 'fridge_1' ||
                      fridge.id == 'fridge_2';

                  int displayCount = fridge.itemCount;
                  if (liveItems.isNotEmpty || isMock) {
                    displayCount = liveItems
                        .where((it) => it.quantity > 0)
                        .length;
                  }

                  final itemsText = displayCount == 0
                      ? 'Empty'
                      : (displayCount == 1 ? '1 Item' : '$displayCount Items');

                  final currentUserId = ref.watch(authProvider).user?.id;
                  final isOwner = fridge.isUserOwner(currentUserId);

                  return FridgeCard(
                    name: fridge.name,
                    description: fridge.description,
                    itemsCountText: itemsText,
                    isPersonal: fridge.isPersonal,
                    memberCount: fridge.memberCount,
                    onTap: () async {
                      await context.push('/fridges/${fridge.id}');
                      if (context.mounted) {
                        ref.read(fridgesProvider.notifier).loadFridges();
                      }
                    },
                    onLongPress: () {
                      if (isOwner) {
                        showDialog(
                          context: context,
                          useRootNavigator: true,
                          builder: (_) => DeleteFridgeDialog(
                            fridgeId: fridge.id,
                            fridgeName: fridge.name,
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          useRootNavigator: true,
                          builder: (_) => LeaveFridgeDialog(
                            fridgeId: fridge.id,
                            fridgeName: fridge.name,
                            onConfirm: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              await ref.read(fridgesProvider.notifier).leaveFridge(fridge.id, currentUserId);
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Left "${fridge.name}" successfully'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                    onMoreOptions: isOwner
                        ? () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: const Color(0xFFF6FBF3),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (_) => EditFridgeSheet(fridge: fridge),
                            );
                          }
                        : null,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 90), // Space for FAB
        ],
      ),
    );
  }

  /// Circular subtle action button matching Figma
  Widget _buildCircleActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    int badgeCount = 0,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFEAEFE8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: const Color(0xFF181D18), size: 20),
            tooltip: tooltip,
            onPressed: onPressed,
            padding: EdgeInsets.zero,
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFBA1A1A),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Center(
                child: Text(
                  badgeCount > 99 ? '99+' : badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
