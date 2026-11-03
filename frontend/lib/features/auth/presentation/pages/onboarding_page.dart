import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../shared/widgets/primary_button.dart';

// TODO(screen #1 Onboarding & Permission): รูปตู้เย็น, หัวข้อ "Reduce Food Waste", "Get smart alerts before your groceries expire.", ปุ่ม "Enable Notifications" (ขอสิทธิ์แจ้งเตือน), ลิงก์ "Skip"
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Placeholder for Fridge illustration / image
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🧊', style: TextStyle(fontSize: 80)),
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Enable Notifications',
                onPressed: () async {
                  await NotificationService().requestPermissions();
                  if (context.mounted) {
                    context.go('/sign-in');
                  }
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/sign-in'),
                child: const Text('Skip'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

