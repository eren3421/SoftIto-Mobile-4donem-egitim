import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/vehicle_entity.dart';

/// `vehicles` koleksiyonu ve yerel Hive önbelleği için JSON/Map ve Firestore `Timestamp`
/// dönüşümlerini sağlayan DTO modeli.
class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.id,
    required super.ownerId,
    required super.brand,
    required super.model,
    required super.year,
    required super.color,
    required super.licensePlate,
    super.totalSeats,
    super.isVerified,
    required super.createdAt,
  });

  factory VehicleModel.fromEntity(VehicleEntity entity) {
    return VehicleModel(
      id: entity.id,
      ownerId: entity.ownerId,
      brand: entity.brand,
      model: entity.model,
      year: entity.year,
      color: entity.color,
      licensePlate: entity.licensePlate,
      totalSeats: entity.totalSeats,
      isVerified: entity.isVerified,
      createdAt: entity.createdAt,
    );
  }

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? 2022,
      color: json['color'] as String? ?? '',
      licensePlate: json['licensePlate'] as String? ?? '',
      totalSeats: (json['totalSeats'] as num?)?.toInt() ?? 4,
      isVerified: json['isVerified'] as bool? ?? true,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'licensePlate': licensePlate,
      'totalSeats': totalSeats,
      'isVerified': isVerified,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      ...toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
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
