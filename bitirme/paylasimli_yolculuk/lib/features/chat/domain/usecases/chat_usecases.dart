import '../../../../core/errors/failures.dart';
import '../entities/chat_entity.dart';
import '../entities/review_entity.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final IChatRepository _repository;
  const SendMessageUseCase(this._repository);

  Future<Result<MessageEntity>> call({
    required String chatId,
    required String senderId,
    required String text,
    String type = 'text',
    double? lat,
    double? lng,
    String? locationName,
    bool isLiveLocation = false,
  }) {
    if (text.trim().isEmpty) {
      return Future.value(
        Result.failure(const ValidationFailure('Mesaj metni boş olamaz.')),
      );
    }
    return _repository.sendMessage(
      chatId: chatId,
      senderId: senderId,
      text: text.trim(),
      type: type,
      lat: lat,
      lng: lng,
      locationName: locationName,
      isLiveLocation: isLiveLocation,
    );
  }
}

class SubmitReviewUseCase {
  final IChatRepository _repository;
  const SubmitReviewUseCase(this._repository);

  Future<Result<ReviewEntity>> call(ReviewEntity review) {
    if (review.rating < 1 || review.rating > 5) {
      return Future.value(
        Result.failure(
          const ValidationFailure('Puan 1 ile 5 yıldız arasında olmalıdır.'),
        ),
      );
    }
    return _repository.submitReview(review);
  }
}
