import '../local/app_database.dart';

class FridgeModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String role; // 'owner' | 'member'
  final bool isSynced;
  final DateTime updatedAt;
  final int memberCount;
  final int itemCount;

  const FridgeModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.ownerId,
    this.role = 'owner',
    this.isSynced = true,
    required this.updatedAt,
    this.memberCount = 1,
    this.itemCount = 0,
  });

  bool get isPersonal => memberCount <= 1;

  bool get isOwner => role.toLowerCase() == 'owner';

  bool isUserOwner([String? currentUserId]) {
    if (role.toLowerCase() == 'owner') return true;
    if (currentUserId != null &&
        currentUserId.isNotEmpty &&
        ownerId.toLowerCase() == currentUserId.toLowerCase()) {
      return true;
    }
    return false;
  }

  String get itemsCountText => itemCount == 0 ? 'Empty' : (itemCount == 1 ? '1 Item' : '$itemCount Items');

  FridgeModel copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    String? role,
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
      role: role ?? this.role,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
      memberCount: memberCount ?? this.memberCount,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  factory FridgeModel.fromEntry(FridgeEntry entry, {int memberCount = 1, int itemCount = 0, String role = 'owner'}) {
    return FridgeModel(
      id: entry.id,
      name: entry.name,
      description: entry.description ?? '',
      ownerId: entry.ownerId,
      role: role,
      isSynced: entry.isSynced,
      updatedAt: entry.updatedAt,
      memberCount: memberCount,
      itemCount: itemCount,
    );
  }

  factory FridgeModel.fromJson(Map<String, dynamic> json) {
    final rawUpdated = json['updatedAt'] ?? json['updated_at'];
    DateTime parsedDate;
    if (rawUpdated is DateTime) {
      parsedDate = rawUpdated;
    } else if (rawUpdated != null) {
      parsedDate = DateTime.tryParse(rawUpdated.toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    final memberVal = json['memberCount'] ?? json['member_count'];
    final itemVal = json['itemCount'] ?? json['item_count'];
    final rawRole = json['role'] ?? json['userRole'];
    final roleStr = rawRole != null ? rawRole.toString() : 'owner';

    return FridgeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      ownerId: (json['ownerId'] ?? json['owner_id'] ?? '').toString(),
      role: roleStr,
      isSynced: json['isSynced'] == true || (json['is_synced'] as int? ?? 1) == 1,
      updatedAt: parsedDate,
      memberCount: memberVal is num ? memberVal.toInt() : int.tryParse(memberVal?.toString() ?? '1') ?? 1,
      itemCount: itemVal is num ? itemVal.toInt() : int.tryParse(itemVal?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'owner_id': ownerId,
      'role': role,
      'is_synced': isSynced ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
      'member_count': memberCount,
      'item_count': itemCount,
    };
  }
}
