import 'address_model.dart';
import 'user_role.dart';

/// Kurumsal Firma: Şube bazlı kayıt olur ve sadece araç kiraya verebilir.
class CompanyUser {
  final String id;
  final String companyName;          // Firma Adı
  final String branchName;           // Şube Adı / Kodu
  final AddressModel branchAddress;  // Şubenin Adresi (Ülke, Şehir, Açık Adres)
  final String contactPhone;         // Şube İletişim Numarası
  final List<String> vehicleIds;     // Şubenin kiraya verdiği araçların ID listesi
  final String email;

  String get displayName => '$companyName - $branchName';
  UserRole get role => UserRole.company;

  const CompanyUser({
    required this.id,
    required this.companyName,
    required this.branchName,
    required this.branchAddress,
    required this.contactPhone,
    this.vehicleIds = const [],
    this.email = '',
  });

  CompanyUser copyWith({
    String? id,
    String? companyName,
    String? branchName,
    AddressModel? branchAddress,
    String? contactPhone,
    List<String>? vehicleIds,
    String? email,
  }) {
    return CompanyUser(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      branchName: branchName ?? this.branchName,
      branchAddress: branchAddress ?? this.branchAddress,
      contactPhone: contactPhone ?? this.contactPhone,
      vehicleIds: vehicleIds ?? this.vehicleIds,
      email: email ?? this.email,
    );
  }

  factory CompanyUser.fromJson(Map<String, dynamic> json) {
    return CompanyUser(
      id: json['id'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      branchName: json['branchName'] as String? ?? '',
      branchAddress: AddressModel.fromJson(json['branchAddress'] as Map<String, dynamic>? ?? {}),
      contactPhone: json['contactPhone'] as String? ?? '',
      vehicleIds: (json['vehicleIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'branchName': branchName,
      'branchAddress': branchAddress.toJson(),
      'contactPhone': contactPhone,
      'vehicleIds': vehicleIds,
      'email': email,
    };
  }
}
