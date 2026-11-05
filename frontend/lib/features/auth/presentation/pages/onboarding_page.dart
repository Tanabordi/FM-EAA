import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../shared/widgets/primary_button.dart';

/// Screen #1: Onboarding & Permission matching Figma node 11:26
/// - Shows when user signs up for the first time (via Email or Google).
/// - 3D Fridge illustration with balanced, responsive, and symmetrical layout.
/// - If user clicks "Enable Notifications", grant permission and permanently mark completed.
/// - If user clicks "Skip", proceed to /fridges without marking permanent, so it prompts again on next signup.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTh = Localizations.localeOf(context).languageCode == 'th';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(flex: 1),

                      // 3D Fridge Illustration matching Figma
                      Center(
                        child: Image.asset(
                          'assets/images/onboarding_fridge.png',
                          width: (constraints.maxWidth * 0.88).clamp(290.0, 350.0),
                          height: (constraints.maxWidth * 0.88).clamp(290.0, 350.0),
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Title matching Figma
                      Text(
                        isTh ? 'ลดขยะอาหารในบ้านคุณ' : 'Reduce Food Waste',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        isTh
                            ? 'รับการแจ้งเตือนอัจฉริยะก่อนอาหารของคุณจะหมดอายุ'
                            : 'Get smart alerts before your groceries expire.',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const Spacer(flex: 3),

                      // Enable Notifications: Permitted and marked as permanently done
                      PrimaryButton(
                        label: isTh ? 'เปิดการแจ้งเตือน' : 'Enable Notifications',
                        onPressed: () async {
                          final isGranted = await NotificationService().requestPermissionsWithFallback(context);
                          if (isGranted) {
                            try {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('notifications_permission_granted', true);
                            } catch (_) {}
                            await NotificationService().syncFcmTokenWithBackend();
                            if (context.mounted) {
                              context.go('/fridges');
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Skip: User skipped, do not mark as permanent, will prompt again on next signup
                      TextButton(
                        onPressed: () {
                          context.go('/fridges');
                        },
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        child: Text(
                          isTh ? 'ข้าม' : 'Skip',
                          style: TextStyle(
                            fontSize: 15,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
