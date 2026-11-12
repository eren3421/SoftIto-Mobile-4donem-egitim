import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/seed_data_service.dart';
import '../../../chat/data/models/chat_model.dart';
import '../../../rides/data/models/ride_model.dart';
import '../models/booking_model.dart';

/// Single Source of Truth = Cloud Firestore.
/// Atomik Koltuk Rezervasyonu (Transaction) ve doğrudan Firestore okuma/yazma işlemlerini yönetir.
class BookingRemoteDataSource {
  final SeedDataService seedService;
  final bool useMockData;

  BookingRemoteDataSource({
    required this.seedService,
    required this.useMockData,
  });

  Future<BookingModel> createBooking({
    required BookingModel booking,
    required bool instantApprove,
  }) async {
    final firestore = FirebaseFirestore.instance;

    // 1. İlgili yolculuğun boş koltuk sayısını Firestore'dan kontrol et
    final rideDoc =
        await firestore.collection('rides').doc(booking.rideId).get();
    if (!rideDoc.exists || rideDoc.data() == null) {
      throw const ServerException('Yolculuk kaydı bulunamadı.');
    }
    final availableSeats =
        (rideDoc.data()!['availableSeats'] as num?)?.toInt() ?? 0;
    if (availableSeats < booking.seatsBooked) {
      throw const SeatQuotaException('Yeterli boş koltuk kalmadı.');
    }

    // 2. Aynı yolcunun aynı ilana aktif başvurusu var mı Firestore'dan kontrol et
    final existingSnap = await firestore
        .collection('bookings')
        .where('rideId', isEqualTo: booking.rideId)
        .where('passengerId', isEqualTo: booking.passengerId)
        .get();
    final duplicate = existingSnap.docs.any((d) {
      final st = d.data()['status']?.toString() ?? '';
      return st == 'pending' || st == 'approved';
    });
    if (duplicate) {
      throw const SeatQuotaException(
        'Bu yolculuk için zaten aktif bir rezervasyonunuz bulunuyor.',
      );
    }

    // 3. Belge ID'sini tek bir kez üret ve önce Firestore'a yaz
    final docRef = booking.id.trim().isNotEmpty
        ? firestore.collection('bookings').doc(booking.id.trim())
        : firestore.collection('bookings').doc();

    final pendingModel = BookingModel.fromEntity(
      booking.copyWith(
        id: docRef.id,
        status: 'pending',
      ),
    );

    try {
      await docRef.set(pendingModel.toFirestore());
      debugPrint(
        '✅ Rezervasyon Firestore `bookings/${pendingModel.id}` belgesine yazıldı.',
      );
    } catch (e) {
      throw ServerException('Rezervasyon oluşturulamadı: $e');
    }

    if (instantApprove) {
      return await approveBookingTransaction(
        rideId: booking.rideId,
        bookingId: pendingModel.id,
      );
    }
    return pendingModel;
  }

  /// 02_veri_depolama_ve_sema.md Bölüm 3.1: Atomik Koltuk Rezervasyonu (Transaction)
  Future<BookingModel> approveBookingTransaction({
    required String rideId,
    required String bookingId,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final rideRef = firestore.collection('rides').doc(rideId);
    final bookingRef = firestore.collection('bookings').doc(bookingId);

    await firestore.runTransaction((transaction) async {
      final rideSnapshot = await transaction.get(rideRef);
      final bookingSnapshot = await transaction.get(bookingRef);

      if (!rideSnapshot.exists || !bookingSnapshot.exists) {
        throw const ServerException(
          'Yolculuk veya rezervasyon kaydı bulunamadı.',
        );
      }

      final int availableSeats =
          (rideSnapshot.data()!['availableSeats'] as num).toInt();
      final int seatsBooked =
          (bookingSnapshot.data()!['seatsBooked'] as num).toInt();
      final String currentStatus =
          bookingSnapshot.data()!['status'] as String;

      if (currentStatus != 'pending') {
        throw const SeatQuotaException('Bu rezervasyon zaten işleme alınmış.');
      }

      if (availableSeats < seatsBooked) {
        throw const SeatQuotaException('Yeterli boş koltuk kalmadı.');
      }

      final int updatedSeats = availableSeats - seatsBooked;
      transaction.update(rideRef, {
        'availableSeats': updatedSeats,
        'status': updatedSeats == 0 ? 'full' : 'planned',
      });

      transaction.update(bookingRef, {
        'status': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    final updatedDoc = await bookingRef.get();
    final approvedModel =
        BookingModel.fromJson({...updatedDoc.data()!, 'id': updatedDoc.id});

    final rideDoc = await rideRef.get();
    if (rideDoc.exists && rideDoc.data() != null) {
      final rideModel =
          RideModel.fromJson({...rideDoc.data()!, 'id': rideDoc.id});
      await _ensureChatRoomCreated(rideModel, approvedModel);
    }

    return approvedModel;
  }

  Future<void> _ensureChatRoomCreated(
    RideModel ride,
    BookingModel booking,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final chatId = 'chat_${ride.id}_${booking.passengerId}';
    final chatRef = firestore.collection('chats').doc(chatId);
    final chatSnap = await chatRef.get();

    if (!chatSnap.exists) {
      final newChat = ChatModel(
        id: chatId,
        rideId: ride.id,
        participantIds: [ride.driverId, booking.passengerId],
        participantNames: {
          ride.driverId: ride.driverSummary.fullName,
          booking.passengerId: booking.passengerSummary.fullName,
        },
        rideSummaryTitle: '${ride.origin.name} → ${ride.destination.name}',
        lastMessage: 'Rezervasyon onaylandı! Mesajlaşmaya başlayabilirsiniz.',
        lastMessageTime: DateTime.now(),
        unreadCounts: {
          ride.driverId: 0,
          booking.passengerId: 1,
        },
      );

      final msgDocRef = chatRef.collection('messages').doc();
      final welcomeMsg = MessageModel(
        id: msgDocRef.id,
        chatId: chatId,
        senderId: ride.driverId,
        text:
            'Merhaba ${booking.passengerSummary.fullName}, rezervasyon talebinizi onayladım. İyi yolculuklar!',
        type: 'text',
        isRead: false,
        createdAt: DateTime.now(),
      );

      await chatRef.set(newChat.toFirestore());
      await msgDocRef.set(welcomeMsg.toFirestore());
    }
  }

  Future<BookingModel> rejectBooking(String bookingId) async {
    final bookingRef =
        FirebaseFirestore.instance.collection('bookings').doc(bookingId);
    await bookingRef.update({
      'status': 'rejected',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final doc = await bookingRef.get();
    if (doc.exists && doc.data() != null) {
      return BookingModel.fromJson({...doc.data()!, 'id': doc.id});
    }
    throw const ServerException('Rezervasyon bulunamadı.');
  }

  Future<BookingModel> cancelBooking({
    required String bookingId,
    required bool byDriver,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final newStatus =
        byDriver ? 'cancelled_by_driver' : 'cancelled_by_passenger';
    final bookingRef = firestore.collection('bookings').doc(bookingId);
    final doc = await bookingRef.get();

    if (!doc.exists || doc.data() == null) {
      throw const ServerException('Rezervasyon bulunamadı.');
    }

    final current = BookingModel.fromJson({...doc.data()!, 'id': doc.id});
    if (current.status == 'completed') {
      throw const ServerException('Tamamlanmış yolculuklar iptal edilemez.');
    }

    final rideRef = firestore.collection('rides').doc(current.rideId);
    final rideSnap = await rideRef.get();
    if (rideSnap.exists && rideSnap.data() != null) {
      final rideStatus = rideSnap.data()!['status'] as String? ?? '';
      if (rideStatus == 'completed') {
        throw const ServerException('Bu yolculuk tamamlandığı için iptal edilemez.');
      }
      if (current.status == 'approved') {
        final currentSeats =
            (rideSnap.data()!['availableSeats'] as num?)?.toInt() ?? 0;
        final restored = currentSeats + current.seatsBooked;
        await rideRef.update({
          'availableSeats': restored,
          'status': 'planned',
        });
      }
    }

    await bookingRef.update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final updatedDoc = await bookingRef.get();
    return BookingModel.fromJson({...updatedDoc.data()!, 'id': updatedDoc.id});
  }

  Future<List<BookingModel>> getAllBookings() async {
    final snap = await FirebaseFirestore.instance.collection('bookings').get();
    final list = snap.docs
        .map((d) => BookingModel.fromJson({...d.data(), 'id': d.id}))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
}
