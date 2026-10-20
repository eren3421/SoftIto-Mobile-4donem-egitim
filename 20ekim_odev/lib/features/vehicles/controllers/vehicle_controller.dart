import 'package:flutter/foundation.dart';
import '../../auth/domain/models/user_role.dart';
import '../domain/models/vehicle_filter_state.dart';
import '../domain/models/vehicle_model.dart';
import '../domain/models/vehicle_type.dart';

class VehicleController extends ChangeNotifier {
  static final VehicleController instance = VehicleController._();
  VehicleController._() {
    _initDefaultVehicles();
  }

  final ValueNotifier<List<VehicleModel>> _vehiclesNotifier = ValueNotifier<List<VehicleModel>>([]);
  final ValueNotifier<VehicleFilterState> _filterNotifier = ValueNotifier<VehicleFilterState>(VehicleFilterState.empty);

  ValueListenable<List<VehicleModel>> get vehicles => _vehiclesNotifier;
  ValueListenable<VehicleFilterState> get filterState => _filterNotifier;

  List<VehicleModel> get allVehicles => _vehiclesNotifier.value;
  VehicleFilterState get currentFilter => _filterNotifier.value;

  /// Reactive 7-criteria filtered list
  List<VehicleModel> get filteredVehicles {
    final list = _vehiclesNotifier.value;
    final f = _filterNotifier.value;

    return list.where((v) {
      // 1. Sahip Filtresi (İsim veya Firma rolü)
      if (f.ownerQuery != null && f.ownerQuery!.trim().isNotEmpty) {
        if (!v.ownerName.toLowerCase().contains(f.ownerQuery!.toLowerCase().trim())) {
          return false;
        }
      }
      if (f.ownerRoleFilter != null && v.ownerRole != f.ownerRoleFilter) {
        return false;
      }

      // 2. Ülke Filtresi
      if (f.country != null && f.country!.isNotEmpty) {
        if (v.country.toLowerCase() != f.country!.toLowerCase()) {
          return false;
        }
      }

      // 3. Şehir Filtresi
      if (f.city != null && f.city!.isNotEmpty) {
        if (v.city.toLowerCase() != f.city!.toLowerCase()) {
          return false;
        }
      }

      // 4. Tür Filtresi (Kara, Hava, Deniz)
      if (f.vehicleType != null && v.vehicleType != f.vehicleType) {
        return false;
      }

      // 5. Marka Filtresi
      if (f.brand != null && f.brand!.isNotEmpty) {
        if (!v.brand.toLowerCase().contains(f.brand!.toLowerCase().trim())) {
          return false;
        }
      }

      // 6. Model Filtresi
      if (f.model != null && f.model!.isNotEmpty) {
        if (!v.model.toLowerCase().contains(f.model!.toLowerCase().trim())) {
          return false;
        }
      }

      // 7. Plaka Filtresi
      if (f.plateNumberQuery != null && f.plateNumberQuery!.trim().isNotEmpty) {
        final query = f.plateNumberQuery!.toUpperCase().replaceAll(' ', '');
        final plate = v.plateNumber.toUpperCase().replaceAll(' ', '');
        if (!plate.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _initDefaultVehicles() {
    _vehiclesNotifier.value = [
      // --- KARA TAŞITLARI ---
      const VehicleModel(
        id: 'v_land_1',
        ownerId: 'civ_1',
        ownerName: 'Ahmet Yılmaz',
        ownerRole: UserRole.civilian,
        vehicleType: VehicleCategory.land,
        brand: 'Mercedes-Benz',
        model: 'G63 AMG 4MATIC',
        plateNumber: '34 VR 1923',
        unitPrice: 8500,
        pricingPeriod: 'Günlük',
        trackingNumber: 'TRK-LAND-3401',
        country: 'Türkiye',
        city: 'İstanbul',
        isAvailable: true,
        description: 'V8 Bi-Turbo 585 BG, Designo deri koltuklar, tam kasko & telemetri donanımlı lüks SUV.',
        specs: {
          'Motor': '4.0L V8 Bi-Turbo (585 BG)',
          'Yakıt': 'Benzin',
          'Vites': '9G-TRONIC Otomatik',
          'Kapasite': '5 Kişilik',
        },
      ),
      const VehicleModel(
        id: 'v_land_2',
        ownerId: 'comp_3',
        ownerName: 'Veloce Luxury Motors - İzmir Alsancak VIP Şb.',
        ownerRole: UserRole.company,
        vehicleType: VehicleCategory.land,
        brand: 'Porsche',
        model: 'Taycan Turbo S Cross Turismo',
        plateNumber: '35 VIP 911',
        unitPrice: 12000,
        pricingPeriod: 'Günlük',
        trackingNumber: 'TRK-LAND-3502',
        country: 'Türkiye',
        city: 'İzmir',
        isAvailable: true,
        description: 'Tamamen elektrikli 761 BG spor grand tourer, Performance Plus bataryalı.',
        specs: {
          'Motor': 'Çift Elektrik Motoru (761 BG)',
          'Menzil': '450 km WLTP',
          'Hızlanma': '0-100: 2.8 sn',
          'Kapasite': '4 Kişilik',
        },
      ),
      const VehicleModel(
        id: 'v_land_3',
        ownerId: 'comp_3',
        ownerName: 'Veloce Luxury Motors - İzmir Alsancak VIP Şb.',
        ownerRole: UserRole.company,
        vehicleType: VehicleCategory.land,
        brand: 'Mercedes-Maybach',
        model: 'S580 4MATIC VIP Chauffeur',
        plateNumber: '34 VIP 580',
        unitPrice: 14500,
        pricingPeriod: 'Günlük',
        trackingNumber: 'TRK-LAND-3499',
        country: 'Türkiye',
        city: 'İstanbul',
        isAvailable: false,
        description: 'VIP şoförlü kiralama seçeneği, masajlı business class arka koltuklar.',
        specs: {
          'Motor': '4.0L V8 Mild Hybrid (503 BG)',
          'Donanım': 'First Class Arka Bölme',
          'Kapasite': '4 Kişilik',
        },
      ),

      // --- HAVA TAŞITLARI ---
      const VehicleModel(
        id: 'v_air_1',
        ownerId: 'comp_1',
        ownerName: 'SkyJet Havacılık - İstanbul HL Genel Havacılık Şb.',
        ownerRole: UserRole.company,
        vehicleType: VehicleCategory.air,
        brand: 'Cessna Citation',
        model: 'CJ4 Gen2 Light Jet',
        plateNumber: 'TC-SKY',
        unitPrice: 42000,
        pricingPeriod: 'Saatlik',
        trackingNumber: 'TRK-HAVA-10492',
        country: 'Türkiye',
        city: 'İstanbul',
        isAvailable: true,
        description: 'Çift pilotlu özel iş jeti, 9 yolcu kapasiteli, 4.010 km menzil, kabin içi Wi-Fi.',
        specs: {
          'Seyir Hızı': '835 km/s (451 knot)',
          'Tavan İrtifa': '45.000 ft (13.716 m)',
          'Menzil': '4.010 km',
          'Mürettebat': '2 Pilot + 1 Kabin Memuru',
        },
      ),
      const VehicleModel(
        id: 'v_air_2',
        ownerId: 'comp_1',
        ownerName: 'SkyJet Havacılık - İstanbul HL Genel Havacılık Şb.',
        ownerRole: UserRole.company,
        vehicleType: VehicleCategory.air,
        brand: 'Airbus Helicopters',
        model: 'H145 VIP Twin-Engine',
        plateNumber: 'TC-HLP',
        unitPrice: 18500,
        pricingPeriod: 'Saatlik',
        trackingNumber: 'TRK-HAVA-20811',
        country: 'Türkiye',
        city: 'Muğla',
        isAvailable: true,
        description: 'Havalimanı-Otel transferleri ve sahil turları için çift türbin motorlu VIP helikopter.',
        specs: {
          'Motor': '2 x Safran Arriel 2E',
          'Seyir Hızı': '240 km/s',
          'Menzil': '650 km',
          'Kapasite': '8 Kişilik',
        },
      ),

      // --- DENİZ TAŞITLARI ---
      const VehicleModel(
        id: 'v_sea_1',
        ownerId: 'civ_2',
        ownerName: 'Mehmet Demir',
        ownerRole: UserRole.civilian,
        vehicleType: VehicleCategory.sea,
        brand: 'Princess Yachts',
        model: 'V50 Open Sports Yacht',
        plateNumber: 'BDR-DNZ-102',
        unitPrice: 22000,
        pricingPeriod: 'Günlük',
        trackingNumber: 'TRK-DENIZ-55301',
        country: 'Türkiye',
        city: 'Muğla',
        isAvailable: true,
        description: 'Bodrum Yalıkavak çıkışlı, kaptan ve yakıt dahil günlük koy gezisi motoryatı.',
        specs: {
          'Tam Boy': '15.80 metre',
          'Kabin': '2 Kamara (4 Yatak)',
          'Motor': '2 x Volvo IPS 600 (870 BG)',
          'Maks. Hız': '32 knot',
        },
      ),
      const VehicleModel(
        id: 'v_sea_2',
        ownerId: 'comp_2',
        ownerName: 'DenizYat Filo A.Ş. - Göcek Marina Merkez Şb.',
        ownerRole: UserRole.company,
        vehicleType: VehicleCategory.sea,
        brand: 'Azimut',
        model: 'Grande 27 Metri Superyacht',
        plateNumber: 'GCK-YAT-88',
        unitPrice: 65000,
        pricingPeriod: 'Günlük',
        trackingNumber: 'TRK-DENIZ-99014',
        country: 'Türkiye',
        city: 'Muğla',
        isAvailable: true,
        description: '5 lüks süit kamara, jakuzi, flybridge bar, 4 kişilik profesyonel mürettebat dahil.',
        specs: {
          'Tam Boy': '26.78 metre',
          'Kabin': '5 Süit (10 Kişilik)',
          'Gövde': 'Karbon Fiber & GRP',
          'Mürettebat': 'Kaptan, Şef, 2 Gemici',
        },
      ),
      const VehicleModel(
        id: 'v_sea_3',
        ownerId: 'civ_1',
        ownerName: 'Ahmet Yılmaz',
        ownerRole: UserRole.civilian,
        vehicleType: VehicleCategory.sea,
        brand: 'Lagoon',
        model: '46 Luxury Catamaran',
        plateNumber: 'IST-YEL-46',
        unitPrice: 19500,
        pricingPeriod: 'Günlük',
        trackingNumber: 'TRK-DENIZ-46011',
        country: 'Türkiye',
        city: 'Antalya',
        isAvailable: true,
        description: 'Kaş ve Kalkan açıklarında yelken deneyimi, geniş güneşlenme güvertesi.',
        specs: {
          'Tam Boy': '13.99 metre',
          'Genişlik': '7.96 metre',
          'Kabin': '4 Kamara',
          'Yelken Alanı': '140 m²',
        },
      ),
    ];
  }

  void updateFilter(VehicleFilterState newState) {
    _filterNotifier.value = newState;
    notifyListeners();
  }

  void updateCategoryFilter(VehicleCategory? category) {
    _filterNotifier.value = _filterNotifier.value.copyWith(
      vehicleType: category,
      clearType: category == null,
    );
    notifyListeners();
  }

  void resetFilters() {
    _filterNotifier.value = VehicleFilterState.empty;
    notifyListeners();
  }

  void addVehicle(VehicleModel newVehicle) {
    _vehiclesNotifier.value = [newVehicle, ..._vehiclesNotifier.value];
    notifyListeners();
  }

  void updateVehicleAvailability(String vehicleId, bool isAvailable) {
    _vehiclesNotifier.value = _vehiclesNotifier.value.map((v) {
      if (v.id == vehicleId) {
        return v.copyWith(isAvailable: isAvailable);
      }
      return v;
    }).toList();
    notifyListeners();
  }

  VehicleModel? getVehicleById(String id) {
    try {
      return _vehiclesNotifier.value.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  VehicleModel? getVehicleByTrackingNumber(String trackingNumber) {
    try {
      final clean = trackingNumber.toUpperCase().trim();
      return _vehiclesNotifier.value.firstWhere((v) => v.trackingNumber.toUpperCase().trim() == clean);
    } catch (_) {
      return null;
    }
  }

  List<String> get availableCountries {
    return _vehiclesNotifier.value.map((v) => v.country).toSet().toList()..sort();
  }

  List<String> getCitiesForCountry(String? country) {
    if (country == null || country.isEmpty) {
      return _vehiclesNotifier.value.map((v) => v.city).toSet().toList()..sort();
    }
    return _vehiclesNotifier.value
        .where((v) => v.country.toLowerCase() == country.toLowerCase())
        .map((v) => v.city)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> getBrandsForCategory(VehicleCategory? category) {
    var list = _vehiclesNotifier.value;
    if (category != null) {
      list = list.where((v) => v.vehicleType == category).toList();
    }
    return list.map((v) => v.brand).toSet().toList()..sort();
  }

  @override
  void dispose() {
    _vehiclesNotifier.dispose();
    _filterNotifier.dispose();
    super.dispose();
  }
}
