import 'package:flutter/material.dart';

// TODO(screen #15 Finish All): กลับหน้ารายการ ของชิ้นนั้นหายไป มี snackbar "<ชื่อ> marked as consumed" + ปุ่ม Undo
class FinishAllSnackbar {
  static void show(BuildContext context, {required String itemName, required VoidCallback onUndo}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName marked as consumed'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: onUndo,
        ),
      ),
    );
  }
}

