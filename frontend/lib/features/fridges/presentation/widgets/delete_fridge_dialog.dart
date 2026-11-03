import 'package:flutter/material.dart';
import '../../../../shared/widgets/confirm_dialog.dart';

// TODO(screen #8 Delete fridge alert): ยืนยันลบตู้ (dialog)
class DeleteFridgeDialog extends StatelessWidget {
  final String fridgeId;

  const DeleteFridgeDialog({super.key, required this.fridgeId});

  @override
  Widget build(BuildContext context) {
    return ConfirmDialog(
      title: 'Delete Fridge',
      message: 'Are you sure you want to delete this fridge? All items and records inside will be permanently deleted.',
      confirmLabel: 'Delete',
      isDestructive: true,
      onConfirm: () {
        // TODO(fridge delete): Delete fridge from repository
      },
    );
  }
}

