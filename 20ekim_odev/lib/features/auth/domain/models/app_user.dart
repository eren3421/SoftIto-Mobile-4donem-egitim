import 'civilian_user.dart';
import 'company_user.dart';
import 'user_role.dart';

/// AppUser represents the unified active session for civilian or company users.
class AppUser {
  final UserRole role;
  final CivilianUser? civilian;
  final CompanyUser? company;

  const AppUser.civilian(CivilianUser user)
      : role = UserRole.civilian,
        civilian = user,
        company = null;

  const AppUser.company(CompanyUser user)
      : role = UserRole.company,
        civilian = null,
        company = user;

  String get id => role == UserRole.civilian ? civilian!.id : company!.id;
  String get displayName => role == UserRole.civilian ? civilian!.fullName : company!.displayName;
  String get contactPhone => role == UserRole.civilian ? civilian!.phoneNumber : company!.contactPhone;
  String get addressSummary => role == UserRole.civilian ? civilian!.address.summary : company!.branchAddress.summary;
  List<String> get vehicleIds => role == UserRole.civilian ? civilian!.vehicleIds : company!.vehicleIds;

  bool get isCivilian => role == UserRole.civilian;
  bool get isCompany => role == UserRole.company;

  /// Business Rule: Only civilians can rent vehicles!
  bool get canRent => isCivilian;

  /// Business Rule: Both civilians and companies can lease/rent out vehicles!
  bool get canLend => true;
}
