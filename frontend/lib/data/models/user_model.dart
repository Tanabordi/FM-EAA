class UserModel {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['ID'] ?? '').toString(),
      username: (json['username'] ?? json['USERNAME'] ?? '').toString(),
      email: (json['email'] ?? json['EMAIL'] ?? '').toString(),
      avatarUrl: (json['avatar_url'] ?? json['avatarUrl'] ?? json['AVATAR_URL']) as String?,
      updatedAt: json['updated_at'] != null
          ? (DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now())
          : (json['updatedAt'] != null
              ? (DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now())
              : (json['UPDATED_AT'] != null
                  ? (DateTime.tryParse(json['UPDATED_AT'].toString()) ?? DateTime.now())
                  : DateTime.now())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    bool clearAvatar = false,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: clearAvatar ? null : (avatarUrl ?? this.avatarUrl),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
