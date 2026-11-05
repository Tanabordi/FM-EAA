import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/freshness_colors.dart';
import '../../../../data/models/fridge_model.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../providers/notifications_provider.dart';
import '../../../fridges/providers/fridges_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  final String? fridgeId;
  final String? fridgeName;

  const NotificationsPage({
    super.key,
    this.fridgeId,
    this.fridgeName,
  });

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> with WidgetsBindingObserver {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkNotificationPermission();
    Future.microtask(() {
      if (mounted) {
        ref.read(fridgesProvider.notifier).loadFridges();
        ref.read(notificationControllerProvider.notifier).sync();
      }
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
    }
  }

  Future<void> _checkNotificationPermission() async {
    final enabled = await NotificationService().areNotificationsEnabled();
    if (mounted && enabled != _notificationsEnabled) {
      setState(() => _notificationsEnabled = enabled);
    }
  }

  Future<void> _handleInviteResponse(NotificationModel notif, bool accept) async {
    final messenger = ScaffoldMessenger.of(context);
    final isTh = ref.read(localeProvider).languageCode == 'th';
    await ref.read(notificationControllerProvider.notifier).respondToInvite(
          notificationId: notif.id,
          inviteId: notif.inviteId,
          accept: accept,
        );

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          isTh
              ? (accept ? 'ยอมรับคำเชิญแล้ว' : 'ปฏิเสธคำเชิญแล้ว')
              : (accept ? 'Accepted invitation.' : 'Declined invitation.'),
        ),
      ),
    );
  }

  Future<void> _handleDismiss(NotificationModel notif) async {
    final messenger = ScaffoldMessenger.of(context);
    final isTh = ref.read(localeProvider).languageCode == 'th';
    await ref.read(notificationControllerProvider.notifier).deleteNotification(notif.id);

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(isTh ? 'ปิดการแจ้งเตือนแล้ว' : 'Notification dismissed.')),
    );
  }

  bool _matchesFridge(NotificationModel n, String fridgeId, String? fridgeName, List<FridgeModel> allFridges) {
    return notificationMatchesFridge(n, fridgeId, fridgeName, allFridges);
  }

  Future<void> _handleMarkAllAsRead([String? effectiveFridgeName]) async {
    final isTh = ref.read(localeProvider).languageCode == 'th';
    if (widget.fridgeId != null) {
      await ref.read(notificationControllerProvider.notifier).markFridgeAsRead(
            widget.fridgeId!,
            null,
            effectiveFridgeName,
          );
    } else {
      await ref.read(notificationControllerProvider.notifier).markAllAsRead();
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isTh ? 'ทำเครื่องหมายว่าอ่านแล้วทั้งหมดแล้ว' : 'All notifications marked as read')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationsAsync = ref.watch(defaultNotificationsStreamProvider);
    final isTh = ref.watch(localeProvider).languageCode == 'th';

    final effectiveFridgeName = widget.fridgeName ??
        (widget.fridgeId != null
            ? ref.watch(fridgesProvider).where((f) => f.id == widget.fridgeId).firstOrNull?.name
            : null);
    final allFridges = ref.watch(fridgesProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 68,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: AppBackButton(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isTh ? 'การแจ้งเตือน' : 'Notifications', style: const TextStyle(fontWeight: FontWeight.bold)),
            if (widget.fridgeId != null && effectiveFridgeName != null && effectiveFridgeName.isNotEmpty)
              Text(
                effectiveFridgeName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: [
          notificationsAsync.maybeWhen(
            data: (list) {
              final filtered = widget.fridgeId != null
                  ? list.where((n) => _matchesFridge(n, widget.fridgeId!, effectiveFridgeName, allFridges)).toList()
                  : list;
              final hasUnread = filtered.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.done_all_rounded, size: 22),
                tooltip: isTh ? 'ทำเครื่องหมายว่าอ่านแล้วทั้งหมด' : 'Mark all as read',
                onPressed: () => _handleMarkAllAsRead(effectiveFridgeName),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildNotificationWarningBanner(context, isTh),
            Expanded(
              child: notificationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error loading notifications: $err')),
                data: (notifications) {
                  final filtered = widget.fridgeId != null
                      ? notifications.where((n) => _matchesFridge(n, widget.fridgeId!, effectiveFridgeName, allFridges)).toList()
                      : notifications;

                  if (filtered.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(notificationControllerProvider.notifier).sync();
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(22),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.notifications_none_outlined,
                                        size: 48,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      widget.fridgeId != null
                                          ? (isTh ? 'ไม่มีการแจ้งเตือนสำหรับตู้นี้' : 'No notifications for this fridge')
                                          : (isTh ? 'ไม่มีการแจ้งเตือน' : 'No Notifications'),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Text(
                                        widget.fridgeId != null
                                            ? (isTh
                                                ? 'การแจ้งเตือนวันหมดอายุและกิจกรรมในตู้เย็นนี้จะแสดงที่นี่'
                                                : 'Expiry alerts and item updates for this fridge will appear here.')
                                            : (isTh
                                                ? 'คุณอ่านครบทั้งหมดแล้ว! การแจ้งเตือนวันหมดอายุและคำเชิญจะแสดงที่นี่'
                                                : "You're all caught up! Expiry alerts and family invites will appear here."),
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          color: theme.colorScheme.onSurfaceVariant,
                                          height: 1.45,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final sortedNotifications = [...filtered]
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(notificationControllerProvider.notifier).sync();
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: sortedNotifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notif = sortedNotifications[index];
                  if (notif.isInvite) {
                    return _buildInviteCard(context, notif, isTh);
                  } else if (notif.isMemberJoined) {
                    return _buildMemberJoinedCard(context, notif, isTh);
                  } else if (notif.isItemAction) {
                    return _buildItemActionCard(context, notif, isTh);
                  } else {
                    return _buildExpiryCard(context, notif, isTh);
                  }
                },
              ),
            );
          },
        ),
      ),
    ],
  ),
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
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
                  isTh ? 'การแจ้งเตือนถูกปิดอยู่ในการตั้งค่า' : 'Notifications disabled in settings',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
                ),
                Text(
                  isTh ? 'เปิดการแจ้งเตือนเพื่อรับการอัปเดตแบบเรียลไทม์' : 'Enable notifications for real-time updates',
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

  Widget _buildInviteCard(BuildContext context, NotificationModel notif, [bool isTh = false]) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timeStr = DateFormat('d MMM · hh:mm a').format(notif.createdAt.toLocal());
    final cardBg = notif.isRead
        ? theme.colorScheme.surfaceContainer
        : (isDark ? theme.colorScheme.surfaceContainerHigh : const Color(0xFFEFF5ED));
    final borderColor = notif.isRead
        ? BorderSide.none
        : BorderSide(color: isDark ? theme.colorScheme.primary.withValues(alpha: 0.5) : const Color(0xFFC3D8C0), width: 1);

    return InkWell(
      onTap: () {
        if (!notif.isRead) {
          ref.read(notificationControllerProvider.notifier).markAsRead(notif.id);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: borderColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mail_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notif.message.isNotEmpty
                                    ? notif.message
                                    : "You have a new fridge invitation",
                                style: TextStyle(
                                  fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (!notif.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(left: 6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2C6B2F),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: FreshnessColors.danger,
                      side: const BorderSide(color: FreshnessColors.danger),
                      shape: const StadiumBorder(),
                      minimumSize: const Size(72, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () => _handleInviteResponse(notif, false),
                    child: Text(isTh ? 'ปฏิเสธ' : 'Decline'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      minimumSize: const Size(72, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 0,
                    ),
                    onPressed: () => _handleInviteResponse(notif, true),
                    child: Text(isTh ? 'ยอมรับ' : 'Accept'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpiryCard(BuildContext context, NotificationModel notif, [bool isTh = false]) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timeStr = DateFormat('d MMM · hh:mm a').format(notif.createdAt.toLocal());
    final cardBg = notif.isRead
        ? theme.colorScheme.surfaceContainer
        : (isDark ? const Color(0xFF2B2117) : const Color(0xFFFFF7ED));
    final borderColor = notif.isRead
        ? BorderSide.none
        : BorderSide(color: isDark ? FreshnessColors.useSoon.withValues(alpha: 0.5) : const Color(0xFFFFD8A8), width: 1);

    return InkWell(
      onTap: () {
        if (!notif.isRead) {
          ref.read(notificationControllerProvider.notifier).markAsRead(notif.id);
        }
        final fridgeId = notif.fridgeId;
        final itemId = notif.itemId;
        if (fridgeId != null && fridgeId.isNotEmpty) {
          if (itemId != null && itemId.isNotEmpty) {
            context.push('/fridges/$fridgeId/items/$itemId');
          } else {
            context.push('/fridges/$fridgeId');
          }
        } else {
          context.push('/fridges');
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: borderColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: isDark ? const Color(0xFF3E2815) : const Color(0xFFFFE8D6),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: FreshnessColors.useSoon,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.localizedTitle(isTh).isNotEmpty ? notif.localizedTitle(isTh) : notif.localizedMessage(isTh),
                            style: TextStyle(
                              fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFD97706),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notif.localizedMessage(isTh).isNotEmpty
                          ? notif.localizedMessage(isTh)
                          : (isTh ? 'อย่าลืมรับประทานก่อนอาหารหมดอายุ' : 'Remember to consume before expiry.'),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: theme.colorScheme.onSurfaceVariant,
                tooltip: isTh ? 'ปิด' : 'Dismiss',
                onPressed: () => _handleDismiss(notif),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberJoinedCard(BuildContext context, NotificationModel notif, [bool isTh = false]) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timeStr = DateFormat('d MMM · hh:mm a').format(notif.createdAt.toLocal());
    final cardBg = notif.isRead
        ? theme.colorScheme.surfaceContainer
        : (isDark ? theme.colorScheme.surfaceContainerHigh : const Color(0xFFE8F5E9));
    final borderColor = notif.isRead
        ? BorderSide.none
        : BorderSide(color: isDark ? theme.colorScheme.primary.withValues(alpha: 0.5) : const Color(0xFFA5D6A7), width: 1);

    return InkWell(
      onTap: () {
        if (!notif.isRead) {
          ref.read(notificationControllerProvider.notifier).markAsRead(notif.id);
        }
        final fridgeId = notif.fridgeId;
        if (fridgeId != null && fridgeId.isNotEmpty) {
          context.push('/fridges/$fridgeId');
        } else {
          context.push('/fridges');
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: borderColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: isDark ? const Color(0xFF1B3B22) : const Color(0xFFC8E6C9),
                child: const Icon(
                  Icons.group_add_rounded,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.localizedTitle(isTh).isNotEmpty
                                ? notif.localizedTitle(isTh)
                                : (isTh ? '👥 สมาชิกใหม่เข้าร่วม' : 'New Member Joined'),
                            style: TextStyle(
                              fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notif.localizedMessage(isTh).isNotEmpty
                          ? notif.localizedMessage(isTh)
                          : (isTh ? 'มีสมาชิกใหม่เข้าร่วมตู้เย็นแล้ว' : 'A new member has joined the fridge.'),
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: theme.colorScheme.onSurfaceVariant,
                tooltip: isTh ? 'ปิด' : 'Dismiss',
                onPressed: () => _handleDismiss(notif),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemActionCard(BuildContext context, NotificationModel notif, [bool isTh = false]) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timeStr = DateFormat('d MMM · hh:mm a').format(notif.createdAt.toLocal());

    Color avatarBg;
    Color iconColor;
    IconData icon;
    Color cardBg;
    Color borderColor;

    if (notif.isItemAdded) {
      avatarBg = isDark ? const Color(0xFF1B3B22) : const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF2E7D32);
      icon = Icons.add_circle_outline_rounded;
      cardBg = notif.isRead
          ? theme.colorScheme.surfaceContainer
          : (isDark ? theme.colorScheme.surfaceContainerHigh : const Color(0xFFF1F8E9));
      borderColor = isDark ? theme.colorScheme.primary.withValues(alpha: 0.5) : const Color(0xFFC5E1A5);
    } else if (notif.isItemConsumed) {
      avatarBg = isDark ? const Color(0xFF3E2815) : const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFE65100);
      icon = Icons.restaurant_rounded;
      cardBg = notif.isRead
          ? theme.colorScheme.surfaceContainer
          : (isDark ? const Color(0xFF2B2117) : const Color(0xFFFFF8E1));
      borderColor = isDark ? FreshnessColors.useSoon.withValues(alpha: 0.5) : const Color(0xFFFFE082);
    } else {
      // isItemDeleted
      avatarBg = isDark ? const Color(0xFF3E1818) : const Color(0xFFFFEBEE);
      iconColor = const Color(0xFFC62828);
      icon = Icons.delete_outline_rounded;
      cardBg = notif.isRead
          ? theme.colorScheme.surfaceContainer
          : (isDark ? const Color(0xFF2D1616) : const Color(0xFFFFF5F5));
      borderColor = isDark ? FreshnessColors.danger.withValues(alpha: 0.5) : const Color(0xFFFFCDD2);
    }

    return InkWell(
      onTap: () {
        if (!notif.isRead) {
          ref.read(notificationControllerProvider.notifier).markAsRead(notif.id);
        }
        final fridgeId = notif.fridgeId;
        if (fridgeId != null && fridgeId.isNotEmpty) {
          context.push('/fridges/$fridgeId');
        } else {
          context.push('/fridges');
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: notif.isRead ? BorderSide.none : BorderSide(color: borderColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: avatarBg,
                child: Icon(
                  icon,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.localizedTitle(isTh).isNotEmpty
                                ? notif.localizedTitle(isTh)
                                : notif.localizedMessage(isTh),
                            style: TextStyle(
                              fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: BoxDecoration(
                              color: iconColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notif.localizedMessage(isTh).isNotEmpty
                          ? notif.localizedMessage(isTh)
                          : (isTh ? 'มีการอัปเดตรายการอาหารในตู้เย็น' : 'Food item activity in your fridge.'),
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: theme.colorScheme.onSurfaceVariant,
                tooltip: isTh ? 'ปิด' : 'Dismiss',
                onPressed: () => _handleDismiss(notif),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
