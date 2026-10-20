import 'package:flutter/foundation.dart';
import '../domain/models/address_model.dart';
import '../domain/models/app_user.dart';
import '../domain/models/civilian_user.dart';
import '../domain/models/company_user.dart';

class AuthController extends ChangeNotifier {
  static final AuthController instance = AuthController._();
  AuthController._() {
    _initDemoUsers();
  }

  final ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  final List<CivilianUser> _registeredCivilians = [];
  final List<CompanyUser> _registeredCompanies = [];

  List<CivilianUser> get demoCivilians => List.unmodifiable(_registeredCivilians);
  List<CompanyUser> get demoCompanies => List.unmodifiable(_registeredCompanies);

  void _initDemoUsers() {
    final c1 = CivilianUser(
      id: 'civ_1',
      firstName: 'Ahmet',
      lastName: 'Yılmaz',
      tcIdentityNumber: '10000000146',
      phoneNumber: '+90 532 111 22 33',
      address: const AddressModel(
        country: 'Türkiye',
        city: 'İstanbul',
        district: 'Beşiktaş',
        fullAddress: 'Levazım Mah. Koru Cad. No: 14/B',
        latitude: 41.0667,
        longitude: 29.0167,
      ),
      vehicleIds: ['v_land_1'],
      email: 'ahmet.yilmaz@email.com',
    );

    final c2 = CivilianUser(
      id: 'civ_2',
      firstName: 'Mehmet',
      lastName: 'Demir',
      tcIdentityNumber: '10000000224',
      phoneNumber: '+90 542 333 44 55',
      address: const AddressModel(
        country: 'Türkiye',
        city: 'Muğla',
        district: 'Bodrum',
        fullAddress: 'Yalıkavak Marina Yolu No: 8',
        latitude: 37.1067,
        longitude: 27.2917,
      ),
      vehicleIds: ['v_sea_1'],
      email: 'mehmet.demir@email.com',
    );

    final comp1 = CompanyUser(
      id: 'comp_1',
      companyName: 'SkyJet Havacılık',
      branchName: 'İstanbul Atatürk HL Genel Havacılık Şb.',
      branchAddress: const AddressModel(
        country: 'Türkiye',
        city: 'İstanbul',
        district: 'Bakırköy',
        fullAddress: 'Atatürk Havalimanı Genel Havacılık Terminali Hangar 4',
        latitude: 40.9769,
        longitude: 28.8146,
      ),
      contactPhone: '+90 212 465 00 00',
      vehicleIds: ['v_air_1', 'v_air_2'],
      email: 'operasyon@skyjet.com.tr',
    );

    final comp2 = CompanyUser(
      id: 'comp_2',
      companyName: 'DenizYat Filo A.Ş.',
      branchName: 'Göcek Marina Merkez Şb.',
      branchAddress: const AddressModel(
        country: 'Türkiye',
        city: 'Muğla',
        district: 'Fethiye',
        fullAddress: 'Göcek D-Marin Rıhtım D Blok No: 12',
        latitude: 36.7533,
        longitude: 28.9417,
      ),
      contactPhone: '+90 252 645 22 11',
      vehicleIds: ['v_sea_2'],
      email: 'info@denizyat.com.tr',
    );

    final comp3 = CompanyUser(
      id: 'comp_3',
      companyName: 'Veloce Luxury Motors',
      branchName: 'İzmir Alsancak VIP Şb.',
      branchAddress: const AddressModel(
        country: 'Türkiye',
        city: 'İzmir',
        district: 'Konak',
        fullAddress: 'Alsancak Kordon Boyu No: 104',
        latitude: 38.4333,
        longitude: 27.1417,
      ),
      contactPhone: '+90 232 464 88 99',
      vehicleIds: ['v_land_2', 'v_land_3'],
      email: 'izmir@velocemotors.com',
    );

    _registeredCivilians.addAll([c1, c2]);
    _registeredCompanies.addAll([comp1, comp2, comp3]);

    // Default to Ahmet Yılmaz (Civilian) for instant experience
    currentUser.value = AppUser.civilian(c1);
  }

  void loginCivilian({required String tcOrPhone, required String password}) {
    isLoading.value = true;
    errorMessage.value = null;

    final cleanInput = tcOrPhone.replaceAll(RegExp(r'\D'), '');
    final match = _registeredCivilians.firstWhere(
      (u) =>
          u.tcIdentityNumber == cleanInput ||
          u.phoneNumber.replaceAll(RegExp(r'\D'), '').contains(cleanInput),
      orElse: () => _registeredCivilians.first,
    );

    currentUser.value = AppUser.civilian(match);
    isLoading.value = false;
    notifyListeners();
  }

  void loginCompany({required String companyOrBranchCode, required String password}) {
    isLoading.value = true;
    errorMessage.value = null;

    final lower = companyOrBranchCode.toLowerCase().trim();
    final match = _registeredCompanies.firstWhere(
      (c) =>
          c.companyName.toLowerCase().contains(lower) ||
          c.branchName.toLowerCase().contains(lower) ||
          c.email.toLowerCase().contains(lower),
      orElse: () => _registeredCompanies.first,
    );

    currentUser.value = AppUser.company(match);
    isLoading.value = false;
    notifyListeners();
  }

  void registerCivilian({
    required String firstName,
    required String lastName,
    required String tcNumber,
    required String phoneNumber,
    required AddressModel address,
    String email = '',
  }) {
    final newUser = CivilianUser(
      id: 'civ_${DateTime.now().millisecondsSinceEpoch}',
      firstName: firstName,
      lastName: lastName,
      tcIdentityNumber: tcNumber,
      phoneNumber: phoneNumber,
      address: address,
      email: email,
    );

    _registeredCivilians.add(newUser);
    currentUser.value = AppUser.civilian(newUser);
    notifyListeners();
  }

  void registerCompany({
    required String companyName,
    required String branchName,
    required AddressModel branchAddress,
    required String contactPhone,
    String email = '',
  }) {
    final newComp = CompanyUser(
      id: 'comp_${DateTime.now().millisecondsSinceEpoch}',
      companyName: companyName,
      branchName: branchName,
      branchAddress: branchAddress,
      contactPhone: contactPhone,
      email: email,
    );

    _registeredCompanies.add(newComp);
    currentUser.value = AppUser.company(newComp);
    notifyListeners();
  }

  void switchToUser(AppUser user) {
    currentUser.value = user;
    notifyListeners();
  }

  void logout() {
    currentUser.value = null;
    notifyListeners();
  }

  @override
  void dispose() {
    currentUser.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    super.dispose();
  }
}
