import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Kimlik doğrulama ve oturum yönetimi soyut sözleşmesi.
abstract class IAuthRepository {
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    String role = 'both',
  });

  Future<Result<UserEntity?>> getCurrentUser();

  Future<Result<UserEntity>> switchDemoAccount(String userId);

  Future<Result<void>> logout();
}

