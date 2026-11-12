/// 02_veri_depolama_ve_sema.md Bölüm 2.6 `reviews` şemasına uygun Domain Entity.
class ReviewEntity {
  final String id;
  final String rideId;
  final String reviewerId;
  final String reviewerName;
  final String revieweeId;
  final int rating; // 1 - 5
  final String comment;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.rideId,
    required this.reviewerId,
    this.reviewerName = 'Kullanıcı',
    required this.revieweeId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  ReviewEntity copyWith({
    String? id,
    String? rideId,
    String? reviewerId,
    String? reviewerName,
    String? revieweeId,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      revieweeId: revieweeId ?? this.revieweeId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

