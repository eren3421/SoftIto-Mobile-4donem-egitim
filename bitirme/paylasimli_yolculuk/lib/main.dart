import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/storage/local_cache_service.dart';
import 'core/storage/seed_data_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase (Authentication + Cloud Firestore) Başlatma
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint(
      '✅ Firebase başarıyla başlatıldı (projectId: ${DefaultFirebaseOptions.currentPlatform.projectId})',
    );
  } catch (e, stackTrace) {
    debugPrint('❌ Firebase başlatma hatası: $e');
    debugPrint('$stackTrace');
  }

  // 2. Hive tabanlı LocalCacheService kutularını başlat ve eski demo/test verilerini tek seferlik sıfırla
  final localCacheService = LocalCacheService();
  await localCacheService.initBoxes();
  await localCacheService.purgeLegacyDemoDataOnce();

  final seedDataService = SeedDataService(localCacheService);

  runApp(
    ProviderScope(
      overrides: [
        localCacheServiceProvider.overrideWithValue(localCacheService),
        seedDataServiceProvider.overrideWithValue(seedDataService),
      ],
      child: const PaylasimliYolculukApp(),
    ),
  );
}
