import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/confirm_dialog.dart';

// TODO(screen #24 Log Out alert): ยืนยันออกจากระบบ (dialog)
class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ConfirmDialog(
      title: 'Log out',
      message: 'Are you sure you want to log out of your account?',
      confirmLabel: 'Log out',
      isDestructive: true,
      onConfirm: () {
        // TODO(auth logout): Clear session and redirect to sign in
        context.go('/sign-in');
      },
    );
  }
}

