import '../local/app_database.dart';

class HistoryModel {
  final String id;
  final String fridgeId;
  final String? itemId;
  final String itemName;
  final String? imagePath;
  final String kind; // 'consumed' | 'expired'
  final double quantityChanged;
  final double quantityLeft;
  final String unit;
  final String byUsername;
  final DateTime createdAt;

  const HistoryModel({
    required this.id,
    required this.fridgeId,
    this.itemId,
    required this.itemName,
    this.imagePath,
    required this.kind,
    required this.quantityChanged,
    required this.quantityLeft,
    required this.unit,
    required this.byUsername,
    required this.createdAt,
  });

  bool get isConsumed => kind == 'consumed';
  bool get isExpired => kind == 'expired';

  factory HistoryModel.fromEntry(ItemHistoryData entry, {String? username}) {
    final cleanUsername = username ??
        (entry.byUserId.startsWith('@')
            ? entry.byUserId.substring(1)
            : entry.byUserId);
    return HistoryModel(
      id: entry.id,
      fridgeId: entry.fridgeId,
      itemId: entry.itemId,
      itemName: entry.itemName,
      imagePath: entry.imagePath,
      kind: entry.kind,
      quantityChanged: entry.quantityChanged,
      quantityLeft: entry.quantityLeft,
      unit: entry.unit,
      byUsername: cleanUsername.isEmpty ? 'user' : cleanUsername,
      createdAt: entry.createdAt,
    );
  }

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    final rawDate = json['created_at'] ?? json['createdAt'];
    if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate != null) {
      parsedDate = DateTime.tryParse(rawDate.toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return HistoryModel(
      id: (json['id'] ?? '').toString(),
      fridgeId: (json['fridgeId'] ?? json['fridge_id'] ?? '').toString(),
      itemId: json['itemId']?.toString() ?? json['item_id']?.toString(),
      itemName: (json['itemName'] ?? json['item_name'] ?? '').toString(),
      imagePath: (json['imagePath'] ?? json['image_path'])?.toString(),
      kind: (json['kind'] ?? 'consumed').toString(),
      quantityChanged: ((json['quantityChanged'] ?? json['quantity_changed'] ?? 1) as num).toDouble(),
      quantityLeft: ((json['quantityLeft'] ?? json['quantity_left'] ?? 0) as num).toDouble(),
      unit: (json['unit'] ?? 'pieces').toString(),
      byUsername: (json['byUsername'] ?? json['by_username'] ?? 'user').toString(),
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fridge_id': fridgeId,
      'item_id': itemId,
      'item_name': itemName,
      'image_path': imagePath,
      'kind': kind,
      'quantity_changed': quantityChanged,
      'quantity_left': quantityLeft,
      'unit': unit,
      'by_username': byUsername,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

