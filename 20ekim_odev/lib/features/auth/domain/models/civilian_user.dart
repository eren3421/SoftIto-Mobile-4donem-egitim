import 'address_model.dart';
import 'user_role.dart';

/// Sivil Kullanıcı: Hem araç kiraya verebilir hem de araç kiralayabilir.
class CivilianUser {
  final String id;
  final String firstName;          // Ad
  final String lastName;           // Soyad
  final String tcIdentityNumber;   // 11 Haneli T.C. Kimlik Numarası
  final String phoneNumber;        // İletişim Numarası
  final AddressModel address;      // Adres (Ülke, Şehir, İlçe, Açık Adres)
  final List<String> vehicleIds;   // Sahip olduğu araçların ID listesi
  final String email;

  String get fullName => '$firstName $lastName';
  UserRole get role => UserRole.civilian;

  const CivilianUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.tcIdentityNumber,
    required this.phoneNumber,
    required this.address,
    this.vehicleIds = const [],
    this.email = '',
  });

  CivilianUser copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? tcIdentityNumber,
    String? phoneNumber,
    AddressModel? address,
    List<String>? vehicleIds,
    String? email,
  }) {
    return CivilianUser(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      tcIdentityNumber: tcIdentityNumber ?? this.tcIdentityNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      vehicleIds: vehicleIds ?? this.vehicleIds,
      email: email ?? this.email,
    );
  }

  factory CivilianUser.fromJson(Map<String, dynamic> json) {
    return CivilianUser(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      tcIdentityNumber: json['tcIdentityNumber'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      address: AddressModel.fromJson(json['address'] as Map<String, dynamic>? ?? {}),
      vehicleIds: (json['vehicleIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'tcIdentityNumber': tcIdentityNumber,
      'phoneNumber': phoneNumber,
      'address': address.toJson(),
      'vehicleIds': vehicleIds,
      'email': email,
    };
  }
}
