import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ride_entity.dart';

/// `rides` koleksiyonu ve Hive yerel önbelleği için JSON/Map ve Firestore `Timestamp`
/// dönüşümlerini sağlayan DTO modeli (04_firebase_ve_local_storage_entegrasyonu.md Bölüm 4).
class RideModel extends RideEntity {
  const RideModel({
    required super.id,
    required super.driverId,
    required super.driverSummary,
    required super.vehicleId,
    required super.vehicleSummary,
    required super.origin,
    required super.destination,
    super.waypoints,
    super.routePolyline,
    required super.departureTime,
    required super.estimatedArrivalTime,
    required super.totalSeatsOffered,
    required super.availableSeats,
    required super.pricePerSeat,
    super.currency,
    super.status,
    super.rules,
    required super.createdAt,
  });

  factory RideModel.fromEntity(RideEntity entity) {
    return RideModel(
      id: entity.id,
      driverId: entity.driverId,
      driverSummary: entity.driverSummary,
      vehicleId: entity.vehicleId,
      vehicleSummary: entity.vehicleSummary,
      origin: entity.origin,
      destination: entity.destination,
      waypoints: entity.waypoints,
      routePolyline: entity.routePolyline,
      departureTime: entity.departureTime,
      estimatedArrivalTime: entity.estimatedArrivalTime,
      totalSeatsOffered: entity.totalSeatsOffered,
      availableSeats: entity.availableSeats,
      pricePerSeat: entity.pricePerSeat,
      currency: entity.currency,
      status: entity.status,
      rules: entity.rules,
      createdAt: entity.createdAt,
    );
  }

  factory RideModel.fromJson(Map<String, dynamic> json) {
    final waypointsRaw = json['waypoints'] as List<dynamic>? ?? [];
    final depTime = _parseDate(json['departureTime']);
    return RideModel(
      id: json['id'] as String? ?? '',
      driverId: json['driverId'] as String? ?? '',
      driverSummary: DriverSummary.fromJson(
        json['driverSummary'] is Map
            ? Map<String, dynamic>.from(json['driverSummary'] as Map)
            : null,
      ),
      vehicleId: json['vehicleId'] as String? ?? '',
      vehicleSummary: VehicleSummary.fromJson(
        json['vehicleSummary'] is Map
            ? Map<String, dynamic>.from(json['vehicleSummary'] as Map)
            : null,
      ),
      origin: RideLocationPoint.fromJson(
        json['origin'] is Map
            ? Map<String, dynamic>.from(json['origin'] as Map)
            : <String, dynamic>{},
      ),
      destination: RideLocationPoint.fromJson(
        json['destination'] is Map
            ? Map<String, dynamic>.from(json['destination'] as Map)
            : <String, dynamic>{},
      ),
      waypoints: waypointsRaw
          .whereType<Map>()
          .map((w) => RideLocationPoint.fromJson(Map<String, dynamic>.from(w)))
          .toList(),
      routePolyline: json['routePolyline'] as String? ?? '',
      departureTime: depTime,
      estimatedArrivalTime: json['estimatedArrivalTime'] != null
          ? _parseDate(json['estimatedArrivalTime'])
          : depTime.add(const Duration(minutes: 45)),
      totalSeatsOffered: (json['totalSeatsOffered'] as num?)?.toInt() ?? 3,
      availableSeats: (json['availableSeats'] as num?)?.toInt() ?? 0,
      pricePerSeat: (json['pricePerSeat'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'TRY',
      status: json['status'] as String? ?? 'planned',
      rules: RideRules.fromJson(
        json['rules'] is Map
            ? Map<String, dynamic>.from(json['rules'] as Map)
            : null,
      ),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  /// Hive (`LocalCacheService`) için `Timestamp` alanlarını ISO-8601 `String` formatına dönüştürür.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'driverSummary': driverSummary.toJson(),
      'vehicleId': vehicleId,
      'vehicleSummary': vehicleSummary.toJson(),
      'origin': origin.toJson(),
      'destination': destination.toJson(),
      'waypoints': waypoints.map((w) => w.toJson()).toList(),
      'routePolyline': routePolyline,
      'departureTime': departureTime.toUtc().toIso8601String(),
      'estimatedArrivalTime': estimatedArrivalTime.toUtc().toIso8601String(),
      'totalSeatsOffered': totalSeatsOffered,
      'availableSeats': availableSeats,
      'pricePerSeat': pricePerSeat,
      'currency': currency,
      'status': status,
      'rules': rules.toJson(),
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  /// Cloud Firestore için tarih alanlarını `Timestamp` olarak saklar.
  Map<String, dynamic> toFirestore() {
    return {
      ...toJson(),
      'departureTime': Timestamp.fromDate(departureTime),
      'estimatedArrivalTime': Timestamp.fromDate(estimatedArrivalTime),
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
