import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/seed_data_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/chat_usecases.dart';

final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  return ChatRepositoryImpl(
    localCacheService: ref.watch(localCacheServiceProvider),
    seedService: ref.watch(seedDataServiceProvider),
    isOffline: ref.watch(isOfflineModeProvider),
    useMockData: ref.watch(useMockDataProvider),
  );
});

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.watch(chatRepositoryProvider));
});

final submitReviewUseCaseProvider = Provider<SubmitReviewUseCase>((ref) {
  return SubmitReviewUseCase(ref.watch(chatRepositoryProvider));
});

/// Kullanıcının sohbet odalarını, okunmamış mesaj bildirimlerini ve canlı konum mesajlarını yöneten AsyncNotifier.
class ChatsNotifier extends AsyncNotifier<List<ChatEntity>> {
  @override
  Future<List<ChatEntity>> build() async {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    if (user == null) return [];
    final repo = ref.watch(chatRepositoryProvider);
    final res = await repo.getUserChats(user.id);
    return res.fold((_) => [], (chats) => chats);
  }

  Future<ChatEntity?> openOrCreateChat({
    required String rideId,
    required String driverId,
    required String driverName,
    required String passengerId,
    required String passengerName,
    required String rideSummaryTitle,
  }) async {
    final repo = ref.read(chatRepositoryProvider);
    final res = await repo.getOrCreateChat(
      rideId: rideId,
      driverId: driverId,
      driverName: driverName,
      passengerId: passengerId,
      passengerName: passengerName,
      rideSummaryTitle: rideSummaryTitle,
    );
    return res.fold((_) => null, (chat) {
      ref.invalidateSelf();
      return chat;
    });
  }

  Future<MessageEntity?> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String type = 'text',
    double? lat,
    double? lng,
    String? locationName,
    bool isLiveLocation = false,
  }) async {
    final useCase = ref.read(sendMessageUseCaseProvider);
    final res = await useCase(
      chatId: chatId,
      senderId: senderId,
      text: text,
      type: type,
      lat: lat,
      lng: lng,
      locationName: locationName,
      isLiveLocation: isLiveLocation,
    );
    return res.fold((_) => null, (msg) {
      ref.invalidateSelf();
      ref.invalidate(chatMessagesProvider(chatId));
      return msg;
    });
  }

  Future<void> updateLiveLocationMessage({
    required String chatId,
    required String messageId,
    required double lat,
    required double lng,
    required String locationName,
    required bool isLiveLocation,
  }) async {
    final repo = ref.read(chatRepositoryProvider);
    await repo.updateLiveLocationMessage(
      chatId: chatId,
      messageId: messageId,
      lat: lat,
      lng: lng,
      locationName: locationName,
      isLiveLocation: isLiveLocation,
    );
    ref.invalidateSelf();
    ref.invalidate(chatMessagesProvider(chatId));
  }

  Future<void> markChatAsRead(String chatId) async {
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;
    final repo = ref.read(chatRepositoryProvider);
    await repo.markChatAsRead(chatId: chatId, userId: user.id);
    ref.invalidateSelf();
    ref.invalidate(chatMessagesProvider(chatId));
  }

  Future<bool> submitReview(ReviewEntity review) async {
    final useCase = ref.read(submitReviewUseCaseProvider);
    final res = await useCase(review);
    return res.fold((_) => false, (_) {
      ref.invalidate(userReviewsProvider(review.revieweeId));
      return true;
    });
  }
}

final chatsNotifierProvider =
    AsyncNotifierProvider<ChatsNotifier, List<ChatEntity>>(ChatsNotifier.new);

/// Aktif kullanıcının tüm sohbetlerdeki toplam okunmamış mesaj sayısını (1, 2, 3...) hesaplar.
final totalUnreadMessagesCountProvider = Provider<int>((ref) {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  if (user == null) return 0;
  final chats = ref.watch(chatsNotifierProvider).valueOrNull ?? [];
  int total = 0;
  for (final chat in chats) {
    total += chat.unreadCountFor(user.id);
  }
  return total;
});

/// Belirli bir kullanıcı ID'si için bekleyen toplam okunmamış mesaj sayısını döner (Hesap değiştirici menü için).
final unreadCountForUserProvider = Provider.family<int, String>((ref, userId) {
  ref.watch(chatsNotifierProvider);
  final seed = ref.watch(seedDataServiceProvider);
  int total = 0;
  for (final chat in seed.chats) {
    if (chat.participantIds.contains(userId)) {
      total += chat.unreadCountFor(userId);
    }
  }
  return total;
});

final chatMessagesProvider =
    FutureProvider.family<List<MessageEntity>, String>((ref, chatId) async {
  final repo = ref.watch(chatRepositoryProvider);
  final res = await repo.getMessages(chatId);
  return res.fold((_) => [], (msgs) => msgs);
});

final userReviewsProvider =
    FutureProvider.family<List<ReviewEntity>, String>((ref, userId) async {
  final repo = ref.watch(chatRepositoryProvider);
  final res = await repo.getReviewsForUser(userId);
  return res.fold((_) => [], (reviews) => reviews);
});
