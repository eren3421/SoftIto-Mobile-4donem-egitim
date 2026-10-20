import '../../../auth/domain/models/user_role.dart';
import 'vehicle_type.dart';

/// 7 Kriterli Araç Filtreleme Durumu
class VehicleFilterState {
  final String? ownerQuery;            // 1. Sahibine göre (isim veya firma)
  final UserRole? ownerRoleFilter;     // Sahip tipi (Tümü / Sivil / Firma)
  final String? country;               // 2. Bulunduğu ülkeye göre
  final String? city;                  // 3. Bulunduğu şehre göre
  final VehicleCategory? vehicleType;  // 4. Türüne göre (Kara, Hava, Deniz)
  final String? brand;                 // 5. Markaya göre
  final String? model;                 // 6. Modele göre
  final String? plateNumberQuery;      // 7. Plakaya göre

  const VehicleFilterState({
    this.ownerQuery,
    this.ownerRoleFilter,
    this.country,
    this.city,
    this.vehicleType,
    this.brand,
    this.model,
    this.plateNumberQuery,
  });

  bool get hasActiveFilters =>
      (ownerQuery != null && ownerQuery!.trim().isNotEmpty) ||
      ownerRoleFilter != null ||
      (country != null && country!.isNotEmpty) ||
      (city != null && city!.isNotEmpty) ||
      vehicleType != null ||
      (brand != null && brand!.isNotEmpty) ||
      (model != null && model!.isNotEmpty) ||
      (plateNumberQuery != null && plateNumberQuery!.trim().isNotEmpty);

  int get activeFilterCount {
    int count = 0;
    if (ownerQuery != null && ownerQuery!.trim().isNotEmpty) count++;
    if (ownerRoleFilter != null) count++;
    if (country != null && country!.isNotEmpty) count++;
    if (city != null && city!.isNotEmpty) count++;
    if (vehicleType != null) count++;
    if (brand != null && brand!.isNotEmpty) count++;
    if (model != null && model!.isNotEmpty) count++;
    if (plateNumberQuery != null && plateNumberQuery!.trim().isNotEmpty) count++;
    return count;
  }

  VehicleFilterState copyWith({
    String? ownerQuery,
    UserRole? ownerRoleFilter,
    String? country,
    String? city,
    VehicleCategory? vehicleType,
    String? brand,
    String? model,
    String? plateNumberQuery,
    bool clearOwner = false,
    bool clearCountry = false,
    bool clearCity = false,
    bool clearType = false,
    bool clearBrand = false,
    bool clearModel = false,
    bool clearPlate = false,
  }) {
    return VehicleFilterState(
      ownerQuery: clearOwner ? null : (ownerQuery ?? this.ownerQuery),
      ownerRoleFilter: clearOwner ? null : (ownerRoleFilter ?? this.ownerRoleFilter),
      country: clearCountry ? null : (country ?? this.country),
      city: clearCity ? null : (city ?? this.city),
      vehicleType: clearType ? null : (vehicleType ?? this.vehicleType),
      brand: clearBrand ? null : (brand ?? this.brand),
      model: clearModel ? null : (model ?? this.model),
      plateNumberQuery: clearPlate ? null : (plateNumberQuery ?? this.plateNumberQuery),
    );
  }

  static const VehicleFilterState empty = VehicleFilterState();
}
