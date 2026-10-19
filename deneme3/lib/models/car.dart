class Car {
  const Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    required this.mileage,
    required this.fuel,
    required this.transmission,
    required this.bodyType,
    required this.color,
    required this.imageUrl,
    required this.description,
    this.badge,
  });

  final String id;
  final String brand;
  final String model;
  final int year;
  final double price;
  final int mileage;
  final String fuel;
  final String transmission;
  final String bodyType;
  final String color;
  final String imageUrl;
  final String description;
  final String? badge;

  String get title => '$brand $model';
}

String formatTry(double amount) {
  final digits = amount.round().toString();
  final grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '₺$grouped';
}

String formatKilometers(int kilometers) {
  final digits = kilometers.toString();
  return '${digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')} km';
}
