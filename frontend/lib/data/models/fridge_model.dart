class FridgeModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final bool isSynced;
  final DateTime updatedAt;
  final int memberCount;
  final int itemCount;

  const FridgeModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.ownerId,
    this.isSynced = true,
    required this.updatedAt,
    this.memberCount = 1,
    this.itemCount = 0,
  });

  bool get isPersonal => memberCount <= 1;

  String get itemsCountText => itemCount == 0 ? 'Empty' : '$itemCount Items';

  FridgeModel copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    bool? isSynced,
    DateTime? updatedAt,
    int? memberCount,
    int? itemCount,
  }) {
    return FridgeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
      memberCount: memberCount ?? this.memberCount,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  factory FridgeModel.fromJson(Map<String, dynamic> json) {
    return FridgeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      ownerId: json['owner_id'] as String,
      isSynced: (json['is_synced'] as int? ?? 1) == 1,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      memberCount: json['member_count'] as int? ?? 1,
      itemCount: json['item_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'owner_id': ownerId,
      'is_synced': isSynced ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
      'member_count': memberCount,
      'item_count': itemCount,
    };
  }
}
