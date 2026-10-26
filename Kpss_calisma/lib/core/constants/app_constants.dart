// Uygulama genelinde kullanılan değişmez (statik) sabit değerleri barındıran sınıf
class AppConstants {
  // Uygulamanın ana başlık adı
  static const String appName = 'KPSS';

  // Uygulamanın alt başlık / slogan metni
  static const String appSubtitle = 'Çalışma Koçu';

  // Uygulama sürüm numarası
  static const String appVersion = '1.0.0';

  // --- Hive Veritabanı Kutu (Tablo) İsimleri ---
  // Kullanıcı ayarlarının saklandığı kutunun adı
  static const String settingsBox = 'settings_box';

  // Konuların tamamlanma durumlarının saklandığı kutunun adı
  static const String topicStatusBox = 'topic_status_box';

  // Çözülen soru kayıtlarının tutulduğu kutunun adı
  static const String questionLogsBox = 'question_logs_box';

  // Sayaç ve Pomodoro çalışma oturumlarının tutulduğu kutunun adı
  static const String studySessionsBox = 'study_sessions_box';

  // Kaydedilen deneme sınavı sonuçlarının tutulduğu kutunun adı
  static const String mockExamsBox = 'mock_exams_box';

  // --- Ayarlar Kutusu İçindeki Anahtar (Key) Değerleri ---
  // Günlük soru çözme hedefi anahtarı
  static const String keyDailyGoal = 'dailyGoal';

  // Karanlık tema aktif mi bilgisini saklayan anahtar
  static const String keyIsDarkTheme = 'isDark';

  // Uygulamanın ilk kez açılıp açılmadığını denetleyen anahtar
  static const String keyFirstRun = 'firstRun';

  // --- Varsayılan Başlangıç Değerleri ---
  // Varsayılan günlük soru hedefi adedi
  static const int defaultDailyGoal = 100;

  // Varsayılan Pomodoro çalışma süresi (dakika)
  static const int defaultPomodoroMinutes = 25;

  // Varsayılan Pomodoro mola süresi (dakika)
  static const int defaultShortBreakMinutes = 5;

  // --- Konu Tamamlanma Durum Kodları ---
  // Konuya henüz başlanmadı (0)
  static const int statusNotStarted = 0;

  // Konu çalışıldı ancak tekrar edilmesi gerekiyor (1)
  static const int statusNeedsReview = 1;

  // Konu tamamen bitirildi ve kavrandı (2)
  static const int statusCompleted = 2;

  // --- Sabit Dosya (Asset) Yolları ---
  // KPSS müfredatını içeren yerel JSON dosyasının yolu
  static const String assetTopicsJson = 'assets/kpss_topics.json';

  // Uygulama logo görselinin dosya yolu
  static const String assetLogo = 'assets/images/kpss_logo.jpg';

  // Uygulama simgesinin dosya yolu
  static const String assetIcon = 'assets/icons/app_icon.png';
}
