/// Yolculuk üzerindeki bir konum noktasını (kalkış, varış veya ara durak) temsil eder.
class RideLocationPoint {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String geohash;

  const RideLocationPoint({
    required this.name,
    this.address = '',
    required this.lat,
    required this.lng,
    this.geohash = '',
  });

  RideLocationPoint copyWith({
    String? name,
    String? address,
    double? lat,
    double? lng,
    String? geohash,
  }) {
    return RideLocationPoint(
      name: name ?? this.name,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      geohash: geohash ?? this.geohash,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'geohash': geohash,
    };
  }

  factory RideLocationPoint.fromJson(Map<String, dynamic> json) {
    return RideLocationPoint(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 41.0082,
      lng: (json['lng'] as num?)?.toDouble() ?? 28.9784,
      geohash: json['geohash'] as String? ?? '',
    );
  }
}

/// İlan içindeki sürücü özet bilgisi (`driverSummary`).
class DriverSummary {
  final String fullName;
  final String avatarUrl;
  final double ratingAvg;

  const DriverSummary({
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

  factory DriverSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DriverSummary(fullName: 'Sürücü');
    }
    return DriverSummary(
      fullName: json['fullName'] as String? ?? 'Sürücü',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// İlan içindeki araç özet bilgisi (`vehicleSummary`).
class VehicleSummary {
  final String brandModel;
  final String color;
  final String licensePlate;

  const VehicleSummary({
    required this.brandModel,
    required this.color,
    required this.licensePlate,
  });

  Map<String, dynamic> toJson() {
    return {
      'brandModel': brandModel,
      'color': color,
      'licensePlate': licensePlate,
    };
  }

  factory VehicleSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const VehicleSummary(
        brandModel: 'Belirtilmedi',
        color: '-',
        licensePlate: '-',
      );
    }
    return VehicleSummary(
      brandModel: json['brandModel'] as String? ?? 'Belirtilmedi',
      color: json['color'] as String? ?? '-',
      licensePlate: json['licensePlate'] as String? ?? '-',
    );
  }
}

/// Yolculuk kuralları (`rules`).
class RideRules {
  final bool instantApproval;
  final String luggageSize; // 'small', 'medium', 'large'
  final bool smokingAllowed;
  final bool petsAllowed;

  const RideRules({
    this.instantApproval = false,
    this.luggageSize = 'medium',
    this.smokingAllowed = false,
    this.petsAllowed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'instantApproval': instantApproval,
      'luggageSize': luggageSize,
      'smokingAllowed': smokingAllowed,
      'petsAllowed': petsAllowed,
    };
  }

  factory RideRules.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RideRules();
    return RideRules(
      instantApproval: json['instantApproval'] as bool? ?? false,
      luggageSize: json['luggageSize'] as String? ?? 'medium',
      smokingAllowed: json['smokingAllowed'] as bool? ?? false,
      petsAllowed: json['petsAllowed'] as bool? ?? false,
    );
  }
}

/// 02_veri_depolama_ve_sema.md Bölüm 2.3 `rides` şemasına birebir uyumlu Domain Entity.
class RideEntity {
  final String id;
  final String driverId;
  final DriverSummary driverSummary;
  final String vehicleId;
  final VehicleSummary vehicleSummary;
  final RideLocationPoint origin;
  final RideLocationPoint destination;
  final List<RideLocationPoint> waypoints;
  final String routePolyline;
  final DateTime departureTime;
  final DateTime estimatedArrivalTime;
  final int totalSeatsOffered;
  final int availableSeats;
  final double pricePerSeat;
  final String currency;
  final String status; // 'planned', 'full', 'ongoing', 'completed', 'cancelled'
  final RideRules rules;
  final DateTime createdAt;

  const RideEntity({
    required this.id,
    required this.driverId,
    required this.driverSummary,
    required this.vehicleId,
    required this.vehicleSummary,
    required this.origin,
    required this.destination,
    this.waypoints = const [],
    this.routePolyline = '',
    required this.departureTime,
    required this.estimatedArrivalTime,
    required this.totalSeatsOffered,
    required this.availableSeats,
    required this.pricePerSeat,
    this.currency = 'TRY',
    this.status = 'planned',
    this.rules = const RideRules(),
    required this.createdAt,
  });

  bool get isFull => availableSeats <= 0 || status == 'full';

  RideEntity copyWith({
    String? id,
    String? driverId,
    DriverSummary? driverSummary,
    String? vehicleId,
    VehicleSummary? vehicleSummary,
    RideLocationPoint? origin,
    RideLocationPoint? destination,
    List<RideLocationPoint>? waypoints,
    String? routePolyline,
    DateTime? departureTime,
    DateTime? estimatedArrivalTime,
    int? totalSeatsOffered,
    int? availableSeats,
    double? pricePerSeat,
    String? currency,
    String? status,
    RideRules? rules,
    DateTime? createdAt,
  }) {
    return RideEntity(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      driverSummary: driverSummary ?? this.driverSummary,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleSummary: vehicleSummary ?? this.vehicleSummary,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      waypoints: waypoints ?? this.waypoints,
      routePolyline: routePolyline ?? this.routePolyline,
      departureTime: departureTime ?? this.departureTime,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      totalSeatsOffered: totalSeatsOffered ?? this.totalSeatsOffered,
      availableSeats: availableSeats ?? this.availableSeats,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      rules: rules ?? this.rules,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

