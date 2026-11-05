import 'dart:convert';
import 'item_model.dart';

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
  bool get isMemberJoined => type == 'member_joined' || type == 'invite_accepted';
  bool get isItemAdded => type == 'item_added';
  bool get isItemConsumed => type == 'item_consumed';
  bool get isItemDeleted => type == 'item_deleted';
  bool get isItemAction => isItemAdded || isItemConsumed || isItemDeleted;

  static String localizeTitleStatic(String rawTitle, [bool isTh = false]) {
    if (!isTh) return rawTitle;
    final t = rawTitle.toLowerCase().trim();
    if (t.contains('new item added') || t.contains('item added')) return '🥬 เพิ่มรายการอาหารใหม่';
    if (t.contains('item consumed')) return '🍽️ รับประทานอาหารแล้ว';
    if (t.contains('item removed') || t.contains('item deleted')) return '🗑️ นำรายการอาหารออกแล้ว';
    if (t.contains('new member joined') || t.contains('member joined')) return '👥 สมาชิกใหม่เข้าร่วม';
    if (t.contains('fridge invitation') || t.contains('invitation')) return '📩 คำเชิญเข้าร่วมตู้เย็น';
    if (t.contains('expiry warning') || t.contains('expir')) return '⚠️ แจ้งเตือนอาหารใกล้หมดอายุ';
    return rawTitle;
  }

  String localizedTitle([bool isTh = false]) => localizeTitleStatic(title, isTh);

  static String localizeMessageStatic(String rawMessage, [bool isTh = false]) {
    if (!isTh || rawMessage.trim().isEmpty) return rawMessage;

    // Pattern 1: user added "Item" (quantity unit) to "Fridge"
    // e.g. wansai added "strawberries" (12 punnet) to "Ulnwza"
    final addMatch = RegExp(r'^(.+?)\s+added\s+"([^"]+)"\s*\(([^)]+)\)\s+to\s+"([^"]+)"$', caseSensitive: false).firstMatch(rawMessage);
    if (addMatch != null) {
      final user = addMatch.group(1) ?? '';
      final item = ItemModel.getThaiFoodName(addMatch.group(2) ?? '');
      final rawQtyUnit = addMatch.group(3) ?? '';
      final fridge = addMatch.group(4) ?? '';

      final qtyUnitMatch = RegExp(r'^(\d+(?:\.\d+)?)\s*(.*)$').firstMatch(rawQtyUnit.trim());
      String qtyUnitStr;
      if (qtyUnitMatch != null) {
        final q = qtyUnitMatch.group(1) ?? '';
        final u = ItemModel.localizeUnit(qtyUnitMatch.group(2) ?? '', true);
        qtyUnitStr = '$q $u'.trim();
      } else {
        qtyUnitStr = ItemModel.localizeUnit(rawQtyUnit, true);
      }
      return '$user เพิ่ม "$item" ($qtyUnitStr) ในตู้ "$fridge"';
    }

    // Pattern 2: user ate quantity unit of "Item" in "Fridge" (quantityLeft unit left)
    // e.g. RRR ate 1 punnet of "strawberries" in "Ulnwza" (7 punnet left)
    final ateMatch = RegExp(r'^(.+?)\s+ate\s+(\d+(?:\.\d+)?)\s*(.+?)\s+of\s+"([^"]+)"\s+in\s+"([^"]+)"\s*\(([^)]+)\s+left\)$', caseSensitive: false).firstMatch(rawMessage);
    if (ateMatch != null) {
      final user = ateMatch.group(1) ?? '';
      final amount = ateMatch.group(2) ?? '';
      final unit1 = ItemModel.localizeUnit(ateMatch.group(3) ?? '', true);
      final item = ItemModel.getThaiFoodName(ateMatch.group(4) ?? '');
      final fridge = ateMatch.group(5) ?? '';
      final rawLeft = ateMatch.group(6) ?? '';

      final leftMatch = RegExp(r'^(\d+(?:\.\d+)?)\s*(.*)$').firstMatch(rawLeft.trim());
      String leftStr;
      if (leftMatch != null) {
        final qL = leftMatch.group(1) ?? '';
        final uL = ItemModel.localizeUnit(leftMatch.group(2) ?? '', true);
        leftStr = '$qL $uL'.trim();
      } else {
        leftStr = ItemModel.localizeUnit(rawLeft, true);
      }
      return '$user รับประทาน "$item" $amount $unit1 ในตู้ "$fridge" (เหลือ $leftStr)';
    }

    // Pattern 3: user finished all "Item" in "Fridge"
    // e.g. wansai finished all "strawberries" in "Ulnwza"
    final finishedMatch = RegExp(r'^(.+?)\s+finished\s+all\s+"([^"]+)"\s+in\s+"([^"]+)"$', caseSensitive: false).firstMatch(rawMessage);
    if (finishedMatch != null) {
      final user = finishedMatch.group(1) ?? '';
      final item = ItemModel.getThaiFoodName(finishedMatch.group(2) ?? '');
      final fridge = finishedMatch.group(3) ?? '';
      return '$user รับประทาน "$item" ทั้งหมด ในตู้ "$fridge"';
    }

    // Pattern 4: user removed "Item" from "Fridge"
    // e.g. wansai removed "strawberries" from "Ulnwza"
    final removedMatch = RegExp(r'^(.+?)\s+removed\s+"([^"]+)"\s+from\s+"([^"]+)"$', caseSensitive: false).firstMatch(rawMessage);
    if (removedMatch != null) {
      final user = removedMatch.group(1) ?? '';
      final item = ItemModel.getThaiFoodName(removedMatch.group(2) ?? '');
      final fridge = removedMatch.group(3) ?? '';
      return '$user นำ "$item" ออกจากตู้ "$fridge"';
    }

    // Pattern 5: user joined "Fridge" (invited by Inviter)
    final joinedMatch = RegExp(r'^(.+?)\s+joined\s+"([^"]+)"\s*\(invited\s+by\s+(.+?)\)$', caseSensitive: false).firstMatch(rawMessage);
    if (joinedMatch != null) {
      final user = joinedMatch.group(1) ?? '';
      final fridge = joinedMatch.group(2) ?? '';
      final inviter = joinedMatch.group(3) ?? '';
      return '$user เข้าร่วมตู้ "$fridge" (ได้รับคำเชิญจาก $inviter)';
    }

    // Pattern 6: user invited you to join "Fridge"
    final inviteMatch = RegExp(r'^(.+?)\s+invited\s+you\s+to\s+join\s+"([^"]+)"$', caseSensitive: false).firstMatch(rawMessage);
    if (inviteMatch != null) {
      final inviter = inviteMatch.group(1) ?? '';
      final fridge = inviteMatch.group(2) ?? '';
      return '$inviter เชิญคุณเข้าร่วมตู้ "$fridge"';
    }

    // Pattern 7: "Item" in "Fridge" expires in N days / expires today
    final expiresMatch = RegExp(r'^"([^"]+)"\s+in\s+"([^"]+)"\s+expires\s+in\s+(\d+)\s+days?$', caseSensitive: false).firstMatch(rawMessage);
    if (expiresMatch != null) {
      final item = ItemModel.getThaiFoodName(expiresMatch.group(1) ?? '');
      final fridge = expiresMatch.group(2) ?? '';
      final days = expiresMatch.group(3) ?? '';
      return '"$item" ในตู้ "$fridge" จะหมดอายุใน $days วัน';
    }
    final expiresTodayMatch = RegExp(r'^"([^"]+)"\s+in\s+"([^"]+)"\s+expires\s+today$', caseSensitive: false).firstMatch(rawMessage);
    if (expiresTodayMatch != null) {
      final item = ItemModel.getThaiFoodName(expiresTodayMatch.group(1) ?? '');
      final fridge = expiresTodayMatch.group(2) ?? '';
      return '"$item" ในตู้ "$fridge" จะหมดอายุวันนี้';
    }

    // Fallback translation for food names inside quotes and common unit keywords
    var msg = rawMessage;
    msg = msg.replaceAllMapped(RegExp(r'"([^"]+)"'), (m) {
      final inner = m.group(1) ?? '';
      return '"${ItemModel.getThaiFoodName(inner)}"';
    });
    msg = msg.replaceAll(RegExp(r'\bpunnets?\b', caseSensitive: false), 'ตะกร้า');
    msg = msg.replaceAll(RegExp(r'\bpieces?\b', caseSensitive: false), 'ชิ้น');
    msg = msg.replaceAll(RegExp(r'\bboxt?s?\b', caseSensitive: false), 'กล่อง');
    msg = msg.replaceAll(RegExp(r'\bbags?\b', caseSensitive: false), 'ถุง');
    msg = msg.replaceAll(RegExp(r'\bbottles?\b', caseSensitive: false), 'ขวด');
    msg = msg.replaceAll(RegExp(r'\bcans?\b', caseSensitive: false), 'กระป๋อง');
    msg = msg.replaceAll(RegExp(r'\bpacks?\b', caseSensitive: false), 'แพ็ค');
    msg = msg.replaceAll(RegExp(r'\bleft\b', caseSensitive: false), 'เหลือ');

    return msg;
  }

  String localizedMessage([bool isTh = false]) => localizeMessageStatic(message, isTh);

  factory NotificationModel.fromEntry(dynamic entry) {
    String title = '';
    String message = '';
    String? fridgeId;
    String? inviteId;
    String? itemId;
    String effectiveType = entry.type as String;

    if (entry.payloadJson != null && entry.payloadJson.toString().isNotEmpty) {
      try {
        final decoded = jsonDecode(entry.payloadJson.toString()) as Map<String, dynamic>;
        title = decoded['title'] as String? ?? '';
        message = decoded['message'] as String? ?? '';
        fridgeId = decoded['fridge_id'] as String? ?? decoded['fridgeId'] as String?;
        inviteId = decoded['invite_id'] as String? ?? decoded['inviteId'] as String?;
        itemId = decoded['item_id'] as String? ?? decoded['itemId'] as String?;
        if (decoded['sub_type'] != null && decoded['sub_type'].toString().isNotEmpty) {
          effectiveType = decoded['sub_type'].toString();
        }
      } catch (_) {
        message = entry.payloadJson.toString();
      }
    }

    if (title.isEmpty) {
      if (effectiveType == 'invite') {
        title = 'Fridge Invitation';
      } else if (effectiveType == 'member_joined' || effectiveType == 'invite_accepted') {
        title = 'New Member Joined';
      } else if (effectiveType == 'item_added') {
        title = 'New Item Added';
      } else if (effectiveType == 'item_consumed') {
        title = 'Item Consumed';
      } else if (effectiveType == 'item_deleted') {
        title = 'Item Removed';
      } else {
        title = 'Item Expiry Warning';
      }
    }

    DateTime createdAt = (entry.createdAt as DateTime).toLocal();
    final now = DateTime.now();
    if (createdAt.isAfter(now.add(const Duration(minutes: 5)))) {
      final offset = now.timeZoneOffset != Duration.zero ? now.timeZoneOffset : const Duration(hours: 7);
      createdAt = createdAt.subtract(offset);
      if (createdAt.isAfter(now.add(const Duration(minutes: 5)))) {
        createdAt = now;
      }
    }

    return NotificationModel(
      id: entry.id as String,
      userId: entry.userId as String,
      type: effectiveType,
      title: title,
      message: message,
      fridgeId: fridgeId,
      inviteId: inviteId,
      itemId: itemId,
      isRead: entry.isRead as bool,
      createdAt: createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    String title = json['title'] as String? ?? '';
    String message = json['message'] as String? ?? '';
    String? fridgeId = json['fridge_id'] as String? ?? json['fridgeId'] as String?;
    String? inviteId = json['invite_id'] as String? ?? json['inviteId'] as String?;
    String? itemId = json['item_id'] as String? ?? json['itemId'] as String?;
    String effectiveType = (json['type'] ?? 'expiry').toString();

    if (json['payload'] != null && json['payload'] is Map<String, dynamic>) {
      final p = json['payload'] as Map<String, dynamic>;
      if (title.isEmpty) title = p['title'] as String? ?? '';
      if (message.isEmpty) message = p['message'] as String? ?? '';
      fridgeId ??= p['fridge_id'] as String? ?? p['fridgeId'] as String?;
      inviteId ??= p['invite_id'] as String? ?? p['inviteId'] as String?;
      itemId ??= p['item_id'] as String? ?? p['itemId'] as String?;
      if (p['sub_type'] != null && p['sub_type'].toString().isNotEmpty) {
        effectiveType = p['sub_type'].toString();
      }
    } else if (json['payload_json'] != null && json['payload_json'].toString().isNotEmpty) {
      try {
        final decoded = jsonDecode(json['payload_json'].toString()) as Map<String, dynamic>;
        if (title.isEmpty) title = decoded['title'] as String? ?? '';
        if (message.isEmpty) message = decoded['message'] as String? ?? '';
        fridgeId ??= decoded['fridge_id'] as String? ?? decoded['fridgeId'] as String?;
        inviteId ??= decoded['invite_id'] as String? ?? decoded['inviteId'] as String?;
        itemId ??= decoded['item_id'] as String? ?? decoded['itemId'] as String?;
        if (decoded['sub_type'] != null && decoded['sub_type'].toString().isNotEmpty) {
          effectiveType = decoded['sub_type'].toString();
        }
      } catch (_) {}
    }

    if (title.isEmpty) {
      if (effectiveType == 'invite') {
        title = 'Fridge Invitation';
      } else if (effectiveType == 'member_joined' || effectiveType == 'invite_accepted') {
        title = 'New Member Joined';
      } else if (effectiveType == 'item_added') {
        title = 'New Item Added';
      } else if (effectiveType == 'item_consumed') {
        title = 'Item Consumed';
      } else if (effectiveType == 'item_deleted') {
        title = 'Item Removed';
      } else {
        title = 'Item Expiry Warning';
      }
    }

    final isReadVal = json['isRead'] ?? json['is_read'];
    final bool isRead = isReadVal is bool ? isReadVal : (isReadVal == 1);

    final rawCreatedAt = json['createdAt'] ?? json['created_at'];
    DateTime createdAt = DateTime.now();
    if (rawCreatedAt != null) {
      try {
        if (rawCreatedAt is DateTime) {
          createdAt = rawCreatedAt.toLocal();
        } else {
          createdAt = DateTime.parse(rawCreatedAt.toString()).toLocal();
        }
        final now = DateTime.now();
        if (createdAt.isAfter(now.add(const Duration(minutes: 5)))) {
          final offset = now.timeZoneOffset != Duration.zero ? now.timeZoneOffset : const Duration(hours: 7);
          createdAt = createdAt.subtract(offset);
          if (createdAt.isAfter(now.add(const Duration(minutes: 5)))) {
            createdAt = now;
          }
        }
      } catch (_) {}
    }

    return NotificationModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      type: effectiveType,
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
