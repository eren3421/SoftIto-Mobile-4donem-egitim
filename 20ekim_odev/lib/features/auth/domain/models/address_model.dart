class AddressModel {
  final String country;      // Ülke (Örn: Türkiye)
  final String city;         // Şehir (Örn: İstanbul)
  final String district;     // İlçe (Örn: Beşiktaş)
  final String fullAddress;  // Açık Adres
  final double? latitude;
  final double? longitude;

  const AddressModel({
    required this.country,
    required this.city,
    required this.district,
    required this.fullAddress,
    this.latitude,
    this.longitude,
  });

  String get summary => '$district, $city / $country';
  String get shortCityCountry => '$city, $country';

  AddressModel copyWith({
    String? country,
    String? city,
    String? district,
    String? fullAddress,
    double? latitude,
    double? longitude,
  }) {
    return AddressModel(
      country: country ?? this.country,
      city: city ?? this.city,
      district: district ?? this.district,
      fullAddress: fullAddress ?? this.fullAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      country: json['country'] as String? ?? 'Türkiye',
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      fullAddress: json['fullAddress'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'city': city,
      'district': district,
      'fullAddress': fullAddress,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}
