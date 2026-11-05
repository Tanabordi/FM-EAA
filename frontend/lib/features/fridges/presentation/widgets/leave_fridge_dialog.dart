import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/locale_provider.dart';

/// Leave Fridge Alert Dialog
class LeaveFridgeDialog extends ConsumerWidget {
  final String fridgeId;
  final String? fridgeName;
  final VoidCallback? onConfirm;

  const LeaveFridgeDialog({
    super.key,
    required this.fridgeId,
    this.fridgeName,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isTh = ref.watch(localeProvider).languageCode == 'th';
    final dialogBg = theme.colorScheme.surfaceContainer;
    const leaveRed = Color(0xFFBA1A1A);
    final textDark = theme.colorScheme.onSurface;
    final textMuted = theme.colorScheme.onSurfaceVariant;

    final displayName = (fridgeName != null && fridgeName!.isNotEmpty)
        ? '"$fridgeName"'
        : (isTh ? 'ตู้เย็นนี้' : 'this fridge');

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
            Text(
              isTh ? 'ออกจากตู้เย็น?' : 'Leave Fridge?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isTh
                  ? 'คุณแน่ใจหรือไม่ว่าต้องการออกจาก $displayName? คุณจะไม่สามารถเข้าถึงวัตถุดิบในตู้เย็นนี้ได้อีก'
                  : 'Are you sure you want to leave $displayName? You will lose access to its items.',
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
                  child: Text(
                    isTh ? 'ยกเลิก' : 'Cancel',
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
                    backgroundColor: leaveRed,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 0,
                    minimumSize: const Size(84, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    if (onConfirm != null) {
                      onConfirm!();
                    }
                  },
                  child: Text(
                    isTh ? 'ออกจากตู้เย็น' : 'Leave',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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
