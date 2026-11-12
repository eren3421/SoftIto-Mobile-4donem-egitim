/// Kullanıcının yolculuk tercihlerini temsil eden Pure Dart varlığı.
class UserPreferences {
  final bool smokingAllowed;
  final bool petsAllowed;
  final String musicPreference;
  final String chatLevel;

  const UserPreferences({
    this.smokingAllowed = false,
    this.petsAllowed = false,
    this.musicPreference = 'Farketmez',
    this.chatLevel = 'moderate',
  });

  UserPreferences copyWith({
    bool? smokingAllowed,
    bool? petsAllowed,
    String? musicPreference,
    String? chatLevel,
  }) {
    return UserPreferences(
      smokingAllowed: smokingAllowed ?? this.smokingAllowed,
      petsAllowed: petsAllowed ?? this.petsAllowed,
      musicPreference: musicPreference ?? this.musicPreference,
      chatLevel: chatLevel ?? this.chatLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'smokingAllowed': smokingAllowed,
      'petsAllowed': petsAllowed,
      'musicPreference': musicPreference,
      'chatLevel': chatLevel,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserPreferences();
    return UserPreferences(
      smokingAllowed: json['smokingAllowed'] as bool? ?? false,
      petsAllowed: json['petsAllowed'] as bool? ?? false,
      musicPreference: json['musicPreference'] as String? ?? 'Farketmez',
      chatLevel: json['chatLevel'] as String? ?? 'moderate',
    );
  }
}

/// 02_veri_depolama_ve_sema.md Bölüm 2.1 `users` şemasına uygun Domain Entity.
class UserEntity {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String avatarUrl;
  final String bio;
  final String role; // 'passenger', 'driver', 'both'
  final bool isVerified;
  final double ratingAvg;
  final int ratingCount;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.avatarUrl = '',
    this.bio = '',
    this.role = 'both',
    this.isVerified = true,
    this.ratingAvg = 0.0,
    this.ratingCount = 0,
    this.preferences = const UserPreferences(),
    required this.createdAt,
    required this.updatedAt,
  });

  /// Her kullanıcı bir yolculukta sürücü veya başka bir yolculukta yolcu olabilir.
  bool get canDrive => true;

  /// Her kullanıcı başka bir kullanıcının ilanına yolcu olarak rezervasyon yapabilir.
  bool get canBook => true;

  /// Kullanıcı unvanı.
  String get roleLabel => 'Üye';

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? bio,
    String? role,
    bool? isVerified,
    double? ratingAvg,
    int? ratingCount,
    UserPreferences? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

