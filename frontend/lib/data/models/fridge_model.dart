import '../local/app_database.dart';

class FridgeModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final bool isSynced;
  final DateTime updatedAt;
  final int memberCount;

  const FridgeModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.ownerId,
    this.isSynced = true,
    required this.updatedAt,
    this.memberCount = 1,
  });

  bool get isPersonal => memberCount <= 1;

  factory FridgeModel.fromEntry(FridgeEntry entry, {int memberCount = 1}) {
    return FridgeModel(
      id: entry.id,
      name: entry.name,
      description: entry.description ?? '',
      ownerId: entry.ownerId,
      isSynced: entry.isSynced,
      updatedAt: entry.updatedAt,
      memberCount: memberCount,
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
    };
  }
}
