/// User data model.
///
/// Matches the Prisma User model from Backend Schemas §2.
library;

enum UserRole { user, moderator, admin }

class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.role = UserRole.user,
    this.emailVerified = false,
    this.twoFactorEnabled = false,
    this.storageUsedBytes = 0,
    this.storageQuotaBytes = 5368709120, // 5GB
    this.suspended = false,
    this.createdAt,
  });

  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final UserRole role;
  final bool emailVerified;
  final bool twoFactorEnabled;
  final int storageUsedBytes;
  final int storageQuotaBytes;
  final bool suspended;
  final DateTime? createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      role: _parseRole(json['role'] as String?),
      emailVerified: json['emailVerified'] as bool? ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      storageUsedBytes: _parseInt(json['storageUsedBytes']),
      storageQuotaBytes: _parseInt(json['storageQuotaBytes']) == 0
          ? 5368709120
          : _parseInt(json['storageQuotaBytes']),
      suspended: json['suspended'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'role': role.name.toUpperCase(),
      'emailVerified': emailVerified,
      'twoFactorEnabled': twoFactorEnabled,
      'storageUsedBytes': storageUsedBytes,
      'storageQuotaBytes': storageQuotaBytes,
      'suspended': suspended,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static UserRole _parseRole(String? roleStr) {
    switch (roleStr?.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'MODERATOR':
        return UserRole.moderator;
      default:
        return UserRole.user;
    }
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? bio,
    UserRole? role,
    bool? emailVerified,
    bool? twoFactorEnabled,
    int? storageUsedBytes,
    int? storageQuotaBytes,
    bool? suspended,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      storageUsedBytes: storageUsedBytes ?? this.storageUsedBytes,
      storageQuotaBytes: storageQuotaBytes ?? this.storageQuotaBytes,
      suspended: suspended ?? this.suspended,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
