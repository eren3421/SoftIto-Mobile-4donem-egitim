import '../../../auth/domain/models/user_role.dart';
import 'vehicle_type.dart';

class VehicleModel {
  final String id;
  final String ownerId;                // Sivil veya Firma ID
  final String ownerName;              // Sivil Ad Soyad veya Firma Adı - Şube
  final UserRole ownerRole;            // civilian veya company
  final VehicleCategory vehicleType;   // Tür: Kara, Hava, Deniz
  final String brand;                  // Marka (Mercedes, Cessna, Azimut)
  final String model;                  // Model (G63 AMG, Citation CJ4, Grande 27M)
  final String plateNumber;            // Plaka No / Kuyruk No / Deniz Sicil No
  final double unitPrice;              // Birim Fiyat
  final String pricingPeriod;          // 'Günlük' veya 'Saatlik'
  final String trackingNumber;         // Benzersiz Takip No (Örn: TRK-LAND-3401)
  final String country;                // Bulunduğu Ülke
  final String city;                   // Bulunduğu Şehir
  final bool isAvailable;              // Kiralanabilir mi?
  final String? description;
  final String? imageUrl;
  final Map<String, String> specs;

  String get title => '$brand $model';
  String get locationSummary => '$city, $country';

  const VehicleModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerRole,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.unitPrice,
    this.pricingPeriod = 'Günlük',
    required this.trackingNumber,
    required this.country,
    required this.city,
    this.isAvailable = true,
    this.description,
    this.imageUrl,
    this.specs = const {},
  });

  VehicleModel copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    UserRole? ownerRole,
    VehicleCategory? vehicleType,
    String? brand,
    String? model,
    String? plateNumber,
    double? unitPrice,
    String? pricingPeriod,
    String? trackingNumber,
    String? country,
    String? city,
    bool? isAvailable,
    String? description,
    String? imageUrl,
    Map<String, String>? specs,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerRole: ownerRole ?? this.ownerRole,
      vehicleType: vehicleType ?? this.vehicleType,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      plateNumber: plateNumber ?? this.plateNumber,
      unitPrice: unitPrice ?? this.unitPrice,
      pricingPeriod: pricingPeriod ?? this.pricingPeriod,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      country: country ?? this.country,
      city: city ?? this.city,
      isAvailable: isAvailable ?? this.isAvailable,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      specs: specs ?? this.specs,
    );
  }

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? '',
      ownerRole: (json['ownerRole'] as String?) == 'company' ? UserRole.company : UserRole.civilian,
      vehicleType: VehicleCategory.values.firstWhere(
        (e) => e.name == json['vehicleType'],
        orElse: () => VehicleCategory.land,
      ),
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      plateNumber: json['plateNumber'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      pricingPeriod: json['pricingPeriod'] as String? ?? 'Günlük',
      trackingNumber: json['trackingNumber'] as String? ?? '',
      country: json['country'] as String? ?? 'Türkiye',
      city: json['city'] as String? ?? 'İstanbul',
      isAvailable: json['isAvailable'] as bool? ?? true,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      specs: (json['specs'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v.toString())) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerRole': ownerRole.name,
      'vehicleType': vehicleType.name,
      'brand': brand,
      'model': model,
      'plateNumber': plateNumber,
      'unitPrice': unitPrice,
      'pricingPeriod': pricingPeriod,
      'trackingNumber': trackingNumber,
      'country': country,
      'city': city,
      'isAvailable': isAvailable,
      'description': description,
      'imageUrl': imageUrl,
      'specs': specs,
    };
  }
}
