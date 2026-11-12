import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/seed_data_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final seed = ref.watch(seedDataServiceProvider);
  final useMock = ref.watch(useMockDataProvider);
  return AuthRemoteDataSource(seedService: seed, useMockData: useMock);
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localCacheService: ref.watch(localCacheServiceProvider),
    secureStorageService: ref.watch(secureStorageServiceProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

/// Kimlik doğrulama ve aktif kullanıcı durumunu yöneten AsyncNotifier.
class AuthNotifier extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() async {
    final seed = ref.read(seedDataServiceProvider);
    await seed.ensureSeeded();
    final useCase = ref.read(getCurrentUserUseCaseProvider);
    final result = await useCase();
    return result.fold((_) => null, (user) => user);
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final useCase = ref.read(loginUseCaseProvider);
    final result = await useCase(email: email, password: password);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (user) {
        state = AsyncData(user);
        return true;
      },
    );
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    String role = 'both',
  }) async {
    state = const AsyncLoading();
    final useCase = ref.read(registerUseCaseProvider);
    final result = await useCase(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      role: role,
    );
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (user) {
        state = AsyncData(user);
        return true;
      },
    );
  }

  Future<void> switchDemoAccount(String userId) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.switchDemoAccount(userId);
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (user) => state = AsyncData(user),
    );
  }

  void updateCurrentUserState(UserEntity updatedUser) {
    state = AsyncData(updatedUser);
  }

  Future<void> refreshCurrentUser() async {
    final useCase = ref.read(getCurrentUserUseCaseProvider);
    final result = await useCase();
    result.fold((_) {}, (user) {
      if (user != null) state = AsyncData(user);
    });
  }

  Future<void> logout() async {
    final useCase = ref.read(logoutUseCaseProvider);
    await useCase();
    state = const AsyncData(null);
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, UserEntity?>(
  AuthNotifier.new,
);

