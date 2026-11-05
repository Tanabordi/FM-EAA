import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/data/models/user_model.dart';
import 'package:fm_eaa/data/remote/api_client.dart';
import 'package:fm_eaa/data/repositories/auth_repository.dart';
import 'package:fm_eaa/data/repositories/family_repository.dart';
import 'package:fm_eaa/features/auth/providers/auth_provider.dart';
import 'package:fm_eaa/features/family/domain/models/family_member.dart';
import 'package:fm_eaa/features/family/presentation/pages/family_share_page.dart';
import 'package:fm_eaa/features/family/presentation/pages/invite_member_page.dart';
import 'package:fm_eaa/features/family/presentation/widgets/remove_member_dialog.dart';
import 'package:fm_eaa/features/family/providers/family_provider.dart';
import 'package:fm_eaa/features/fridges/presentation/widgets/leave_fridge_dialog.dart';

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(AuthState initialState)
      : super(AuthRepository(apiClient: ApiClient())) {
    state = initialState;
  }
}

class FakeFamilyRepository extends FamilyRepository {
  List<FamilyMemberItem> membersList;
  List<UserSearchResult> searchList;
  bool shouldThrow;
  String? lastInvitedUsername;
  String? lastRemovedUserId;

  FakeFamilyRepository({
    List<FamilyMemberItem>? members,
    List<UserSearchResult>? searchResults,
    this.shouldThrow = false,
  })  : membersList = members ?? [],
        searchList = searchResults ?? [],
        super(apiClient: ApiClient());

  @override
  Future<List<FamilyMemberItem>> getMembers(String fridgeId) async {
    if (shouldThrow) throw Exception('Network error');
    return List.from(membersList);
  }

  @override
  Future<List<UserSearchResult>> searchUsers(String fridgeId, String query) async {
    if (shouldThrow) throw Exception('Search error');
    return List.from(searchList);
  }

  @override
  Future<Map<String, dynamic>> inviteMember(String fridgeId, String username) async {
    if (shouldThrow) throw Exception('Invite error');
    lastInvitedUsername = username;
    return {'success': true, 'message': 'Invitation sent'};
  }

  @override
  Future<void> removeMember(String fridgeId, String userId) async {
    if (shouldThrow) throw Exception('Remove error');
    lastRemovedUserId = userId;
    membersList.removeWhere((m) => m.id == userId);
  }

  @override
  Future<void> respondInvite(String inviteId, bool accept) async {
    if (shouldThrow) throw Exception('Respond error');
  }
}

void main() {
  group('Family Models Unit Tests', () {
    test('FamilyMemberItem.fromJson parses correctly', () {
      final jsonOwner = {
        'id': 'u1',
        'username': 'Mimi',
        'role': 'owner',
        'avatar_url': 'https://example.com/avatar.png',
        'email': 'mimi@example.com',
      };
      final itemOwner = FamilyMemberItem.fromJson(jsonOwner);
      expect(itemOwner.id, 'u1');
      expect(itemOwner.name, 'Mimi');
      expect(itemOwner.role, 'Owner');
      expect(itemOwner.isOwner, true);
      expect(itemOwner.avatarUrl, 'https://example.com/avatar.png');
      expect(itemOwner.email, 'mimi@example.com');

      final jsonMember = {
        'id': 'u2',
        'name': 'Mint',
        'role': 'member',
        'avatarUrl': '',
      };
      final itemMember = FamilyMemberItem.fromJson(jsonMember);
      expect(itemMember.id, 'u2');
      expect(itemMember.name, 'Mint');
      expect(itemMember.role, 'Member');
      expect(itemMember.isOwner, false);
      expect(itemMember.avatarUrl, '');
    });

    test('UserSearchResult.fromJson parses status and handles defaults', () {
      final json = {
        'id': 'u3',
        'username': 'Minty',
        'status': 'pending',
        'avatar_url': 'https://example.com/minty.png',
      };
      final result = UserSearchResult.fromJson(json);
      expect(result.id, 'u3');
      expect(result.username, 'Minty');
      expect(result.status, 'pending');
      expect(result.avatarUrl, 'https://example.com/minty.png');
    });
  });

  group('FamilyMembersNotifier Unit Tests', () {
    test('loads members on creation and allows removal', () async {
      final fakeRepo = FakeFamilyRepository(
        members: [
          const FamilyMemberItem(
            id: 'm1',
            name: 'Mimi',
            role: 'Owner',
            isOwner: true,
            avatarUrl: '',
          ),
          const FamilyMemberItem(
            id: 'm2',
            name: 'Mint',
            role: 'Member',
            isOwner: false,
            avatarUrl: '',
          ),
        ],
      );

      final notifier = FamilyMembersNotifier(fakeRepo, 'f1');
      await Future.delayed(Duration.zero);

      expect(notifier.state.members.length, 2);
      expect(notifier.state.isLoading, false);

      await notifier.removeMember('m2');
      expect(notifier.state.members.length, 1);
      expect(notifier.state.members[0].id, 'm1');
      expect(fakeRepo.lastRemovedUserId, 'm2');
    });

    test('reverts optimistic removal on error', () async {
      final fakeRepo = FakeFamilyRepository(
        members: [
          const FamilyMemberItem(
            id: 'm1',
            name: 'Mimi',
            role: 'Owner',
            isOwner: true,
            avatarUrl: '',
          ),
        ],
        shouldThrow: true,
      );

      final notifier = FamilyMembersNotifier(fakeRepo, 'f1');
      await Future.delayed(Duration.zero);

      expect(() => notifier.removeMember('m1'), throwsA(isA<Exception>()));
    });
  });

  group('FamilySharePage Widget Tests', () {
    testWidgets('renders fridge name, member count, and member list', (tester) async {
      final fakeRepo = FakeFamilyRepository(
        members: [
          const FamilyMemberItem(
            id: 'm1',
            name: 'Mimi (ME)',
            role: 'Owner',
            isOwner: true,
            avatarUrl: '',
          ),
          const FamilyMemberItem(
            id: 'm2',
            name: 'Mint',
            role: 'Member',
            isOwner: false,
            avatarUrl: '',
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            familyRepositoryProvider.overrideWithValue(fakeRepo),
            authProvider.overrideWith((ref) => FakeAuthNotifier(
              AuthState(
                isAuthenticated: true,
                user: UserModel(
                  id: 'm1',
                  username: 'Mimi',
                  email: 'mimi@example.com',
                  updatedAt: DateTime.now(),
                ),
              ),
            )),
          ],
          child: const MaterialApp(
            home: FamilySharePage(
              fridgeId: 'fridge_123',
              fridgeName: 'Kitchen Fridge',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Family Share'), findsOneWidget);
      expect(find.text('Kitchen Fridge'), findsOneWidget);
      expect(find.text('2 Members'), findsOneWidget);
      expect(find.text('Mimi (ME)'), findsOneWidget);
      expect(find.text('Mint'), findsOneWidget);
      expect(find.text('Owner'), findsOneWidget);
      expect(find.text('Member'), findsOneWidget);
      expect(find.text('Invite Member'), findsOneWidget);
      // Delete icon is visible only for non-owner member Mint (not for owner Mimi)
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      // Owner cannot leave fridge
      expect(find.byIcon(Icons.exit_to_app_rounded), findsNothing);
      expect(find.text('Leave Fridge'), findsNothing);
    });

    testWidgets('tapping delete icon shows RemoveMemberDialog and confirms removal', (tester) async {
      final fakeRepo = FakeFamilyRepository(
        members: [
          const FamilyMemberItem(
            id: 'm1',
            name: 'Mimi (ME)',
            role: 'Owner',
            isOwner: true,
            avatarUrl: '',
          ),
          const FamilyMemberItem(
            id: 'm2',
            name: 'Mint',
            role: 'Member',
            isOwner: false,
            avatarUrl: '',
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            familyRepositoryProvider.overrideWithValue(fakeRepo),
            authProvider.overrideWith((ref) => FakeAuthNotifier(
              AuthState(
                isAuthenticated: true,
                user: UserModel(
                  id: 'm1',
                  username: 'Mimi',
                  email: 'mimi@example.com',
                  updatedAt: DateTime.now(),
                ),
              ),
            )),
          ],
          child: const MaterialApp(
            home: FamilySharePage(
              fridgeId: 'fridge_123',
              fridgeName: 'Kitchen Fridge',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap delete icon for Mint
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Dialog appears
      expect(find.byType(RemoveMemberDialog), findsOneWidget);
      expect(find.text('Remove Mint from\nFamily?'), findsOneWidget);
      expect(find.text('They will lose access to this shared fridge.'), findsOneWidget);

      // Tap Remove button in dialog
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      // Member removed
      expect(fakeRepo.lastRemovedUserId, 'm2');
      expect(find.text('1 Member'), findsOneWidget);
      expect(find.text('Mint'), findsNothing);
    });

    testWidgets('non-owner member can see Leave Fridge button and open LeaveFridgeDialog', (tester) async {
      final fakeRepo = FakeFamilyRepository(
        members: [
          const FamilyMemberItem(
            id: 'owner_1',
            name: 'Alice',
            role: 'Owner',
            isOwner: true,
            avatarUrl: '',
          ),
          const FamilyMemberItem(
            id: 'member_1',
            name: 'Bob',
            role: 'Member',
            isOwner: false,
            avatarUrl: '',
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          familyRepositoryProvider.overrideWithValue(fakeRepo),
          authProvider.overrideWith((ref) => FakeAuthNotifier(
            AuthState(
              isAuthenticated: true,
              user: UserModel(
                id: 'member_1',
                username: 'Bob',
                email: 'bob@example.com',
                updatedAt: DateTime.now(),
              ),
            ),
          )),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FamilySharePage(
              fridgeId: 'fridge_123',
              fridgeName: 'Kitchen Fridge',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Non-owner member cannot delete anyone (no delete icons at all)
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      // Non-owner cannot see "Invite Member" button
      expect(find.text('Invite Member'), findsNothing);
      // Non-owner sees leave icon button on their own row and in bottom button
      expect(find.byIcon(Icons.exit_to_app_rounded), findsNWidgets(2));

      // As non-owner, "Leave Fridge" button should be visible at bottom
      expect(find.text('Leave Fridge'), findsOneWidget);

      // Tap "Leave Fridge"
      await tester.tap(find.text('Leave Fridge'));
      await tester.pumpAndSettle();

      // LeaveFridgeDialog should appear
      expect(find.byType(LeaveFridgeDialog), findsOneWidget);
      expect(find.text('Leave Fridge?'), findsOneWidget);
      expect(find.textContaining('You will lose access to its items'), findsOneWidget);
      expect(find.text('Leave'), findsOneWidget);
    });
  });

  group('InviteMemberPage Widget Tests', () {
    testWidgets('renders search box and performs search', (tester) async {
      final fakeRepo = FakeFamilyRepository(
        searchResults: [
          const UserSearchResult(
            id: 'u_10',
            username: 'Minty',
            status: 'available',
            avatarUrl: '',
          ),
          const UserSearchResult(
            id: 'u_11',
            username: 'Mintra',
            status: 'pending',
            avatarUrl: '',
          ),
          const UserSearchResult(
            id: 'u_12',
            username: 'Mint',
            status: 'already',
            avatarUrl: '',
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            familyRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: InviteMemberPage(fridgeId: 'fridge_123'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Invite to Family'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Enter search term
      await tester.enterText(find.byType(TextField), 'Mint');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // Verify results rendered
      expect(find.text('Search results'), findsOneWidget);
      expect(find.text('3 Users'), findsOneWidget);
      expect(find.text('Minty'), findsOneWidget);
      expect(find.text('Mintra'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is Text && w.data == 'Mint'),
        findsOneWidget,
      );
      expect(find.text('Invite'), findsOneWidget);


      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Already in family'), findsOneWidget);

      // Tap Invite button
      await tester.tap(find.text('Invite'));
      await tester.pumpAndSettle();

      expect(fakeRepo.lastInvitedUsername, 'Minty');
      // Status changes to pending
      expect(find.text('Invitation sent to Minty'), findsOneWidget);
      expect(find.text('Pending'), findsNWidgets(2));
    });
  });
}
