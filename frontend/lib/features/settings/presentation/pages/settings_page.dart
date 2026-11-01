import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/theme/freshness_colors.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/user_avatar.dart';
import 'package:fm_eaa/features/settings/providers/settings_provider.dart';
import '../widgets/logout_dialog.dart';

/// Screen #22: Settings matching Figma Node 134:187
/// Features Profile card, Language switch (TH | EN), Theme switch (Light | Dark), and Logout button
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(userProfileProvider);
    final currentLocale = ref.watch(localeProvider);
    final currentThemeMode = ref.watch(themeModeProvider);

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
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Profile Section
            const Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      tooltip: 'Edit Profile',
                      onPressed: () => context.push('/settings/profile'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Preferences Section
            const Text(
              'Preferences',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Language', style: TextStyle(fontWeight: FontWeight.w500)),
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
                          ref.read(localeProvider.notifier).setLocale(set.first);
                        },
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Theme', style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: SizedBox(
                      width: 140,
                      child: SegmentedButton<ThemeMode>(
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                        segments: const [
                          ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                          ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                        ],
                        selected: {currentThemeMode},
                        onSelectionChanged: (set) {
                          ref.read(themeModeProvider.notifier).setThemeMode(set.first);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Log out Button
            PrimaryButton(
              label: 'Log out',
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
