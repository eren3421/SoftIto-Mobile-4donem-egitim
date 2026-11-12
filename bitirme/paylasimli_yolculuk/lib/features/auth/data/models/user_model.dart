import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

/// `users` koleksiyonu ve Hive yerel önbelleği için JSON/Map ve Firestore `Timestamp`
/// dönüşümlerini sağlayan DTO modeli.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.phoneNumber,
    super.avatarUrl,
    super.bio,
    super.role,
    super.isVerified,
    super.ratingAvg,
    super.ratingCount,
    super.preferences,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      avatarUrl: entity.avatarUrl,
      bio: entity.bio,
      role: entity.role,
      isVerified: entity.isVerified,
      ratingAvg: entity.ratingAvg,
      ratingCount: entity.ratingCount,
      preferences: entity.preferences,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      role: json['role'] as String? ?? 'both',
      isVerified: json['isVerified'] as bool? ?? true,
      ratingAvg: (json['ratingCount'] == 0 || json['ratingCount'] == null)
          ? 0.0
          : ((json['ratingAvg'] as num?)?.toDouble() ?? 0.0),
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      preferences: UserPreferences.fromJson(
        json['preferences'] is Map
            ? Map<String, dynamic>.from(json['preferences'] as Map)
            : null,
      ),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'role': role,
      'isVerified': isVerified,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'preferences': preferences.toJson(),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      ...toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
