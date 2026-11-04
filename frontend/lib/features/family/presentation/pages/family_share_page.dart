import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/figma_auth_widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../domain/models/family_member.dart';

import '../../providers/family_provider.dart';
import '../widgets/remove_member_dialog.dart';

/// Screen #18: Family Share matching Figma node 11:49 exactly
class FamilySharePage extends ConsumerStatefulWidget {
  final String fridgeId;
  final String fridgeName;

  const FamilySharePage({
    super.key,
    required this.fridgeId,
    this.fridgeName = 'Kitchen',
  });

  @override
  ConsumerState<FamilySharePage> createState() => _FamilySharePageState();
}

class _FamilySharePageState extends ConsumerState<FamilySharePage> {
  bool _isRemoving = false;

  void _showRemoveDialog(FamilyMemberItem member) {
    showDialog(
      context: context,
      builder: (context) => RemoveMemberDialog(
        memberName: member.name,
        onConfirm: () => _handleRemoveMember(member),
      ),
    );
  }

  Future<void> _handleRemoveMember(FamilyMemberItem member) async {
    setState(() => _isRemoving = true);
    try {
      await ref
          .read(familyMembersProvider(widget.fridgeId).notifier)
          .removeMember(member.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${member.name} has been removed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove member: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isRemoving = false);
    }
  }

  Widget _buildAvatar(FamilyMemberItem member) {
    final initials = member.name.isNotEmpty
        ? member.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '?';

    return CircleAvatar(
      radius: 24,
      backgroundColor: const Color(0xFFD3DDD1),
      backgroundImage: member.avatarUrl.isNotEmpty ? NetworkImage(member.avatarUrl) : null,
      onBackgroundImageError: member.avatarUrl.isNotEmpty ? (_, __) {} : null,
      child: member.avatarUrl.isEmpty

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
    final familyState = ref.watch(familyMembersProvider(widget.fridgeId));
    final currentUserId = ref.watch(authProvider).user?.id ?? '';
    final members = familyState.members;

    // Check if current user is owner of the fridge
    final isCurrentUserOwner = members.any((m) => m.id == currentUserId && m.isOwner) ||
        (currentUserId.isEmpty && members.any((m) => m.isOwner));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref
              .read(familyMembersProvider(widget.fridgeId).notifier)
              .loadMembers(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Bar with back button
                Row(
                  children: [
                    const FigmaBackButton(),
                    const SizedBox(width: 16),
                    Text(
                      'Family Share',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Dynamic Fridge Card (Figma node 11:49)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEFE8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.kitchen_outlined,
                        size: 32,
                        color: Color(0xFF181D18),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          widget.fridgeName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: const Color(0xFF181D18),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Section Title with count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Family members',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${members.length} ${members.length == 1 ? "Member" : "Members"}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Members Container Card
                if (familyState.isLoading && members.isEmpty)
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAEFE8),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFF2E6A44)),
                    ),
                  )
                else if (members.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAEFE8),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        'No members yet. Invite someone below!',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAEFE8),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: members.map((member) {
                        final isMe = member.id == currentUserId;
                        final displayName = isMe && !member.name.contains('(ME)')
                            ? '${member.name} (ME)'
                            : member.name;

                        // Delete button is shown if current user is owner and target is not owner,
                        // or if member is removing themselves (leaving)
                        final canDelete = isCurrentUserOwner && !member.isOwner;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              _buildAvatar(member),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF181D18),
                                  ),
                                ),
                              ),
                              Text(
                                member.role,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF414942),
                                ),
                              ),
                              const SizedBox(width: 4),
                              if (canDelete)
                                IconButton(
                                  onPressed: _isRemoving ? null : () => _showRemoveDialog(member),
                                  tooltip: 'Remove ${member.name}',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Color(0xFFB91C1C),
                                    size: 24,
                                  ),
                                )
                              else
                                const SizedBox(width: 48),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 20),

                // Explanatory Note with Fridge icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.kitchen_outlined,
                        size: 20,
                        color: Color(0xFF414942),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Everyone can share a refrigerator, manage a shopping list, and further reduce food waste.',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // Invite Member Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E6A44),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.person_add_alt, size: 20),
                    label: const Text(
                      'Invite Member',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      context.push('/fridges/${widget.fridgeId}/family/invite');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
