import 'package:flutter/material.dart';

/// Screen #16 / Delete Item details confirmation dialog.
/// Displays dialog matching mockup:
/// - Background: #EAEFE8
/// - Rounded corners: 28dp
/// - Title: "Delete {itemName}?" (fontSize 22, bold, #181D17)
/// - Content: "This action cannot be undone" (fontSize 14, #414941)
/// - Actions: Cancel (text button #181D17) and Delete (stadium filled red button #B71C1C)
class DeleteItemDialog extends StatelessWidget {
  final String itemId;
  final String itemName;
  final VoidCallback? onConfirm;

  const DeleteItemDialog({
    super.key,
    required this.itemId,
    this.itemName = 'Strawberries',
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFEAEFE8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 20, 20),
      title: Text(
        'Delete $itemName?',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF181D17),
        ),
      ),
      content: const Text(
        'This action cannot be undone',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF414941),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF181D17),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFB71C1C),
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            onConfirm?.call();
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
