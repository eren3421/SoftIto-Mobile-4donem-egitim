import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/bookings/data/models/booking_model.dart';
import '../../features/chat/data/models/chat_model.dart';
import '../../features/chat/data/models/review_model.dart';
import '../../features/profile/data/models/vehicle_model.dart';
import '../../features/rides/data/models/ride_model.dart';
import '../../features/rides/domain/entities/ride_entity.dart';
import '../utils/geocoding_service.dart';
import 'local_cache_service.dart';

/// Türkiye / İstanbul gerçekçi konum noktaları kataloğu (Harita ve Hızlı Seçim için).
class TurkeyLocations {
  TurkeyLocations._();

  static const List<RideLocationPoint> popularPoints = [
    RideLocationPoint(
      name: 'Kadıköy Rıhtım',
      address: 'Caferağa, Kadıköy/İstanbul',
      lat: 40.9901,
      lng: 29.0234,
      geohash: 'sxk9g8',
    ),
    RideLocationPoint(
      name: 'İTÜ Ayazağa Kampüsü',
      address: 'Maslak, Sarıyer/İstanbul',
      lat: 41.1055,
      lng: 29.0252,
      geohash: 'sxk9u2',
    ),
    RideLocationPoint(
      name: 'Mecidiyeköy Metrobüs',
      address: 'Şişli/İstanbul',
      lat: 41.0668,
      lng: 28.9963,
      geohash: 'sxk9n4',
    ),
    RideLocationPoint(
      name: 'Beşiktaş Meydan',
      address: 'Sinanpaşa, Beşiktaş/İstanbul',
      lat: 41.0422,
      lng: 29.0067,
      geohash: 'sxk9m1',
    ),
    RideLocationPoint(
      name: 'Sabiha Gökçen Havalimanı',
      address: 'Sanayi, Pendik/İstanbul',
      lat: 40.8986,
      lng: 29.3092,
      geohash: 'sxkcb3',
    ),
    RideLocationPoint(
      name: 'Üsküdar Marmaray',
      address: 'Mimar Sinan, Üsküdar/İstanbul',
      lat: 41.0260,
      lng: 29.0151,
      geohash: 'sxk9k2',
    ),
    RideLocationPoint(
      name: 'YTÜ Davutpaşa Kampüsü',
      address: 'Davutpaşa, Esenler/İstanbul',
      lat: 41.0252,
      lng: 28.8897,
      geohash: 'sxk93z',
    ),
    RideLocationPoint(
      name: 'Boğaziçi Üni. Güney Kampüs',
      address: 'Bebek, Beşiktaş/İstanbul',
      lat: 41.0845,
      lng: 29.0505,
      geohash: 'sxk9s8',
    ),
    RideLocationPoint(
      name: 'Bostancı İskele',
      address: 'Bostancı, Kadıköy/İstanbul',
      lat: 40.9522,
      lng: 29.0942,
      geohash: 'sxk9d9',
    ),
    RideLocationPoint(
      name: 'Koç Üniversitesi Rumelifeneri',
      address: 'Rumelifeneri, Sarıyer/İstanbul',
      lat: 41.2054,
      lng: 29.0728,
      geohash: 'sxkd81',
    ),
    RideLocationPoint(
      name: 'Bakırköy Özgürlük Meydanı',
      address: 'Zuhuratbaba, Bakırköy/İstanbul',
      lat: 40.9801,
      lng: 28.8720,
      geohash: 'sxk8x2',
    ),
    RideLocationPoint(
      name: 'ODTÜ Kampüsü (Ankara)',
      address: 'Üniversiteler, Çankaya/Ankara',
      lat: 39.8914,
      lng: 32.7847,
      geohash: 'sz2h8k',
    ),
    RideLocationPoint(
      name: 'Taksim Meydanı',
      address: 'Gümüşsuyu, Beyoğlu/İstanbul',
      lat: 41.0370,
      lng: 28.9851,
      geohash: 'sxk9m0',
    ),
    RideLocationPoint(
      name: 'Ataşehir Finans Merkezi',
      address: 'Barbaros, Ataşehir/İstanbul',
      lat: 40.9923,
      lng: 29.1244,
      geohash: 'sxk9f4',
    ),
    RideLocationPoint(
      name: 'Maltepe Sahil',
      address: 'Yalı, Maltepe/İstanbul',
      lat: 40.9248,
      lng: 29.1311,
      geohash: 'sxk9c1',
    ),
    RideLocationPoint(
      name: 'Kartal Metro',
      address: 'Cumhuriyet, Kartal/İstanbul',
      lat: 40.9109,
      lng: 29.1904,
      geohash: 'sxk9b8',
    ),
    RideLocationPoint(
      name: 'Ümraniye Çarşı',
      address: 'Atatürk, Ümraniye/İstanbul',
      lat: 41.0256,
      lng: 29.0963,
      geohash: 'sxk9q1',
    ),
    RideLocationPoint(
      name: 'Levent Metro',
      address: 'Levent, Beşiktaş/İstanbul',
      lat: 41.0781,
      lng: 29.0138,
      geohash: 'sxk9t1',
    ),
    RideLocationPoint(
      name: 'Avcılar Metrobüs',
      address: 'Merkez, Avcılar/İstanbul',
      lat: 40.9801,
      lng: 28.7175,
      geohash: 'sxk8m2',
    ),
    RideLocationPoint(
      name: 'Beylikdüzü Meydan',
      address: 'Cumhuriyet, Beylikdüzü/İstanbul',
      lat: 41.0014,
      lng: 28.6419,
      geohash: 'sxk8h5',
    ),
    RideLocationPoint(
      name: 'İstanbul Havalimanı (İGA)',
      address: 'Tayakadın, Arnavutköy/İstanbul',
      lat: 41.2753,
      lng: 28.7519,
      geohash: 'sxkd12',
    ),
    RideLocationPoint(
      name: 'Gebze Teknik Üniversitesi',
      address: 'Cumhuriyet, Gebze/Kocaeli',
      lat: 40.8075,
      lng: 29.3558,
      geohash: 'sxkby1',
    ),
    RideLocationPoint(
      name: 'Kızılay Meydanı (Ankara)',
      address: 'Kızılay, Çankaya/Ankara',
      lat: 39.9208,
      lng: 32.8541,
      geohash: 'sz2h9p',
    ),
    RideLocationPoint(
      name: 'Konak Meydanı (İzmir)',
      address: 'Konak/İzmir',
      lat: 38.4189,
      lng: 27.1287,
      geohash: 'swq9h2',
    ),
  ];

  /// Kullanıcının klavyeden yazdığı metne göre gerçek Türkiye konum önerilerini döndürür.
  static List<RideLocationPoint> searchSuggestions(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return popularPoints.take(8).toList();
    }
    final matches = GeocodingService.searchLocalRealPlaces(trimmed);
    return matches.isNotEmpty ? matches.take(10).toList() : [];
  }

  /// Kullanıcının klavyeden serbestçe yazdığı herhangi bir konum adını/adresini
  /// gerçek Türkiye koordinat veritabanı (`GeocodingService`) üzerinden çözümler.
  static RideLocationPoint findOrCreate(
    String name, {
    double? customLat,
    double? customLng,
    String? customAddress,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return RideLocationPoint(
        name: 'Seçilen Konum',
        address: customAddress ?? 'Türkiye',
        lat: customLat ?? 39.9208,
        lng: customLng ?? 32.8541,
        geohash: 'tr',
      );
    }

    // 1. Önce Türkiye geneli gerçek koordinat veritabanında (Havalimanları, YHT Garları,
    // Otogarlar, Üniversiteler, 81 İl ve İlçeler) ara:
    final localMatches = GeocodingService.searchLocalRealPlaces(trimmed);
    if (localMatches.isNotEmpty) {
      final best = localMatches.first;
      return RideLocationPoint(
        name: trimmed,
        address: customAddress ?? best.address,
        lat: customLat ?? best.lat,
        lng: customLng ?? best.lng,
        geohash: best.geohash,
      );
    }

    // 2. Özel koordinat verilmişse onu kullan, verilmemişse Türkiye merkezi (Ankara) varsayılanını ata
    // (Canlı Nominatim API yanıtı geldiğinde gerçek sokak/bina koordinatıyla anında güncellenir)
    final resolvedLat = customLat ?? 39.9208;
    final resolvedLng = customLng ?? 32.8541;

    return RideLocationPoint(
      name: trimmed,
      address: customAddress ??
          '$trimmed (${resolvedLat.toStringAsFixed(4)}, ${resolvedLng.toStringAsFixed(4)})',
      lat: resolvedLat,
      lng: resolvedLng,
      geohash: 'tr',
    );
  }

  /// Harita üzerinde tıklanan `(lat, lng)` koordinatına en yakın gerçek Türkiye bölgesini bulup
  /// anlamlı bir `RideLocationPoint` oluşturur.
  static RideLocationPoint fromCoordinates(
    double lat,
    double lng, {
    String? customName,
    String? customAddress,
  }) {
    final nearest = GeocodingService.findNearestLocalPlace(
      lat,
      lng,
      customName: customName,
    );
    if (customAddress != null && customAddress.trim().isNotEmpty) {
      return nearest.copyWith(address: customAddress.trim());
    }
    return nearest;
  }
}

/// Sahte/demo veri tohumlama devre dışı bırakılmıştır.
/// Tüm veriler doğrudan Cloud Firestore (Single Source of Truth) ve Hive (`LocalCacheService`)
/// üzerinden kullanıcı tarafından oluşturularak yönetilir.
class SeedDataService {
  final LocalCacheService _cacheService;

  final List<UserModel> users = [];
  final List<VehicleModel> vehicles = [];
  final List<RideModel> rides = [];
  final List<BookingModel> bookings = [];
  final List<ChatModel> chats = [];
  final Map<String, List<MessageModel>> messagesByChat = {};
  final List<ReviewModel> reviews = [];

  SeedDataService(this._cacheService);

  Future<void> ensureSeeded() async {
    // Sahte kullanıcı veya sahte yolculuk oluşturma tamamen kaldırıldı.
    final _ = _cacheService;
  }
}

final useMockDataProvider = StateProvider<bool>((ref) => false);

final isOfflineModeProvider = StateProvider<bool>((ref) => false);

final seedDataServiceProvider = Provider<SeedDataService>((ref) {
  final cache = ref.watch(localCacheServiceProvider);
  return SeedDataService(cache);
});

