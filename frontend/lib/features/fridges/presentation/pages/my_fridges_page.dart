import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/fridge_card.dart';
import '../../../../shared/widgets/offline_banner.dart';
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

class _MyFridgesPageState extends ConsumerState<MyFridgesPage> with WidgetsBindingObserver {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkNotificationPermission();
    Future.microtask(() async {
      if (ref.read(authProvider).user == null) {
        await ref.read(authProvider.notifier).restoreSession();
      }
      ref.read(fridgesProvider.notifier).loadFridges();
      ref.read(notificationControllerProvider.notifier).sync();
      NotificationService().syncFcmTokenWithBackend();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNotificationPermission();
      ref.read(notificationControllerProvider.notifier).sync();
    }
  }

  Future<void> _checkNotificationPermission() async {
    final enabled = await NotificationService().areNotificationsEnabled();
    if (mounted && enabled != _notificationsEnabled) {
      setState(() => _notificationsEnabled = enabled);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && next.user != null) {
        ref.read(fridgesProvider.notifier).loadFridges();
        ref.read(notificationControllerProvider.notifier).sync();
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
    final isTh = ref.watch(localeProvider).languageCode == 'th';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: isEmpty
                  ? _buildEmptyState(context, unreadNotifs, isTh)
                  : _buildPopulatedState(context, ref, fridges, theme, unreadNotifs, isTh),
            ),
          ],
        ),
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
  Widget _buildEmptyState(BuildContext context, int unreadNotifs, bool isTh) {
    final theme = Theme.of(context);
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
              Text(
                isTh ? 'ตู้เย็นของฉัน' : 'My Fridges',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  _buildCircleActionButton(
                    icon: Icons.notifications_outlined,
                    tooltip: isTh ? 'การแจ้งเตือน' : 'Notifications',
                    badgeCount: unreadNotifs,
                    onPressed: () => context.push('/notifications'),
                  ),
                  const SizedBox(width: 10),
                  _buildCircleActionButton(
                    icon: Icons.settings_outlined,
                    tooltip: isTh ? 'การตั้งค่า' : 'Settings',
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),
            ],
          ),
          _buildNotificationWarningBanner(context, isTh),
          const Spacer(flex: 3),
          const Center(
            child: CuteFridgeIllustration(size: 240),
          ),
          const SizedBox(height: 32),
          Text(
            isTh ? 'ยังไม่มีตู้เย็น' : 'No fridges yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isTh
                ? 'สร้างตู้เย็นแรกของคุณ\nเพื่อเริ่มติดตามอาหาร'
                : 'Create your first fridge space to start\ntracking your food',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              color: theme.colorScheme.onSurfaceVariant,
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
              label: Text(
                isTh ? 'เพิ่มตู้เย็นแรก' : 'Add First Fridge',
                style: const TextStyle(
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
    bool isTh,
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
              Text(
                isTh ? 'ตู้เย็นของฉัน' : 'My Fridges',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  _buildCircleActionButton(
                    icon: Icons.notifications_outlined,
                    tooltip: isTh ? 'การแจ้งเตือน' : 'Notifications',
                    badgeCount: unreadNotifs,
                    onPressed: () => context.push('/notifications'),
                  ),
                  const SizedBox(width: 10),
                  _buildCircleActionButton(
                    icon: Icons.settings_outlined,
                    tooltip: isTh ? 'การตั้งค่า' : 'Settings',
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isTh ? 'ตรวจสอบรายการอาหารสดใหม่ในตู้' : "A fresh look at what's inside.",
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          _buildNotificationWarningBanner(context, isTh),
          const SizedBox(height: 24),
          // Section header: "Your fridges" + "N fridges"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                isTh ? 'ตู้เย็นของคุณ' : 'Your fridges',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                isTh ? '${dynamicFridges.length} ตู้' : '${dynamicFridges.length} fridges',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                  decorationColor: theme.colorScheme.onSurfaceVariant,
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

                  final itemsText = isTh
                      ? (displayCount == 0 ? 'ว่างเปล่า' : '$displayCount รายการ')
                      : (displayCount == 0
                          ? 'Empty'
                          : (displayCount == 1 ? '1 Item' : '$displayCount Items'));

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
                              backgroundColor: Theme.of(context).colorScheme.surface,
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

  Widget _buildNotificationWarningBanner(BuildContext context, [bool isTh = false]) {
    if (_notificationsEnabled) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bannerBg = isDark ? const Color(0xFF332A15) : const Color(0xFFFFF3CD);
    final bannerBorder = isDark ? const Color(0xFF5E4E24) : const Color(0xFFFFEEBA);
    final textColor = isDark ? const Color(0xFFFFE58F) : const Color(0xFF856404);
    final iconColor = isDark ? const Color(0xFFFFD666) : const Color(0xFF856404);
    final btnBg = isDark ? const Color(0xFFD48806) : const Color(0xFF856404);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_off_rounded, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTh ? 'การแจ้งเตือนถูกปิดอยู่' : 'Notifications are turned off',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
                ),
                Text(
                  isTh ? 'คุณอาจไม่ได้รับแจ้งเตือนของหมดอายุ' : 'You may miss expiration date alerts',
                  style: TextStyle(fontSize: 11.5, color: textColor),
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: btnBg,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await NotificationService().requestPermissionsWithFallback(context, isTh);
              _checkNotificationPermission();
            },
            child: Text(
              isTh ? 'เปิดสิทธิ์' : 'Enable',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
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
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(icon, color: theme.colorScheme.onSurface, size: 20),
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
      },
    );
  }
}
