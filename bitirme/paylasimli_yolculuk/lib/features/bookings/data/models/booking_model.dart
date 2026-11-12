import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../rides/domain/entities/ride_entity.dart';
import '../../domain/entities/booking_entity.dart';

/// `bookings` koleksiyonu ve yerel Hive önbelleği için JSON/Map ve Firestore `Timestamp`
/// dönüşümlerini sağlayan DTO modeli.
class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.rideId,
    required super.driverId,
    required super.passengerId,
    required super.passengerSummary,
    required super.seatsBooked,
    required super.totalPrice,
    super.status,
    required super.pickupPoint,
    super.noteToDriver,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BookingModel.fromEntity(BookingEntity entity) {
    return BookingModel(
      id: entity.id,
      rideId: entity.rideId,
      driverId: entity.driverId,
      passengerId: entity.passengerId,
      passengerSummary: entity.passengerSummary,
      seatsBooked: entity.seatsBooked,
      totalPrice: entity.totalPrice,
      status: entity.status,
      pickupPoint: entity.pickupPoint,
      noteToDriver: entity.noteToDriver,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String? ?? '',
      rideId: json['rideId'] as String? ?? '',
      driverId: json['driverId'] as String? ?? '',
      passengerId: json['passengerId'] as String? ?? '',
      passengerSummary: PassengerSummary.fromJson(
        json['passengerSummary'] is Map
            ? Map<String, dynamic>.from(json['passengerSummary'] as Map)
            : null,
      ),
      seatsBooked: (json['seatsBooked'] as num?)?.toInt() ?? 1,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      pickupPoint: RideLocationPoint.fromJson(
        json['pickupPoint'] is Map
            ? Map<String, dynamic>.from(json['pickupPoint'] as Map)
            : <String, dynamic>{},
      ),
      noteToDriver: json['noteToDriver'] as String? ?? '',
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  /// Hive (`LocalCacheService`) için `Timestamp` alanlarını ISO-8601 `String` formatına dönüştürür.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rideId': rideId,
      'driverId': driverId,
      'passengerId': passengerId,
      'passengerSummary': passengerSummary.toJson(),
      'seatsBooked': seatsBooked,
      'totalPrice': totalPrice,
      'status': status,
      'pickupPoint': pickupPoint.toJson(),
      'noteToDriver': noteToDriver,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  /// Cloud Firestore için tarih alanlarını `Timestamp` olarak saklar.
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
