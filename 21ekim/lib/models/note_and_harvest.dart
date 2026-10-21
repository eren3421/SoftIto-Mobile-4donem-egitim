class NoteAndHarvest {
  final String id;
  final String greenhouseId;
  final String? plantId;
  final String type; // 'note', 'harvest', 'treatment'
  final String title;
  final String content;
  final int? harvestAmountGrams;
  final int? qualityRating; // 1 to 5
  final DateTime createdAt;

  NoteAndHarvest({
    required this.id,
    required this.greenhouseId,
    this.plantId,
    required this.type,
    required this.title,
    required this.content,
    this.harvestAmountGrams,
    this.qualityRating,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'greenhouseId': greenhouseId,
        'plantId': plantId,
        'type': type,
        'title': title,
        'content': content,
        'harvestAmountGrams': harvestAmountGrams,
        'qualityRating': qualityRating,
        'createdAt': createdAt.toIso8601String(),
      };

  factory NoteAndHarvest.fromJson(Map<String, dynamic> json) {
    return NoteAndHarvest(
      id: json['id'] ?? '',
      greenhouseId: json['greenhouseId'] ?? '',
      plantId: json['plantId'],
      type: json['type'] ?? 'note',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      harvestAmountGrams: json['harvestAmountGrams'],
      qualityRating: json['qualityRating'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
