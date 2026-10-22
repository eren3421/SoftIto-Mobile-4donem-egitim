import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'data/local/hive_storage_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/services/notification_service.dart';
import 'features/auth/login_screen.dart';
import 'features/habits/home_habits_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe tarih formatlama sembollerini başlat
  try {
    await initializeDateFormatting('tr_TR', null);
  } catch (e) {
    debugPrint('Date formatting init error: $e');
  }

  // Yerel depolama (Hive boxes) başlat
  await HiveStorageService.instance.init();

  // Kayıtlı Hugging Face Token varsa AppConfig'e yükle
  final savedHfToken = HiveStorageService.instance.getHfToken();
  if (savedHfToken != null && savedHfToken.trim().isNotEmpty) {
    AppConfig.huggingFaceToken = savedHfToken.trim();
  }

  // Bildirim servisini başlat
  await NotificationService.instance.init();

  runApp(
    const ProviderScope(
      child: MentorApp(),
    ),
  );
}

class MentorApp extends ConsumerWidget {
  const MentorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return MaterialApp(
      title: 'MENTOR - Alışkanlık Takibi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: currentUser != null ? const HomeHabitsScreen() : const LoginScreen(),
    );
  }
}
