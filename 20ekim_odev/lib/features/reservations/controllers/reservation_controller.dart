import 'package:flutter/foundation.dart';
import '../../auth/domain/models/app_user.dart';
import '../../auth/domain/models/user_role.dart';
import '../../vehicles/domain/models/vehicle_model.dart';
import '../../vehicles/domain/models/vehicle_type.dart';
import '../domain/models/reservation_model.dart';
import '../domain/models/reservation_status.dart';

class ReservationController extends ChangeNotifier {
  static final ReservationController instance = ReservationController._();
  ReservationController._() {
    _initDemoReservations();
  }

  final ValueNotifier<List<ReservationModel>> _reservationsNotifier =
      ValueNotifier<List<ReservationModel>>([]);

  ValueListenable<List<ReservationModel>> get reservations => _reservationsNotifier;
  List<ReservationModel> get allReservations => _reservationsNotifier.value;

  void _initDemoReservations() {
    final now = DateTime.now();

    _reservationsNotifier.value = [
      // 1. Aktif Kiralama (Kara - Ahmet Yılmaz'ın G63'ünü Selin Arslan kiraladı)
      ReservationModel(
        id: 'res_101',
        vehicleId: 'v_land_1',
        vehicleSummary: 'Mercedes-Benz G63 AMG 4MATIC',
        vehicleType: VehicleCategory.land,
        plateNumber: '34 VR 1923',
        trackingNumber: 'TRK-LAND-3401',
        unitPrice: 8500,
        renterCivilianId: 'civ_selin',
        renterFullName: 'Selin Arslan',
        renterTcNumber: '10000000302',
        renterPhone: '+90 535 777 88 99',
        renterAddressSummary: 'Kadıköy, İstanbul / Türkiye',
        ownerId: 'civ_1',
        ownerRole: UserRole.civilian,
        ownerDisplayName: 'Ahmet Yılmaz',
        ownerAddressSummary: 'Beşiktaş, İstanbul / Türkiye',
        ownerContactPhone: '+90 532 111 22 33',
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 2)),
        totalPrice: 25500,
        status: ReservationStatus.active,
      ),

      // 2. Onay Bekleyen Rezervasyon (Hava - SkyJet Jet kiralama talebi Ahmet Yılmaz'dan)
      ReservationModel(
        id: 'res_102',
        vehicleId: 'v_air_1',
        vehicleSummary: 'Cessna Citation CJ4 Gen2 Light Jet',
        vehicleType: VehicleCategory.air,
        plateNumber: 'TC-SKY',
        trackingNumber: 'TRK-HAVA-10492',
        unitPrice: 42000,
        renterCivilianId: 'civ_1',
        renterFullName: 'Ahmet Yılmaz',
        renterTcNumber: '10000000146',
        renterPhone: '+90 532 111 22 33',
        renterAddressSummary: 'Beşiktaş, İstanbul / Türkiye',
        ownerId: 'comp_1',
        ownerRole: UserRole.company,
        ownerDisplayName: 'SkyJet Havacılık - İstanbul HL Genel Havacılık Şb.',
        ownerAddressSummary: 'Bakırköy, İstanbul / Türkiye',
        ownerContactPhone: '+90 212 465 00 00',
        startDate: now.add(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 4)),
        totalPrice: 42000,
        status: ReservationStatus.pending,
      ),

      // 3. Onaylanmış Rezervasyon (Deniz - DenizYat A.Ş. Süperyatını Mehmet Demir kiraladı)
      ReservationModel(
        id: 'res_103',
        vehicleId: 'v_sea_2',
        vehicleSummary: 'Azimut Grande 27 Metri Superyacht',
        vehicleType: VehicleCategory.sea,
        plateNumber: 'GCK-YAT-88',
        trackingNumber: 'TRK-DENIZ-99014',
        unitPrice: 65000,
        renterCivilianId: 'civ_2',
        renterFullName: 'Mehmet Demir',
        renterTcNumber: '10000000224',
        renterPhone: '+90 542 333 44 55',
        renterAddressSummary: 'Bodrum, Muğla / Türkiye',
        ownerId: 'comp_2',
        ownerRole: UserRole.company,
        ownerDisplayName: 'DenizYat Filo A.Ş. - Göcek Marina Merkez Şb.',
        ownerAddressSummary: 'Fethiye, Muğla / Türkiye',
        ownerContactPhone: '+90 252 645 22 11',
        startDate: now.add(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 10)),
        totalPrice: 195000,
        status: ReservationStatus.approved,
      ),
    ];
  }

  List<ReservationModel> getReservationsForUser(AppUser? user) {
    if (user == null) return _reservationsNotifier.value;
    final userId = user.id;

    return _reservationsNotifier.value.where((r) {
      if (user.isCivilian) {
        // As a civilian: either you rented it, or you own the vehicle
        return r.renterCivilianId == userId || r.ownerId == userId;
      } else {
        // As a company: you are the owner
        return r.ownerId == userId;
      }
    }).toList();
  }

  void createReservation({
    required VehicleModel vehicle,
    required AppUser renterUser,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!renterUser.canRent || renterUser.civilian == null) {
      throw Exception('Yalnızca sivil kullanıcılar araç kiralayabilir.');
    }

    final diffDays = endDate.difference(startDate).inDays;
    final days = diffDays <= 0 ? 1 : diffDays;
    final total = vehicle.unitPrice * days;

    final newRes = ReservationModel(
      id: 'res_${DateTime.now().millisecondsSinceEpoch}',
      vehicleId: vehicle.id,
      vehicleSummary: vehicle.title,
      vehicleType: vehicle.vehicleType,
      plateNumber: vehicle.plateNumber,
      trackingNumber: vehicle.trackingNumber,
      unitPrice: vehicle.unitPrice,
      renterCivilianId: renterUser.id,
      renterFullName: renterUser.displayName,
      renterTcNumber: renterUser.civilian!.tcIdentityNumber,
      renterPhone: renterUser.contactPhone,
      renterAddressSummary: renterUser.addressSummary,
      ownerId: vehicle.ownerId,
      ownerRole: vehicle.ownerRole,
      ownerDisplayName: vehicle.ownerName,
      ownerAddressSummary: vehicle.locationSummary,
      ownerContactPhone: '+90 (İletişim Hattı)',
      startDate: startDate,
      endDate: endDate,
      totalPrice: total,
      status: ReservationStatus.pending,
    );

    _reservationsNotifier.value = [newRes, ..._reservationsNotifier.value];
    notifyListeners();
  }

  void updateStatus(String reservationId, ReservationStatus newStatus) {
    _reservationsNotifier.value = _reservationsNotifier.value.map((r) {
      if (r.id == reservationId) {
        return r.copyWith(status: newStatus);
      }
      return r;
    }).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    _reservationsNotifier.dispose();
    super.dispose();
  }
}
