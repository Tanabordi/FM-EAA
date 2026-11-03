import 'package:flutter/material.dart';
import '../../../../shared/widgets/confirm_dialog.dart';

// TODO(screen #20 Remove Member alert): ยืนยันลบสมาชิก (dialog)
class RemoveMemberDialog extends StatelessWidget {
  final String memberName;

  const RemoveMemberDialog({super.key, required this.memberName});

  @override
  Widget build(BuildContext context) {
    return ConfirmDialog(
      title: 'Remove Member',
      message: 'Are you sure you want to remove $memberName from this fridge?',
      confirmLabel: 'Remove',
      isDestructive: true,
      onConfirm: () {
        // TODO(family remove_member): Call familyRepository.removeMember
      },
    );
  }
}

