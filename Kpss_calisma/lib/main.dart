// Flutter'ın temel Material Design widget ve bileşen kütüphanesini içe aktarıyoruz
import 'package:flutter/material.dart';
// Durum yönetimi (State Management) için Provider paketini içe aktarıyoruz
import 'package:provider/provider.dart';
// Uygulama adı, sabit metinler ve konfigürasyonları içe aktarıyoruz
import 'core/constants/app_constants.dart';
// Yerel Hive NoSQL veritabanı servisini içe aktarıyoruz
import 'core/services/hive_service.dart';
// Açık ve koyu tema tasarımlarını içeren tema sınıfımızı içe aktarıyoruz
import 'core/theme/app_theme.dart';
// Uygulamanın alt gezinti çubuğuna ve ana ekranlarına sahip ana iskeletini içe aktarıyoruz
import 'main_screen.dart';
// Müfredat ve konu takip durumlarını yöneten provider'ı içe aktarıyoruz
import 'providers/curriculum_provider.dart';
// Deneme sınavı sonuçlarını yöneten provider'ı içe aktarıyoruz
import 'providers/mock_exam_provider.dart';
// Soru çözümleri ve çalışma sürelerini yöneten provider'ı içe aktarıyoruz
import 'providers/question_provider.dart';
// Kullanıcı hedefleri ve tema ayarlarını yöneten provider'ı içe aktarıyoruz
import 'providers/settings_provider.dart';
// Pomodoro ve kronometre çalışma sayacını yöneten provider'ı içe aktarıyoruz
import 'providers/timer_provider.dart';

// Dart ve Flutter uygulamasının giriş noktası olan ana asenkron fonksiyon
Future<void> main() async {
  // Flutter widget motorunun yerel işletim sistemiyle iletişimini garanti altına alıyoruz
  WidgetsFlutterBinding.ensureInitialized();

  // Hive yerel veritabanı kutularını (boxes) asenkron olarak başlatıyoruz
  await HiveService.init();

  // Uygulamanın en üst seviyesinde provider'ları tanımlayarak uygulamayı başlatıyoruz
  runApp(
    // Tüm uygulama genelinde erişilebilir birden fazla provider tanımlamak için MultiProvider kullanıyoruz
    MultiProvider(
      providers: [
        // Tema ve hedef soru sayısı ayarlarını sağlayan sağlayıcı
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        // KPSS ders ve konu listesi ilerlemesini yöneten sağlayıcı
        ChangeNotifierProvider(create: (_) => CurriculumProvider()),
        // Günlük ve genel soru çözümlerini yöneten sağlayıcı
        ChangeNotifierProvider(create: (_) => QuestionProvider()),
        // Pomodoro ve süre tutma işlemlerini yöneten sağlayıcı
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        // Deneme sınavı sonuçları ve netlerini yöneten sağlayıcı
        ChangeNotifierProvider(create: (_) => MockExamProvider()),
      ],
      // Uygulamanın kök widget'ı
      child: const KpssApp(),
    ),
  );
}

// KPSS Çalışma Koçu uygulamasının kök (root) StatelessWidget widget'ı
class KpssApp extends StatelessWidget {
  // Kök widget kurucusu
  const KpssApp({super.key});

  @override
  Widget build(BuildContext context) {
    // SettingsProvider'ı dinleyerek tema değişikliklerinde arayüzün anında güncellenmesini sağlıyoruz
    final settingsProv = context.watch<SettingsProvider>();

    // Flutter'ın temel Material uygulama yapılandırıcısını döndürüyoruz
    return MaterialApp(
      // Cihazın görev yöneticisinde ve sistemde görünen uygulama adı
      title: AppConstants.appName,
      // Sağ üstteki hata ayıklama (DEBUG) bandını gizliyoruz
      debugShowCheckedModeBanner: false,
      // Uygulamanın açık (light) teması
      theme: AppTheme.lightTheme,
      // Uygulamanın koyu (dark) teması
      darkTheme: AppTheme.darkTheme,
      // Kullanıcının tercihine göre temanın açık mı koyu mu olacağını belirliyoruz
      themeMode: settingsProv.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      // Uygulama açıldığında gösterilecek ilk ana ekran (MainScreen)
      home: const MainScreen(),
    );
  }
}
