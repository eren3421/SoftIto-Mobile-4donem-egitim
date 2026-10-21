class LocalizedText {
  final String tr;
  final String en;

  const LocalizedText({required this.tr, required this.en});

  String get(String lang) => lang == 'en' ? en : tr;

  Map<String, dynamic> toJson() => {'tr': tr, 'en': en};

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(
      tr: json['tr'] ?? '',
      en: json['en'] ?? '',
    );
  }
}

class PlantSpecies {
  final String speciesId;
  final LocalizedText name;
  final String scientificName;
  final LocalizedText category;
  final int wateringIntervalDays;
  final int wateringAmountMl;
  final LocalizedText wateringTip;
  final int fertilizingIntervalDays;
  final LocalizedText fertilizingTip;
  final int pruningIntervalDays;
  final LocalizedText pruningTip;
  final String sunlightHours;
  final LocalizedText sunlightType;
  final String idealTempRange;
  final String idealHumidity;
  final int expectedHarvestDays;
  final String icon;

  const PlantSpecies({
    required this.speciesId,
    required this.name,
    required this.scientificName,
    required this.category,
    required this.wateringIntervalDays,
    required this.wateringAmountMl,
    required this.wateringTip,
    required this.fertilizingIntervalDays,
    required this.fertilizingTip,
    required this.pruningIntervalDays,
    required this.pruningTip,
    required this.sunlightHours,
    required this.sunlightType,
    required this.idealTempRange,
    required this.idealHumidity,
    required this.expectedHarvestDays,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
        'speciesId': speciesId,
        'name': name.toJson(),
        'scientificName': scientificName,
        'category': category.toJson(),
        'wateringIntervalDays': wateringIntervalDays,
        'wateringAmountMl': wateringAmountMl,
        'wateringTip': wateringTip.toJson(),
        'fertilizingIntervalDays': fertilizingIntervalDays,
        'fertilizingTip': fertilizingTip.toJson(),
        'pruningIntervalDays': pruningIntervalDays,
        'pruningTip': pruningTip.toJson(),
        'sunlightHours': sunlightHours,
        'sunlightType': sunlightType.toJson(),
        'idealTempRange': idealTempRange,
        'idealHumidity': idealHumidity,
        'expectedHarvestDays': expectedHarvestDays,
        'icon': icon,
      };

  factory PlantSpecies.fromJson(Map<String, dynamic> json) {
    return PlantSpecies(
      speciesId: json['speciesId'] ?? '',
      name: LocalizedText.fromJson(Map<String, dynamic>.from(json['name'] ?? {})),
      scientificName: json['scientificName'] ?? '',
      category: LocalizedText.fromJson(Map<String, dynamic>.from(json['category'] ?? {})),
      wateringIntervalDays: json['wateringIntervalDays'] ?? 3,
      wateringAmountMl: json['wateringAmountMl'] ?? 300,
      wateringTip: LocalizedText.fromJson(Map<String, dynamic>.from(json['wateringTip'] ?? {})),
      fertilizingIntervalDays: json['fertilizingIntervalDays'] ?? 14,
      fertilizingTip: LocalizedText.fromJson(Map<String, dynamic>.from(json['fertilizingTip'] ?? {})),
      pruningIntervalDays: json['pruningIntervalDays'] ?? 21,
      pruningTip: LocalizedText.fromJson(Map<String, dynamic>.from(json['pruningTip'] ?? {})),
      sunlightHours: json['sunlightHours'] ?? '6 Saat',
      sunlightType: LocalizedText.fromJson(Map<String, dynamic>.from(json['sunlightType'] ?? {})),
      idealTempRange: json['idealTempRange'] ?? '18°C - 25°C',
      idealHumidity: json['idealHumidity'] ?? '%50 - %70',
      expectedHarvestDays: json['expectedHarvestDays'] ?? 60,
      icon: json['icon'] ?? '🌱',
    );
  }
}
