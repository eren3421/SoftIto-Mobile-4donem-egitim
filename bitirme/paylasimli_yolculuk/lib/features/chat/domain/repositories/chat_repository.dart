import '../../../../core/errors/failures.dart';
import '../entities/chat_entity.dart';
import '../entities/review_entity.dart';

/// Uygulama içi sohbet, gerçek zamanlı konum paylaşımı ve değerlendirme (Review) soyut sözleşmesi (FR-06, FR-08).
abstract class IChatRepository {
  Future<Result<List<ChatEntity>>> getUserChats(String userId);
  Future<Result<List<MessageEntity>>> getMessages(String chatId);
  Future<Result<MessageEntity>> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String type = 'text',
    double? lat,
    double? lng,
    String? locationName,
    bool isLiveLocation = false,
  });
  Future<Result<MessageEntity>> updateLiveLocationMessage({
    required String chatId,
    required String messageId,
    required double lat,
    required double lng,
    required String locationName,
    required bool isLiveLocation,
  });
  Future<Result<void>> markChatAsRead({
    required String chatId,
    required String userId,
  });
  Future<Result<ChatEntity>> getOrCreateChat({
    required String rideId,
    required String driverId,
    required String driverName,
    required String passengerId,
    required String passengerName,
    required String rideSummaryTitle,
  });

  // Değerlendirme ve puanlama (Reviews)
  Future<Result<ReviewEntity>> submitReview(ReviewEntity review);
  Future<Result<List<ReviewEntity>>> getReviewsForUser(String userId);
}
