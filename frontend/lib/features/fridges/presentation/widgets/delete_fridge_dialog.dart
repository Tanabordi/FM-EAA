import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/fridges_provider.dart';

/// Screen #8: Delete Fridge Alert Dialog (Matching Image 3: media_1793353307481_8e2a9f17.png 100% pixel-perfect)
class DeleteFridgeDialog extends ConsumerWidget {
  final String fridgeId;
  final String? fridgeName;

  const DeleteFridgeDialog({
    super.key,
    required this.fridgeId,
    this.fridgeName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const dialogBg = Color(0xFFEAEFE8);
    const deleteRed = Color(0xFFBA1A1A);
    const textDark = Color(0xFF181D18);
    const textMuted = Color(0xFF414942);

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delete Fridge?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone',
              style: TextStyle(
                fontSize: 15.5,
                color: textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: textDark,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: deleteRed,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 0,
                    minimumSize: const Size(84, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                  ),
                  onPressed: () {
                    final messenger = ScaffoldMessenger.of(context);
                    ref.read(fridgesProvider.notifier).removeFridge(fridgeId);
                    final displayName = (fridgeName != null && fridgeName!.isNotEmpty)
                        ? '"$fridgeName"'
                        : 'Fridge';
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('$displayName deleted successfully'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.of(context).pop(true);
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
