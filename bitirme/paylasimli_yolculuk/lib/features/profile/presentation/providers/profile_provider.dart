import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/seed_data_service.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/profile_usecases.dart';

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    localCacheService: ref.watch(localCacheServiceProvider),
    seedService: ref.watch(seedDataServiceProvider),
    useMockData: ref.watch(useMockDataProvider),
    isOffline: ref.watch(isOfflineModeProvider),
  );
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
});

final getUserVehiclesUseCaseProvider = Provider<GetUserVehiclesUseCase>((ref) {
  return GetUserVehiclesUseCase(ref.watch(profileRepositoryProvider));
});

final addVehicleUseCaseProvider = Provider<AddVehicleUseCase>((ref) {
  return AddVehicleUseCase(ref.watch(profileRepositoryProvider));
});

/// Aktif kullanıcının araç listesini yöneten AsyncNotifier.
class UserVehiclesNotifier extends AsyncNotifier<List<VehicleEntity>> {
  @override
  Future<List<VehicleEntity>> build() async {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    if (user == null) return [];
    final useCase = ref.watch(getUserVehiclesUseCaseProvider);
    final result = await useCase(user.id);
    return result.fold((_) => [], (vehicles) => vehicles);
  }

  Future<bool> addVehicle(VehicleEntity vehicle) async {
    final useCase = ref.read(addVehicleUseCaseProvider);
    final result = await useCase(vehicle);
    return result.fold(
      (failure) => false,
      (added) {
        final current = state.valueOrNull ?? [];
        state = AsyncData([...current, added]);
        return true;
      },
    );
  }

  Future<void> deleteVehicle(String vehicleId) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.deleteVehicle(vehicleId);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((v) => v.id != vehicleId).toList());
  }

  Future<bool> updateProfile(UserEntity updatedUser) async {
    final useCase = ref.read(updateProfileUseCaseProvider);
    final result = await useCase(updatedUser);
    return result.fold(
      (_) => false,
      (saved) {
        ref.read(authNotifierProvider.notifier).updateCurrentUserState(saved);
        return true;
      },
    );
  }
}

final userVehiclesProvider =
    AsyncNotifierProvider<UserVehiclesNotifier, List<VehicleEntity>>(
  UserVehiclesNotifier.new,
);

