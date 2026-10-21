class Plant {
  final String id;
  final String greenhouseId;
  final String speciesId;
  final String customName;
  final DateTime plantedAt;
  DateTime lastWateredAt;
  DateTime lastFertilizedAt;
  DateTime lastPrunedAt;
  final String locationNote;
  final int? customWateringDays;
  final int? customFertilizingDays;
  final int? customPruningDays;
  final int? customHarvestDays;
  final DateTime createdAt;

  Plant({
    required this.id,
    required this.greenhouseId,
    required this.speciesId,
    required this.customName,
    required this.plantedAt,
    required this.lastWateredAt,
    required this.lastFertilizedAt,
    required this.lastPrunedAt,
    this.locationNote = '',
    this.customWateringDays,
    this.customFertilizingDays,
    this.customPruningDays,
    this.customHarvestDays,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'greenhouseId': greenhouseId,
        'speciesId': speciesId,
        'customName': customName,
        'plantedAt': plantedAt.toIso8601String(),
        'lastWateredAt': lastWateredAt.toIso8601String(),
        'lastFertilizedAt': lastFertilizedAt.toIso8601String(),
        'lastPrunedAt': lastPrunedAt.toIso8601String(),
        'locationNote': locationNote,
        'customWateringDays': customWateringDays,
        'customFertilizingDays': customFertilizingDays,
        'customPruningDays': customPruningDays,
        'customHarvestDays': customHarvestDays,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] ?? '',
      greenhouseId: json['greenhouseId'] ?? '',
      speciesId: json['speciesId'] ?? '',
      customName: json['customName'] ?? '',
      plantedAt: json['plantedAt'] != null
          ? DateTime.tryParse(json['plantedAt']) ?? DateTime.now()
          : DateTime.now(),
      lastWateredAt: json['lastWateredAt'] != null
          ? DateTime.tryParse(json['lastWateredAt']) ?? DateTime.now()
          : DateTime.now(),
      lastFertilizedAt: json['lastFertilizedAt'] != null
          ? DateTime.tryParse(json['lastFertilizedAt']) ?? DateTime.now()
          : DateTime.now(),
      lastPrunedAt: json['lastPrunedAt'] != null
          ? DateTime.tryParse(json['lastPrunedAt']) ?? DateTime.now()
          : DateTime.now(),
      locationNote: json['locationNote'] ?? '',
      customWateringDays: json['customWateringDays'],
      customFertilizingDays: json['customFertilizingDays'],
      customPruningDays: json['customPruningDays'],
      customHarvestDays: json['customHarvestDays'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Plant copyWith({
    String? customName,
    DateTime? plantedAt,
    DateTime? lastWateredAt,
    DateTime? lastFertilizedAt,
    DateTime? lastPrunedAt,
    String? locationNote,
    int? customWateringDays,
    int? customFertilizingDays,
    int? customPruningDays,
    int? customHarvestDays,
  }) {
    return Plant(
      id: id,
      greenhouseId: greenhouseId,
      speciesId: speciesId,
      customName: customName ?? this.customName,
      plantedAt: plantedAt ?? this.plantedAt,
      lastWateredAt: lastWateredAt ?? this.lastWateredAt,
      lastFertilizedAt: lastFertilizedAt ?? this.lastFertilizedAt,
      lastPrunedAt: lastPrunedAt ?? this.lastPrunedAt,
      locationNote: locationNote ?? this.locationNote,
      customWateringDays: customWateringDays ?? this.customWateringDays,
      customFertilizingDays:
          customFertilizingDays ?? this.customFertilizingDays,
      customPruningDays: customPruningDays ?? this.customPruningDays,
      customHarvestDays: customHarvestDays ?? this.customHarvestDays,
      createdAt: createdAt,
    );
  }
}
