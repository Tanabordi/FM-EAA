import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../shared/widgets/figma_auth_widgets.dart';
import '../../../../shared/widgets/user_avatar.dart';
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

  bool get _isTh {
    try {
      return ref.read(localeProvider).languageCode == 'th';
    } catch (_) {
      try {
        return Localizations.localeOf(context).languageCode == 'th';
      } catch (_) {
        return false;
      }
    }
  }

  bool _isThRead() {
    try {
      return ref.read(localeProvider).languageCode == 'th';
    } catch (_) {
      try {
        return Localizations.localeOf(context).languageCode == 'th';
      } catch (_) {
        return false;
      }
    }
  }

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
          final isTh = _isThRead();
          _searchMessage = isTh ? 'ไม่พบผู้ใช้ที่ตรงกับ "$query"' : 'No users found matching "$query"';
        }
      });
    } catch (e) {
      if (!mounted) return;
      final isTh = _isThRead();
      setState(() {
        _isSearching = false;
        _searchMessage = isTh ? 'ค้นหาผู้ใช้ไม่สำเร็จ กรุณาลองใหม่อีกครั้ง' : 'Failed to search users. Please try again.';
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
      final isTh = _isThRead();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isTh ? 'ส่งคำเชิญไปยัง $username เรียบร้อยแล้ว' : 'Invitation sent to $username')),
      );
    } catch (e) {
      if (!mounted) return;
      final isTh = _isThRead();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isTh ? 'ส่งคำเชิญไม่สำเร็จ: ${e.toString()}' : 'Failed to send invitation: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isInviting = false);
    }
  }


  Widget _buildUserTile(UserSearchResult user) {
    final currentStatus = _userStatuses[user.username] ?? user.status;
    final isTh = _isTh;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Row(
            children: [
              UserAvatar(
                name: user.username,
                avatarUrl: user.avatarUrl,
                radius: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  user.username,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (currentStatus == 'already')
                Text(
                  isTh ? 'อยู่ในครอบครัวแล้ว' : 'Already in family',
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                )
              else if (currentStatus == 'pending')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Text(
                    isTh ? 'รอการตอบรับ' : 'Pending',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: const StadiumBorder(),
                    minimumSize: const Size(76, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    elevation: 0,
                  ),
                  onPressed: _isInviting ? null : () => _handleInvite(user.username),
                  child: Text(
                    isTh ? 'เชิญ' : 'Invite',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTh = _isTh;

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
                        isTh ? 'เชิญเข้าร่วมครอบครัว' : 'Invite to Family',
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
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        // Search Button
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _doSearch,
                          child: SizedBox(
                            width: 48,
                            height: 52,
                            child: Center(
                              child: Icon(Icons.search, color: colorScheme.onSurface, size: 22),
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
                            style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                            decoration: InputDecoration(
                              hintText: isTh ? 'ค้นหาชื่อผู้ใช้' : 'Search Username',
                              hintStyle: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              fillColor: Colors.transparent,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              isDense: true,
                            ),
                          ),
                        ),
                        // Clear Button
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _clearSearch,
                            child: SizedBox(
                              width: 48,
                              height: 52,
                              child: Center(
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: colorScheme.surfaceContainerHighest,
                                  child: Icon(Icons.close, size: 14, color: colorScheme.onSurface),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(color: theme.colorScheme.primary),
                ),
              )
            else if (_searchMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Center(
                  child: Text(
                    _searchMessage!,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
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
                        Text(
                          isTh ? 'ผลการค้นหา' : 'Search results',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          isTh
                              ? '${_searchResults.length} ผู้ใช้'
                              : '${_searchResults.length} ${_searchResults.length == 1 ? "User" : "Users"}',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _searchResults.map(_buildUserTile).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isTh
                          ? 'เพื่อนจะได้รับคำเชิญในการแจ้งเตือน และต้องกดยอมรับก่อนจึงจะเข้าร่วมครอบครัวได้'
                          : 'Friends will receive an invitation in their notifications and must accept it before they can join the family.',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
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
