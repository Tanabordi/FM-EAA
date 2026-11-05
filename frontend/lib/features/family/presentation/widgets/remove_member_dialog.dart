import 'package:flutter/material.dart';

class RemoveMemberDialog extends StatelessWidget {
  final String memberName;
  final VoidCallback onConfirm;

  const RemoveMemberDialog({
    super.key,
    required this.memberName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isTh = Localizations.localeOf(context).languageCode == 'th';

    return Dialog(
      backgroundColor: const Color(0xFFEAEFE8),
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTh ? 'ลบ $memberName ออกจาก\nครอบครัวหรือไม่?' : 'Remove $memberName from\nFamily?',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181D18),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isTh ? 'พวกเขาจะไม่สามารถเข้าถึงตู้เย็นที่แชร์นี้ได้อีก' : 'They will lose access to this shared fridge.',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF414942),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      isTh ? 'ยกเลิก' : 'Cancel',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181D18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFB91C1C),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    child: Text(
                      isTh ? 'ลบออก' : 'Remove',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
