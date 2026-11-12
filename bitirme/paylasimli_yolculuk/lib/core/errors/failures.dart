/// Domain ve Presentation katmanlarında kullanılan hata sınıfları.
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

class SeatQuotaFailure extends Failure {
  const SeatQuotaFailure(super.message, {super.code});
}

/// Fonksiyonel hata yönetimi için hafif Either/Result yapısı.
class Result<T> {
  final T? data;
  final Failure? failure;

  const Result._({this.data, this.failure});

  factory Result.success(T data) => Result._(data: data);
  factory Result.failure(Failure failure) => Result._(failure: failure);

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    if (failure != null) {
      return onFailure(failure!);
    }
    return onSuccess(data as T);
  }
}

