import 'package:flutter/material.dart';

/// Screen #16 SnackBar confirming consumption.
/// Standard full-width bottom SnackBar matching app pattern (e.g. Added "..." successfully).
class FinishAllSnackbar {
  static void show(
    BuildContext context, {
    required String itemName,
    VoidCallback? onUndo,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final isTh = Localizations.localeOf(context).languageCode == 'th';

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          isTh
              ? 'บันทึกการบริโภค "$itemName" เรียบร้อยแล้ว'
              : 'Consumed "$itemName" successfully',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
