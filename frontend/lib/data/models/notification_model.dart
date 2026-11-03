class NotificationModel {
  final String id;
  final String userId;
  final String type; // 'invite' | 'expiry'
  final String title;
  final String message;
  final String? fridgeId;
  final String? inviteId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.fridgeId,
    this.inviteId,
    this.isRead = false,
    required this.createdAt,
  });

  bool get isInvite => type == 'invite';
  bool get isExpiry => type == 'expiry';

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      fridgeId: json['fridge_id'] as String?,
      inviteId: json['invite_id'] as String?,
      isRead: (json['is_read'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'fridge_id': fridgeId,
      'invite_id': inviteId,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

