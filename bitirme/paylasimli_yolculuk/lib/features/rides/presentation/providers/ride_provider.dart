import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/seed_data_service.dart';
import '../../data/datasources/ride_remote_datasource.dart';
import '../../data/repositories/ride_repository_impl.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/repositories/ride_repository.dart';
import '../../domain/usecases/ride_usecases.dart';

final rideRemoteDataSourceProvider = Provider<RideRemoteDataSource>((ref) {
  return RideRemoteDataSource(
    seedService: ref.watch(seedDataServiceProvider),
    useMockData: ref.watch(useMockDataProvider),
  );
});

final rideRepositoryProvider = Provider<IRideRepository>((ref) {
  return RideRepositoryImpl(
    remoteDataSource: ref.watch(rideRemoteDataSourceProvider),
    localCacheService: ref.watch(localCacheServiceProvider),
    isOffline: ref.watch(isOfflineModeProvider),
  );
});

final searchRidesUseCaseProvider = Provider<SearchRidesUseCase>((ref) {
  return SearchRidesUseCase(ref.watch(rideRepositoryProvider));
});

final createRideUseCaseProvider = Provider<CreateRideUseCase>((ref) {
  return CreateRideUseCase(ref.watch(rideRepositoryProvider));
});

final getRideByIdUseCaseProvider = Provider<GetRideByIdUseCase>((ref) {
  return GetRideByIdUseCase(ref.watch(rideRepositoryProvider));
});

final getDriverRidesUseCaseProvider = Provider<GetDriverRidesUseCase>((ref) {
  return GetDriverRidesUseCase(ref.watch(rideRepositoryProvider));
});

/// Arama filtre durumunu tutan StateProvider.
final rideSearchFilterProvider = StateProvider<RideSearchFilter>((ref) {
  return const RideSearchFilter();
});

/// Arama geçmişini (`box_search_history`) yöneten Notifier.
class SearchHistoryNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() {
    return ref.watch(rideRepositoryProvider).getSearchHistory();
  }

  void refresh() {
    state = ref.read(rideRepositoryProvider).getSearchHistory();
  }

  Future<void> clear() async {
    await ref.read(rideRepositoryProvider).clearSearchHistory();
    state = [];
  }
}

final searchHistoryProvider =
    NotifierProvider<SearchHistoryNotifier, List<Map<String, dynamic>>>(
  SearchHistoryNotifier.new,
);

/// Yolculuk listesini ve arama sonuçlarını yöneten AsyncNotifier.
class RidesNotifier extends AsyncNotifier<List<RideEntity>> {
  @override
  Future<List<RideEntity>> build() async {
    final filter = ref.watch(rideSearchFilterProvider);
    final useCase = ref.watch(searchRidesUseCaseProvider);
    final result = await useCase(filter);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (rides) => rides,
    );
  }

  Future<void> applyFilter(RideSearchFilter filter) async {
    ref.read(rideSearchFilterProvider.notifier).state = filter;
    ref.read(searchHistoryProvider.notifier).refresh();
  }

  Future<bool> createRide(RideEntity ride) async {
    final useCase = ref.read(createRideUseCaseProvider);
    final result = await useCase(ride);
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidateSelf();
        return true;
      },
    );
  }

  Future<bool> updateRideStatus({
    required String rideId,
    required String status,
  }) async {
    final repo = ref.read(rideRepositoryProvider);
    final result = await repo.updateRideStatus(rideId: rideId, status: status);
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidateSelf();
        return true;
      },
    );
  }
}

final ridesNotifierProvider =
    AsyncNotifierProvider<RidesNotifier, List<RideEntity>>(RidesNotifier.new);

/// Tekil yolculuk detay sağlayıcısı.
final rideDetailProvider =
    FutureProvider.family<RideEntity, String>((ref, rideId) async {
  // Rides listesi güncellendiğinde detay da yenilensin
  ref.watch(ridesNotifierProvider);
  final useCase = ref.watch(getRideByIdUseCaseProvider);
  final result = await useCase(rideId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (ride) => ride,
  );
});

