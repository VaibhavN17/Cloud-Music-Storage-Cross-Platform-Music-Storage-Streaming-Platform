/// Folder data model.
///
/// Matches the Prisma Folder model from Backend Schemas §2.
library;

class FolderModel {
  const FolderModel({
    required this.id,
    required this.ownerId,
    this.parentId,
    required this.name,
    this.trackCount = 0,
    this.createdAt,
  });

  final String id;
  final String ownerId;
  final String? parentId;
  final String name;
  final int trackCount;
  final DateTime? createdAt;

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String? ?? '',
      parentId: json['parentId'] as String?,
      name: json['name'] as String,
      trackCount: json['trackCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'parentId': parentId,
      'name': name,
      'trackCount': trackCount,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  FolderModel copyWith({
    String? id,
    String? ownerId,
    String? parentId,
    String? name,
    int? trackCount,
    DateTime? createdAt,
  }) {
    return FolderModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      trackCount: trackCount ?? this.trackCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
