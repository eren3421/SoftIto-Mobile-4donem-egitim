import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../local/hive_storage_service.dart';
import '../models/user_model.dart';
import '../services/mail_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    storage: HiveStorageService.instance,
    mailService: MailService.instance,
  );
});

final currentUserProvider = StateProvider<UserModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getCurrentUser();
});

class AuthRepository {
  final HiveStorageService _storage;
  final MailService _mailService;

  AuthRepository({
    required HiveStorageService storage,
    required MailService mailService,
  })  : _storage = storage,
        _mailService = mailService;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password.trim());
    return sha256.convert(bytes).toString();
  }

  UserModel? getCurrentUser() {
    final uid = _storage.getCurrentUserId();
    if (uid == null) return null;
    return _storage.getUserById(uid);
  }

  /// Giriş Yap (Username veya E-posta ve Şifre ile)
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.trim();
    var user = _storage.getUserByUsername(cleanUsername);
    user ??= _storage.getUserByEmail(cleanUsername);

    if (user == null) {
      throw Exception('Kullanıcı bulunamadı. Lütfen kullanıcı adınızı veya e-postanızı kontrol edin.');
    }

    final hash = _hashPassword(password);
    if (user.passwordHash != hash) {
      throw Exception('Hatalı şifre girdiniz.');
    }

    await _storage.setCurrentUserId(user.id);
    return user;
  }

  /// Kayıt Ol ve E-posta Doğrulama Kodu Gönder
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final cleanUsername = username.trim();
    final cleanEmail = email.trim();

    if (_storage.getUserByUsername(cleanUsername) != null) {
      throw Exception('Bu kullanıcı adı zaten kullanılmaktadır.');
    }

    if (_storage.getUserByEmail(cleanEmail) != null) {
      throw Exception('Bu e-posta adresiyle zaten bir hesap mevcut.');
    }

    final user = UserModel(
      id: const Uuid().v4(),
      username: cleanUsername,
      email: cleanEmail,
      passwordHash: _hashPassword(password),
      isVerified: true, // OTP doğrulaması ile tam aktifleşir
    );

    await _storage.saveUser(user);
    await _storage.setCurrentUserId(user.id);

    // OTP Gönder
    final otp = _mailService.generateOtp();
    await _mailService.sendVerificationEmail(toEmail: cleanEmail, otpCode: otp);

    return user;
  }

  /// Şifre Yenileme İçin Kod Gönder (Adım 1)
  Future<String> sendResetPasswordCode(String email) async {
    final user = _storage.getUserByEmail(email.trim());
    if (user == null) {
      throw Exception('Bu e-posta adresine kayıtlı bir kullanıcı bulunamadı.');
    }

    final otp = _mailService.generateOtp();
    await _mailService.sendVerificationEmail(
      toEmail: email.trim(),
      otpCode: otp,
      subject: 'MENTOR - Şifre Yenileme Kodu',
    );
    return otp;
  }

  /// OTP Doğrula
  bool verifyOtpCode(String email, String otp) {
    return _mailService.verifyOtp(email, otp);
  }

  /// Şifre Yenile (Adım 2)
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final user = _storage.getUserByEmail(email.trim());
    if (user == null) {
      throw Exception('Kullanıcı bulunamadı.');
    }

    final updated = user.copyWith(
      passwordHash: _hashPassword(newPassword),
    );

    await _storage.saveUser(updated);
  }

  /// Çıkış Yap
  Future<void> logout() async {
    await _storage.setCurrentUserId(null);
  }

  /// Hesabı Sil (Kullanıcının tüm yerel verilerini kalıcı olarak yok eder)
  Future<void> deleteAccount(String userId) async {
    await _storage.deleteUserAccountCompletely(userId);
  }
}
