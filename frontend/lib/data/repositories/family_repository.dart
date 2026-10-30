import '../remote/api_client.dart';

// TODO(repo family): Implement members listing, invite by username, and member removal
class FamilyRepository {
  final ApiClient apiClient;

  FamilyRepository({required this.apiClient});

  Future<List<Map<String, dynamic>>> getMembers(String fridgeId) async {
    // TODO: GET /api/fridges/:id/members
    return [];
  }

  Future<void> inviteMember(String fridgeId, String username) async {
    // TODO: POST /api/fridges/:id/invites
  }

  Future<void> removeMember(String fridgeId, String userId) async {
    // TODO: DELETE /api/fridges/:id/members/:userId
  }

  Future<void> respondInvite(String inviteId, bool accept) async {
    // TODO: POST /api/invites/:id/accept or decline
  }
}

