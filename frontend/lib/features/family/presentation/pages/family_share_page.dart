import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/figma_auth_widgets.dart';
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
  // Initial list matching Figma: Mimi (ME) as Owner, Mint as Member
  final List<FamilyMemberItem> _members = [
    const FamilyMemberItem(
      id: '1',
      name: 'Mimi (ME)',
      role: 'Owner',
      isOwner: true,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    ),
    const FamilyMemberItem(
      id: '2',
      name: 'Mint',
      role: 'Member',
      isOwner: false,
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    ),
  ];

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
      // Connect to familyRepositoryProvider
      await ref.read(familyRepositoryProvider).removeMember(widget.fridgeId, member.id);

      if (!mounted) return;
      setState(() {
        _members.removeWhere((m) => m.id == member.id);
      });
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
      onBackgroundImageError: (_, __) {},
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
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
                    '${_members.length} Member',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Members Container Card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEFE8),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: _members.map((member) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          // Member avatar with offline initial fallback
                          _buildAvatar(member),
                          const SizedBox(width: 14),
                          // Name
                          Expanded(
                            child: Text(
                              member.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF181D18),
                              ),
                            ),
                          ),
                          // Role (Owner / Member)
                          Text(
                            member.role,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF414942),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Delete icon in red color for non-owner
                          if (!member.isOwner)
                            IconButton(
                              onPressed: _isRemoving ? null : () => _showRemoveDialog(member),
                              tooltip: 'Remove ${member.name}',
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Color(0xFFB91C1C), // Destructive Red
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
    );
  }
}
