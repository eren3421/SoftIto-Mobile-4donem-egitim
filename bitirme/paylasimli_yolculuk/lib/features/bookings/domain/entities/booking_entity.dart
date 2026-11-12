import '../../../rides/domain/entities/ride_entity.dart';

/// Yolcu özet bilgisi (`passengerSummary`).
class PassengerSummary {
  final String fullName;
  final String avatarUrl;
  final double ratingAvg;

  const PassengerSummary({
    required this.fullName,
    this.avatarUrl = '',
    this.ratingAvg = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'ratingAvg': ratingAvg,
    };
  }

  factory PassengerSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PassengerSummary(fullName: 'Yolcu');
    }
    return PassengerSummary(
      fullName: json['fullName'] as String? ?? 'Yolcu',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// 02_veri_depolama_ve_sema.md Bölüm 2.4 `bookings` şemasına uygun Domain Entity.
///
/// Olası `status` değerleri:
/// - `pending` (Onay Bekliyor)
/// - `approved` (Onaylandı)
/// - `rejected` (Reddedildi)
/// - `cancelled_by_passenger` (Yolcu İptal Etti)
/// - `cancelled_by_driver` (Sürücü İptal Etti)
/// - `completed` (Tamamlandı)
class BookingEntity {
  final String id;
  final String rideId;
  final String driverId;
  final String passengerId;
  final PassengerSummary passengerSummary;
  final int seatsBooked;
  final double totalPrice;
  final String status;
  final RideLocationPoint pickupPoint;
  final String noteToDriver;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingEntity({
    required this.id,
    required this.rideId,
    required this.driverId,
    required this.passengerId,
    required this.passengerSummary,
    required this.seatsBooked,
    required this.totalPrice,
    this.status = 'pending',
    required this.pickupPoint,
    this.noteToDriver = '',
    required this.createdAt,
    required this.updatedAt,
  });

  BookingEntity copyWith({
    String? id,
    String? rideId,
    String? driverId,
    String? passengerId,
    PassengerSummary? passengerSummary,
    int? seatsBooked,
    double? totalPrice,
    String? status,
    RideLocationPoint? pickupPoint,
    String? noteToDriver,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      driverId: driverId ?? this.driverId,
      passengerId: passengerId ?? this.passengerId,
      passengerSummary: passengerSummary ?? this.passengerSummary,
      seatsBooked: seatsBooked ?? this.seatsBooked,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      pickupPoint: pickupPoint ?? this.pickupPoint,
      noteToDriver: noteToDriver ?? this.noteToDriver,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

