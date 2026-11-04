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
  final _focusNode = FocusNode();
  List<UserSearchResult> _searchResults = [];
  Map<String, String> _userStatuses = {};
  bool _isSearching = false;
  bool _isInviting = false;
  String? _searchMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  Future<void> _doSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    _dismissKeyboard();
    setState(() {
      _isSearching = true;
      _searchMessage = null;
    });

    try {
      final results = await ref
          .read(familyRepositoryProvider)
          .searchUsers(widget.fridgeId, query);

      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _userStatuses = {for (var u in results) u.username: u.status};
        _isSearching = false;
        if (results.isEmpty) {
          _searchMessage = 'No users found matching "$query"';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _searchMessage = 'Failed to search users. Please try again.';
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _dismissKeyboard();
    setState(() {
      _searchResults = [];
      _searchMessage = null;
    });
  }

  Future<void> _handleInvite(String username) async {
    setState(() => _isInviting = true);
    try {
      await ref.read(familyRepositoryProvider).inviteMember(widget.fridgeId, username);
      if (!mounted) return;
      setState(() => _userStatuses[username] = 'pending');
      // Trigger update on fridge members provider
      ref.read(familyMembersProvider(widget.fridgeId).notifier).loadMembers();
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
      onBackgroundImageError: user.avatarUrl.isNotEmpty ? (_, __) {} : null,
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

  Widget _buildUserTile(UserSearchResult user) {
    final currentStatus = _userStatuses[user.username] ?? user.status;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
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
          if (currentStatus == 'already')
            const Text(
              'Already in family',
              style: TextStyle(fontSize: 13, color: Color(0xFF414942)),
            )
          else if (currentStatus == 'pending')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF717971)),
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
                minimumSize: const Size(76, 38),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Header + Search Box ───
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  const SizedBox(height: 20),
                  // Search Box Pill (Figma)
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAEFE8),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        // Search Button
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _doSearch,
                          child: const SizedBox(
                            width: 48,
                            height: 52,
                            child: Center(
                              child: Icon(Icons.search, color: Color(0xFF181D18), size: 22),
                            ),
                          ),
                        ),
                        // Input Field
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _doSearch(),
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
                              filled: false,
                              fillColor: Colors.transparent,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                              isDense: true,
                            ),
                          ),
                        ),
                        // Clear Button
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _clearSearch,
                            child: const SizedBox(
                              width: 48,
                              height: 52,
                              child: Center(
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Color(0xFFD3DDD1),
                                  child: Icon(Icons.close, size: 14, color: Color(0xFF181D18)),
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── Search Progress or Message ───
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF2E6A44)),
                ),
              )
            else if (_searchMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Center(
                  child: Text(
                    _searchMessage!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF414942),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // ─── Search Results ───
            if (!_isSearching && _searchResults.isNotEmpty)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  children: [
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
                          '${_searchResults.length} ${_searchResults.length == 1 ? "User" : "Users"}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF414942),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAEFE8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _searchResults.map(_buildUserTile).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Friends will receive an invitation in their notifications and must accept it before they can join the family.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF414942),
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
