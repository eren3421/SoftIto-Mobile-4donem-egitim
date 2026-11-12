import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/repositories/ride_repository.dart';
import '../datasources/ride_remote_datasource.dart';
import '../models/ride_model.dart';

/// Network-First with Local Fallback (Çevrimdışı Önbellek) stratejisini uygulayan
/// `RideRepositoryImpl` sınıfı (`box_my_rides` ve `box_search_history` entegreli).
class RideRepositoryImpl implements IRideRepository {
  final RideRemoteDataSource remoteDataSource;
  final LocalCacheService localCacheService;
  final bool isOffline;

  RideRepositoryImpl({
    required this.remoteDataSource,
    required this.localCacheService,
    required this.isOffline,
  });

  @override
  Future<Result<List<RideEntity>>> searchRides(RideSearchFilter filter) async {
    try {
      // Arama yapıldığında geçmişe kaydet (`box_search_history`)
      if (filter.originQuery.trim().isNotEmpty ||
          filter.destinationQuery.trim().isNotEmpty) {
        await localCacheService.addSearchHistory(
          origin: filter.originQuery,
          destination: filter.destinationQuery,
        );
      }

      List<RideModel> allRides;
      if (isOffline) {
        // Çevrimdışı modda yerel Hive kutusundan (`box_my_rides`) oku
        allRides = localCacheService
            .getCachedRides()
            .map(RideModel.fromJson)
            .toList();
      } else {
        allRides = await remoteDataSource.fetchAllRides();
        // Yerel önbelleği güncelle
        await localCacheService.cacheRides(
          allRides.map((r) => r.toJson()).toList(),
        );
      }

      final filtered = _applyFilter(allRides, filter);
      return Result.success(filtered);
    } catch (e) {
      // Hata durumunda yerel önbellekten (Local Fallback) sun
      final cached = localCacheService
          .getCachedRides()
          .map(RideModel.fromJson)
          .toList();
      if (cached.isNotEmpty) {
        return Result.success(_applyFilter(cached, filter));
      }
      return Result.failure(ServerFailure('Yolculuklar yüklenemedi: $e'));
    }
  }

  List<RideEntity> _applyFilter(
    List<RideModel> source,
    RideSearchFilter filter,
  ) {
    return source.where((ride) {
      if (ride.status == 'cancelled') return false;

      // Kalkış noktası filtresi
      if (filter.originQuery.trim().isNotEmpty) {
        final q = filter.originQuery.trim().toLowerCase();
        final matchOrigin = ride.origin.name.toLowerCase().contains(q) ||
            ride.origin.address.toLowerCase().contains(q) ||
            ride.waypoints.any((w) => w.name.toLowerCase().contains(q));
        if (!matchOrigin) return false;
      }

      // Varış noktası filtresi
      if (filter.destinationQuery.trim().isNotEmpty) {
        final q = filter.destinationQuery.trim().toLowerCase();
        final matchDest = ride.destination.name.toLowerCase().contains(q) ||
            ride.destination.address.toLowerCase().contains(q) ||
            ride.waypoints.any((w) => w.name.toLowerCase().contains(q));
        if (!matchDest) return false;
      }

      // Tarih filtresi
      if (filter.date != null) {
        final d = filter.date!;
        final rDate = ride.departureTime.toLocal();
        final sameDay =
            rDate.year == d.year && rDate.month == d.month && rDate.day == d.day;
        if (!sameDay) return false;
      }

      // Boş koltuk sayısı filtresi
      if (filter.minSeats > 1 && ride.availableSeats < filter.minSeats) {
        return false;
      }

      // Maksimum fiyat filtresi
      if (filter.maxPrice != null && ride.pricePerSeat > filter.maxPrice!) {
        return false;
      }

      // Durum / Kapasite / Başvuru Uygunluk Filtresi
      if (filter.statusFilter == 'available') {
        if (ride.status == 'completed' || ride.availableSeats <= 0) return false;
      } else if (filter.statusFilter == 'full') {
        if (ride.status == 'completed' || ride.availableSeats > 0) return false;
      } else if (filter.statusFilter == 'completed') {
        if (ride.status != 'completed') return false;
      }

      return true;
    }).toList();
  }

  @override
  Future<Result<RideEntity>> getRideById(String rideId) async {
    try {
      if (isOffline) {
        final cached = localCacheService
            .getCachedRides()
            .map(RideModel.fromJson)
            .where((r) => r.id == rideId);
        if (cached.isNotEmpty) {
          return Result.success(cached.first);
        }
        return Result.failure(
          const CacheFailure('Çevrimdışı önbellekte bu yolculuk bulunamadı.'),
        );
      }

      final ride = await remoteDataSource.getRideById(rideId);
      return Result.success(ride);
    } catch (e) {
      final cached = localCacheService
          .getCachedRides()
          .map(RideModel.fromJson)
          .where((r) => r.id == rideId);
      if (cached.isNotEmpty) {
        return Result.success(cached.first);
      }
      return Result.failure(ServerFailure('Yolculuk detayı alınamadı: $e'));
    }
  }

  @override
  Future<Result<RideEntity>> createRide(RideEntity ride) async {
    try {
      final docId = ride.id.trim().isNotEmpty
          ? ride.id.trim()
          : FirebaseFirestore.instance.collection('rides').doc().id;

      final model = RideModel.fromEntity(ride.copyWith(id: docId));

      // 1. Önce FirebaseFirestore üzerine yaz (İnternet varsa)
      if (!isOffline) {
        try {
          await FirebaseFirestore.instance
              .collection('rides')
              .doc(docId)
              .set(model.toFirestore())
              .timeout(const Duration(seconds: 4));
          debugPrint('✅ Yolculuk Firestore `rides/$docId` belgesine yazıldı.');
        } catch (e) {
          debugPrint(
            '⚠️ Firestore yazma uyarısı, yerel önbelleğe devam ediliyor: $e',
          );
        }
      }

      // 2. Hemen ardından aynı ID ile Hive kutusuna kaydet
      final currentCached = <RideModel>[];
      try {
        for (final item in localCacheService.getCachedRides()) {
          try {
            currentCached.add(RideModel.fromJson(item));
          } catch (_) {}
        }
      } catch (_) {}
      currentCached.removeWhere((r) => r.id == model.id);
      currentCached.insert(0, model);
      await localCacheService.cacheRides(
        currentCached.map((r) => r.toJson()).toList(),
      );
      final myRides =
          currentCached.where((r) => r.driverId == model.driverId).toList();
      await localCacheService.cacheMyRidesForUser(
        model.driverId,
        myRides.map((r) => r.toJson()).toList(),
      );

      return Result.success(model);
    } catch (e) {
      return Result.failure(ServerFailure('İlan oluşturulamadı: $e'));
    }
  }

  @override
  Future<Result<RideEntity>> updateRideStatus({
    required String rideId,
    required String status,
  }) async {
    try {
      final updated = await remoteDataSource.updateRideStatus(
        rideId: rideId,
        status: status,
      );
      final all = await remoteDataSource.fetchAllRides();
      await localCacheService.cacheRides(all.map((r) => r.toJson()).toList());
      if (status == 'completed') {
        final cachedBookings = localCacheService.getCachedBookings();
        final updatedBookings = cachedBookings.map((b) {
          if (b['rideId'] == rideId &&
              (b['status'] == 'approved' || b['status'] == 'pending')) {
            return {...b, 'status': 'completed'};
          }
          return b;
        }).toList();
        await localCacheService.cacheBookings(updatedBookings);
      }
      return Result.success(updated);
    } catch (e) {
      if (e is ServerException) {
        return Result.failure(ServerFailure(e.message));
      }
      return Result.failure(ServerFailure('Durum güncellenemedi: $e'));
    }
  }

  @override
  Future<Result<List<RideEntity>>> getDriverRides(String driverId) async {
    try {
      if (isOffline) {
        final cached = localCacheService.getCachedMyRidesForUser(driverId);
        if (cached.isNotEmpty) {
          return Result.success(cached.map(RideModel.fromJson).toList());
        }
        final fallback = localCacheService
            .getCachedRides()
            .map(RideModel.fromJson)
            .where((r) => r.driverId == driverId)
            .toList();
        return Result.success(fallback);
      }

      final all = await remoteDataSource.fetchAllRides();
      final myRides = all.where((r) => r.driverId == driverId).toList();
      await localCacheService.cacheMyRidesForUser(
        driverId,
        myRides.map((r) => r.toJson()).toList(),
      );
      return Result.success(myRides);
    } catch (e) {
      final fallback = localCacheService
          .getCachedRides()
          .map(RideModel.fromJson)
          .where((r) => r.driverId == driverId)
          .toList();
      return Result.success(fallback);
    }
  }

  @override
  List<Map<String, dynamic>> getSearchHistory() {
    return localCacheService.getSearchHistory();
  }

  @override
  Future<void> clearSearchHistory() {
    return localCacheService.clearSearchHistory();
  }
}

