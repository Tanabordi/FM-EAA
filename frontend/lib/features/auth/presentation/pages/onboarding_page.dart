import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../shared/widgets/primary_button.dart';

/// Screen #1: Onboarding & Permission matching Figma node 11:26
/// - Shows when user signs up for the first time (via Email or Google).
/// - If user clicks "Enable Notifications", grant permission and permanently mark completed.
/// - If user clicks "Skip", proceed to /fridges without marking permanent, so it prompts again on next signup.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Circle illustration matching Figma
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🧊', style: TextStyle(fontSize: 84)),
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                'Reduce Food Waste',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Get smart alerts before your groceries expire.',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Enable Notifications: Permitted and marked as permanently done
              PrimaryButton(
                label: 'Enable Notifications',
                onPressed: () async {
                  await NotificationService().requestPermissions();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('notifications_permission_granted', true);

                  if (context.mounted) {
                    context.go('/fridges');
                  }
                },
              ),
              const SizedBox(height: 12),
              // Skip: User skipped, do not mark as permanent, will prompt again on next signup
              TextButton(
                onPressed: () {
                  context.go('/fridges');
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 15,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
