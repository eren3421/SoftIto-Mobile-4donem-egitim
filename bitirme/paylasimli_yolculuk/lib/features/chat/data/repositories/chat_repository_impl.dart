import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/seed_data_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_model.dart';
import '../models/review_model.dart';

/// Single Source of Truth = Cloud Firestore, Cache = Hive (`LocalCacheService`).
/// Tüm yazma işlemlerinde belge ID'si tek bir kez üretilir, önce FirebaseFirestore üzerine yazılır,
/// hemen ardından aynı ID ile Hive kutusuna kaydedilir.
/// Okuma işlemlerinde internet varken veriler Firestore'dan çekilip Hive üzerine yazılır;
/// internet yokken doğrudan Hive'dan okunur.
class ChatRepositoryImpl implements IChatRepository {
  final LocalCacheService localCacheService;
  final SeedDataService seedService;
  final bool isOffline;
  final bool useMockData;

  ChatRepositoryImpl({
    required this.localCacheService,
    required this.seedService,
    required this.isOffline,
    this.useMockData = false,
  });

  @override
  Future<Result<List<ChatEntity>>> getUserChats(String userId) async {
    try {
      if (isOffline) {
        final cached = localCacheService
            .getCachedChats()
            .map(ChatModel.fromJson)
            .where((c) => c.participantIds.contains(userId))
            .toList();
        return Result.success(cached);
      }

      final snap = await FirebaseFirestore.instance
          .collection('chats')
          .where('participantIds', arrayContains: userId)
          .get();
      final firestoreChats = snap.docs
          .map((d) => ChatModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      firestoreChats.sort(
        (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime),
      );

      // Hive önbelleğinin üzerine yaz
      final otherChats = localCacheService
          .getCachedChats()
          .map(ChatModel.fromJson)
          .where((c) => !c.participantIds.contains(userId))
          .toList();
      await localCacheService.cacheChats(
        [...firestoreChats, ...otherChats].map((c) => c.toJson()).toList(),
      );

      return Result.success(firestoreChats);
    } catch (e) {
      final cached = localCacheService
          .getCachedChats()
          .map(ChatModel.fromJson)
          .where((c) => c.participantIds.contains(userId))
          .toList();
      return Result.success(cached);
    }
  }

  @override
  Future<Result<List<MessageEntity>>> getMessages(String chatId) async {
    try {
      if (isOffline) {
        final cached = localCacheService
            .getCachedMessages(chatId)
            .map(MessageModel.fromJson)
            .toList();
        return Result.success(cached);
      }

      final snap = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('createdAt')
          .get();
      final firestoreMsgs = snap.docs
          .map((d) => MessageModel.fromJson({...d.data(), 'id': d.id}))
          .toList();

      // Hive önbelleğinin üzerine yaz
      await localCacheService.cacheMessages(
        chatId,
        firestoreMsgs.map((m) => m.toJson()).toList(),
      );
      return Result.success(firestoreMsgs);
    } catch (e) {
      final cached = localCacheService
          .getCachedMessages(chatId)
          .map(MessageModel.fromJson)
          .toList();
      return Result.success(cached);
    }
  }

  @override
  Future<Result<MessageEntity>> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String type = 'text',
    double? lat,
    double? lng,
    String? locationName,
    bool isLiveLocation = false,
  }) async {
    try {
      final now = DateTime.now();
      final chatDocRef =
          FirebaseFirestore.instance.collection('chats').doc(chatId);

      // 1. Belge ID'sini tek bir kez üret (Firestore doc().id)
      final msgDocRef = chatDocRef.collection('messages').doc();
      final msg = MessageModel(
        id: msgDocRef.id,
        chatId: chatId,
        senderId: senderId,
        text: text,
        type: type,
        isRead: false,
        createdAt: now,
        lat: lat,
        lng: lng,
        locationName: locationName,
        isLiveLocation: isLiveLocation,
      );

      // Mevcut sohbetin participantIds ve unreadCounts bilgisini al
      Map<String, int> updatedUnread = {};
      List<String> participantIds = [];

      if (!isOffline) {
        final chatSnap = await chatDocRef.get();
        if (chatSnap.exists && chatSnap.data() != null) {
          final currentChat =
              ChatModel.fromJson({...chatSnap.data()!, 'id': chatSnap.id});
          participantIds = currentChat.participantIds;
          updatedUnread = Map<String, int>.from(currentChat.unreadCounts);
        }
      }

      if (participantIds.isEmpty) {
        final cachedChats =
            localCacheService.getCachedChats().map(ChatModel.fromJson);
        final match = cachedChats.where((c) => c.id == chatId);
        if (match.isNotEmpty) {
          participantIds = match.first.participantIds;
          updatedUnread = Map<String, int>.from(match.first.unreadCounts);
        }
      }

      for (final p in participantIds) {
        if (p != senderId) {
          updatedUnread[p] = (updatedUnread[p] ?? 0) + 1;
        } else {
          updatedUnread[p] = 0;
        }
      }

      // 2. Önce FirebaseFirestore üzerine yaz
      if (!isOffline) {
        await msgDocRef.set(msg.toFirestore());
        await chatDocRef.set(
          {
            'lastMessage': text,
            'lastMessageTime': FieldValue.serverTimestamp(),
            if (updatedUnread.isNotEmpty) 'unreadCounts': updatedUnread,
          },
          SetOptions(merge: true),
        );
      }

      // 3. Hemen ardından aynı ID ile Hive yerel kutusuna kaydet
      final cachedMsgs = localCacheService
          .getCachedMessages(chatId)
          .map(MessageModel.fromJson)
          .where((m) => m.id != msg.id)
          .toList();
      cachedMsgs.add(msg);
      await localCacheService.cacheMessages(
        chatId,
        cachedMsgs.map((m) => m.toJson()).toList(),
      );

      final cachedChats = localCacheService
          .getCachedChats()
          .map(ChatModel.fromJson)
          .toList();
      final chatIdx = cachedChats.indexWhere((c) => c.id == chatId);
      if (chatIdx >= 0) {
        final updatedChat = ChatModel.fromEntity(
          cachedChats[chatIdx].copyWith(
            lastMessage: text,
            lastMessageTime: now,
            unreadCounts: updatedUnread,
          ),
        );
        cachedChats.removeAt(chatIdx);
        cachedChats.insert(0, updatedChat);
        await localCacheService.cacheChats(
          cachedChats.map((c) => c.toJson()).toList(),
        );
      }

      return Result.success(msg);
    } catch (e) {
      return Result.failure(ServerFailure('Mesaj gönderilemedi: $e'));
    }
  }

  @override
  Future<Result<MessageEntity>> updateLiveLocationMessage({
    required String chatId,
    required String messageId,
    required double lat,
    required double lng,
    required String locationName,
    required bool isLiveLocation,
  }) async {
    try {
      final coordText = '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      final statusPrefix =
          isLiveLocation ? '🔴 CANLI KONUM' : '📍 Konum Paylaşımı Tamamlandı';
      final updatedText = '$statusPrefix: $locationName ($coordText)';

      final cachedMsgs = localCacheService
          .getCachedMessages(chatId)
          .map(MessageModel.fromJson)
          .toList();
      final idx = cachedMsgs.indexWhere((m) => m.id == messageId);

      MessageModel updatedMsg;
      if (idx >= 0) {
        updatedMsg = MessageModel.fromEntity(
          cachedMsgs[idx].copyWith(
            lat: lat,
            lng: lng,
            locationName: locationName,
            isLiveLocation: isLiveLocation,
            text: updatedText,
          ),
        );
      } else {
        final doc = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(messageId)
            .get();
        if (!doc.exists || doc.data() == null) {
          return Result.failure(
            const ServerFailure('Konum mesajı bulunamadı.'),
          );
        }
        final existing = MessageModel.fromJson({...doc.data()!, 'id': doc.id});
        updatedMsg = MessageModel.fromEntity(
          existing.copyWith(
            lat: lat,
            lng: lng,
            locationName: locationName,
            isLiveLocation: isLiveLocation,
            text: updatedText,
          ),
        );
      }

      // 1. Önce FirebaseFirestore üzerine yaz
      if (!isOffline) {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(messageId)
            .set(updatedMsg.toFirestore(), SetOptions(merge: true));
        await FirebaseFirestore.instance.collection('chats').doc(chatId).set(
          {
            'lastMessage': updatedText,
            'lastMessageTime': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      // 2. Hemen ardından Hive kutusuna kaydet
      if (idx >= 0) {
        cachedMsgs[idx] = updatedMsg;
      } else {
        cachedMsgs.add(updatedMsg);
      }
      await localCacheService.cacheMessages(
        chatId,
        cachedMsgs.map((m) => m.toJson()).toList(),
      );

      final cachedChats = localCacheService
          .getCachedChats()
          .map(ChatModel.fromJson)
          .toList();
      final chatIdx = cachedChats.indexWhere((c) => c.id == chatId);
      if (chatIdx >= 0) {
        cachedChats[chatIdx] = ChatModel.fromEntity(
          cachedChats[chatIdx].copyWith(
            lastMessage: updatedText,
            lastMessageTime: DateTime.now(),
          ),
        );
        await localCacheService.cacheChats(
          cachedChats.map((c) => c.toJson()).toList(),
        );
      }

      return Result.success(updatedMsg);
    } catch (e) {
      return Result.failure(ServerFailure('Canlı konum güncellenemedi: $e'));
    }
  }

  @override
  Future<Result<void>> markChatAsRead({
    required String chatId,
    required String userId,
  }) async {
    try {
      final cachedChats = localCacheService
          .getCachedChats()
          .map(ChatModel.fromJson)
          .toList();
      final chatIdx = cachedChats.indexWhere((c) => c.id == chatId);
      Map<String, int> updatedUnread = {};

      if (chatIdx >= 0) {
        updatedUnread = Map<String, int>.from(cachedChats[chatIdx].unreadCounts);
        updatedUnread[userId] = 0;
      }

      // 1. Önce FirebaseFirestore üzerinde okundu olarak güncelle
      if (!isOffline) {
        await FirebaseFirestore.instance.collection('chats').doc(chatId).set(
          {
            'unreadCounts': {userId: 0},
          },
          SetOptions(merge: true),
        );
      }

      // 2. Hemen ardından Hive kutusunu güncelle
      if (chatIdx >= 0) {
        cachedChats[chatIdx] = ChatModel.fromEntity(
          cachedChats[chatIdx].copyWith(unreadCounts: updatedUnread),
        );
        await localCacheService.cacheChats(
          cachedChats.map((c) => c.toJson()).toList(),
        );
      }

      final cachedMsgs = localCacheService
          .getCachedMessages(chatId)
          .map(MessageModel.fromJson)
          .toList();
      if (cachedMsgs.isNotEmpty) {
        bool changed = false;
        for (int i = 0; i < cachedMsgs.length; i++) {
          if (cachedMsgs[i].senderId != userId && !cachedMsgs[i].isRead) {
            cachedMsgs[i] = MessageModel.fromEntity(
              cachedMsgs[i].copyWith(isRead: true),
            );
            changed = true;
          }
        }
        if (changed) {
          await localCacheService.cacheMessages(
            chatId,
            cachedMsgs.map((m) => m.toJson()).toList(),
          );
        }
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure('Okundu bilgisi güncellenemedi: $e'));
    }
  }

  @override
  Future<Result<ChatEntity>> getOrCreateChat({
    required String rideId,
    required String driverId,
    required String driverName,
    required String passengerId,
    required String passengerName,
    required String rideSummaryTitle,
  }) async {
    try {
      // Belge ID'si tek bir kez üretilir (deterministik sohbet ID'si)
      final chatId = 'chat_${rideId}_$passengerId';
      final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

      if (!isOffline) {
        final existingDoc = await chatRef.get();
        if (existingDoc.exists && existingDoc.data() != null) {
          final existingChat = ChatModel.fromJson({
            ...existingDoc.data()!,
            'id': existingDoc.id,
          });
          await _upsertChatInHive(existingChat);
          return Result.success(existingChat);
        }
      } else {
        final cached = localCacheService
            .getCachedChats()
            .map(ChatModel.fromJson)
            .where((c) => c.id == chatId);
        if (cached.isNotEmpty) {
          return Result.success(cached.first);
        }
      }

      final newChat = ChatModel(
        id: chatId,
        rideId: rideId,
        participantIds: [driverId, passengerId],
        participantNames: {
          driverId: driverName,
          passengerId: passengerName,
        },
        rideSummaryTitle: rideSummaryTitle,
        lastMessage: 'Sohbet başlatıldı.',
        lastMessageTime: DateTime.now(),
        unreadCounts: {driverId: 0, passengerId: 0},
      );

      // 1. Önce FirebaseFirestore üzerine yaz
      if (!isOffline) {
        await chatRef.set(newChat.toFirestore());
      }

      // 2. Hemen ardından aynı ID ile Hive kutusuna kaydet
      await _upsertChatInHive(newChat);
      return Result.success(newChat);
    } catch (e) {
      return Result.failure(ServerFailure('Sohbet odası açılamadı: $e'));
    }
  }

  Future<void> _upsertChatInHive(ChatModel chat) async {
    final current = localCacheService
        .getCachedChats()
        .map(ChatModel.fromJson)
        .where((c) => c.id != chat.id)
        .toList();
    current.insert(0, chat);
    await localCacheService.cacheChats(
      current.map((c) => c.toJson()).toList(),
    );
  }

  @override
  Future<Result<ReviewEntity>> submitReview(ReviewEntity review) async {
    try {
      // 1. Belge ID'sini tek bir kez belirle
      final docRef = review.id.trim().isNotEmpty
          ? FirebaseFirestore.instance
              .collection('reviews')
              .doc(review.id.trim())
          : FirebaseFirestore.instance.collection('reviews').doc();

      final model = ReviewModel(
        id: docRef.id,
        rideId: review.rideId,
        reviewerId: review.reviewerId,
        reviewerName: review.reviewerName,
        revieweeId: review.revieweeId,
        rating: review.rating,
        comment: review.comment,
        createdAt: review.createdAt,
      );

      // 2. Önce FirebaseFirestore üzerine yaz
      if (!isOffline) {
        await docRef.set(model.toFirestore());

        // Değerlendirilen kullanıcının (`revieweeId`) ortalama puanını Firestore'daki gerçek değerlendirmelerden hesapla (FR-08)
        final userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(review.revieweeId);
        final userSnap = await userRef.get();
        if (userSnap.exists && userSnap.data() != null) {
          final reviewsSnapshot = await FirebaseFirestore.instance
              .collection('reviews')
              .where('revieweeId', isEqualTo: review.revieweeId)
              .get();

          final allRatings = reviewsSnapshot.docs
              .map((d) => (d.data()['rating'] as num?)?.toDouble() ?? 0.0)
              .where((r) => r > 0)
              .toList();

          if (!reviewsSnapshot.docs.any((d) => d.id == model.id)) {
            allRatings.add(review.rating.toDouble());
          }

          final newCount = allRatings.length;
          final totalScore = allRatings.fold<double>(0.0, (sum, r) => sum + r);
          final newAvg = newCount > 0
              ? double.parse((totalScore / newCount).toStringAsFixed(2))
              : 0.0;

          await userRef.set(
            {
              'ratingAvg': newAvg,
              'ratingCount': newCount,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
          final user =
              UserModel.fromJson({...userSnap.data()!, 'id': userSnap.id});
          final updatedUser = UserModel.fromEntity(
            user.copyWith(
              ratingAvg: newAvg,
              ratingCount: newCount,
              updatedAt: DateTime.now(),
            ),
          );
          await localCacheService.saveUserById(
            updatedUser.id,
            updatedUser.toJson(),
          );
        }
      }

      // 3. Hemen ardından aynı ID ile Hive yerel kutusuna kaydet
      final currentReviews = localCacheService
          .getCachedReviews()
          .map(ReviewModel.fromJson)
          .where((r) => r.id != model.id)
          .toList();
      currentReviews.insert(0, model);
      await localCacheService.cacheReviews(
        currentReviews.map((r) => r.toJson()).toList(),
      );

      return Result.success(model);
    } catch (e) {
      return Result.failure(ServerFailure('Değerlendirme kaydedilemedi: $e'));
    }
  }

  @override
  Future<Result<List<ReviewEntity>>> getReviewsForUser(String userId) async {
    try {
      if (isOffline) {
        final cached = localCacheService
            .getCachedReviews()
            .map(ReviewModel.fromJson)
            .where((r) => r.revieweeId == userId)
            .toList();
        return Result.success(cached);
      }

      final firestore = FirebaseFirestore.instance;
      final snap = await firestore
          .collection('reviews')
          .where('revieweeId', isEqualTo: userId)
          .get();
      List<ReviewModel> firestoreReviews = snap.docs
          .map((d) => ReviewModel.fromJson({...d.data(), 'id': d.id}))
          .toList();

      // Eğer doğrudan sorguda boş geldiyse tüm reviews koleksiyonunu kontrol et (alternatif alan adları için)
      if (firestoreReviews.isEmpty) {
        final allSnap = await firestore.collection('reviews').get();
        firestoreReviews = allSnap.docs
            .map((d) => ReviewModel.fromJson({...d.data(), 'id': d.id}))
            .where((r) =>
                r.revieweeId == userId ||
                (userId.isNotEmpty && r.revieweeId.trim() == userId.trim()))
            .toList();
      }

      // Yorum yapan yolcunun adı ('Kullanıcı' veya boş kalmışsa) users koleksiyonundan canlı çek
      for (int i = 0; i < firestoreReviews.length; i++) {
        final r = firestoreReviews[i];
        if ((r.reviewerName == 'Kullanıcı' ||
                r.reviewerName == 'Yolcu' ||
                r.reviewerName.trim().isEmpty) &&
            r.reviewerId.isNotEmpty) {
          try {
            final uDoc =
                await firestore.collection('users').doc(r.reviewerId).get();
            if (uDoc.exists && uDoc.data() != null) {
              final fullName = uDoc.data()!['fullName']?.toString();
              if (fullName != null && fullName.isNotEmpty) {
                firestoreReviews[i] =
                    ReviewModel.fromEntity(r.copyWith(reviewerName: fullName));
              }
            }
          } catch (_) {}
        }
      }

      firestoreReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Kullanıcının puan ortalaması ve değerlendirme sayısını Firestore users koleksiyonuna da senkronize et
      if (firestoreReviews.isNotEmpty) {
        final count = firestoreReviews.length;
        final sum =
            firestoreReviews.fold<double>(0.0, (prev, r) => prev + r.rating);
        final avg = double.parse((sum / count).toStringAsFixed(1));
        try {
          await firestore.collection('users').doc(userId).set({
            'ratingAvg': avg,
            'ratingCount': count,
          }, SetOptions(merge: true));
        } catch (_) {}
      }

      // Hive önbelleğinin üzerine yaz
      final otherReviews = localCacheService
          .getCachedReviews()
          .map(ReviewModel.fromJson)
          .where((r) => r.revieweeId != userId)
          .toList();
      await localCacheService.cacheReviews(
        [...firestoreReviews, ...otherReviews].map((r) => r.toJson()).toList(),
      );

      return Result.success(firestoreReviews);
    } catch (e) {
      final cached = localCacheService
          .getCachedReviews()
          .map(ReviewModel.fromJson)
          .where((r) => r.revieweeId == userId)
          .toList();
      return Result.success(cached);
    }
  }
}
