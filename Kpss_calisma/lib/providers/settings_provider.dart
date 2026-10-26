// Flutter'ın temel arayüz kütüphanesini içe aktarıyoruz
import 'package:flutter/material.dart';
// Uygulama sabitlerini (anahtarlar ve varsayılan değerler) içe aktarıyoruz
import '../core/constants/app_constants.dart';
// Hive yerel veritabanı servisini içe aktarıyoruz
import '../core/services/hive_service.dart';

// Kullanıcı ayarlarını (hedef soru sayısı, açık/koyu tema) yöneten ve UI'ı güncelleyen Provider sınıfı
class SettingsProvider with ChangeNotifier {
  // Günlük soru hedefini saklayan özel (private) değişken
  late int _dailyGoal;

  // Koyu temanın açık olup olmadığını saklayan özel (private) değişken
  late bool _isDarkTheme;

  // SettingsProvider oluşturulduğunda ayarları Hive'dan yükleyen kurucu fonksiyon
  SettingsProvider() {
    _loadSettings();
  }

  // Dışarıdan günlük hedefe erişim sağlayan getter
  int get dailyGoal => _dailyGoal;

  // Dışarıdan tema durumuna erişim sağlayan getter
  bool get isDarkTheme => _isDarkTheme;

  // Hive veritabanından kaydedilmiş ayarları okuyan özel fonksiyon
  void _loadSettings() {
    // Hive ayarlar kutusunu alıyoruz
    final box = HiveService.settingsBox;

    // Günlük hedefi okuyoruz; kayıt yoksa varsayılan olarak 100 atıyoruz
    _dailyGoal = box.get(AppConstants.keyDailyGoal, defaultValue: AppConstants.defaultDailyGoal) as int;

    // Tema tercihini okuyoruz; kayıt yoksa varsayılan olarak false (açık tema) atıyoruz
    _isDarkTheme = box.get(AppConstants.keyIsDarkTheme, defaultValue: false) as bool;
  }

  // Kullanıcının belirlediği yeni günlük soru hedefini kaydeden fonksiyon
  Future<void> setDailyGoal(int newGoal) async {
    // Hedef sıfır veya negatif girilmişse işlemi iptal et
    if (newGoal <= 0) return;

    // Bellekteki hedef değerini güncelliyoruz
    _dailyGoal = newGoal;

    // Yeni hedefi kalıcı olarak Hive veritabanına yazıyoruz
    await HiveService.settingsBox.put(AppConstants.keyDailyGoal, newGoal);

    // Bu sağlayıcıyı dinleyen tüm widget'ları bilgilendirip yeniden çizdiriyoruz
    notifyListeners();
  }

  // Açık ve koyu tema arasında geçiş yapan (toggle) fonksiyon
  Future<void> toggleTheme() async {
    // Mevcut durumun tersini alıyoruz (true -> false veya false -> true)
    _isDarkTheme = !_isDarkTheme;

    // Yeni tema durumunu Hive'a kaydediyoruz
    await HiveService.settingsBox.put(AppConstants.keyIsDarkTheme, _isDarkTheme);

    // Arayüzün güncellenmesi için dinleyicilere haber veriyoruz
    notifyListeners();
  }

  // Belirli bir tema durumunu doğrudan atayan fonksiyon
  Future<void> setTheme(bool isDark) async {
    // Bellekteki tema değişkenini güncelliyoruz
    _isDarkTheme = isDark;

    // Hive'a kaydediyoruz
    await HiveService.settingsBox.put(AppConstants.keyIsDarkTheme, _isDarkTheme);

    // Dinleyicileri haberdar ediyoruz
    notifyListeners();
  }
}
