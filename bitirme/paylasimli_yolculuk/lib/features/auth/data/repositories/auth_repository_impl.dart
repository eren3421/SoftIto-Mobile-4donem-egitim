import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Single Source of Truth = Cloud Firestore, Cache = Hive (`LocalCacheService`).
/// Tüm oturum ve kayıt işlemlerinde önce Firestore'dan doğrular/yazar, hemen ardından
/// aynı belge ID'si ile Hive kutusunu (`box_user_session`) günceller.
class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final LocalCacheService localCacheService;
  final SecureStorageService secureStorageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localCacheService,
    required this.secureStorageService,
  });

  @override
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );
      await _persistSessionToHive(userModel);
      return Result.success(userModel);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } catch (e) {
      return Result.failure(AuthFailure('Beklenmeyen giriş hatası: $e'));
    }
  }

  @override
  Future<Result<UserEntity>> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    String role = 'both',
  }) async {
    try {
      // 1. Önce Firestore'da tekil ID ile oluşturulur
      final userModel = await remoteDataSource.register(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        role: role,
      );
      // 2. Hemen ardından aynı ID ile Hive yerel kutusuna kaydedilir
      await _persistSessionToHive(userModel);
      return Result.success(userModel);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } catch (e) {
      return Result.failure(AuthFailure('Kayıt sırasında hata oluştu: $e'));
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final cachedJson = localCacheService.getUserSession();
      String? userId = cachedJson?['id']?.toString();
      userId ??= await secureStorageService.getUserId();

      if (userId == null || userId.isEmpty) {
        return Result.success(null);
      }

      // İnternet varken Firestore'dan güncel kullanıcıyı çek ve Hive üzerine yaz
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (doc.exists && doc.data() != null) {
          final freshUser = UserModel.fromJson({...doc.data()!, 'id': doc.id});
          await _persistSessionToHive(freshUser);
          return Result.success(freshUser);
        }
      } catch (_) {
        // Çevrimdışı durumda doğrudan Hive'dan oku
      }

      if (cachedJson != null) {
        return Result.success(UserModel.fromJson(cachedJson));
      }
      final byId = localCacheService.getUserById(userId);
      if (byId != null) {
        return Result.success(UserModel.fromJson(byId));
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure('Oturum bilgisi okunamadı: $e'));
    }
  }

  @override
  Future<Result<UserEntity>> switchDemoAccount(String userId) async {
    try {
      final userModel = await remoteDataSource.getDemoUserById(userId);
      await _persistSessionToHive(userModel);
      return Result.success(userModel);
    } catch (e) {
      return Result.failure(AuthFailure('Hesap değiştirilemedi: $e'));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
      // Kullanıcı çıkış yaptığında tüm yerel Hive kutularını ve güvenli oturumu temizle
      await localCacheService.clearAll();
      await secureStorageService.clearSession();
      return Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure('Çıkış yapılırken hata oluştu: $e'));
    }
  }

  Future<void> _persistSessionToHive(UserModel user) async {
    await localCacheService.saveUserSession(user.toJson());
    await localCacheService.saveUserById(user.id, user.toJson());
    await secureStorageService.saveSession(
      userId: user.id,
      email: user.email,
      authToken: 'jwt_token_${user.id}',
      refreshToken: 'refresh_token_${user.id}',
    );
  }
}
