import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/freshness_colors.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../providers/notifications_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  Future<void> _handleInviteResponse(NotificationModel notif, bool accept) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(notificationControllerProvider.notifier).respondToInvite(
          notificationId: notif.id,
          inviteId: notif.inviteId,
          accept: accept,
        );

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          accept ? 'Accepted invitation.' : 'Declined invitation.',
        ),
      ),
    );
  }

  Future<void> _handleDismiss(NotificationModel notif) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(notificationControllerProvider.notifier).deleteNotification(notif.id);

    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Notification dismissed.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationsAsync = ref.watch(defaultNotificationsStreamProvider);

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
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading notifications: $err')),
          data: (notifications) {
            if (notifications.isEmpty) {
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
                      child: const Icon(
                        Icons.notifications_none_outlined,
                        size: 48,
                        color: Color(0xFF717971),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Notifications',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "You're all caught up! Expiry alerts and family invites will appear here.",
                      style: TextStyle(fontSize: 13, color: Color(0xFF717971)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                if (notif.isInvite) {
                  return _buildInviteCard(context, notif);
                } else {
                  return _buildExpiryCard(context, notif);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInviteCard(BuildContext context, NotificationModel notif) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('d MMM · hh:mm a').format(notif.createdAt);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      Text(
                        notif.message.isNotEmpty
                            ? notif.message
                            : "You have a new fridge invitation",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                  ),
                  onPressed: () => _handleInviteResponse(notif, false),
                  child: const Text('Decline'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => _handleInviteResponse(notif, true),
                  child: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryCard(BuildContext context, NotificationModel notif) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('d MMM · hh:mm a').format(notif.createdAt);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  Text(
                    notif.title.isNotEmpty ? notif.title : notif.message,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
    );
  }
}
