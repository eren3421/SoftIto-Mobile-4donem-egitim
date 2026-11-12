import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/storage_keys.dart';

/// Hive tabanlı Yapılandırılmış Yerel Veritabanı (NoSQL Cache) Servisi.
///
/// 04_firebase_ve_local_storage_entegrasyonu.md Bölüm 3.1 uyarınca:
/// - `box_user_session`: Aktif kullanıcının profil verisini saklar.
/// - `box_my_rides`: Kullanıcının oluşturduğu veya katıldığı yolculukları çevrimdışı erişim için saklar.
/// - `box_my_bookings`: Kullanıcının aktif rezervasyonlarını çevrimdışı bilet gösterimi için saklar.
/// - `box_search_history`: Son aranan kalkış-varış çiftlerini saklar.
class LocalCacheService {
  static const String userSessionBoxName = StorageKeys.boxUserSession;
  static const String myRidesBoxName = StorageKeys.boxMyRides;
  static const String myBookingsBoxName = StorageKeys.boxMyBookings;
  static const String searchHistoryBoxName = StorageKeys.boxSearchHistory;

  bool _isInitialized = false;

  late Box<dynamic> _userSessionBox;
  late Box<dynamic> _myRidesBox;
  late Box<dynamic> _searchHistoryBox;
  late Box<dynamic> _bookingsBox;
  late Box<dynamic> _chatsBox;
  late Box<dynamic> _vehiclesBox;
  late Box<dynamic> _reviewsBox;

  bool get isInitialized => _isInitialized;

  /// 04_firebase_ve_local_storage_entegrasyonu.md Bölüm 3.1:
  /// Tüm Hive kutularını açar (`init` ile eş anlamlı çalışır).
  Future<void> initBoxes({String? testPath}) => init(testPath: testPath);

  /// Uygulama başlangıcında (`main.dart`) veya test ortamında Hive kutularını açar.
  Future<void> init({String? testPath}) async {
    if (_isInitialized) return;

    if (testPath != null) {
      Hive.init(testPath);
    } else {
      await Hive.initFlutter();
    }

    _userSessionBox = await Hive.openBox<dynamic>(userSessionBoxName);
    _myRidesBox = await Hive.openBox<dynamic>(myRidesBoxName);
    _bookingsBox = await Hive.openBox<dynamic>(myBookingsBoxName);
    _searchHistoryBox = await Hive.openBox<dynamic>(searchHistoryBoxName);
    _chatsBox = await Hive.openBox<dynamic>(StorageKeys.boxChats);
    _vehiclesBox = await Hive.openBox<dynamic>(StorageKeys.boxVehicles);
    _reviewsBox = await Hive.openBox<dynamic>(StorageKeys.boxReviews);

    _isInitialized = true;
  }

  // ---------------------------------------------------------------------------
  // 04_firebase_ve_local_storage_entegrasyonu.md Bölüm 3.1 Genel JSON Metodları
  // ---------------------------------------------------------------------------

  /// Liste önbellekleme (Örn: Yolculuklarım veya Rezervasyonlarım)
  Future<void> cacheJsonList(
    String boxName,
    String key,
    List<Map<String, dynamic>> items,
  ) async {
    final box = Hive.box<dynamic>(boxName);
    await box.put(key, jsonEncode(items));
  }

  /// Önbellekten JSON listesi okuma
  List<Map<String, dynamic>> getCachedJsonList(String boxName, String key) {
    final box = Hive.box<dynamic>(boxName);
    final raw = box.get(key);
    if (raw == null) return [];
    if (raw is String) {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  /// Tekil nesne önbellekleme (Örn: Kullanıcı Profili)
  Future<void> cacheJsonObject(
    String boxName,
    String key,
    Map<String, dynamic> data,
  ) async {
    final box = Hive.box<dynamic>(boxName);
    await box.put(key, jsonEncode(data));
  }

  /// Önbellekten tekil JSON nesnesi okuma
  Map<String, dynamic>? getCachedJsonObject(String boxName, String key) {
    final box = Hive.box<dynamic>(boxName);
    final raw = box.get(key);
    if (raw == null) return null;
    if (raw is String) {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  /// Tüm yerel önbelleği temizler (`clearAll` ile eş anlamlı).
  Future<void> clearAllCache() => clearAll();

  // ---------------------------------------------------------------------------
  // 1. Oturum Açmış Kullanıcı ve Tüm Kullanıcılar Önbelleği (`box_user_session`)
  // ---------------------------------------------------------------------------
  Future<void> saveUserSession(Map<String, dynamic> userJson) async {
    await cacheJsonObject(
      userSessionBoxName,
      StorageKeys.keyCurrentUser,
      userJson,
    );
    final id = userJson['id']?.toString();
    if (id != null && id.isNotEmpty) {
      await saveUserById(id, userJson);
    }
  }

  Map<String, dynamic>? getUserSession() {
    return getCachedJsonObject(userSessionBoxName, StorageKeys.keyCurrentUser);
  }

  Future<void> clearUserSession() async {
    await _userSessionBox.delete(StorageKeys.keyCurrentUser);
  }

  Future<void> saveUserById(String userId, Map<String, dynamic> userJson) async {
    await cacheJsonObject(userSessionBoxName, 'user_$userId', userJson);
    final list = getCachedJsonList(userSessionBoxName, 'users_list');
    list.removeWhere((u) => u['id']?.toString() == userId);
    list.add(userJson);
    await cacheJsonList(userSessionBoxName, 'users_list', list);
  }

  Map<String, dynamic>? getUserById(String userId) {
    return getCachedJsonObject(userSessionBoxName, 'user_$userId');
  }

  Future<void> cacheUsers(List<Map<String, dynamic>> users) async {
    await cacheJsonList(userSessionBoxName, 'users_list', users);
    for (final u in users) {
      final id = u['id']?.toString();
      if (id != null && id.isNotEmpty) {
        await cacheJsonObject(userSessionBoxName, 'user_$id', u);
      }
    }
  }

  /// Hive `box_user_session` içerisindeki tüm kayıtlı kullanıcıları (`users_list`,
  /// `current_user` ve `user_<id>` anahtarları dahil) tekilleştirerek döndürür.
  List<Map<String, dynamic>> getAllCachedUsers() {
    final Map<String, Map<String, dynamic>> byId = {};
    for (final u in getCachedJsonList(userSessionBoxName, 'users_list')) {
      final id = u['id']?.toString();
      if (id != null && id.isNotEmpty) {
        byId[id] = u;
      }
    }
    final current = getUserSession();
    if (current != null && current['id'] != null) {
      byId[current['id'].toString()] = current;
    }
    if (_isInitialized) {
      for (final key in _userSessionBox.keys) {
        final k = key.toString();
        if (k.startsWith('user_')) {
          final obj = getCachedJsonObject(userSessionBoxName, k);
          if (obj != null && obj['id'] != null) {
            byId[obj['id'].toString()] = obj;
          }
        }
      }
    }
    return byId.values.toList();
  }

  // ---------------------------------------------------------------------------
  // 2. Yolculuklar Önbelleği (`box_my_rides`)
  // ---------------------------------------------------------------------------
  Future<void> cacheRides(List<Map<String, dynamic>> rides) async {
    await cacheJsonList(myRidesBoxName, StorageKeys.keyCachedRidesList, rides);
  }

  List<Map<String, dynamic>> getCachedRides() {
    return getCachedJsonList(myRidesBoxName, StorageKeys.keyCachedRidesList);
  }

  Future<void> cacheMyRidesForUser(
    String userId,
    List<Map<String, dynamic>> rides,
  ) async {
    await cacheJsonList(myRidesBoxName, 'my_rides_$userId', rides);
  }

  List<Map<String, dynamic>> getCachedMyRidesForUser(String userId) {
    return getCachedJsonList(myRidesBoxName, 'my_rides_$userId');
  }

  // ---------------------------------------------------------------------------
  // 3. Arama Geçmişi (`box_search_history` - Son 10 Rota)
  // ---------------------------------------------------------------------------
  Future<void> addSearchHistory({
    required String origin,
    required String destination,
  }) async {
    final trimmedOrigin = origin.trim();
    final trimmedDest = destination.trim();
    if (trimmedOrigin.isEmpty && trimmedDest.isEmpty) return;

    final current = getSearchHistory();
    final entry = {
      'origin': trimmedOrigin,
      'destination': trimmedDest,
      'timestamp': DateTime.now().toIso8601String(),
    };

    current.removeWhere(
      (item) =>
          (item['origin']?.toString().toLowerCase() ==
              trimmedOrigin.toLowerCase()) &&
          (item['destination']?.toString().toLowerCase() ==
              trimmedDest.toLowerCase()),
    );

    current.insert(0, entry);
    if (current.length > 10) {
      current.removeRange(10, current.length);
    }

    await cacheJsonList(
      searchHistoryBoxName,
      StorageKeys.keySearchHistoryList,
      current,
    );
  }

  List<Map<String, dynamic>> getSearchHistory() {
    return getCachedJsonList(
      searchHistoryBoxName,
      StorageKeys.keySearchHistoryList,
    );
  }

  Future<void> clearSearchHistory() async {
    await _searchHistoryBox.delete(StorageKeys.keySearchHistoryList);
  }

  // ---------------------------------------------------------------------------
  // 4. Rezervasyonlar Önbelleği (`box_my_bookings`)
  // ---------------------------------------------------------------------------
  Future<void> cacheBookings(List<Map<String, dynamic>> bookings) async {
    await cacheJsonList(
      myBookingsBoxName,
      StorageKeys.keyMyBookingsList,
      bookings,
    );
  }

  List<Map<String, dynamic>> getCachedBookings() {
    return getCachedJsonList(
      myBookingsBoxName,
      StorageKeys.keyMyBookingsList,
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Sohbet ve Mesajlar Önbelleği (`box_chats`)
  // ---------------------------------------------------------------------------
  Future<void> cacheChats(List<Map<String, dynamic>> chats) async {
    await cacheJsonList(StorageKeys.boxChats, 'chats_list', chats);
  }

  List<Map<String, dynamic>> getCachedChats() {
    return getCachedJsonList(StorageKeys.boxChats, 'chats_list');
  }

  Future<void> cacheMessages(
    String chatId,
    List<Map<String, dynamic>> messages,
  ) async {
    await cacheJsonList(
      StorageKeys.boxChats,
      '${StorageKeys.keyRecentMessagesPrefix}$chatId',
      messages,
    );
  }

  List<Map<String, dynamic>> getCachedMessages(String chatId) {
    return getCachedJsonList(
      StorageKeys.boxChats,
      '${StorageKeys.keyRecentMessagesPrefix}$chatId',
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Araçlar ve Değerlendirmeler Önbelleği (`box_vehicles` & `box_reviews`)
  // ---------------------------------------------------------------------------
  Future<void> cacheVehicles(List<Map<String, dynamic>> vehicles) async {
    await cacheJsonList(StorageKeys.boxVehicles, 'vehicles_list', vehicles);
  }

  List<Map<String, dynamic>> getCachedVehicles() {
    return getCachedJsonList(StorageKeys.boxVehicles, 'vehicles_list');
  }

  Future<void> cacheReviews(List<Map<String, dynamic>> reviews) async {
    await cacheJsonList(StorageKeys.boxReviews, 'reviews_list', reviews);
  }

  List<Map<String, dynamic>> getCachedReviews() {
    return getCachedJsonList(StorageKeys.boxReviews, 'reviews_list');
  }

  Future<void> clearAll() async {
    await _userSessionBox.clear();
    await _myRidesBox.clear();
    await _searchHistoryBox.clear();
    await _bookingsBox.clear();
    await _chatsBox.clear();
    await _vehiclesBox.clear();
    await _reviewsBox.clear();
    await _userSessionBox.put('v3_clean_slate_migrated', true);
  }

  /// Uygulama ilk kez yeniden başlatıldığında mevcut Hive kutularındaki
  /// ve Firestore üzerindeki eski demo/test verilerini tek seferlik tamamen temizler.
  Future<void> purgeLegacyDemoDataOnce() async {
    if (!_isInitialized) return;
    final migrated = _userSessionBox.get('v3_clean_slate_migrated') == true;
    if (!migrated) {
      await clearAll();
      try {
        final firestore = FirebaseFirestore.instance;
        final batch = firestore.batch();
        for (final id in [
          'demo_driver_1',
          'demo_passenger_1',
          'usr_987654321',
          'usr_111222333',
          'usr_444555666',
        ]) {
          batch.delete(firestore.collection('users').doc(id));
        }
        for (final id in [
          'demo_vehicle_1',
          'veh_123456',
          'veh_789012',
          'veh_345678',
          'veh_default',
        ]) {
          batch.delete(firestore.collection('vehicles').doc(id));
        }
        for (final id in [
          'demo_ride_1',
          'ride_555666',
          'ride_666777',
          'ride_777888',
          'ride_888999',
        ]) {
          batch.delete(firestore.collection('rides').doc(id));
        }
        for (final id in [
          'demo_booking_1',
          'bkg_777888',
          'bkg_777889',
          'bkg_777890',
        ]) {
          batch.delete(firestore.collection('bookings').doc(id));
        }
        for (final chatId in ['demo_chat_1', 'chat_555666_111222333']) {
          for (final msgId in ['demo_msg_1', 'msg_001', 'msg_002', 'msg_003']) {
            batch.delete(
              firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .doc(msgId),
            );
          }
          batch.delete(firestore.collection('chats').doc(chatId));
        }
        for (final id in ['demo_review_1', 'rev_999000', 'rev_999001']) {
          batch.delete(firestore.collection('reviews').doc(id));
        }
        await batch.commit();
      } catch (_) {}
    }
  }
}

final localCacheServiceProvider = Provider<LocalCacheService>((ref) {
  return LocalCacheService();
});
