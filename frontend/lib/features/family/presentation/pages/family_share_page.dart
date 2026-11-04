import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/figma_auth_widgets.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../domain/models/family_member.dart';

import '../../providers/family_provider.dart';
import '../widgets/remove_member_dialog.dart';
import '../../../fridges/presentation/widgets/leave_fridge_dialog.dart';
import '../../../fridges/providers/fridges_provider.dart';

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

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (ref.read(authProvider).user == null) {
        await ref.read(authProvider.notifier).restoreSession();
      }
      ref
          .read(familyMembersProvider(widget.fridgeId).notifier)
          .loadMembers();
    });
  }

  void _showRemoveDialog(FamilyMemberItem member) {
    showDialog(
      context: context,
      builder: (context) => RemoveMemberDialog(
        memberName: member.name,
        onConfirm: () => _handleRemoveMember(member),
      ),
    );
  }

  void _showLeaveDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => LeaveFridgeDialog(
        fridgeId: widget.fridgeId,
        fridgeName: widget.fridgeName,
        onConfirm: () => _handleLeaveFridge(),
      ),
    );
  }

  Future<void> _handleLeaveFridge() async {
    setState(() => _isRemoving = true);
    final currentUserId = ref.read(authProvider).user?.id ?? '';
    try {
      if (currentUserId.isNotEmpty) {
        await ref
            .read(familyMembersProvider(widget.fridgeId).notifier)
            .removeMember(currentUserId);
      }
      await ref.read(fridgesProvider.notifier).leaveFridge(widget.fridgeId, currentUserId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have left "${widget.fridgeName}"'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/fridges');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to leave fridge: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isRemoving = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final familyState = ref.watch(familyMembersProvider(widget.fridgeId));
    final currentUser = ref.watch(authProvider).user;
    final currentUserId = currentUser?.id ?? '';
    final currentUsername = currentUser?.username ?? '';
    final members = familyState.members;

    final fridges = ref.watch(fridgesProvider);
    final currentFridge = fridges.where((f) => f.id == widget.fridgeId).firstOrNull;

    bool checkIsMe(FamilyMemberItem m) {
      if (currentUserId.isNotEmpty && m.id.isNotEmpty && m.id.toLowerCase() == currentUserId.toLowerCase()) {
        return true;
      }
      final cleanName = m.name.replaceAll(RegExp(r'\s*\(me\)$', caseSensitive: false), '').trim();
      if (currentUsername.isNotEmpty && cleanName.isNotEmpty && cleanName.toLowerCase() == currentUsername.toLowerCase()) {
        return true;
      }
      return false;
    }


    final bool isCurrentUserOwner;
    if (currentFridge != null && currentFridge.role.toLowerCase() == 'member') {
      isCurrentUserOwner = false;
    } else if (currentFridge != null && currentUserId.isNotEmpty) {
      isCurrentUserOwner = currentFridge.isUserOwner(currentUserId);
    } else {
      isCurrentUserOwner = members.any((m) => checkIsMe(m) && m.isOwner);
    }

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
                        final isMe = checkIsMe(member);
                        final displayName = isMe && !member.name.contains('(ME)')
                            ? '${member.name} (ME)'
                            : member.name;

                        // Only owner can delete other members (never themselves)
                        final canDelete = isCurrentUserOwner && !member.isOwner && !isMe;
                        // Non-owner member viewing themselves can leave
                        final isMeAndCanLeave = isMe && !isCurrentUserOwner;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              UserAvatar(
                                name: member.name,
                                avatarUrl: member.avatarUrl,
                                radius: 24,
                              ),
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
                              else if (isMeAndCanLeave)
                                IconButton(
                                  onPressed: _isRemoving ? null : _showLeaveDialog,
                                  tooltip: 'Leave Fridge',
                                  icon: const Icon(
                                    Icons.exit_to_app_rounded,
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

                // Action Button at bottom
                if (isCurrentUserOwner) ...[
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
                if (!isCurrentUserOwner) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      key: const Key('leave_fridge_bottom_button'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFBA1A1A),
                        side: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.exit_to_app_rounded, size: 20),
                      label: const Text(
                        'Leave Fridge',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isRemoving ? null : _showLeaveDialog,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
