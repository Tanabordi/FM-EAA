class FamilyMemberItem {
  final String id;
  final String name;
  final String role; // 'Owner' | 'Member'
  final bool isOwner;
  final String avatarUrl;
  final String email;

  const FamilyMemberItem({
    required this.id,
    required this.name,
    required this.role,
    required this.isOwner,
    required this.avatarUrl,
    this.email = '',
  });

  factory FamilyMemberItem.fromJson(Map<String, dynamic> json) {
    final rawRole = json['role'] as String? ?? 'Member';
    final isOwner = rawRole.toLowerCase() == 'owner';
    final role = isOwner ? 'Owner' : 'Member';
    return FamilyMemberItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['username'] as String? ?? '',
      role: role,
      isOwner: isOwner,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'isOwner': isOwner,
      'avatarUrl': avatarUrl,
      'email': email,
    };
  }
}

class UserSearchResult {
  final String id;
  final String username;
  final String status; // 'already', 'available', 'pending'
  final String avatarUrl;
  final String email;

  const UserSearchResult({
    this.id = '',
    required this.username,
    required this.status,
    required this.avatarUrl,
    this.email = '',
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      status: json['status'] as String? ?? 'available',
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'status': status,
      'avatarUrl': avatarUrl,
      'email': email,
    };
  }
}


