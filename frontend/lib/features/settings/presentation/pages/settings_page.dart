import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_back_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/theme/freshness_colors.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../widgets/logout_dialog.dart';

// TODO(screen #22 Settings): หัวข้อ Profile: การ์ดโปรไฟล์ (ตัวอักษรย่อ "AL", ชื่อ, อีเมล, ปุ่มแก้ไข); หัวข้อ Preferences: Language (TH | EN), Theme (Light | Dark); ปุ่ม "Log out" (แดง)
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLocale = ref.watch(localeProvider);
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 68,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: AppBackButton(),
        ),
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile Section
            const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const UserAvatar(name: 'Alex Lee', radius: 24),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alex Lee', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 2),
                          Text('alex.lee@example.com', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => context.push('/settings/profile'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Preferences Section
            const Text('Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Language'),
                    trailing: SegmentedButton<String>(
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
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Theme'),
                    trailing: SegmentedButton<ThemeMode>(
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
                ],
              ),
            ),
            const SizedBox(height: 36),
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

