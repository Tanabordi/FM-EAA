import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import 'package:fm_eaa/features/settings/providers/settings_provider.dart';

/// Screen #24: Log Out Alert Dialog matching Figma Node 133:438
class LogoutDialog extends ConsumerWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConfirmDialog(
      title: 'Log out',
      message: 'Are you sure you want to log out of your account?',
      confirmLabel: 'Log out',
      isDestructive: true,
      onConfirm: () {
        final router = GoRouter.of(context);
        ref.read(authRepositoryProvider).logout().catchError((_) {});
        router.go('/sign-in');
      },
    );
  }
}
