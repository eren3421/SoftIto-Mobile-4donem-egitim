import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/seed_data_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../rides/domain/entities/ride_entity.dart';
import '../../../rides/presentation/providers/ride_provider.dart';
import '../../data/datasources/booking_remote_datasource.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/usecases/booking_usecases.dart';

final bookingRemoteDataSourceProvider =
    Provider<BookingRemoteDataSource>((ref) {
  return BookingRemoteDataSource(
    seedService: ref.watch(seedDataServiceProvider),
    useMockData: ref.watch(useMockDataProvider),
  );
});

final bookingRepositoryProvider = Provider<IBookingRepository>((ref) {
  return BookingRepositoryImpl(
    remoteDataSource: ref.watch(bookingRemoteDataSourceProvider),
    localCacheService: ref.watch(localCacheServiceProvider),
    seedService: ref.watch(seedDataServiceProvider),
    isOffline: ref.watch(isOfflineModeProvider),
  );
});

final bookSeatUseCaseProvider = Provider<BookSeatUseCase>((ref) {
  return BookSeatUseCase(ref.watch(bookingRepositoryProvider));
});

final approveBookingUseCaseProvider = Provider<ApproveBookingUseCase>((ref) {
  return ApproveBookingUseCase(ref.watch(bookingRepositoryProvider));
});

final rejectBookingUseCaseProvider = Provider<RejectBookingUseCase>((ref) {
  return RejectBookingUseCase(ref.watch(bookingRepositoryProvider));
});

final cancelBookingUseCaseProvider = Provider<CancelBookingUseCase>((ref) {
  return CancelBookingUseCase(ref.watch(bookingRepositoryProvider));
});

/// Aktif kullanıcının yolcu olarak yaptığı rezervasyonları yöneten Notifier.
class PassengerBookingsNotifier extends AsyncNotifier<List<BookingEntity>> {
  @override
  Future<List<BookingEntity>> build() async {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    if (user == null) return [];
    final repo = ref.watch(bookingRepositoryProvider);
    final res = await repo.getBookingsForPassenger(user.id);
    return res.fold((_) => [], (list) => list);
  }

  Future<String?> requestBooking({
    required BookingEntity booking,
    required int currentAvailableSeats,
    required bool instantApprove,
  }) async {
    final useCase = ref.read(bookSeatUseCaseProvider);
    final result = await useCase(
      booking: booking,
      currentAvailableSeats: currentAvailableSeats,
      instantApprove: instantApprove,
    );
    return result.fold(
      (failure) => failure.message,
      (_) {
        ref.invalidateSelf();
        ref.invalidate(driverBookingsProvider);
        ref.invalidate(ridesNotifierProvider);
        return null; // Hata yok
      },
    );
  }

  Future<String?> approveBooking({
    required String rideId,
    required String bookingId,
  }) async {
    final useCase = ref.read(approveBookingUseCaseProvider);
    final result = await useCase(rideId: rideId, bookingId: bookingId);
    return result.fold(
      (failure) => failure.message,
      (_) {
        ref.invalidateSelf();
        ref.invalidate(driverBookingsProvider);
        ref.invalidate(ridesNotifierProvider);
        return null;
      },
    );
  }

  Future<String?> rejectBooking(String bookingId) async {
    final useCase = ref.read(rejectBookingUseCaseProvider);
    final result = await useCase(bookingId);
    return result.fold(
      (failure) => failure.message,
      (_) {
        ref.invalidateSelf();
        ref.invalidate(driverBookingsProvider);
        ref.invalidate(ridesNotifierProvider);
        return null;
      },
    );
  }

  Future<String?> cancelBooking({
    required String bookingId,
    required bool byDriver,
  }) async {
    final useCase = ref.read(cancelBookingUseCaseProvider);
    final result = await useCase(bookingId: bookingId, byDriver: byDriver);
    return result.fold(
      (failure) => failure.message,
      (_) {
        ref.invalidateSelf();
        ref.invalidate(driverBookingsProvider);
        ref.invalidate(ridesNotifierProvider);
        return null;
      },
    );
  }
}

final passengerBookingsProvider =
    AsyncNotifierProvider<PassengerBookingsNotifier, List<BookingEntity>>(
  PassengerBookingsNotifier.new,
);

/// Sürücünün ilanlarına gelen rezervasyon taleplerini getiren sağlayıcı.
final driverBookingsProvider =
    FutureProvider<List<BookingEntity>>((ref) async {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  if (user == null) return [];
  final repo = ref.watch(bookingRepositoryProvider);
  final res = await repo.getBookingsForDriver(user.id);
  return res.fold((_) => [], (list) => list);
});

/// Sürücünün açtığı ilanları çevrimdışı önbellek destekli olarak getiren sağlayıcı.
final myDriverRidesProvider = FutureProvider<List<RideEntity>>((ref) async {
  ref.watch(ridesNotifierProvider);
  final user = ref.watch(authNotifierProvider).valueOrNull;
  if (user == null) return [];
  final useCase = ref.watch(getDriverRidesUseCaseProvider);
  final res = await useCase(user.id);
  return res.fold((_) => [], (list) => list);
});

