import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/locale_provider.dart';
import '../../sync/connectivity_watcher.dart';

/// Top banner that automatically appears when network connectivity is lost.
/// Alerts the user that the app is operating in Offline-First mode.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineAsync = ref.watch(isOnlineProvider);
    final isOnline = onlineAsync.value ?? true;
    final isTh = ref.watch(localeProvider).languageCode == 'th';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: isOnline
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3B2A10) : const Color(0xFFFFF4E5),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF7A541A) : const Color(0xFFFFD8A8),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 18,
                    color: isDark ? const Color(0xFFFFA94D) : const Color(0xFFD9480F),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isTh
                          ? 'โหมดออฟไลน์: บันทึกข้อมูลในเครื่อง ข้อมูลจะซิงค์เมื่อต่อเน็ต'
                          : 'Offline mode: Changes saved locally, will sync when reconnected',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFFFFD8A8) : const Color(0xFFD9480F),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
