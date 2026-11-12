import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/seed_data_service.dart';
import '../models/ride_model.dart';

/// Uzak veri kaynağı (Single Source of Truth = Cloud Firestore).
class RideRemoteDataSource {
  final SeedDataService seedService;
  final bool useMockData;

  RideRemoteDataSource({
    required this.seedService,
    required this.useMockData,
  });

  Future<List<RideModel>> fetchAllRides() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('rides').get();
      final list = snapshot.docs
          .map((d) => RideModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      list.sort((a, b) => a.departureTime.compareTo(b.departureTime));
      return list;
    } catch (e) {
      throw ServerException('Yolculuk ilanları Firestore\'dan alınamadı: $e');
    }
  }

  Future<RideModel> getRideById(String rideId) async {
    final doc =
        await FirebaseFirestore.instance.collection('rides').doc(rideId).get();
    if (doc.exists && doc.data() != null) {
      return RideModel.fromJson({...doc.data()!, 'id': doc.id});
    }
    throw const ServerException('Yolculuk kaydı bulunamadı.');
  }

  Future<RideModel> createRide(RideModel ride) async {
    try {
      // Belge ID'si tek bir kez üretilir / kullanılır ve önce Firestore'a yazılır
      final docRef = ride.id.trim().isNotEmpty
          ? FirebaseFirestore.instance.collection('rides').doc(ride.id.trim())
          : FirebaseFirestore.instance.collection('rides').doc();

      final finalModel = RideModel.fromEntity(ride.copyWith(id: docRef.id));
      await docRef.set(finalModel.toFirestore());
      debugPrint(
        '✅ Yolculuk Firestore `rides/${finalModel.id}` belgesine yazıldı.',
      );
      return finalModel;
    } catch (e) {
      throw ServerException('Yolculuk oluşturulamadı: $e');
    }
  }

  Future<RideModel> updateRideStatus({
    required String rideId,
    required String status,
  }) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('rides')
          .doc(rideId)
          .get();
      if (doc.exists && doc.data() != null) {
        final currentStatus = doc.data()!['status'] as String?;
        if (currentStatus == 'completed' && status == 'cancelled') {
          throw const ServerException('Tamamlanmış yolculuklar iptal edilemez.');
        }
      }

      await FirebaseFirestore.instance
          .collection('rides')
          .doc(rideId)
          .update({'status': status});

      if (status == 'completed') {
        final snap = await FirebaseFirestore.instance
            .collection('bookings')
            .where('rideId', isEqualTo: rideId)
            .get();
        for (final bDoc in snap.docs) {
          final bStatus = bDoc.data()['status'] as String?;
          if (bStatus == 'approved' || bStatus == 'pending') {
            await bDoc.reference.update({
              'status': 'completed',
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }

      return await getRideById(rideId);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Yolculuk durumu güncellenemedi: $e');
    }
  }
}
