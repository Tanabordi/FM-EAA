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

  /// Formatted status label for Item Details page badge (e.g. "Use soon in 1 Day", "Use soon in 2 Days", "Fresh in 7 Days")
  String get detailStatusLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final diffDays = target.difference(today).inDays;

    if (diffDays < 0) {
      if (diffDays == -1) return 'Expired yesterday';
      return 'Expired ${diffDays.abs()} days ago';
    } else if (diffDays == 0) {
      return 'Expires today';
    } else if (diffDays == 1) {
      return 'Use soon in 1 Day';
    } else if (diffDays == 2) {
      return 'Use soon in 2 Days';
    } else {
      return 'Fresh in $diffDays Days';
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
    final rawExpiry = json['expiryDate'] ?? json['expiry_date'];
    DateTime parsedExpiry;
    if (rawExpiry is DateTime) {
      parsedExpiry = rawExpiry;
    } else if (rawExpiry != null) {
      parsedExpiry = DateTime.tryParse(rawExpiry.toString()) ?? DateTime.now();
    } else {
      parsedExpiry = DateTime.now();
    }

    final rawUpdated = json['updatedAt'] ?? json['updated_at'];
    DateTime parsedUpdated;
    if (rawUpdated is DateTime) {
      parsedUpdated = rawUpdated;
    } else if (rawUpdated != null) {
      parsedUpdated = DateTime.tryParse(rawUpdated.toString()) ?? DateTime.now();
    } else {
      parsedUpdated = DateTime.now();
    }

    final rawQuantity = json['quantity'];
    double qty = 1.0;
    if (rawQuantity is num) {
      qty = rawQuantity.toDouble();
    } else if (rawQuantity != null) {
      qty = double.tryParse(rawQuantity.toString()) ?? 1.0;
    }

    return ItemModel(
      id: json['id']?.toString() ?? '',
      fridgeId: (json['fridgeId'] ?? json['fridge_id'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'meals',
      zone: json['zone']?.toString() ?? 'fridge',
      quantity: qty,
      unit: json['unit']?.toString() ?? 'pieces',
      expiryDate: parsedExpiry,
      imagePath: (json['imagePath'] ?? json['image_path'])?.toString(),
      isSynced: json['isSynced'] == true || (json['is_synced'] as int? ?? 1) == 1,
      updatedAt: parsedUpdated,
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
