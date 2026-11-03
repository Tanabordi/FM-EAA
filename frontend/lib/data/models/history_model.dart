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

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'] as String,
      fridgeId: json['fridge_id'] as String,
      itemId: json['item_id'] as String?,
      itemName: json['item_name'] as String,
      imagePath: json['image_path'] as String?,
      kind: json['kind'] as String,
      quantityChanged: (json['quantity_changed'] as num).toDouble(),
      quantityLeft: (json['quantity_left'] as num).toDouble(),
      unit: json['unit'] as String,
      byUsername: json['by_username'] as String? ?? 'user',
      createdAt: DateTime.parse(json['created_at'] as String),
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

