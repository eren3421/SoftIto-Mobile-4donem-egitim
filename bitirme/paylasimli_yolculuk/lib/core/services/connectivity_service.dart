import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `connectivity_plus` tabanlı ağ bağlantısı kontrol servisi.
/// 04_firebase_ve_local_storage_entegrasyonu.md Bölüm 1 ve Bölüm 4'teki
/// Network-First + Offline-Fallback (Çevrimdışı Senkronizasyon) mimarisini destekler.
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  /// Cihazda aktif bir internet (Wi-Fi, Mobil Veri, Ethernet) bağlantısı olup olmadığını kontrol eder.
  Future<bool> hasActiveConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.isNotEmpty &&
          !results.every((r) => r == ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }

  /// Bağlantı durumu değişikliklerini gerçek zamanlı dinler.
  Stream<bool> get onConnectionChanged {
    return _connectivity.onConnectivityChanged.map(
      (results) =>
          results.isNotEmpty &&
          !results.every((r) => r == ConnectivityResult.none),
    );
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

