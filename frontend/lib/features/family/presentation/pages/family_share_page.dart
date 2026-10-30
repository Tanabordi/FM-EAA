import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/freshness_colors.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../widgets/remove_member_dialog.dart';

// TODO(screen #18 Family Share): การ์ดชื่อตู้ ("Kitchen fridge"), "Family members" + "N Member", แถวสมาชิก: รูปโปรไฟล์, ชื่อ ("Mimi (ME)"), role Owner/Member, ปุ่มลบสมาชิก (เฉพาะที่ไม่ใช่ owner), ข้อความอธิบาย, ปุ่ม "Invite Member"
class FamilySharePage extends StatelessWidget {
  final String fridgeId;

  const FamilySharePage({super.key, required this.fridgeId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock members list
    final members = [
      {'name': 'Mimi (ME)', 'role': 'Owner', 'isOwner': true},
      {'name': 'Sarah', 'role': 'Member', 'isOwner': false},
      {'name': 'John', 'role': 'Member', 'isOwner': false},
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Family Share', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fridge Name Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Text('🧊', style: TextStyle(fontSize: 28)),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kitchen fridge', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('Shared with your household', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Family members (${members.length} Members)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final isOwner = member['isOwner'] as bool;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: UserAvatar(name: member['name'] as String, radius: 20),
                      title: Text(member['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(member['role'] as String),
                      trailing: !isOwner
                          ? IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: FreshnessColors.danger),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => RemoveMemberDialog(memberName: member['name'] as String),
                                );
                              },
                            )
                          : null,
                    );
                  },
                ),
              ),
              Text(
                'Members can view, add, consume, and edit items in this fridge.',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Invite Member',
                onPressed: () => context.push('/fridges/$fridgeId/family/invite'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

