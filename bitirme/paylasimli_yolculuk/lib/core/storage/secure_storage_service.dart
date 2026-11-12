import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

/// 04_firebase_ve_local_storage_entegrasyonu.md Bölüm 3.2:
/// Hassas oturum bilgilerini (`uid`, `email`, `auth_token`) şifreli olarak saklar.
class SecureStorageService {
  final FlutterSecureStorage? _secureStorage;
  final Map<String, String> _memoryFallback = {};
  final bool _useMemoryFallback;

  static const String _keyUserId = StorageKeys.secureUserId;
  static const String _keyUserEmail = StorageKeys.secureUserEmail;

  SecureStorageService({
    FlutterSecureStorage? secureStorage,
    bool useMemoryFallback = false,
  })  : _secureStorage = secureStorage ??
            (useMemoryFallback
                ? null
                : const FlutterSecureStorage(
                    aOptions: AndroidOptions(encryptedSharedPreferences: true),
                  )),
        _useMemoryFallback = useMemoryFallback;

  Future<void> saveSession({
    required String userId,
    String? email,
    String? authToken,
    String? refreshToken,
  }) async {
    final resolvedToken = authToken ?? 'firebase_session_$userId';
    try {
      _memoryFallback[_keyUserId] = userId;
      if (email != null) _memoryFallback[_keyUserEmail] = email;
      _memoryFallback[StorageKeys.secureAuthToken] = resolvedToken;
      if (refreshToken != null) {
        _memoryFallback[StorageKeys.secureRefreshToken] = refreshToken;
      }

      if (_useMemoryFallback || _secureStorage == null) {
        return;
      }
      await _secureStorage.write(key: _keyUserId, value: userId);
      if (email != null) {
        await _secureStorage.write(key: _keyUserEmail, value: email);
      }
      await _secureStorage.write(
        key: StorageKeys.secureAuthToken,
        value: resolvedToken,
      );
      if (refreshToken != null) {
        await _secureStorage.write(
          key: StorageKeys.secureRefreshToken,
          value: refreshToken,
        );
      }
    } catch (_) {
      // Web veya masaüstünde keychain izni yoksa bellek yedeği aktif kalır
    }
  }

  Future<String?> getUserId() async {
    try {
      if (_useMemoryFallback || _secureStorage == null) {
        return _memoryFallback[_keyUserId];
      }
      return await _secureStorage.read(key: _keyUserId) ??
          _memoryFallback[_keyUserId];
    } catch (_) {
      return _memoryFallback[_keyUserId];
    }
  }

  Future<String?> getUserEmail() async {
    try {
      if (_useMemoryFallback || _secureStorage == null) {
        return _memoryFallback[_keyUserEmail];
      }
      return await _secureStorage.read(key: _keyUserEmail) ??
          _memoryFallback[_keyUserEmail];
    } catch (_) {
      return _memoryFallback[_keyUserEmail];
    }
  }

  Future<String?> getAuthToken() async {
    try {
      if (_useMemoryFallback || _secureStorage == null) {
        return _memoryFallback[StorageKeys.secureAuthToken];
      }
      return await _secureStorage.read(key: StorageKeys.secureAuthToken) ??
          _memoryFallback[StorageKeys.secureAuthToken];
    } catch (_) {
      return _memoryFallback[StorageKeys.secureAuthToken];
    }
  }

  Future<void> clearSession() async {
    _memoryFallback.clear();
    try {
      if (!_useMemoryFallback && _secureStorage != null) {
        await _secureStorage.deleteAll();
      }
    } catch (_) {}
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
