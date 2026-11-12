import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sahte/demo veri tohumlama devre dışı bırakılmıştır.
/// Uygulama tüm verileri doğrudan Cloud Firestore (Single Source of Truth)
/// ve Hive yerel önbelleği üzerinden yönetir.
class FirestoreSeeder {
  final FirebaseFirestore _firestore;

  FirestoreSeeder(this._firestore);

  Future<void> seedInitialDataIfNeeded({bool force = false}) async {
    // Sahte veri ekleme kaldırıldı.
    final _ = _firestore;
  }
}

final firestoreSeederProvider = Provider<FirestoreSeeder>((ref) {
  return FirestoreSeeder(FirebaseFirestore.instance);
});
