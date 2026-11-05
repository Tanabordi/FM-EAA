import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/freshness_colors.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/user_avatar.dart';
import 'package:fm_eaa/features/settings/providers/settings_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/logout_dialog.dart';

/// Screen #22: Settings matching Figma Node 134:187
/// Features Profile card, Language switch (TH | EN), Theme switch (Light | Dark), and Logout button
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!next.isAuthenticated) {
        try {
          ref.read(routerProvider).go('/sign-in');
        } catch (_) {
          try {
            context.go('/sign-in');
          } catch (_) {}
        }
      }
    });

    final theme = Theme.of(context);
    final user = ref.watch(userProfileProvider);
    final currentLocale = ref.watch(localeProvider);
    final currentThemeMode = ref.watch(themeModeProvider);
    final isTh = currentLocale.languageCode == 'th';

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
        title: Text(isTh ? 'การตั้งค่า' : 'Settings', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Profile Section
            Text(
              isTh ? 'ข้อมูลส่วนตัว' : 'Profile',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    UserAvatar(
                      name: user.username,
                      avatarUrl: user.avatarUrl,
                      radius: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: isTh ? 'แก้ไขโปรไฟล์' : 'Edit Profile',
                      onPressed: () => context.push('/settings/profile'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Preferences Section
            Text(
              isTh ? 'การตั้งค่าทั่วไป' : 'Preferences',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    title: Text(isTh ? 'ภาษา' : 'Language', style: const TextStyle(fontWeight: FontWeight.w500)),
                    trailing: SizedBox(
                      width: 130,
                      child: SegmentedButton<String>(
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                        segments: const [
                          ButtonSegment(value: 'th', label: Text('TH')),
                          ButtonSegment(value: 'en', label: Text('EN')),
                        ],
                        selected: {currentLocale.languageCode},
                        onSelectionChanged: (set) {
                          final newLang = set.first;
                          ref.read(localeProvider.notifier).setLocale(newLang);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                newLang == 'th'
                                    ? 'เปลี่ยนภาษาเป็นภาษาไทยแล้ว'
                                    : 'Switched language to English',
                              ),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(isTh ? 'ธีม' : 'Theme', style: const TextStyle(fontWeight: FontWeight.w500)),
                    trailing: SizedBox(
                      width: 140,
                      child: SegmentedButton<ThemeMode>(
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                        segments: [
                          ButtonSegment(value: ThemeMode.light, label: Text(isTh ? 'สว่าง' : 'Light')),
                          ButtonSegment(value: ThemeMode.dark, label: Text(isTh ? 'มืด' : 'Dark')),
                        ],
                        selected: {currentThemeMode},
                        onSelectionChanged: (set) {
                          ref.read(themeModeProvider.notifier).setThemeMode(set.first);
                        },
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: const Text('Manage device permissions & alerts', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      await NotificationService().openNotificationSettings();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Log out Button
            PrimaryButton(
              label: isTh ? 'ออกจากระบบ' : 'Log out',
              backgroundColor: FreshnessColors.danger,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const LogoutDialog(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
