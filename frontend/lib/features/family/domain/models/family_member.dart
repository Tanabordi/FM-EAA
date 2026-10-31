class FamilyMemberItem {
  final String id;
  final String name;
  final String role; // 'Owner' | 'Member'
  final bool isOwner;
  final String avatarUrl;

  const FamilyMemberItem({
    required this.id,
    required this.name,
    required this.role,
    required this.isOwner,
    required this.avatarUrl,
  });

  factory FamilyMemberItem.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as String? ?? 'Member';
    return FamilyMemberItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['username'] as String? ?? '',
      role: role,
      isOwner: role.toLowerCase() == 'owner',
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'isOwner': isOwner,
      'avatarUrl': avatarUrl,
    };
  }
}

class UserSearchResult {
  final String username;
  final String status; // 'already', 'available', 'pending'
  final String avatarUrl;

  const UserSearchResult({
    required this.username,
    required this.status,
    required this.avatarUrl,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      username: json['username'] as String? ?? '',
      status: json['status'] as String? ?? 'available',
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'status': status,
      'avatarUrl': avatarUrl,
    };
  }
}

