import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/seed_data_service.dart';
import '../models/user_model.dart';

/// Uzak veri kaynağı (Single Source of Truth = Cloud Firestore + Firebase Auth).
class AuthRemoteDataSource {
  final SeedDataService seedService;
  final bool useMockData;

  AuthRemoteDataSource({
    required this.seedService,
    required this.useMockData,
  });

  /// E-posta (salt) ve şifre üzerinden deterministik, tek yönlü karma (hash) üretir.
  /// Böylece Firebase Auth kapalı olsa bile Firestore üzerinden şifre doğrulaması
  /// kesin olarak yapılır ve yanlış şifreyle giriş engellenir.
  String _hashPassword(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    final bytes = utf8.encode('py_salt_v1:$normalizedEmail:$password');
    int h1 = 0x811c9dc5;
    int h2 = 0xcbf29ce4;
    for (int i = 0; i < bytes.length; i++) {
      final b = bytes[i];
      h1 ^= b;
      h1 = (h1 * 0x01000193) & 0xFFFFFFFF;
      h2 ^= (b + i) & 0xFF;
      h2 = (h2 * 0x01000193) & 0xFFFFFFFF;
    }
    return '${h1.toRadixString(16).padLeft(8, '0')}${h2.toRadixString(16).padLeft(8, '0')}';
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _findUserDocByEmail(
    String email,
  ) async {
    final trimmed = email.trim();
    final normalized = trimmed.toLowerCase();

    final querySnap = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: trimmed)
        .limit(1)
        .get();
    if (querySnap.docs.isNotEmpty) {
      return querySnap.docs.first;
    }

    final allUsersSnap =
        await FirebaseFirestore.instance.collection('users').get();
    for (final doc in allUsersSnap.docs) {
      final data = doc.data();
      if ((data['email']?.toString().toLowerCase() ?? '') == normalized) {
        return doc;
      }
    }
    return null;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final expectedHash = _hashPassword(trimmedEmail, password);

    // 1. Önce Firestore `users` koleksiyonunda kullanıcı belgesini bul
    DocumentSnapshot<Map<String, dynamic>>? userDoc;
    try {
      userDoc = await _findUserDocByEmail(trimmedEmail);
    } catch (e) {
      throw AuthException('Veritabanı bağlantı hatası: $e');
    }

    // 2. Eğer Firestore belgesinde `passwordHash` kayıtlıysa doğrudan doğrula
    if (userDoc != null && userDoc.data() != null) {
      final data = userDoc.data()!;
      final storedHash = data['passwordHash']?.toString();
      if (storedHash != null && storedHash.isNotEmpty) {
        if (storedHash != expectedHash) {
          throw const AuthException(
            'E-posta veya şifre hatalı. Lütfen şifrenizi kontrol edin.',
          );
        }
        // Şifre doğru; varsa Firebase Auth oturumunu da arka planda aç
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: trimmedEmail,
            password: password,
          );
        } catch (_) {}
        return UserModel.fromJson({...data, 'id': userDoc.id});
      }
    }

    // 3. Belgede henüz `passwordHash` yoksa (veya kullanıcı sadece Firebase Auth'da varsa)
    // Firebase Auth üzerinden şifre doğrulamasını zorunlu tut
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      final authUid = credential.user?.uid;
      if (authUid != null) {
        final docRef =
            FirebaseFirestore.instance.collection('users').doc(authUid);
        final doc = await docRef.get();
        if (doc.exists && doc.data() != null) {
          // Doğrulanan şifrenin hash değerini Firestore belgesine de kaydet
          await docRef.set(
            {'passwordHash': expectedHash},
            SetOptions(merge: true),
          );
          return UserModel.fromJson({...doc.data()!, 'id': doc.id});
        }
      }
      if (userDoc != null && userDoc.data() != null) {
        await userDoc.reference.set(
          {'passwordHash': expectedHash},
          SetOptions(merge: true),
        );
        return UserModel.fromJson({...userDoc.data()!, 'id': userDoc.id});
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' && userDoc == null) {
        throw const AuthException(
          'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı. Lütfen önce kayıt olun.',
        );
      }
      throw const AuthException(
        'E-posta veya şifre hatalı. Lütfen şifrenizi kontrol edin.',
      );
    } catch (_) {
      throw const AuthException(
        'E-posta veya şifre hatalı. Lütfen şifrenizi kontrol edin.',
      );
    }

    throw const AuthException(
      'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı. Lütfen önce kayıt olun.',
    );
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    String role = 'both',
  }) async {
    final now = DateTime.now();
    final trimmedEmail = email.trim();
    final expectedHash = _hashPassword(trimmedEmail, password);

    // 1. Önce Firestore'da bu e-postaya ait mevcut bir kullanıcı var mı kontrol et
    DocumentSnapshot<Map<String, dynamic>>? existingDoc;
    try {
      existingDoc = await _findUserDocByEmail(trimmedEmail);
    } catch (_) {}

    // Eğer Firestore'da zaten bu kullanıcı varsa:
    if (existingDoc != null && existingDoc.data() != null) {
      final data = existingDoc.data()!;
      final storedHash = data['passwordHash']?.toString();
      // Şifre eşleşiyorsa doğrudan oturum açıp kullanıcıyı döndür
      if (storedHash != null && storedHash == expectedHash) {
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: trimmedEmail,
            password: password,
          );
        } catch (_) {}
        return UserModel.fromJson({...data, 'id': existingDoc.id});
      }
      throw const AuthException(
        'Bu e-posta adresiyle zaten bir hesap mevcut. Lütfen giriş yapın.',
      );
    }

    // 2. Firebase Auth üzerinde kullanıcı oluşturmayı dene
    String? userId;
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      userId = credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Firebase Auth'ta hesap zaten var; verilen şifre ile giriş yapmayı dene
        try {
          final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: trimmedEmail,
            password: password,
          );
          userId = cred.user?.uid;
        } catch (_) {
          throw const AuthException(
            'Bu e-posta adresiyle zaten bir hesap mevcut. Lütfen giriş yapın veya şifrenizi kontrol edin.',
          );
        }
      } else if (e.code == 'weak-password') {
        throw const AuthException('Şifre en az 6 karakter olmalıdır.');
      } else if (e.code == 'invalid-email') {
        throw const AuthException('Geçersiz e-posta adresi formatı.');
      } else {
        debugPrint(
          'ℹ️ FirebaseAuth bilgi notu (${e.code}) -> Firestore kaydı ile devam ediliyor.',
        );
      }
    } catch (e) {
      debugPrint(
        'ℹ️ FirebaseAuth bilgi notu ($e) -> Firestore kaydı ile devam ediliyor.',
      );
    }

    final docRef = userId != null
        ? FirebaseFirestore.instance.collection('users').doc(userId)
        : FirebaseFirestore.instance.collection('users').doc();
    final finalId = docRef.id;

    final newUser = UserModel(
      id: finalId,
      email: trimmedEmail,
      fullName: fullName.trim(),
      phoneNumber: phoneNumber.trim(),
      bio: '',
      role: role,
      isVerified: true,
      ratingAvg: 0.0,
      ratingCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    // 3. Önce FirebaseFirestore üzerine (şifre karması ve seçilen rol ile birlikte) yaz
    try {
      await docRef.set({
        ...newUser.toFirestore(),
        'passwordHash': expectedHash,
      }, SetOptions(merge: true));
      debugPrint(
        '✅ Kullanıcı Firestore `users/$finalId` belgesine (role: $role) yazıldı.',
      );
    } catch (e) {
      throw AuthException('Kullanıcı Firestore\'a kaydedilemedi: $e');
    }

    return newUser;
  }

  Future<UserModel> getDemoUserById(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson({...doc.data()!, 'id': doc.id});
    }
    throw const AuthException('Kullanıcı bulunamadı.');
  }
}
