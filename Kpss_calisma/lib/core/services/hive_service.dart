// Flutter için optimize edilmiş Hive yerel NoSQL veritabanı kütüphanesini içe aktarıyoruz
import 'package:hive_flutter/hive_flutter.dart';
// Uygulama sabitlerini (kutu isimleri vb.) içe aktarıyoruz
import '../constants/app_constants.dart';

// Hive veritabanını başlatan ve kutulara (tablolara) erişim sağlayan servis sınıfı
class HiveService {
  // Hive veritabanını başlatan ve gerekli tüm kutuları açan asenkron metot
  static Future<void> init() async {
    // Hive'ı Flutter'ın dosya sistemi dizininde başlatıyoruz
    await Hive.initFlutter();

    // Uygulamada kullanılacak tüm kutuları eşzamanlı ve hızlı şekilde açıyoruz
    await Future.wait([
      // Ayarlar kutusunu açar
      Hive.openBox(AppConstants.settingsBox),
      // Konu durumları kutusunu açar
      Hive.openBox(AppConstants.topicStatusBox),
      // Soru kayıtları kutusunu açar
      Hive.openBox(AppConstants.questionLogsBox),
      // Çalışma oturumları kutusunu açar
      Hive.openBox(AppConstants.studySessionsBox),
      // Deneme sınavları kutusunu açar
      Hive.openBox(AppConstants.mockExamsBox),
    ]);
  }

  // Ayarlar kutusuna doğrudan erişim sağlayan getter
  static Box get settingsBox => Hive.box(AppConstants.settingsBox);

  // Konu durum kutusuna doğrudan erişim sağlayan getter
  static Box get topicStatusBox => Hive.box(AppConstants.topicStatusBox);

  // Soru kayıtları kutusuna doğrudan erişim sağlayan getter
  static Box get questionLogsBox => Hive.box(AppConstants.questionLogsBox);

  // Çalışma süreleri kutusuna doğrudan erişim sağlayan getter
  static Box get studySessionsBox => Hive.box(AppConstants.studySessionsBox);

  // Deneme sınavları kutusuna doğrudan erişim sağlayan getter
  static Box get mockExamsBox => Hive.box(AppConstants.mockExamsBox);
}
