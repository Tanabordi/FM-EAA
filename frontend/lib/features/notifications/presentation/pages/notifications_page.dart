import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/freshness_colors.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../providers/notifications_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

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

  Future<void> _handleMarkAllAsRead() async {
    final isTh = ref.read(localeProvider).languageCode == 'th';
    await ref.read(notificationControllerProvider.notifier).markAllAsRead();
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
        title: Text(isTh ? 'การแจ้งเตือน' : 'Notifications', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          notificationsAsync.maybeWhen(
            data: (list) {
              final hasUnread = list.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.done_all_rounded, size: 22),
                tooltip: isTh ? 'ทำเครื่องหมายว่าอ่านแล้วทั้งหมด' : 'Mark all as read',
                onPressed: _handleMarkAllAsRead,
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
            _buildNotificationWarningBanner(context),
            Expanded(
              child: notificationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error loading notifications: $err')),
                data: (notifications) {
            if (notifications.isEmpty) {
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
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEAEFE8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_none_outlined,
                                  size: 48,
                                  color: Color(0xFF717971),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                isTh ? 'ไม่มีการแจ้งเตือน' : 'No Notifications',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF181D18),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  isTh
                                      ? 'คุณอ่านครบทั้งหมดแล้ว! การแจ้งเตือนวันหมดอายุและคำเชิญจะแสดงที่นี่'
                                      : "You're all caught up! Expiry alerts and family invites will appear here.",
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF717971),
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

            final sortedNotifications = [...notifications]
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
                    return _buildMemberJoinedCard(context, notif);
                  } else if (notif.isItemAction) {
                    return _buildItemActionCard(context, notif);
                  } else {
                    return _buildExpiryCard(context, notif);
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

  Widget _buildNotificationWarningBanner(BuildContext context) {
    if (_notificationsEnabled) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFEEBA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_off_rounded, color: Color(0xFF856404), size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'การแจ้งเตือนถูกปิดอยู่ในการตั้งค่า',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF856404)),
                ),
                Text(
                  'เปิดการแจ้งเตือนเพื่อรับการอัปเดตแบบเรียลไทม์',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF856404)),
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF856404),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await NotificationService().requestPermissionsWithFallback(context);
              _checkNotificationPermission();
            },
            child: const Text('เปิดสิทธิ์', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCard(BuildContext context, NotificationModel notif, [bool isTh = false]) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('d MMM · hh:mm a').format(notif.createdAt.toLocal());

    return InkWell(
      onTap: () {
        if (!notif.isRead) {
          ref.read(notificationControllerProvider.notifier).markAsRead(notif.id);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        color: notif.isRead ? theme.colorScheme.surfaceContainer : const Color(0xFFEFF5ED),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: notif.isRead
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFC3D8C0), width: 1),
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
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
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

  Widget _buildExpiryCard(BuildContext context, NotificationModel notif) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('d MMM · hh:mm a').format(notif.createdAt.toLocal());

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
        color: notif.isRead ? theme.colorScheme.surfaceContainer : const Color(0xFFFFF7ED),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: notif.isRead
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFFFD8A8), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFFFE8D6),
                child: Icon(
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
                            notif.title.isNotEmpty ? notif.title : notif.message,
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
                      notif.message.isNotEmpty ? notif.message : 'Remember to consume before expiry.',
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
                tooltip: 'Dismiss',
                onPressed: () => _handleDismiss(notif),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberJoinedCard(BuildContext context, NotificationModel notif) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('d MMM · hh:mm a').format(notif.createdAt.toLocal());

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
        color: notif.isRead ? theme.colorScheme.surfaceContainer : const Color(0xFFE8F5E9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: notif.isRead
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFA5D6A7), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFC8E6C9),
                child: Icon(
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
                            notif.title.isNotEmpty ? notif.title : 'New Member Joined',
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
                      notif.message.isNotEmpty ? notif.message : 'A new member has joined the fridge.',
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
                tooltip: 'Dismiss',
                onPressed: () => _handleDismiss(notif),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemActionCard(BuildContext context, NotificationModel notif) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('d MMM · hh:mm a').format(notif.createdAt.toLocal());

    Color avatarBg;
    Color iconColor;
    IconData icon;
    Color cardBg;
    Color borderColor;

    if (notif.isItemAdded) {
      avatarBg = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF2E7D32);
      icon = Icons.add_circle_outline_rounded;
      cardBg = notif.isRead ? theme.colorScheme.surfaceContainer : const Color(0xFFF1F8E9);
      borderColor = const Color(0xFFC5E1A5);
    } else if (notif.isItemConsumed) {
      avatarBg = const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFE65100);
      icon = Icons.restaurant_rounded;
      cardBg = notif.isRead ? theme.colorScheme.surfaceContainer : const Color(0xFFFFF8E1);
      borderColor = const Color(0xFFFFE082);
    } else {
      // isItemDeleted
      avatarBg = const Color(0xFFFFEBEE);
      iconColor = const Color(0xFFC62828);
      icon = Icons.delete_outline_rounded;
      cardBg = notif.isRead ? theme.colorScheme.surfaceContainer : const Color(0xFFFFF5F5);
      borderColor = const Color(0xFFFFCDD2);
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
                            notif.title.isNotEmpty ? notif.title : notif.message,
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
                      notif.message.isNotEmpty ? notif.message : 'Food item activity in your fridge.',
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
                tooltip: 'Dismiss',
                onPressed: () => _handleDismiss(notif),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
