import 'package:flutter/material.dart';

/// Screen #16 SnackBar confirming consumption.
/// Displays a floating dark capsule with checkmark icon.
class FinishAllSnackbar {
  static void show(
    BuildContext context, {
    required String itemName,
    VoidCallback? onUndo,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF181D17),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$itemName marked as consumed',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
