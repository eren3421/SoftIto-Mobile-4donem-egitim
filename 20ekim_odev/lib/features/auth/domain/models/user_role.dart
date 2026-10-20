enum UserRole {
  civilian, // Sivil Kullanıcı (Bireysel)
  company;  // Kurumsal Firma (Şube Bazlı)

  String get displayName {
    switch (this) {
      case UserRole.civilian:
        return 'Sivil Kullanıcı';
      case UserRole.company:
        return 'Kurumsal Firma';
    }
  }

  bool get isCivilian => this == UserRole.civilian;
  bool get isCompany => this == UserRole.company;
}
