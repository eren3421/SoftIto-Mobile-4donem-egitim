/// Günlük kaydı veri modeli.
/// project.md ve SKILL.md kurallarına uygun olarak değişmez (immutable) yapıda tasarlanmıştır.
class DiaryEntryModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String mood;
  final bool isFavorite;

  const DiaryEntryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.mood,
    this.isFavorite = false,
  });

  DiaryEntryModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    String? mood,
    bool? isFavorite,
  }) {
    return DiaryEntryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      mood: mood ?? this.mood,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory DiaryEntryModel.fromJson(Map<String, dynamic> json) {
    return DiaryEntryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      mood: json['mood'] as String? ?? 'Huzurlu',
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'mood': mood,
      'is_favorite': isFavorite,
    };
  }
}
