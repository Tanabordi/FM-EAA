import 'package:flutter/material.dart';
import '../../../../core/theme/freshness_colors.dart';
import '../../../../shared/widgets/app_top_bar.dart';

// TODO(screen #21 Notifications): การ์ดคำเชิญ ("John invited you to join 'Home Fridge'" + ปุ่ม Accept เขียว / Decline แดง), การ์ดแจ้งเตือนวันหมดอายุ (ไอคอนนาฬิกา "Milk expires tomorrow")
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF3),
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(title: 'Notifications'),
            Expanded(
              child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Invitation Card
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.mail_outline, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "John invited you to join 'Home Fridge'",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: FreshnessColors.danger,
                            side: const BorderSide(color: FreshnessColors.danger),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () {
                            // TODO(invite decline): Decline invitation
                          },
                          child: const Text('Decline'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () {
                            // TODO(invite accept): Accept invitation
                          },
                          child: const Text('Accept'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Expiry Alert Card
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFFFFE8D6),
                      child: Icon(Icons.access_time_rounded, color: FreshnessColors.useSoon),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Milk expires tomorrow', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          SizedBox(height: 2),
                          Text('Remember to consume before expiry.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
