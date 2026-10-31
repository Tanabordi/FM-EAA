import 'package:flutter/material.dart';
import '../../../../shared/widgets/confirm_dialog.dart';

/// Screen #16 / Delete Item confirmation dialog.
class DeleteItemDialog extends StatelessWidget {
  final String itemId;
  final VoidCallback? onConfirm;

  const DeleteItemDialog({
    super.key,
    required this.itemId,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return ConfirmDialog(
      title: 'Delete Item',
      message: 'Are you sure you want to delete this item? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
      onConfirm: () {
        onConfirm?.call();
      },
    );
  }
}
