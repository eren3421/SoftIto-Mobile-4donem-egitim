class Greenhouse {
  final String id;
  final String userId;
  final String name;
  final String photoUrl;
  final String icon;
  final DateTime createdAt;

  Greenhouse({
    required this.id,
    required this.userId,
    required this.name,
    this.photoUrl = '',
    this.icon = '🏡',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'photoUrl': photoUrl,
        'icon': icon,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Greenhouse.fromJson(Map<String, dynamic> json) {
    return Greenhouse(
      id: json['id'] ?? '',
      userId: json['userId'] ?? 'user_default',
      name: json['name'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      icon: json['icon'] ?? '🏡',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Greenhouse copyWith({
    String? name,
    String? photoUrl,
    String? icon,
  }) {
    return Greenhouse(
      id: id,
      userId: userId,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      icon: icon ?? this.icon,
      createdAt: createdAt,
    );
  }
}
