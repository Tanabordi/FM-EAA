import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/user_avatar.dart';

// TODO(screen #19 Invite to Family): ช่องค้นหา "Search Username" ผลลัพธ์ผู้ใช้ตามชื่อ (3 เฟรม = state: ว่าง, พิมพ์คำค้น, ผลลัพธ์/เชิญแล้ว)
class InviteMemberPage extends StatefulWidget {
  final String fridgeId;

  const InviteMemberPage({super.key, required this.fridgeId});

  @override
  State<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends State<InviteMemberPage> {
  final _searchController = TextEditingController();
  bool _hasInvited = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF3),
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(title: 'Invite to Family'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _searchController,
                hintText: 'Search Username',
                prefixIcon: const Icon(Icons.search),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              if (_searchController.text.trim().isNotEmpty) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: UserAvatar(name: _searchController.text.trim(), radius: 20),
                  title: Text(_searchController.text.trim(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: _hasInvited ? Colors.grey : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _hasInvited
                        ? null
                        : () {
                            setState(() => _hasInvited = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Invitation sent to ${_searchController.text.trim()}')),
                            );
                          },
                    child: Text(_hasInvited ? 'Invited' : 'Invite'),
                  ),
                ),
              ],
            ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
