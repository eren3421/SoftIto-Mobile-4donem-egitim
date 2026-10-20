/// Girişimcinin not, rapor ve fikir kayıtlarını temsil eden değişmez (immutable) model.
class NotModel {
  final String id;
  final String? projectId;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;
  final bool isFavorite;
  final bool isPinned;

  const NotModel({
    required this.id,
    this.projectId,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    this.isFavorite = false,
    this.isPinned = false,
  });

  NotModel copyWith({
    String? id,
    String? projectId,
    String? title,
    String? content,
    String? category,
    DateTime? createdAt,
    bool? isFavorite,
    bool? isPinned,
  }) {
    return NotModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  factory NotModel.fromJson(Map<String, dynamic> json) {
    return NotModel(
      id: json['id'] as String? ?? '',
      projectId: json['project_id'] as String?,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      category: json['category'] as String? ?? 'Genel',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      isFavorite: json['is_favorite'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'content': content,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'is_favorite': isFavorite,
      'is_pinned': isPinned,
    };
  }
}
