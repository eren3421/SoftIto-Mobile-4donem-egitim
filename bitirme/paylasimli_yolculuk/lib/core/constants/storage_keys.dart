/// Yerel depolama (Hive, SharedPreferences ve FlutterSecureStorage) anahtarları.
class StorageKeys {
  StorageKeys._();

  // Hive Box İsimleri (02_veri_depolama_ve_sema.md & 04_firebase_ve_local_storage_entegrasyonu.md)
  static const String boxUserSession = 'box_user_session';
  static const String boxMyRides = 'box_my_rides';
  static const String boxMyBookings = 'box_my_bookings';
  static const String boxSearchHistory = 'box_search_history';
  static const String boxBookings = 'box_my_bookings';
  static const String boxChats = 'box_chats';
  static const String boxVehicles = 'box_vehicles';
  static const String boxReviews = 'box_reviews';

  // Box İçi Anahtarlar
  static const String keyCurrentUser = 'current_user';
  static const String keyCachedRidesList = 'cached_rides_list';
  static const String keyMyBookingsList = 'my_bookings_list';
  static const String keySearchHistoryList = 'search_history_list';
  static const String keyRecentMessagesPrefix = 'recent_messages_';

  // Secure Storage Anahtarları (04_firebase_ve_local_storage_entegrasyonu.md Bölüm 3.2)
  static const String secureUserId = 'secure_user_id';
  static const String secureUserEmail = 'secure_user_email';
  static const String secureAuthToken = 'secure_auth_token';
  static const String secureRefreshToken = 'secure_refresh_token';
  static const String secureBiometricKey = 'secure_biometric_key';

  // SharedPreferences Anahtarları
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefLanguage = 'pref_language';
  static const String prefOnboardingDone = 'pref_onboarding_done';
  static const String prefUseMockData = 'pref_use_mock_data';
  static const String prefOfflineMode = 'pref_offline_mode';
}
