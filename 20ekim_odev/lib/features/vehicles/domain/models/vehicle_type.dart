enum VehicleCategory {
  land, // Kara Taşıtı (Otomobil, SUV, Karavan, VIP Minibüs)
  air,  // Hava Taşıtı (Helikopter, Özel Jet, Deniz Uçağı)
  sea;  // Deniz Taşıtı (Motoryat, Katamaran, Gulet, Sürat Teknesi)

  String get displayName {
    switch (this) {
      case VehicleCategory.land:
        return 'Kara';
      case VehicleCategory.air:
        return 'Hava';
      case VehicleCategory.sea:
        return 'Deniz';
    }
  }

  String get fullTitle {
    switch (this) {
      case VehicleCategory.land:
        return 'Kara Taşıtları';
      case VehicleCategory.air:
        return 'Hava Taşıtları';
      case VehicleCategory.sea:
        return 'Deniz Taşıtları';
    }
  }
}
