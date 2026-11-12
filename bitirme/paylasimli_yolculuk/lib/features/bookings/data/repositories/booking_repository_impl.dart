import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/seed_data_service.dart';
import '../../../rides/data/models/ride_model.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';
import '../models/booking_model.dart';

/// Single Source of Truth = Cloud Firestore, Cache = Hive (`LocalCacheService`).
/// Yazma işlemlerinde önce Firestore'a yazar, hemen ardından aynı ID ile Hive önbelleğini günceller.
/// Okuma işlemlerinde çevrimiçiyken Firestore'dan çekip Hive üzerine yazar; çevrimdışıyken Hive'dan okur.
class BookingRepositoryImpl implements IBookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  final LocalCacheService localCacheService;
  final SeedDataService seedService;
  final bool isOffline;

  BookingRepositoryImpl({
    required this.remoteDataSource,
    required this.localCacheService,
    required this.seedService,
    required this.isOffline,
  });

  Future<void> _upsertBookingInHive(BookingModel booking) async {
    final current = localCacheService
        .getCachedBookings()
        .map(BookingModel.fromJson)
        .where((b) => b.id != booking.id)
        .toList();
    current.insert(0, booking);
    await localCacheService.cacheBookings(
      current.map((b) => b.toJson()).toList(),
    );
  }

  Future<void> _refreshRideInHive(String rideId) async {
    try {
      final rideDoc = await FirebaseFirestore.instance
          .collection('rides')
          .doc(rideId)
          .get();
      if (rideDoc.exists && rideDoc.data() != null) {
        final freshRide =
            RideModel.fromJson({...rideDoc.data()!, 'id': rideDoc.id});
        final currentRides = localCacheService
            .getCachedRides()
            .map(RideModel.fromJson)
            .where((r) => r.id != freshRide.id)
            .toList();
        currentRides.insert(0, freshRide);
        await localCacheService.cacheRides(
          currentRides.map((r) => r.toJson()).toList(),
        );
      }
    } catch (_) {}
  }

  @override
  Future<Result<BookingEntity>> createBooking({
    required BookingEntity booking,
    bool instantApprove = false,
  }) async {
    try {
      final model = BookingModel.fromEntity(booking);
      // 1. Önce Firestore'a tekil ID ile yazılır
      final created = await remoteDataSource.createBooking(
        booking: model,
        instantApprove: instantApprove,
      );
      // 2. Hemen ardından aynı ID ile Hive kutusuna kaydedilir
      await _upsertBookingInHive(created);
      if (instantApprove) {
        await _refreshRideInHive(created.rideId);
      }
      return Result.success(created);
    } on SeatQuotaException catch (e) {
      return Result.failure(SeatQuotaFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('Rezervasyon hatası: $e'));
    }
  }

  @override
  Future<Result<BookingEntity>> approveBooking({
    required String rideId,
    required String bookingId,
  }) async {
    try {
      final approved = await remoteDataSource.approveBookingTransaction(
        rideId: rideId,
        bookingId: bookingId,
      );
      await _upsertBookingInHive(approved);
      await _refreshRideInHive(rideId);
      return Result.success(approved);
    } on SeatQuotaException catch (e) {
      return Result.failure(SeatQuotaFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('Onaylama hatası: $e'));
    }
  }

  @override
  Future<Result<BookingEntity>> rejectBooking({
    required String bookingId,
  }) async {
    try {
      final rejected = await remoteDataSource.rejectBooking(bookingId);
      await _upsertBookingInHive(rejected);
      return Result.success(rejected);
    } catch (e) {
      return Result.failure(ServerFailure('Reddetme işlemi başarısız: $e'));
    }
  }

  @override
  Future<Result<BookingEntity>> cancelBooking({
    required String bookingId,
    required bool byDriver,
  }) async {
    try {
      final cancelled = await remoteDataSource.cancelBooking(
        bookingId: bookingId,
        byDriver: byDriver,
      );
      await _upsertBookingInHive(cancelled);
      await _refreshRideInHive(cancelled.rideId);
      return Result.success(cancelled);
    } catch (e) {
      if (e is ServerException) {
        return Result.failure(ServerFailure(e.message));
      }
      return Result.failure(ServerFailure('İptal işlemi başarısız: $e'));
    }
  }

  @override
  Future<Result<List<BookingEntity>>> getBookingsForPassenger(
    String passengerId,
  ) async {
    try {
      if (isOffline) {
        final cached = localCacheService
            .getCachedBookings()
            .map(BookingModel.fromJson)
            .where((b) => b.passengerId == passengerId)
            .toList();
        return Result.success(cached);
      }

      final all = await remoteDataSource.getAllBookings();
      await localCacheService.cacheBookings(
        all.map((b) => b.toJson()).toList(),
      );
      final list = all.where((b) => b.passengerId == passengerId).toList();
      return Result.success(list);
    } catch (e) {
      final cached = localCacheService
          .getCachedBookings()
          .map(BookingModel.fromJson)
          .where((b) => b.passengerId == passengerId)
          .toList();
      return Result.success(cached);
    }
  }

  @override
  Future<Result<List<BookingEntity>>> getBookingsForRide(String rideId) async {
    try {
      if (isOffline) {
        final cached = localCacheService
            .getCachedBookings()
            .map(BookingModel.fromJson)
            .where((b) => b.rideId == rideId)
            .toList();
        return Result.success(cached);
      }
      final all = await remoteDataSource.getAllBookings();
      await localCacheService.cacheBookings(
        all.map((b) => b.toJson()).toList(),
      );
      return Result.success(all.where((b) => b.rideId == rideId).toList());
    } catch (e) {
      final cached = localCacheService
          .getCachedBookings()
          .map(BookingModel.fromJson)
          .where((b) => b.rideId == rideId)
          .toList();
      return Result.success(cached);
    }
  }

  @override
  Future<Result<List<BookingEntity>>> getBookingsForDriver(
    String driverId,
  ) async {
    try {
      if (isOffline) {
        final cached = localCacheService
            .getCachedBookings()
            .map(BookingModel.fromJson)
            .where((b) => b.driverId == driverId)
            .toList();
        return Result.success(cached);
      }
      final all = await remoteDataSource.getAllBookings();
      await localCacheService.cacheBookings(
        all.map((b) => b.toJson()).toList(),
      );
      return Result.success(all.where((b) => b.driverId == driverId).toList());
    } catch (e) {
      final cached = localCacheService
          .getCachedBookings()
          .map(BookingModel.fromJson)
          .where((b) => b.driverId == driverId)
          .toList();
      return Result.success(cached);
    }
  }
}
