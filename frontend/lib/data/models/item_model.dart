import '../../core/theme/freshness_colors.dart';
import '../local/app_database.dart';

class ItemModel {
  final String id;
  final String fridgeId;
  final String name;
  final String category; // proteins, veggies, beverages, meals, sauces
  final String zone; // fridge, freezer
  final double quantity;
  final String unit;
  final DateTime expiryDate;
  final String? imagePath;
  final bool isSynced;
  final DateTime updatedAt;

  const ItemModel({
    required this.id,
    required this.fridgeId,
    required this.name,
    required this.category,
    required this.zone,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    this.imagePath,
    this.isSynced = true,
    required this.updatedAt,
  });

  /// Calculate FreshnessStatus and human readable label
  FreshnessStatus get status {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final diffDays = target.difference(today).inDays;

    if (diffDays < 0) {
      return FreshnessStatus.expired;
    } else if (diffDays <= 2) {
      return FreshnessStatus.useSoon;
    } else {
      return FreshnessStatus.fresh;
    }
  }

  String get statusText {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final diffDays = target.difference(today).inDays;

    if (diffDays < 0) {
      if (diffDays == -1) return 'Yesterday';
      return '${diffDays.abs()} days ago';
    } else if (diffDays == 0) {
      return 'Expires today';
    } else if (diffDays == 1) {
      return '1 day left';
    } else {
      return '$diffDays days left';
    }
  }

  /// Formatted quantity text helper (e.g. "1 carton", "2.5 kg", "500g · 2 pieces")
  String get formattedQuantity {
    final qtyStr = quantity == quantity.toInt() ? quantity.toInt().toString() : quantity.toString();
    if (unit.contains('·') || unit.contains('pieces')) {
      return quantity > 0 ? '$qtyStr $unit'.trim() : unit.trim();
    }
    return '$qtyStr $unit'.trim();
  }

  ItemModel copyWith({
    String? id,
    String? fridgeId,
    String? name,
    String? category,
    String? zone,
    double? quantity,
    String? unit,
    DateTime? expiryDate,
    String? imagePath,
    bool? isSynced,
    DateTime? updatedAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      fridgeId: fridgeId ?? this.fridgeId,
      name: name ?? this.name,
      category: category ?? this.category,
      zone: zone ?? this.zone,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      imagePath: imagePath ?? this.imagePath,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ItemModel.fromEntry(ItemEntry entry) {
    return ItemModel(
      id: entry.id,
      fridgeId: entry.fridgeId,
      name: entry.name,
      category: entry.category,
      zone: entry.zone,
      quantity: entry.quantity,
      unit: entry.unit,
      expiryDate: entry.expiryDate,
      imagePath: entry.imagePath,
      isSynced: entry.isSynced,
      updatedAt: entry.updatedAt,
    );
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String,
      fridgeId: json['fridge_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      zone: json['zone'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      imagePath: json['image_path'] as String?,
      isSynced: (json['is_synced'] as int? ?? 1) == 1,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fridge_id': fridgeId,
      'name': name,
      'category': category,
      'zone': zone,
      'quantity': quantity,
      'unit': unit,
      'expiry_date': expiryDate.toIso8601String(),
      'image_path': imagePath,
      'is_synced': isSynced ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
