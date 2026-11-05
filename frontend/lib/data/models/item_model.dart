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

  String localizedStatusText([bool isTh = false]) {
    if (!isTh) return statusText;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final diffDays = target.difference(today).inDays;

    if (diffDays < 0) {
      if (diffDays == -1) return 'เมื่อวานนี้';
      return '${diffDays.abs()} วันที่แล้ว';
    } else if (diffDays == 0) {
      return 'หมดอายุวันนี้';
    } else if (diffDays == 1) {
      return 'เหลืออีก 1 วัน';
    } else {
      return 'เหลืออีก $diffDays วัน';
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

  String localizedDetailStatusLabel([bool isTh = false]) {
    if (!isTh) return detailStatusLabel;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final diffDays = target.difference(today).inDays;

    if (diffDays < 0) {
      if (diffDays == -1) return 'หมดอายุเมื่อวานนี้';
      return 'หมดอายุไปแล้ว ${diffDays.abs()} วัน';
    } else if (diffDays == 0) {
      return 'หมดอายุวันนี้';
    } else if (diffDays == 1) {
      return 'ควรบริโภคใน 1 วัน';
    } else if (diffDays == 2) {
      return 'ควรบริโภคใน 2 วัน';
    } else {
      return 'สดใหม่อีก $diffDays วัน';
    }
  }

  /// Helper to localize units to Thai when active (e.g. pieces -> ชิ้น, bottle -> ขวด)
  static String localizeUnit(String unit, bool isTh) {
    if (!isTh) return unit;
    final u = unit.toLowerCase().trim();
    if (u == 'pieces' || u == 'piece' || u == 'pcs' || u == 'pc') return 'ชิ้น';
    if (u == 'bottle' || u == 'bottles') return 'ขวด';
    if (u == 'bag' || u == 'bags') return 'ถุง';
    if (u == 'box' || u == 'boxes') return 'กล่อง';
    if (u == 'can' || u == 'cans') return 'กระป๋อง';
    if (u == 'pack' || u == 'packs' || u == 'pkt') return 'แพ็ค';
    if (u == 'punnet' || u == 'punnets') return 'ตะกร้า';
    if (u == 'portion' || u == 'portions') return 'ส่วน';
    if (u == 'carton' || u == 'cartons') return 'กล่อง';
    if (u == 'g' || u == 'gram' || u == 'grams') return 'g';
    if (u == 'kg' || u == 'kilo' || u == 'kilograms') return 'kg';
    if (u.contains('pieces')) return unit.replaceAll(RegExp(r'pieces', caseSensitive: false), 'ชิ้น');
    if (u.contains('piece')) return unit.replaceAll(RegExp(r'piece', caseSensitive: false), 'ชิ้น');
    if (u.contains('punnet')) return unit.replaceAll(RegExp(r'punnet', caseSensitive: false), 'ตะกร้า');
    if (u.contains('bottle')) return unit.replaceAll(RegExp(r'bottle', caseSensitive: false), 'ขวด');
    if (u.contains('bag')) return unit.replaceAll(RegExp(r'bag', caseSensitive: false), 'ถุง');
    if (u.contains('box')) return unit.replaceAll(RegExp(r'box', caseSensitive: false), 'กล่อง');
    if (u.contains('can')) return unit.replaceAll(RegExp(r'can', caseSensitive: false), 'กระป๋อง');
    if (u.contains('pack')) return unit.replaceAll(RegExp(r'pack', caseSensitive: false), 'แพ็ค');
    return unit;
  }

  /// Formatted quantity text helper with optional localization (e.g. "1 carton", "2.5 kg", "500g · 2 pieces", "1 ชิ้น")
  String formattedQuantityLocalized(bool isTh) {
    final qtyStr = quantity == quantity.toInt() ? quantity.toInt().toString() : quantity.toString();
    final displayUnit = localizeUnit(unit, isTh);
    if (displayUnit.contains('·') || displayUnit.contains('ชิ้น') || displayUnit.contains('pieces')) {
      return quantity > 0 ? '$qtyStr $displayUnit'.trim() : displayUnit.trim();
    }
    return '$qtyStr $displayUnit'.trim();
  }

  /// Default getter for backwards compatibility
  String get formattedQuantity => formattedQuantityLocalized(false);

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
