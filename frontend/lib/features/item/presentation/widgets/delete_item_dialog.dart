import 'package:flutter/material.dart';
import '../../../../shared/widgets/confirm_dialog.dart';

// TODO(screen #16 Delete Item alert): ยืนยันลบของ (และใช้ pattern เดียวกันกับการลบรายการประวัติ)
class DeleteItemDialog extends StatelessWidget {
  final String itemId;

  const DeleteItemDialog({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return ConfirmDialog(
      title: 'Delete Item',
      message: 'Are you sure you want to delete this item? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
      onConfirm: () {
        // TODO(item delete): Call itemRepository.deleteItem
      },
    );
  }
}

