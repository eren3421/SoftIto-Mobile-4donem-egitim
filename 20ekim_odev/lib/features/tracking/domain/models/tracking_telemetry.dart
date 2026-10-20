import '../../../vehicles/domain/models/vehicle_type.dart';

class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint(this.latitude, this.longitude);

  Map<String, dynamic> toJson() => {'lat': latitude, 'lng': longitude};
}

class TrackingTelemetry {
  final String trackingNumber;       // Aracın takip numarası (Örn: TRK-LAND-3401)
  final String vehicleId;
  final String plateNumber;
  final VehicleCategory vehicleType;
  final double latitude;             // Anlık Enlem
  final double longitude;            // Anlık Boylam
  final double speedKmh;             // Anlık Hız (km/s veya knot)
  final double headingDegrees;       // Yön açısı (0-360)
  final double? altitudeMeters;      // Hava taşıtları için irtifa (m)
  final bool isEngineRunning;        // Motor / Kontak durumu
  final DateTime lastUpdated;        // Son sinyal zamanı
  final String? activeReservationId; // Aktif kirada ise rezervasyon ID
  final String? renterName;          // Kiralayan sivil kullanıcı
  final List<GeoPoint> routeHistory; // Çizilecek son rota geçmişi

  const TrackingTelemetry({
    required this.trackingNumber,
    required this.vehicleId,
    required this.plateNumber,
    required this.vehicleType,
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.headingDegrees,
    this.altitudeMeters,
    required this.isEngineRunning,
    required this.lastUpdated,
    this.activeReservationId,
    this.renterName,
    this.routeHistory = const [],
  });

  String get speedDisplay {
    if (vehicleType == VehicleCategory.sea) {
      final knots = (speedKmh * 0.539957).toStringAsFixed(1);
      return '$knots knot (${speedKmh.toStringAsFixed(0)} km/s)';
    }
    return '${speedKmh.toStringAsFixed(0)} km/s';
  }

  String get altitudeDisplay {
    if (altitudeMeters != null) {
      final feet = (altitudeMeters! * 3.28084).toStringAsFixed(0);
      return '${altitudeMeters!.toStringAsFixed(0)} m ($feet ft)';
    }
    return '0 m (Zemin)';
  }

  String get statusDisplay {
    if (!isEngineRunning) return 'Park / Beklemede';
    if (speedKmh < 2) return 'Rölantide / Duraklamada';
    return 'Seyir Halinde';
  }

  TrackingTelemetry copyWith({
    String? trackingNumber,
    String? vehicleId,
    String? plateNumber,
    VehicleCategory? vehicleType,
    double? latitude,
    double? longitude,
    double? speedKmh,
    double? headingDegrees,
    double? altitudeMeters,
    bool? isEngineRunning,
    DateTime? lastUpdated,
    String? activeReservationId,
    String? renterName,
    List<GeoPoint>? routeHistory,
  }) {
    return TrackingTelemetry(
      trackingNumber: trackingNumber ?? this.trackingNumber,
      vehicleId: vehicleId ?? this.vehicleId,
      plateNumber: plateNumber ?? this.plateNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speedKmh: speedKmh ?? this.speedKmh,
      headingDegrees: headingDegrees ?? this.headingDegrees,
      altitudeMeters: altitudeMeters ?? this.altitudeMeters,
      isEngineRunning: isEngineRunning ?? this.isEngineRunning,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      activeReservationId: activeReservationId ?? this.activeReservationId,
      renterName: renterName ?? this.renterName,
      routeHistory: routeHistory ?? this.routeHistory,
    );
  }
}
