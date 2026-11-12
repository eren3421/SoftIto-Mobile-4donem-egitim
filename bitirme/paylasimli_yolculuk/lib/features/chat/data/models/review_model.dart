import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review_entity.dart';

/// `reviews` koleksiyonu ve yerel Hive önbelleği için JSON/Map ve Firestore `Timestamp` dönüşüm modeli.
class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.rideId,
    required super.reviewerId,
    super.reviewerName,
    required super.revieweeId,
    required super.rating,
    required super.comment,
    required super.createdAt,
  });

  factory ReviewModel.fromEntity(ReviewEntity entity) {
    return ReviewModel(
      id: entity.id,
      rideId: entity.rideId,
      reviewerId: entity.reviewerId,
      reviewerName: entity.reviewerName,
      revieweeId: entity.revieweeId,
      rating: entity.rating,
      comment: entity.comment,
      createdAt: entity.createdAt,
    );
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String? ?? '',
      rideId: json['rideId'] as String? ?? '',
      reviewerId: (json['reviewerId'] ??
              json['passengerId'] ??
              json['authorId']) as String? ??
          '',
      reviewerName: (json['reviewerName'] ??
              json['passengerName'] ??
              json['authorName'] ??
              json['reviewerEmail'] ??
              'Kullanıcı') as String? ??
          'Kullanıcı',
      revieweeId: (json['revieweeId'] ??
              json['driverId'] ??
              json['targetUserId'] ??
              json['userId']) as String? ??
          '',
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      comment: json['comment'] as String? ?? '',
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rideId': rideId,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'revieweeId': revieweeId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      ...toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
