import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/figma_auth_widgets.dart';
import '../../domain/models/family_member.dart';
import '../../providers/family_provider.dart';

/// Screen #19: Invite to Family matching Figma nodes 170:5, 174:6 & 172:81
class InviteMemberPage extends ConsumerStatefulWidget {
  final String fridgeId;

  const InviteMemberPage({super.key, required this.fridgeId});

  @override
  ConsumerState<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends ConsumerState<InviteMemberPage> {
  final _searchController = TextEditingController();

  // Mock users matching Figma node 174:6 (Mint, Minty, Mintra)
  final List<UserSearchResult> _allMockUsers = [
    const UserSearchResult(
      username: 'Mint',
      status: 'already',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    ),
    const UserSearchResult(
      username: 'Minty',
      status: 'available',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    ),
    const UserSearchResult(
      username: 'Mintra',
      status: 'pending',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    ),
  ];

  late Map<String, String> _userStatuses;
  bool _isInviting = false;

  @override
  void initState() {
    super.initState();
    _userStatuses = {for (var u in _allMockUsers) u.username: u.status};
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleInvite(String username) async {
    setState(() => _isInviting = true);
    try {
      // Connect to familyRepositoryProvider
      await ref.read(familyRepositoryProvider).inviteMember(widget.fridgeId, username);

      if (!mounted) return;
      setState(() {
        _userStatuses[username] = 'pending';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invitation sent to $username')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send invitation: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isInviting = false);
    }
  }

  Widget _buildAvatar(UserSearchResult user) {
    final initials = user.username.isNotEmpty ? user.username[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: 24,
      backgroundColor: const Color(0xFFD3DDD1),
      backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
      onBackgroundImageError: (_, __) {},
      child: user.avatarUrl.isEmpty
          ? Text(
              initials,
              style: const TextStyle(
                color: Color(0xFF181D18),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final query = _searchController.text.trim().toLowerCase();
    final matchingUsers = query.isEmpty
        ? <UserSearchResult>[]
        : _allMockUsers.where((u) => u.username.toLowerCase().contains(query)).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with rounded back button
              Row(
                children: [
                  const FigmaBackButton(),
                  const SizedBox(width: 16),
                  Text(
                    'Invite to Family',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Search Input Box (Figma Node 170:5)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEFE8),
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFF181D18), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 16, color: Color(0xFF181D18)),
                        decoration: const InputDecoration(
                          hintText: 'Search Username',
                          hintStyle: TextStyle(
                            color: Color(0xFF414942),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        iconSize: 18,
                        tooltip: 'Clear search',
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD3DDD1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 14, color: Color(0xFF181D18)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Search Results (Frame 174:6)
              if (matchingUsers.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Search results',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF181D18),
                      ),
                    ),
                    Text(
                      '${matchingUsers.length} User',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF414942),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Results List Card
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEFE8),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: matchingUsers.map((user) {
                      final currentStatus = _userStatuses[user.username] ?? 'available';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            // Avatar with fallback
                            _buildAvatar(user),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                user.username,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF181D18),
                                ),
                              ),
                            ),
                            // Action button based on status
                            if (currentStatus == 'already')
                              const Text(
                                'Already in family',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF414942),
                                ),
                              )
                            else if (currentStatus == 'pending')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFF717971), width: 1),
                                ),
                                child: const Text(
                                  'Pending',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF181D18),
                                  ),
                                ),
                              )
                            else
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E6A44),
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                                  elevation: 0,
                                ),
                                onPressed: _isInviting ? null : () => _handleInvite(user.username),
                                child: const Text(
                                  'Invite',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                // Footer notice matching Figma
                const Text(
                  'Friends will receive an invitation in their notifications and must accept it before they can join the family.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF414942),
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
