/// 02_veri_depolama_ve_sema.md Bölüm 2.2 `vehicles` şemasına uygun Domain Entity.
class VehicleEntity {
  final String id;
  final String ownerId;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final int totalSeats;
  final bool isVerified;
  final DateTime createdAt;

  const VehicleEntity({
    required this.id,
    required this.ownerId,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    this.totalSeats = 4,
    this.isVerified = true,
    required this.createdAt,
  });

  String get brandModel => '$brand $model';

  VehicleEntity copyWith({
    String? id,
    String? ownerId,
    String? brand,
    String? model,
    int? year,
    String? color,
    String? licensePlate,
    int? totalSeats,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return VehicleEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      totalSeats: totalSeats ?? this.totalSeats,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

