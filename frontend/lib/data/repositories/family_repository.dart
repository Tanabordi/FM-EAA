import '../../features/family/domain/models/family_member.dart';
import '../local/app_database.dart';
import '../remote/api_client.dart';

class FamilyRepository {
  final ApiClient apiClient;
  final AppDatabase? database;

  FamilyRepository({
    required this.apiClient,
    this.database,
  });

  /// Fetch fridge members from backend
  Future<List<FamilyMemberItem>> getMembers(String fridgeId) async {
    final response = await apiClient.dio.get('/fridges/$fridgeId/members');
    final data = response.data as Map<String, dynamic>;
    final rawList = data['members'] as List<dynamic>? ?? [];
    return rawList
        .map((item) => FamilyMemberItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Search users to invite to a specific fridge
  Future<List<UserSearchResult>> searchUsers(String fridgeId, String query) async {
    if (query.trim().isEmpty) return [];
    final response = await apiClient.dio.get(
      '/fridges/$fridgeId/search-users',
      queryParameters: {'username': query.trim()},
    );
    final data = response.data as Map<String, dynamic>;
    final rawList = data['users'] as List<dynamic>? ?? [];
    return rawList
        .map((item) => UserSearchResult.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Invite a user to a fridge by username
  Future<Map<String, dynamic>> inviteMember(String fridgeId, String username) async {
    final response = await apiClient.dio.post(
      '/fridges/$fridgeId/invites',
      data: {'username': username.trim()},
    );
    return response.data as Map<String, dynamic>? ?? {};
  }

  /// Remove a member or leave fridge
  Future<void> removeMember(String fridgeId, String userId) async {
    await apiClient.dio.delete('/fridges/$fridgeId/members/$userId');
  }

  /// Respond to a fridge invitation (accept or decline)
  Future<void> respondInvite(String inviteId, bool accept) async {
    await apiClient.dio.post(
      '/invites/$inviteId/${accept ? 'accept' : 'decline'}',
      data: {},
    );
  }
}
