/// Örnek İmmutable Model Sınıfı (Susadım Standartı)
class SampleActivityModel {
  final String id;
  final String title;
  final int value;
  final DateTime timestamp;

  const SampleActivityModel({
    required this.id,
    required this.title,
    required this.value,
    required this.timestamp,
  });

  SampleActivityModel copyWith({
    String? id,
    String? title,
    int? value,
    DateTime? timestamp,
  }) {
    return SampleActivityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'value': value,
    'timestamp': timestamp.toIso8601String(),
  };

  factory SampleActivityModel.fromJson(Map<String, dynamic> json) =>
      SampleActivityModel(
        id: json['id'] as String,
        title: json['title'] as String,
        value: json['value'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
