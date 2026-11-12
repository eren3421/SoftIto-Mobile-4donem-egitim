import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final IAuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<Result<UserEntity>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}

class RegisterUseCase {
  final IAuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<Result<UserEntity>> call({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    String role = 'both',
  }) {
    return _repository.register(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      role: role,
    );
  }
}

class GetCurrentUserUseCase {
  final IAuthRepository _repository;
  const GetCurrentUserUseCase(this._repository);

  Future<Result<UserEntity?>> call() => _repository.getCurrentUser();
}

class LogoutUseCase {
  final IAuthRepository _repository;
  const LogoutUseCase(this._repository);

  Future<Result<void>> call() => _repository.logout();
}

