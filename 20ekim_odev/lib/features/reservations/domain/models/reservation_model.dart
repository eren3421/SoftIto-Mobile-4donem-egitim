import '../../../auth/domain/models/user_role.dart';
import '../../../vehicles/domain/models/vehicle_type.dart';
import 'reservation_status.dart';

/// Üç Taraflı Rezervasyon Modeli (Araç + Kiralayan [Sivil] + Araç Sahibi [Sivil/Firma])
class ReservationModel {
  final String id;

  // 1. Taraf: Araç Bilgileri
  final String vehicleId;
  final String vehicleSummary;       // Örn: Mercedes-Benz G63 AMG
  final VehicleCategory vehicleType; // Kara / Hava / Deniz
  final String plateNumber;
  final String trackingNumber;
  final double unitPrice;

  // 2. Taraf: Kiralayan (Yalnızca Sivil Kullanıcı)
  final String renterCivilianId;
  final String renterFullName;
  final String renterTcNumber;       // Algoritmik 11 haneli T.C. No
  final String renterPhone;
  final String renterAddressSummary;

  // 3. Taraf: Araç Sahibi (Sivil veya Firma)
  final String ownerId;
  final UserRole ownerRole;
  final String ownerDisplayName;     // Ad Soyad veya Firma Adı - Şube
  final String ownerAddressSummary;  // Sivil Adresi veya Firma Şube Adresi
  final String ownerContactPhone;

  // Zaman ve Finansal Detaylar
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final ReservationStatus status;

  int get dayCount {
    final diff = endDate.difference(startDate).inDays;
    return diff <= 0 ? 1 : diff;
  }

  String get maskedTcNumber {
    if (renterTcNumber.length >= 11) {
      return '${renterTcNumber.substring(0, 3)}*****${renterTcNumber.substring(8)}';
    }
    return renterTcNumber;
  }

  const ReservationModel({
    required this.id,
    required this.vehicleId,
    required this.vehicleSummary,
    required this.vehicleType,
    required this.plateNumber,
    required this.trackingNumber,
    required this.unitPrice,
    required this.renterCivilianId,
    required this.renterFullName,
    required this.renterTcNumber,
    required this.renterPhone,
    required this.renterAddressSummary,
    required this.ownerId,
    required this.ownerRole,
    required this.ownerDisplayName,
    required this.ownerAddressSummary,
    required this.ownerContactPhone,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });

  ReservationModel copyWith({
    String? id,
    String? vehicleId,
    String? vehicleSummary,
    VehicleCategory? vehicleType,
    String? plateNumber,
    String? trackingNumber,
    double? unitPrice,
    String? renterCivilianId,
    String? renterFullName,
    String? renterTcNumber,
    String? renterPhone,
    String? renterAddressSummary,
    String? ownerId,
    UserRole? ownerRole,
    String? ownerDisplayName,
    String? ownerAddressSummary,
    String? ownerContactPhone,
    DateTime? startDate,
    DateTime? endDate,
    double? totalPrice,
    ReservationStatus? status,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleSummary: vehicleSummary ?? this.vehicleSummary,
      vehicleType: vehicleType ?? this.vehicleType,
      plateNumber: plateNumber ?? this.plateNumber,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      unitPrice: unitPrice ?? this.unitPrice,
      renterCivilianId: renterCivilianId ?? this.renterCivilianId,
      renterFullName: renterFullName ?? this.renterFullName,
      renterTcNumber: renterTcNumber ?? this.renterTcNumber,
      renterPhone: renterPhone ?? this.renterPhone,
      renterAddressSummary: renterAddressSummary ?? this.renterAddressSummary,
      ownerId: ownerId ?? this.ownerId,
      ownerRole: ownerRole ?? this.ownerRole,
      ownerDisplayName: ownerDisplayName ?? this.ownerDisplayName,
      ownerAddressSummary: ownerAddressSummary ?? this.ownerAddressSummary,
      ownerContactPhone: ownerContactPhone ?? this.ownerContactPhone,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
    );
  }

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as String? ?? '',
      vehicleId: json['vehicleId'] as String? ?? '',
      vehicleSummary: json['vehicleSummary'] as String? ?? '',
      vehicleType: VehicleCategory.values.firstWhere(
        (e) => e.name == json['vehicleType'],
        orElse: () => VehicleCategory.land,
      ),
      plateNumber: json['plateNumber'] as String? ?? '',
      trackingNumber: json['trackingNumber'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      renterCivilianId: json['renterCivilianId'] as String? ?? '',
      renterFullName: json['renterFullName'] as String? ?? '',
      renterTcNumber: json['renterTcNumber'] as String? ?? '',
      renterPhone: json['renterPhone'] as String? ?? '',
      renterAddressSummary: json['renterAddressSummary'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      ownerRole: (json['ownerRole'] as String?) == 'company' ? UserRole.company : UserRole.civilian,
      ownerDisplayName: json['ownerDisplayName'] as String? ?? '',
      ownerAddressSummary: json['ownerAddressSummary'] as String? ?? '',
      ownerContactPhone: json['ownerContactPhone'] as String? ?? '',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: ReservationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReservationStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'vehicleSummary': vehicleSummary,
      'vehicleType': vehicleType.name,
      'plateNumber': plateNumber,
      'trackingNumber': trackingNumber,
      'unitPrice': unitPrice,
      'renterCivilianId': renterCivilianId,
      'renterFullName': renterFullName,
      'renterTcNumber': renterTcNumber,
      'renterPhone': renterPhone,
      'renterAddressSummary': renterAddressSummary,
      'ownerId': ownerId,
      'ownerRole': ownerRole.name,
      'ownerDisplayName': ownerDisplayName,
      'ownerAddressSummary': ownerAddressSummary,
      'ownerContactPhone': ownerContactPhone,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status.name,
    };
  }
}
