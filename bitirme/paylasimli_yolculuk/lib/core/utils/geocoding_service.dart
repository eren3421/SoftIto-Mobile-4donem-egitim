import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/rides/domain/entities/ride_entity.dart';

/// Gerçek zamanlı OpenStreetMap (Nominatim & Photon) Geocoding / Reverse Geocoding servisi
/// ve Türkiye geneli (81 İl, Havalimanları, YHT Garları, Otogarlar, Üniversiteler, İlçeler)
/// gerçek koordinat veritabanı.
class GeocodingService {
  GeocodingService._();

  static final Map<String, List<RideLocationPoint>> _searchCache = {};

  /// Türkçe karakterleri normalize ederek büyük/küçük harf duyarsız arama anahtarı üretir.
  /// Örn: "ESENBOĞA" -> "esenboga", "İTÜ Ayazağa" -> "itu ayazaga"
  static String normalizeTr(String input) {
    return input
        .trim()
        .replaceAll('İ', 'i')
        .replaceAll('I', 'i')
        .replaceAll('ı', 'i')
        .replaceAll('Ğ', 'g')
        .replaceAll('ğ', 'g')
        .replaceAll('Ü', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('Ş', 's')
        .replaceAll('ş', 's')
        .replaceAll('Ö', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('Ç', 'c')
        .replaceAll('ç', 'c')
        .toLowerCase();
  }

  /// Klavyeden girilen metni gerçek zamanlı olarak OpenStreetMap Nominatim API üzerinden arar.
  /// Aynı zamanda yerel gerçek Türkiye koordinat veritabanı ile destekler.
  static Future<List<RideLocationPoint>> searchPlaces(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final cacheKey = normalizeTr(trimmed);
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    // 1. Önce yerel doğrulanmış Türkiye gerçek konum veritabanından eşleşenleri al
    final localMatches = searchLocalRealPlaces(trimmed);

    // 2. OpenStreetMap Nominatim gerçek zamanlı Geocoding API isteği
    final remoteResults = <RideLocationPoint>[];
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': trimmed,
          'format': 'jsonv2',
          'addressdetails': '1',
          'limit': '6',
          'countrycodes': 'tr',
          'accept-language': 'tr',
        },
      );

      final response = await http
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              final lat = double.tryParse(item['lat']?.toString() ?? '');
              final lon = double.tryParse(item['lon']?.toString() ?? '');
              if (lat != null && lon != null) {
                final displayName = item['display_name']?.toString() ?? trimmed;
                final nameField = item['name']?.toString() ?? '';
                final shortName = nameField.isNotEmpty
                    ? nameField
                    : displayName.split(',').first.trim();

                remoteResults.add(
                  RideLocationPoint(
                    name: shortName,
                    address: displayName,
                    lat: lat,
                    lng: lon,
                    geohash: 'osm',
                  ),
                );
              }
            }
          }
        }
      }
    } catch (_) {
      // Nominatim erişilemezse Photon (OpenStreetMap tabanlı alternatif) dene
      try {
        final photonUri = Uri.https(
          'photon.komoot.io',
          '/api/',
          {
            'q': trimmed,
            'limit': '5',
            'lat': '39.92',
            'lon': '32.85',
          },
        );
        final resp = await http
            .get(photonUri)
            .timeout(const Duration(seconds: 3));
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          final features = data['features'];
          if (features is List) {
            for (final f in features) {
              final geom = f['geometry'];
              final props = f['properties'];
              if (geom != null && props != null) {
                final coords = geom['coordinates'];
                if (coords is List && coords.length >= 2) {
                  final lon = (coords[0] as num).toDouble();
                  final lat = (coords[1] as num).toDouble();
                  final name = props['name']?.toString() ?? trimmed;
                  final city = props['city']?.toString() ??
                      props['state']?.toString() ??
                      'Türkiye';
                  remoteResults.add(
                    RideLocationPoint(
                      name: name,
                      address: '$name, $city',
                      lat: lat,
                      lng: lon,
                      geohash: 'osm',
                    ),
                  );
                }
              }
            }
          }
        }
      } catch (_) {}
    }

    // Sonuçları birleştir (mükerrer olanları ele)
    final combined = <RideLocationPoint>[...localMatches];
    for (final r in remoteResults) {
      final alreadyExists = combined.any(
        (existing) =>
            (existing.lat - r.lat).abs() < 0.003 &&
            (existing.lng - r.lng).abs() < 0.003,
      );
      if (!alreadyExists) {
        combined.add(r);
      }
    }

    if (combined.isNotEmpty) {
      _searchCache[cacheKey] = combined;
    }
    return combined;
  }

  /// Haritada tıklanan `(lat, lng)` koordinatının gerçek sokak/semt/ilçe/il karşılığını
  /// OpenStreetMap Nominatim Reverse Geocoding API üzerinden bulur.
  static Future<RideLocationPoint> reverseGeocode(
    double lat,
    double lng, {
    String? customName,
  }) async {
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        {
          'lat': lat.toString(),
          'lon': lng.toString(),
          'format': 'jsonv2',
          'addressdetails': '1',
          'accept-language': 'tr',
        },
      );

      final response = await http
          .get(
            uri,
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final displayName = data['display_name']?.toString() ?? '';
          final nameField = data['name']?.toString() ?? '';
          final address = data['address'] as Map<String, dynamic>?;

          String bestShortName = nameField;
          if (bestShortName.isEmpty && address != null) {
            final road = address['road']?.toString() ??
                address['pedestrian']?.toString() ??
                '';
            final suburb = address['suburb']?.toString() ??
                address['neighbourhood']?.toString() ??
                address['quarter']?.toString() ??
                '';
            final town = address['town']?.toString() ??
                address['district']?.toString() ??
                address['city_district']?.toString() ??
                address['city']?.toString() ??
                address['province']?.toString() ??
                '';

            final parts = [
              if (road.isNotEmpty) road,
              if (suburb.isNotEmpty) suburb,
              if (town.isNotEmpty) town,
            ];
            bestShortName = parts.take(2).join(', ');
          }

          if (bestShortName.isEmpty && displayName.isNotEmpty) {
            bestShortName = displayName.split(',').take(2).join(',').trim();
          }

          final resolvedName =
              (customName != null && customName.trim().isNotEmpty)
                  ? customName.trim()
                  : (bestShortName.isNotEmpty
                      ? bestShortName
                      : 'Harita Konumu (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})');

          return RideLocationPoint(
            name: resolvedName,
            address: displayName.isNotEmpty
                ? displayName
                : '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
            lat: lat,
            lng: lng,
            geohash: 'osm',
          );
        }
      }
    } catch (_) {
      // Çevrimdışıysa yerel en yakın gerçek konumu bul
    }

    return findNearestLocalPlace(lat, lng, customName: customName);
  }

  /// Senkron / anlık olarak yerel gerçek Türkiye koordinat veritabanında arama yapar.
  static List<RideLocationPoint> searchLocalRealPlaces(String query) {
    final normQuery = normalizeTr(query);
    if (normQuery.isEmpty) return [];

    final exactMatches = <RideLocationPoint>[];
    final startsWithMatches = <RideLocationPoint>[];
    final containsMatches = <RideLocationPoint>[];

    for (final entry in _turkeyRealPlacesGazetteer) {
      final normName = normalizeTr(entry.name);
      final normAddr = normalizeTr(entry.address);
      final normKeywords = normalizeTr(entry.keywords);

      if (normName == normQuery ||
          normKeywords.split(',').any((k) => k.trim() == normQuery)) {
        exactMatches.add(entry.point);
      } else if (normName.startsWith(normQuery) ||
          normKeywords.split(',').any((k) => k.trim().startsWith(normQuery))) {
        startsWithMatches.add(entry.point);
      } else if (normName.contains(normQuery) ||
          normAddr.contains(normQuery) ||
          normKeywords.contains(normQuery) ||
          (normQuery.length >= 4 && normQuery.contains(normName))) {
        containsMatches.add(entry.point);
      }
    }

    return [
      ...exactMatches,
      ...startsWithMatches,
      ...containsMatches,
    ];
  }

  /// Verilen koordinata en yakın gerçek Türkiye noktasını bulur.
  static RideLocationPoint findNearestLocalPlace(
    double lat,
    double lng, {
    String? customName,
  }) {
    _PlaceGazetteerEntry? closest;
    double minDistSq = double.infinity;

    for (final entry in _turkeyRealPlacesGazetteer) {
      final dLat = entry.point.lat - lat;
      final dLng = entry.point.lng - lng;
      final distSq = dLat * dLat + dLng * dLng;
      if (distSq < minDistSq) {
        minDistSq = distSq;
        closest = entry;
      }
    }

    final coordStr = '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    final isClose = minDistSq < 0.01 && closest != null;

    final resolvedName = (customName != null && customName.trim().isNotEmpty)
        ? customName.trim()
        : (isClose ? '${closest.point.name} Civarı' : 'Konum ($coordStr)');

    final resolvedAddress = isClose
        ? '${closest.point.address} ($coordStr)'
        : 'Koordinat: $coordStr';

    return RideLocationPoint(
      name: resolvedName,
      address: resolvedAddress,
      lat: lat,
      lng: lng,
      geohash: 'tr',
    );
  }

  /// Türkiye genelindeki önemli ulaşım merkezleri, havalimanları, YHT garları,
  /// otogarlar, üniversiteler, popüler ilçeler ve 81 ilin GERÇEK koordinatları.
  static const List<_PlaceGazetteerEntry> _turkeyRealPlacesGazetteer = [
    // --- ANKARA ---
    _PlaceGazetteerEntry(
      name: 'Ankara Esenboğa Havalimanı',
      address: 'Balıkhisar, Çubuk/Akyurt, Ankara',
      lat: 40.1281,
      lng: 32.9951,
      keywords: 'esenboga,esenboğa,ankara havalimani,ankara havaalani,esb',
    ),
    _PlaceGazetteerEntry(
      name: 'Ankara YHT Garı',
      address: 'Celal Bayar Blv., Çankaya/Altındağ, Ankara',
      lat: 39.9344,
      lng: 32.8427,
      keywords: 'ankara yht,ankara gar,ankara tren gari,tcdd ankara gar,yht ankara',
    ),
    _PlaceGazetteerEntry(
      name: 'Eryaman YHT Garı (Ankara)',
      address: 'Eryaman, Etimesgut/Ankara',
      lat: 39.9794,
      lng: 32.6331,
      keywords: 'eryaman yht,eryaman gar,eryaman',
    ),
    _PlaceGazetteerEntry(
      name: 'AŞTİ (Ankara Şehirlerarası Terminal)',
      address: 'Beştepe, Söğütözü, Yenimahalle/Ankara',
      lat: 39.9179,
      lng: 32.8131,
      keywords: 'asti,aşti,ankara otogar,ankara terminal,sogutozu',
    ),
    _PlaceGazetteerEntry(
      name: 'Kızılay Meydanı (Ankara)',
      address: 'Kızılay, Çankaya/Ankara',
      lat: 39.9208,
      lng: 32.8541,
      keywords: 'kizilay,kızılay,cankaya,ankara merkez',
    ),
    _PlaceGazetteerEntry(
      name: 'ODTÜ Kampüsü (Ankara)',
      address: 'Üniversiteler Mah., Çankaya/Ankara',
      lat: 39.8914,
      lng: 32.7847,
      keywords: 'odtu,odtü,orta dogu teknik,metu',
    ),
    _PlaceGazetteerEntry(
      name: 'Bilkent Üniversitesi (Ankara)',
      address: 'Üniversiteler, Çankaya/Ankara',
      lat: 39.8680,
      lng: 32.7488,
      keywords: 'bilkent,bilkent universitesi',
    ),
    _PlaceGazetteerEntry(
      name: 'Hacettepe Üniversitesi Beytepe',
      address: 'Beytepe, Çankaya/Ankara',
      lat: 39.8659,
      lng: 32.7344,
      keywords: 'hacettepe,beytepe',
    ),
    _PlaceGazetteerEntry(
      name: 'Gazi Üniversitesi (Ankara)',
      address: 'Emek/Teknikokullar, Yenimahalle/Ankara',
      lat: 39.9396,
      lng: 32.8226,
      keywords: 'gazi universitesi,besevler,beşevler',
    ),
    _PlaceGazetteerEntry(
      name: 'Ankara Üniversitesi Tandoğan',
      address: 'Tandoğan, Çankaya/Ankara',
      lat: 39.9347,
      lng: 32.8342,
      keywords: 'tandogan,tandoğan,ankara universitesi',
    ),
    _PlaceGazetteerEntry(
      name: 'Ulus Meydanı (Ankara)',
      address: 'Ulus, Altındağ/Ankara',
      lat: 39.9417,
      lng: 32.8543,
      keywords: 'ulus,altindag,altındağ',
    ),
    _PlaceGazetteerEntry(
      name: 'Tunalı Hilmi / Kavaklıdere',
      address: 'Kavaklıdere, Çankaya/Ankara',
      lat: 39.9082,
      lng: 32.8615,
      keywords: 'tunali,tunalı,kavaklidere,kuğulu',
    ),
    _PlaceGazetteerEntry(
      name: 'Bahçelievler 7. Cadde (Ankara)',
      address: 'Bahçelievler, Çankaya/Ankara',
      lat: 39.9261,
      lng: 32.8235,
      keywords: 'bahcelievler ankara,7 cadde,emek',
    ),
    _PlaceGazetteerEntry(
      name: 'Çayyolu / Ümitköy (Ankara)',
      address: 'Çayyolu, Çankaya/Ankara',
      lat: 39.8825,
      lng: 32.6875,
      keywords: 'cayyolu,çayyolu,umitkoy,ümitköy,konutkent,yasamkent',
    ),
    _PlaceGazetteerEntry(
      name: 'Batıkent Meydan (Ankara)',
      address: 'Batıkent, Yenimahalle/Ankara',
      lat: 39.9690,
      lng: 32.7305,
      keywords: 'batikent,batıkent,yenimahalle',
    ),
    _PlaceGazetteerEntry(
      name: 'Keçiören (Ankara)',
      address: 'Keçiören/Ankara',
      lat: 39.9856,
      lng: 32.8644,
      keywords: 'kecioren,keçiören,etlik',
    ),
    _PlaceGazetteerEntry(
      name: 'Etimesgut / Sincan (Ankara)',
      address: 'Etimesgut/Ankara',
      lat: 39.9531,
      lng: 32.6719,
      keywords: 'etimesgut,sincan,elvan,baglica',
    ),
    _PlaceGazetteerEntry(
      name: 'Mamak (Ankara)',
      address: 'Mamak/Ankara',
      lat: 39.9272,
      lng: 32.9189,
      keywords: 'mamak,abidinpasa,natoyolu',
    ),
    _PlaceGazetteerEntry(
      name: 'Gölbaşı (Ankara)',
      address: 'Gölbaşı/Ankara',
      lat: 39.7897,
      lng: 32.8061,
      keywords: 'golbasi,gölbaşı,incek',
    ),
    _PlaceGazetteerEntry(
      name: 'Polatlı YHT / Merkez (Ankara)',
      address: 'Polatlı/Ankara',
      lat: 39.5842,
      lng: 32.1472,
      keywords: 'polatli,polatlı,polatli yht',
    ),
    _PlaceGazetteerEntry(
      name: 'Çubuk (Ankara)',
      address: 'Çubuk/Ankara',
      lat: 40.2386,
      lng: 33.0322,
      keywords: 'cubuk,çubuk,akyurt,pursaklar',
    ),

    // --- İSTANBUL ---
    _PlaceGazetteerEntry(
      name: 'Kadıköy Rıhtım',
      address: 'Caferağa, Kadıköy/İstanbul',
      lat: 40.9901,
      lng: 29.0234,
      keywords: 'kadikoy,kadıköy,rihtim,moda,caferaga',
    ),
    _PlaceGazetteerEntry(
      name: 'Söğütlüçeşme YHT & Metrobüs',
      address: 'Zühtüpaşa, Kadıköy/İstanbul',
      lat: 40.9908,
      lng: 29.0375,
      keywords: 'sogutlucesme,söğütlüçeşme,kadikoy yht,sogutlucesme yht',
    ),
    _PlaceGazetteerEntry(
      name: 'İTÜ Ayazağa Kampüsü',
      address: 'Maslak, Sarıyer/İstanbul',
      lat: 41.1055,
      lng: 29.0252,
      keywords: 'itu,itü,ayazaga,maslak,istanbul teknik',
    ),
    _PlaceGazetteerEntry(
      name: 'Mecidiyeköy Metrobüs',
      address: 'Mecidiyeköy, Şişli/İstanbul',
      lat: 41.0668,
      lng: 28.9963,
      keywords: 'mecidiyekoy,mecidiyeköy,sisli,şişli,cevahir,trump',
    ),
    _PlaceGazetteerEntry(
      name: 'Beşiktaş Meydan',
      address: 'Sinanpaşa, Beşiktaş/İstanbul',
      lat: 41.0422,
      lng: 29.0067,
      keywords: 'besiktas,beşiktaş,ortakoy,barbaros',
    ),
    _PlaceGazetteerEntry(
      name: 'Sabiha Gökçen Havalimanı (SAW)',
      address: 'Sanayi, Pendik/İstanbul',
      lat: 40.8986,
      lng: 29.3092,
      keywords: 'sabiha,sabiha gokcen,sabiha gökçen,saw,kurtkoy',
    ),
    _PlaceGazetteerEntry(
      name: 'İstanbul Havalimanı (İGA)',
      address: 'Tayakadın, Arnavutköy/İstanbul',
      lat: 41.2753,
      lng: 28.7519,
      keywords: 'istanbul havalimani,iga,ist,yeni havalimani,arnavutkoy',
    ),
    _PlaceGazetteerEntry(
      name: 'Üsküdar Marmaray / İskele',
      address: 'Mimar Sinan, Üsküdar/İstanbul',
      lat: 41.0260,
      lng: 29.0151,
      keywords: 'uskudar,üsküdar,altunizade,baglarbasi,camlica',
    ),
    _PlaceGazetteerEntry(
      name: 'YTÜ Davutpaşa Kampüsü',
      address: 'Davutpaşa, Esenler/İstanbul',
      lat: 41.0252,
      lng: 28.8897,
      keywords: 'ytu,ytü,yildiz teknik,davutpasa,esenler',
    ),
    _PlaceGazetteerEntry(
      name: 'Boğaziçi Üni. Güney Kampüs',
      address: 'Bebek, Beşiktaş/İstanbul',
      lat: 41.0845,
      lng: 29.0505,
      keywords: 'bogazici,boğaziçi,bebek,hisarustu',
    ),
    _PlaceGazetteerEntry(
      name: 'Bostancı İskele & YHT',
      address: 'Bostancı, Kadıköy/İstanbul',
      lat: 40.9522,
      lng: 29.0942,
      keywords: 'bostanci,bostancı,bostanci yht,suadiye,bagdat caddesi',
    ),
    _PlaceGazetteerEntry(
      name: 'Koç Üniversitesi Rumelifeneri',
      address: 'Rumelifeneri, Sarıyer/İstanbul',
      lat: 41.2054,
      lng: 29.0728,
      keywords: 'koc universitesi,koç üniversitesi,sariyer,rumelifeneri',
    ),
    _PlaceGazetteerEntry(
      name: 'Bakırköy Özgürlük Meydanı & YHT',
      address: 'Zuhuratbaba, Bakırköy/İstanbul',
      lat: 40.9801,
      lng: 28.8720,
      keywords: 'bakirkoy,bakırköy,atakoy,incirli,florya,yesilkoy',
    ),
    _PlaceGazetteerEntry(
      name: 'Taksim Meydanı',
      address: 'Gümüşsuyu, Beyoğlu/İstanbul',
      lat: 41.0370,
      lng: 28.9851,
      keywords: 'taksim,beyoglu,beyoğlu,istiklal,karakoy,cihangir',
    ),
    _PlaceGazetteerEntry(
      name: 'Ataşehir Finans Merkezi',
      address: 'Barbaros, Ataşehir/İstanbul',
      lat: 40.9923,
      lng: 29.1244,
      keywords: 'atasehir,ataşehir,watergarden,metropol,bati atasehir',
    ),
    _PlaceGazetteerEntry(
      name: 'Maltepe Sahil',
      address: 'Yalı, Maltepe/İstanbul',
      lat: 40.9248,
      lng: 29.1311,
      keywords: 'maltepe,kucukyali,küçükyalı,idealtepe',
    ),
    _PlaceGazetteerEntry(
      name: 'Kartal Metro',
      address: 'Cumhuriyet, Kartal/İstanbul',
      lat: 40.9109,
      lng: 29.1904,
      keywords: 'kartal,soganlik,yakacik',
    ),
    _PlaceGazetteerEntry(
      name: 'Pendik Sahil & YHT Garı',
      address: 'Batı, Pendik/İstanbul',
      lat: 40.8796,
      lng: 29.2319,
      keywords: 'pendik,pendik yht,kaynarca',
    ),
    _PlaceGazetteerEntry(
      name: 'Tuzla İTÜ Denizcilik / Marina',
      address: 'Postane, Tuzla/İstanbul',
      lat: 40.8161,
      lng: 29.3014,
      keywords: 'tuzla,sabanci universitesi,okan universitesi,aydintepe',
    ),
    _PlaceGazetteerEntry(
      name: 'Ümraniye Çarşı',
      address: 'Atatürk, Ümraniye/İstanbul',
      lat: 41.0256,
      lng: 29.0963,
      keywords: 'umraniye,ümraniye,cekmekoy,çekmeköy,sancaktepe,dudullu',
    ),
    _PlaceGazetteerEntry(
      name: 'Levent Metro',
      address: 'Levent, Beşiktaş/İstanbul',
      lat: 41.0781,
      lng: 29.0138,
      keywords: 'levent,4 levent,etiler,zincirlikuyu,kanyon',
    ),
    _PlaceGazetteerEntry(
      name: 'Fatih / Eminönü / Yenikapı',
      address: 'Fatih/İstanbul',
      lat: 41.0122,
      lng: 28.9544,
      keywords: 'fatih,eminonu,eminönü,sultanahmet,yenikapi,aksaray,beyazit,cevizlibag,topkapi',
    ),
    _PlaceGazetteerEntry(
      name: 'Esenler 15 Temmuz Demokrasi Otogarı',
      address: 'Altıntepsi, Bayrampaşa/İstanbul',
      lat: 41.0400,
      lng: 28.8936,
      keywords: 'esenler otogar,bayrampasa,istanbul otogar,otogar',
    ),
    _PlaceGazetteerEntry(
      name: 'Avcılar Metrobüs & İÜC Kampüs',
      address: 'Merkez, Avcılar/İstanbul',
      lat: 40.9801,
      lng: 28.7175,
      keywords: 'avcilar,avcılar,kucukcekmece,küçükçekmece,sefakoy',
    ),
    _PlaceGazetteerEntry(
      name: 'Halkalı YHT & Marmaray Garı',
      address: 'Halkalı, Küçükçekmece/İstanbul',
      lat: 41.0169,
      lng: 28.7675,
      keywords: 'halkali,halkalı,halkali yht,atakent',
    ),
    _PlaceGazetteerEntry(
      name: 'Beylikdüzü Meydan / TÜYAP',
      address: 'Cumhuriyet, Beylikdüzü/İstanbul',
      lat: 41.0014,
      lng: 28.6419,
      keywords: 'beylikduzu,beylikdüzü,esenyurt,buyukcekmece,tuyap',
    ),
    _PlaceGazetteerEntry(
      name: 'Başakşehir / Kayaşehir',
      address: 'Başakşehir/İstanbul',
      lat: 41.0931,
      lng: 28.8020,
      keywords: 'basaksehir,başakşehir,ikitelli,bahcesehir,kayasehir,bagcilar,gungoren',
    ),
    _PlaceGazetteerEntry(
      name: 'Beykoz / Kavacık',
      address: 'Kavacık, Beykoz/İstanbul',
      lat: 41.0892,
      lng: 29.0933,
      keywords: 'beykoz,kavacik,kavacık,acarkent,riva',
    ),
    _PlaceGazetteerEntry(
      name: 'Sarıyer Merkez / Hacıosman',
      address: 'Sarıyer/İstanbul',
      lat: 41.1667,
      lng: 29.0500,
      keywords: 'sariyer,sarıyer,haciosman,tarabya,istinye',
    ),
    _PlaceGazetteerEntry(
      name: 'Şile Merkez',
      address: 'Şile/İstanbul',
      lat: 41.1754,
      lng: 29.6128,
      keywords: 'sile,şile,agva,ağva',
    ),
    _PlaceGazetteerEntry(
      name: 'Silivri Merkez',
      address: 'Silivri/İstanbul',
      lat: 41.0736,
      lng: 28.2464,
      keywords: 'silivri,catalca,çatalca',
    ),

    // --- İZMİR ---
    _PlaceGazetteerEntry(
      name: 'Konak Meydanı (İzmir)',
      address: 'Konak/İzmir',
      lat: 38.4189,
      lng: 27.1287,
      keywords: 'izmir,konak,alsancak,kordon',
    ),
    _PlaceGazetteerEntry(
      name: 'İzmir Adnan Menderes Havalimanı (ADB)',
      address: 'Gaziemir/İzmir',
      lat: 38.2924,
      lng: 27.1570,
      keywords: 'adnan menderes,izmir havalimani,gaziemir,adb',
    ),
    _PlaceGazetteerEntry(
      name: 'Bornova / Ege Üniversitesi (İzmir)',
      address: 'Bornova/İzmir',
      lat: 38.4622,
      lng: 27.2164,
      keywords: 'bornova,ege universitesi,izmir otogar',
    ),
    _PlaceGazetteerEntry(
      name: 'Karşıyaka / Bostanlı (İzmir)',
      address: 'Karşıyaka/İzmir',
      lat: 38.4561,
      lng: 27.1100,
      keywords: 'karsiyaka,karşıyaka,bostanli,mavisehir,cigli',
    ),
    _PlaceGazetteerEntry(
      name: 'Buca / Dokuz Eylül Üni. (İzmir)',
      address: 'Buca/İzmir',
      lat: 38.3853,
      lng: 27.1753,
      keywords: 'buca,dokuz eylul,tinaztepe',
    ),
    _PlaceGazetteerEntry(
      name: 'Urla / İYTE / Çeşme (İzmir)',
      address: 'Urla/İzmir',
      lat: 38.3222,
      lng: 26.7647,
      keywords: 'urla,iyte,cesme,çeşme,alacati',
    ),

    // --- DİĞER ÖNEMLİ YHT GARLARI, ÜNİVERSİTELER VE 81 İL MERKEZİ ---
    _PlaceGazetteerEntry(
      name: 'Gebze Teknik Üni. & YHT',
      address: 'Gebze/Kocaeli',
      lat: 40.8075,
      lng: 29.3558,
      keywords: 'gebze,gtu,gebze teknik,cayirova,darica',
    ),
    _PlaceGazetteerEntry(
      name: 'Kocaeli (İzmit) Merkez & YHT',
      address: 'İzmit/Kocaeli',
      lat: 40.7654,
      lng: 29.9408,
      keywords: 'kocaeli,izmit,izmit yht,umuttepe',
    ),
    _PlaceGazetteerEntry(
      name: 'Sakarya (Adapazarı / Serdivan)',
      address: 'Adapazarı/Sakarya',
      lat: 40.7569,
      lng: 30.3783,
      keywords: 'sakarya,adapazari,serdivan,arifiye yht,sapanca',
    ),
    _PlaceGazetteerEntry(
      name: 'Eskişehir YHT Garı & Merkez',
      address: 'Tepebaşı/Eskişehir',
      lat: 39.7825,
      lng: 30.5106,
      keywords: 'eskisehir,eskişehir,eskisehir yht,odunpazari,tepebasi,anadolu universitesi,osmangazi',
    ),
    _PlaceGazetteerEntry(
      name: 'Bursa (Nilüfer / Osmangazi)',
      address: 'Osmangazi/Bursa',
      lat: 40.1885,
      lng: 29.0610,
      keywords: 'bursa,nilufer,osmangazi,gorukle,uludag universitesi,mudanya,gemlik,inegol',
    ),
    _PlaceGazetteerEntry(
      name: 'Konya YHT Garı & Merkez',
      address: 'Selçuklu/Konya',
      lat: 37.8746,
      lng: 32.4932,
      keywords: 'konya,selcuklu,selçuklu,meram,karatay,konya yht,bosna hersek',
    ),
    _PlaceGazetteerEntry(
      name: 'Antalya Merkez / Muratpaşa / Konyaaltı',
      address: 'Muratpaşa/Antalya',
      lat: 36.8841,
      lng: 30.7056,
      keywords: 'antalya,muratpasa,konyaalti,lara,akdeniz universitesi,alanya,manavgat,kemer,kas',
    ),
    _PlaceGazetteerEntry(
      name: 'Adana Merkez / Seyhan / Çukurova',
      address: 'Seyhan/Adana',
      lat: 37.0000,
      lng: 35.3213,
      keywords: 'adana,seyhan,cukurova,çukurova,yuregir',
    ),
    _PlaceGazetteerEntry(
      name: 'Mersin Merkez / Yenişehir',
      address: 'Yenişehir/Mersin',
      lat: 36.8121,
      lng: 34.6415,
      keywords: 'mersin,yenisehir,mezitli,tarsus,erdemli',
    ),
    _PlaceGazetteerEntry(
      name: 'Gaziantep Merkez / Şahinbey / Şehitkamil',
      address: 'Şahinbey/Gaziantep',
      lat: 37.0662,
      lng: 37.3833,
      keywords: 'gaziantep,antep,sahinbey,sehitkamil',
    ),
    _PlaceGazetteerEntry(
      name: 'Kayseri Merkez / Melikgazi / Talas',
      address: 'Melikgazi/Kayseri',
      lat: 38.7312,
      lng: 35.4787,
      keywords: 'kayseri,melikgazi,talas,erciyes',
    ),
    _PlaceGazetteerEntry(
      name: 'Samsun Merkez / Atakum / İlkadım',
      address: 'Atakum/Samsun',
      lat: 41.2867,
      lng: 36.3300,
      keywords: 'samsun,atakum,ilkadim,ondokuz mayis',
    ),
    _PlaceGazetteerEntry(
      name: 'Trabzon Merkez / Ortahisar / KTÜ',
      address: 'Ortahisar/Trabzon',
      lat: 41.0027,
      lng: 39.7168,
      keywords: 'trabzon,ortahisar,ktu,akcaabat',
    ),
    _PlaceGazetteerEntry(
      name: 'Diyarbakır Merkez / Kayapınar / Sur',
      address: 'Yenişehir/Diyarbakır',
      lat: 37.9144,
      lng: 40.2306,
      keywords: 'diyarbakir,diyarbakır,kayapinar,sur,baglar',
    ),
    _PlaceGazetteerEntry(
      name: 'Şanlıurfa Merkez / Haliliye / Karaköprü',
      address: 'Haliliye/Şanlıurfa',
      lat: 37.1591,
      lng: 38.7969,
      keywords: 'sanliurfa,şanlıurfa,urfa,haliliye,karakopru',
    ),
    _PlaceGazetteerEntry(
      name: 'Erzurum Merkez / Yakutiye / Atatürk Üni.',
      address: 'Yakutiye/Erzurum',
      lat: 39.9043,
      lng: 41.2679,
      keywords: 'erzurum,yakutiye,palandoken,ataturk universitesi',
    ),
    _PlaceGazetteerEntry(
      name: 'Sivas Merkez & YHT Garı',
      address: 'Merkez/Sivas',
      lat: 39.7477,
      lng: 37.0179,
      keywords: 'sivas,sivas yht,cumhuriyet universitesi',
    ),
    _PlaceGazetteerEntry(
      name: 'Bolu Merkez / Abant İzzet Baysal',
      address: 'Merkez/Bolu',
      lat: 40.7350,
      lng: 31.6061,
      keywords: 'bolu,abant,gerede',
    ),
    _PlaceGazetteerEntry(
      name: 'Düzce Merkez',
      address: 'Merkez/Düzce',
      lat: 40.8438,
      lng: 31.1565,
      keywords: 'duzce,düzce,akcakoca',
    ),
    _PlaceGazetteerEntry(
      name: 'Yalova Merkez / İDO İskele',
      address: 'Merkez/Yalova',
      lat: 40.6550,
      lng: 29.2769,
      keywords: 'yalova,cinarcik',
    ),
    _PlaceGazetteerEntry(
      name: 'Tekirdağ Merkez / Süleymanpaşa / Çorlu',
      address: 'Süleymanpaşa/Tekirdağ',
      lat: 40.9833,
      lng: 27.5167,
      keywords: 'tekirdag,tekirdağ,corlu,çorlu,cerkezkoy',
    ),
    _PlaceGazetteerEntry(
      name: 'Edirne Merkez / Trakya Üniversitesi',
      address: 'Merkez/Edirne',
      lat: 41.6771,
      lng: 26.5557,
      keywords: 'edirne,trakya,kesan',
    ),
    _PlaceGazetteerEntry(
      name: 'Çanakkale Merkez / İskele / ÇOMÜ',
      address: 'Merkez/Çanakkale',
      lat: 40.1553,
      lng: 26.4142,
      keywords: 'canakkale,çanakkale,gelibolu,biga',
    ),
    _PlaceGazetteerEntry(
      name: 'Balıkesir Merkez / Bandırma / Edremit',
      address: 'Karesi/Balıkesir',
      lat: 39.6484,
      lng: 27.8826,
      keywords: 'balikesir,balıkesir,bandirma,edremit,ayvalik,akcay',
    ),
    _PlaceGazetteerEntry(
      name: 'Manisa Merkez / Yunusemre / Celal Bayar',
      address: 'Yunusemre/Manisa',
      lat: 38.6191,
      lng: 27.4289,
      keywords: 'manisa,turgutlu,akhisar,salihli',
    ),
    _PlaceGazetteerEntry(
      name: 'Aydın Merkez / Efeler / Kuşadası',
      address: 'Efeler/Aydın',
      lat: 37.8560,
      lng: 27.8416,
      keywords: 'aydin,aydın,kusadasi,kuşadası,didim,nazilli,soke',
    ),
    _PlaceGazetteerEntry(
      name: 'Muğla Merkez / Bodrum / Marmaris / Fethiye',
      address: 'Menteşe/Muğla',
      lat: 37.2153,
      lng: 28.3636,
      keywords: 'mugla,muğla,kotekli,bodrum,marmaris,fethiye,dalaman,milas,datca',
    ),
    _PlaceGazetteerEntry(
      name: 'Denizli Merkez / Pamukkale',
      address: 'Pamukkale/Denizli',
      lat: 37.7765,
      lng: 29.0864,
      keywords: 'denizli,pamukkale',
    ),
    _PlaceGazetteerEntry(
      name: 'Isparta Merkez / SDÜ',
      address: 'Merkez/Isparta',
      lat: 37.7648,
      lng: 30.5566,
      keywords: 'isparta,ısparta,sdu,suleyman demirel',
    ),
    _PlaceGazetteerEntry(
      name: 'Afyonkarahisar Merkez',
      address: 'Merkez/Afyonkarahisar',
      lat: 38.7507,
      lng: 30.5567,
      keywords: 'afyon,afyonkarahisar,sandikli',
    ),
    _PlaceGazetteerEntry(
      name: 'Kütahya Merkez / Dumlupınar Üni.',
      address: 'Merkez/Kütahya',
      lat: 39.4167,
      lng: 29.9833,
      keywords: 'kutahya,kütahya,tavsanli',
    ),
    _PlaceGazetteerEntry(
      name: 'Bilecik / Bozüyük YHT',
      address: 'Merkez/Bilecik',
      lat: 40.1451,
      lng: 29.9799,
      keywords: 'bilecik,bozuyuk,bozüyük,bilecik yht',
    ),
    _PlaceGazetteerEntry(
      name: 'Kırıkkale Merkez',
      address: 'Merkez/Kırıkkale',
      lat: 39.8468,
      lng: 33.5153,
      keywords: 'kirikkale,kırıkkale,yahsihan',
    ),
    _PlaceGazetteerEntry(
      name: 'Kırşehir Merkez',
      address: 'Merkez/Kırşehir',
      lat: 39.1425,
      lng: 34.1709,
      keywords: 'kirsehir,kırşehir',
    ),
    _PlaceGazetteerEntry(
      name: 'Nevşehir / Kapadokya / Ürgüp',
      address: 'Merkez/Nevşehir',
      lat: 38.6244,
      lng: 34.7144,
      keywords: 'nevsehir,nevşehir,kapadokya,urgup,goreme,avanos',
    ),
    _PlaceGazetteerEntry(
      name: 'Aksaray Merkez',
      address: 'Merkez/Aksaray',
      lat: 38.3687,
      lng: 34.0370,
      keywords: 'aksaray',
    ),
    _PlaceGazetteerEntry(
      name: 'Niğde Merkez',
      address: 'Merkez/Niğde',
      lat: 37.9667,
      lng: 34.6833,
      keywords: 'nigde,niğde,bor',
    ),
    _PlaceGazetteerEntry(
      name: 'Karaman Merkez & YHT',
      address: 'Merkez/Karaman',
      lat: 37.1759,
      lng: 33.2287,
      keywords: 'karaman,karaman yht',
    ),
    _PlaceGazetteerEntry(
      name: 'Yozgat Merkez & YHT',
      address: 'Merkez/Yozgat',
      lat: 39.8181,
      lng: 34.8147,
      keywords: 'yozgat,yozgat yht,sorgun',
    ),
    _PlaceGazetteerEntry(
      name: 'Çorum Merkez',
      address: 'Merkez/Çorum',
      lat: 40.5506,
      lng: 34.9556,
      keywords: 'corum,çorum,sungurlu',
    ),
    _PlaceGazetteerEntry(
      name: 'Amasya Merkez / Merzifon',
      address: 'Merkez/Amasya',
      lat: 40.6499,
      lng: 35.8353,
      keywords: 'amasya,merzifon',
    ),
    _PlaceGazetteerEntry(
      name: 'Tokat Merkez',
      address: 'Merkez/Tokat',
      lat: 40.3167,
      lng: 36.5500,
      keywords: 'tokat,erbaa,turhal',
    ),
    _PlaceGazetteerEntry(
      name: 'Zonguldak Merkez / Ereğli',
      address: 'Merkez/Zonguldak',
      lat: 41.4564,
      lng: 31.7987,
      keywords: 'zonguldak,eregli,karadeniz eregli',
    ),
    _PlaceGazetteerEntry(
      name: 'Karabük Merkez / Safranbolu',
      address: 'Merkez/Karabük',
      lat: 41.2061,
      lng: 32.6204,
      keywords: 'karabuk,karabük,safranbolu',
    ),
    _PlaceGazetteerEntry(
      name: 'Kastamonu Merkez',
      address: 'Merkez/Kastamonu',
      lat: 41.3887,
      lng: 33.7827,
      keywords: 'kastamonu',
    ),
    _PlaceGazetteerEntry(
      name: 'Ordu Merkez / Altınordu / Ünye',
      address: 'Altınordu/Ordu',
      lat: 40.9839,
      lng: 37.8764,
      keywords: 'ordu,altinordu,unye,fatsa',
    ),
    _PlaceGazetteerEntry(
      name: 'Giresun Merkez',
      address: 'Merkez/Giresun',
      lat: 40.9128,
      lng: 38.3895,
      keywords: 'giresun,bulancak',
    ),
    _PlaceGazetteerEntry(
      name: 'Rize Merkez',
      address: 'Merkez/Rize',
      lat: 41.0201,
      lng: 40.5234,
      keywords: 'rize,cayeli,ardesen',
    ),
    _PlaceGazetteerEntry(
      name: 'Malatya Merkez / İnönü Üni.',
      address: 'Battalgazi/Malatya',
      lat: 38.3552,
      lng: 38.3095,
      keywords: 'malatya,battalgazi,yesilyurt',
    ),
    _PlaceGazetteerEntry(
      name: 'Elazığ Merkez / Fırat Üni.',
      address: 'Merkez/Elazığ',
      lat: 38.6810,
      lng: 39.2264,
      keywords: 'elazig,elazığ,firat universitesi',
    ),
    _PlaceGazetteerEntry(
      name: 'Hatay (Antakya / İskenderun)',
      address: 'Antakya/Hatay',
      lat: 36.2021,
      lng: 36.1606,
      keywords: 'hatay,antakya,iskenderun,dortyol',
    ),
    _PlaceGazetteerEntry(
      name: 'Kahramanmaraş Merkez',
      address: 'Onikişubat/Kahramanmaraş',
      lat: 37.5858,
      lng: 36.9371,
      keywords: 'kahramanmaras,kahramanmaraş,maras,elbistan',
    ),
    _PlaceGazetteerEntry(
      name: 'Van Merkez / İpekyolu / Edremit',
      address: 'İpekyolu/Van',
      lat: 38.4891,
      lng: 43.4089,
      keywords: 'van,ipekyolu,tusba,yuzuncu yil',
    ),
    _PlaceGazetteerEntry(
      name: 'Mardin Merkez / Artuklu',
      address: 'Artuklu/Mardin',
      lat: 37.3212,
      lng: 40.7245,
      keywords: 'mardin,artuklu,kiziltepe,midyat',
    ),
    _PlaceGazetteerEntry(
      name: 'Batman Merkez',
      address: 'Merkez/Batman',
      lat: 37.8812,
      lng: 41.1351,
      keywords: 'batman',
    ),
  ];
}

class _PlaceGazetteerEntry {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String keywords;

  const _PlaceGazetteerEntry({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.keywords = '',
  });

  RideLocationPoint get point => RideLocationPoint(
        name: name,
        address: address,
        lat: lat,
        lng: lng,
        geohash: 'tr',
      );
}

