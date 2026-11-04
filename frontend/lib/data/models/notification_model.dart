import 'dart:convert';

class NotificationModel {
  final String id;
  final String userId;
  final String type; // 'invite' | 'expiry'
  final String title;
  final String message;
  final String? fridgeId;
  final String? inviteId;
  final String? itemId;
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
    this.itemId,
    this.isRead = false,
    required this.createdAt,
  });

  bool get isInvite => type == 'invite';
  bool get isExpiry => type == 'expiry';

  factory NotificationModel.fromEntry(dynamic entry) {
    String title = '';
    String message = '';
    String? fridgeId;
    String? inviteId;
    String? itemId;

    if (entry.payloadJson != null && entry.payloadJson.toString().isNotEmpty) {
      try {
        final decoded = jsonDecode(entry.payloadJson.toString()) as Map<String, dynamic>;
        title = decoded['title'] as String? ?? '';
        message = decoded['message'] as String? ?? '';
        fridgeId = decoded['fridge_id'] as String? ?? decoded['fridgeId'] as String?;
        inviteId = decoded['invite_id'] as String? ?? decoded['inviteId'] as String?;
        itemId = decoded['item_id'] as String? ?? decoded['itemId'] as String?;
      } catch (_) {
        message = entry.payloadJson.toString();
      }
    }

    if (title.isEmpty) {
      title = entry.type == 'invite' ? 'Fridge Invitation' : 'Item Expiry Warning';
    }

    return NotificationModel(
      id: entry.id as String,
      userId: entry.userId as String,
      type: entry.type as String,
      title: title,
      message: message,
      fridgeId: fridgeId,
      inviteId: inviteId,
      itemId: itemId,
      isRead: entry.isRead as bool,
      createdAt: entry.createdAt as DateTime,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    String title = json['title'] as String? ?? '';
    String message = json['message'] as String? ?? '';
    String? fridgeId = json['fridge_id'] as String? ?? json['fridgeId'] as String?;
    String? inviteId = json['invite_id'] as String? ?? json['inviteId'] as String?;
    String? itemId = json['item_id'] as String? ?? json['itemId'] as String?;

    if (json['payload'] != null && json['payload'] is Map<String, dynamic>) {
      final p = json['payload'] as Map<String, dynamic>;
      if (title.isEmpty) title = p['title'] as String? ?? '';
      if (message.isEmpty) message = p['message'] as String? ?? '';
      fridgeId ??= p['fridge_id'] as String? ?? p['fridgeId'] as String?;
      inviteId ??= p['invite_id'] as String? ?? p['inviteId'] as String?;
      itemId ??= p['item_id'] as String? ?? p['itemId'] as String?;
    } else if (json['payload_json'] != null && json['payload_json'].toString().isNotEmpty) {
      try {
        final decoded = jsonDecode(json['payload_json'].toString()) as Map<String, dynamic>;
        if (title.isEmpty) title = decoded['title'] as String? ?? '';
        if (message.isEmpty) message = decoded['message'] as String? ?? '';
        fridgeId ??= decoded['fridge_id'] as String? ?? decoded['fridgeId'] as String?;
        inviteId ??= decoded['invite_id'] as String? ?? decoded['inviteId'] as String?;
        itemId ??= decoded['item_id'] as String? ?? decoded['itemId'] as String?;
      } catch (_) {}
    }

    if (title.isEmpty) {
      title = json['type'] == 'invite' ? 'Fridge Invitation' : 'Item Expiry Warning';
    }

    final isReadVal = json['isRead'] ?? json['is_read'];
    final bool isRead = isReadVal is bool ? isReadVal : (isReadVal == 1);

    final rawCreatedAt = json['createdAt'] ?? json['created_at'];
    DateTime createdAt = DateTime.now();
    if (rawCreatedAt != null) {
      try {
        createdAt = DateTime.parse(rawCreatedAt.toString());
      } catch (_) {}
    }

    return NotificationModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      type: (json['type'] ?? 'expiry').toString(),
      title: title,
      message: message,
      fridgeId: fridgeId,
      inviteId: inviteId,
      itemId: itemId,
      isRead: isRead,
      createdAt: createdAt,
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
      'item_id': itemId,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    String? fridgeId,
    String? inviteId,
    String? itemId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      fridgeId: fridgeId ?? this.fridgeId,
      inviteId: inviteId ?? this.inviteId,
      itemId: itemId ?? this.itemId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
