import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../fridges/providers/fridges_provider.dart';

/// Screen #24: Log Out Alert Dialog matching Figma Node 133:438
class LogoutDialog extends ConsumerWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isTh = false;
    try {
      isTh = ref.watch(localeProvider).languageCode == 'th';
    } catch (_) {
      try {
        isTh = Localizations.localeOf(context).languageCode == 'th';
      } catch (_) {
        isTh = false;
      }
    }

    return ConfirmDialog(
      title: isTh ? 'ออกจากระบบ' : 'Log out',
      message: isTh
          ? 'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบบัญชีของคุณ?'
          : 'Are you sure you want to log out of your account?',
      confirmLabel: isTh ? 'ออกจากระบบ' : 'Log out',
      cancelLabel: isTh ? 'ยกเลิก' : 'Cancel',
      isDestructive: true,
      onConfirm: () async {
        try {
          ref.read(fridgesProvider.notifier).clearAll();
        } catch (_) {}

        await ref.read(authProvider.notifier).logout();

        try {
          ref.read(routerProvider).go('/sign-in');
        } catch (_) {
          if (context.mounted) {
            try {
              GoRouter.of(context).go('/sign-in');
            } catch (_) {}
          }
        }
      },
    );
  }
}
