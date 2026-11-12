/// Veri katmanında (Data Source) fırlatılan özel istisnalar.
class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException(this.message, {this.code});

  @override
  String toString() => 'ServerException: $message (code: $code)';
}

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class SeatQuotaException implements Exception {
  final String message;

  const SeatQuotaException(this.message);

  @override
  String toString() => 'SeatQuotaException: $message';
}

