# Paylaşımlı Yolculuk Uygulaması — Firebase + Local Storage Entegrasyon ve Kurulum Spesifikasyonu (Antigravity İçin)

Bu doküman, Flutter tabanlı paylaşımlı yolculuk uygulamasının **Firebase (Authentication + Cloud Firestore)** ve **Local Storage (Hive + Flutter Secure Storage + Shared Preferences)** katmanlarının birbirine nasıl bağlanacağını, koleksiyonların nasıl otomatik oluşturulacağını, güvenlik kurallarını (Security Rules), bileşik indeksleri (Composite Indexes) ve çevrimdışı senkronizasyon (Offline-First) kod mimarisini tanımlar.

> **Antigravity İçin Talimat:**
> Kullanıcı Firebase projesini açıp `flutterfire configure` komutunu çalıştırarak `lib/firebase_options.dart` dosyasını oluşturmuştur (veya oluşturacaktır). Veri katmanını (`data/`), yerel depolama servislerini (`core/storage/`) ve başlangıç veri tohumlama (`SeedDataService`) yapısını bu dokümandaki kurallara birebir uyarak kodla.

## 1. Gerekli Paketler (`pubspec.yaml`)

Antigravity `pubspec.yaml` dosyasına aşağıdaki veritabanı ve depolama paketlerini eklemelidir:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management & Routing
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.0

  # Cloud Database & Auth (Firebase)
  firebase_core: ^3.3.0
  firebase_auth: ^5.1.4
  cloud_firestore: ^5.2.1

  # Local Storage (Cihaz İçi Veri Depolama)
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.2.2
  shared_preferences: ^2.3.1

  # Bağlantı Kontrolü ve Yardımcılar
  connectivity_plus: ^6.0.4
  intl: ^0.19.0
  uuid: ^4.4.2
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
```

## 2. Firestore Koleksiyonlarını Otomatik Oluşturma (`FirestoreSeeder`)

Firestore NoSQL bir veritabanı olduğu için SQL'deki gibi önceden boş tablo (`CREATE TABLE`) oluşturulmasına gerek yoktur; ilk belge (`Document`) yazıldığında koleksiyon (`Collection`) otomatik oluşur.

Ancak projenin ilk çalıştırılışında tüm koleksiyonların (`users`, `vehicles`, `rides`, `bookings`, `chats`, `reviews`) Firebase Console üzerinde hemen görünmesi ve uygulamanın dolu verilerle test edilebilmesi için Antigravity **`lib/core/services/firestore_seeder.dart`** sınıfını oluşturmalıdır:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeeder {
  final FirebaseFirestore _firestore;

  FirestoreSeeder(this._firestore);

  /// Veritabanı boşsa örnek kullanıcı, araç ve yolculuk ilanlarını oluşturur.
  Future<void> seedInitialDataIfNeeded() async {
    final ridesSnapshot = await _firestore.collection('rides').limit(1).get();
    if (ridesSnapshot.docs.isNotEmpty) {
      return; // Veritabanında zaten veri var, tekrar ekleme yapma.
    }

    final batch = _firestore.batch();

    // 1. Örnek Sürücü Kullanıcı (users koleksiyonu)
    final driverRef = _firestore.collection('users').doc('demo_driver_1');
    batch.set(driverRef, {
      'id': 'demo_driver_1',
      'email': 'ahmet.yilmaz@universite.edu.tr',
      'fullName': 'Ahmet Yılmaz',
      'phoneNumber': '+905551112233',
      'avatarUrl': 'https://i.pravatar.cc/150?u=ahmet',
      'bio': 'Bilgisayar Müh. 4. Sınıf. Her sabah Kadıköy - Maslak arası gidiyorum.',
      'role': 'both',
      'isVerified': true,
      'ratingAvg': 4.9,
      'ratingCount': 18,
      'preferences': {
        'smokingAllowed': false,
        'petsAllowed': true,
        'musicPreference': 'Rock / Akustik',
        'chatLevel': 'moderate',
      },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 2. Örnek Araç (vehicles koleksiyonu)
    final vehicleRef = _firestore.collection('vehicles').doc('demo_vehicle_1');
    batch.set(vehicleRef, {
      'id': 'demo_vehicle_1',
      'ownerId': 'demo_driver_1',
      'brand': 'Renault',
      'model': 'Clio',
      'year': 2023,
      'color': 'Beyaz',
      'licensePlate': '34 ABC 123',
      'totalSeats': 4,
      'isVerified': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 3. Örnek Yolculuk İlanı (rides koleksiyonu)
    final rideRef = _firestore.collection('rides').doc('demo_ride_1');
    final tomorrowMorning = DateTime.now().add(const Duration(days: 1));
    batch.set(rideRef, {
      'id': 'demo_ride_1',
      'driverId': 'demo_driver_1',
      'driverSummary': {
        'fullName': 'Ahmet Yılmaz',
        'avatarUrl': 'https://i.pravatar.cc/150?u=ahmet',
        'ratingAvg': 4.9,
      },
      'vehicleId': 'demo_vehicle_1',
      'vehicleSummary': {
        'brandModel': 'Renault Clio',
        'color': 'Beyaz',
        'licensePlate': '34 ABC 123',
      },
      'origin': {
        'name': 'Kadıköy Rıhtım',
        'address': 'Caferağa, Kadıköy/İstanbul',
        'lat': 40.9901,
        'lng': 29.0234,
      },
      'destination': {
        'name': 'İTÜ Ayazağa Kampüsü',
        'address': 'Maslak, Sarıyer/İstanbul',
        'lat': 41.1055,
        'lng': 29.0252,
      },
      'waypoints': [
        {'name': 'Mecidiyeköy Metrobüs', 'lat': 41.0668, 'lng': 28.9963}
      ],
      'departureTime': Timestamp.fromDate(
        DateTime(tomorrowMorning.year, tomorrowMorning.month, tomorrowMorning.day, 8, 30),
      ),
      'totalSeatsOffered': 3,
      'availableSeats': 2,
      'pricePerSeat': 80.0,
      'currency': 'TRY',
      'status': 'planned',
      'rules': {
        'instantApproval': false,
        'luggageSize': 'medium',
        'smokingAllowed': false,
        'petsAllowed': true,
      },
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
```

## 3. Hibrit Veri Depolama Servisi (`LocalCacheService` + `SecureStorageService`)

Antigravity, `lib/core/storage/` dizini altında aşağıdaki iki temel servisi oluşturmalıdır:

### 3.1. `LocalCacheService` (`lib/core/storage/local_cache_service.dart`)
Hive üzerinde JSON tabanlı önbellekleme yapar. Böylece `build_runner` ile TypeAdapter çakışması yaşanmadan tüm modeller `Map<String, dynamic>` (JSON) olarak saklanır ve okunur:

- **`box_user_session`**: Aktif kullanıcının profil verisini saklar.
- **`box_my_rides`**: Kullanıcının oluşturduğu veya katıldığı yolculukları çevrimdışı erişim için saklar.
- **`box_my_bookings`**: Kullanıcının aktif rezervasyonlarını çevrimdışı bilet gösterimi için saklar.
- **`box_search_history`**: Son aranan kalkış-varış çiftlerini saklar.

```dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class LocalCacheService {
  static const String userSessionBoxName = 'box_user_session';
  static const String myRidesBoxName = 'box_my_rides';
  static const String myBookingsBoxName = 'box_my_bookings';
  static const String searchHistoryBoxName = 'box_search_history';

  Future<void> initBoxes() async {
    await Hive.openBox<String>(userSessionBoxName);
    await Hive.openBox<String>(myRidesBoxName);
    await Hive.openBox<String>(myBookingsBoxName);
    await Hive.openBox<String>(searchHistoryBoxName);
  }

  // Liste önbellekleme (Örn: Yolculuklarım veya Rezervasyonlarım)
  Future<void> cacheJsonList(String boxName, String key, List<Map<String, dynamic>> items) async {
    final box = Hive.box<String>(boxName);
    await box.put(key, jsonEncode(items));
  }

  List<Map<String, dynamic>> getCachedJsonList(String boxName, String key) {
    final box = Hive.box<String>(boxName);
    final raw = box.get(key);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // Tekil nesne önbellekleme (Örn: Kullanıcı Profili)
  Future<void> cacheJsonObject(String boxName, String key, Map<String, dynamic> data) async {
    final box = Hive.box<String>(boxName);
    await box.put(key, jsonEncode(data));
  }

  Map<String, dynamic>? getCachedJsonObject(String boxName, String key) {
    final box = Hive.box<String>(boxName);
    final raw = box.get(key);
    if (raw == null) return null;
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<void> clearAllCache() async {
    await Hive.box<String>(userSessionBoxName).clear();
    await Hive.box<String>(myRidesBoxName).clear();
    await Hive.box<String>(myBookingsBoxName).clear();
  }
}
```

### 3.2. `SecureStorageService` (`lib/core/storage/secure_storage_service.dart`)
Hassas oturum bilgilerini (`uid`, `email`, `auth_token`) şifreli olarak saklar:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _keyUserId = 'secure_user_id';
  static const String _keyUserEmail = 'secure_user_email';

  Future<void> saveSession({required String userId, required String email}) async {
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyUserEmail, value: email);
  }

  Future<String?> getUserId() => _storage.read(key: _keyUserId);

  Future<void> clearSession() => _storage.deleteAll();
}
```

## 4. Network-First + Offline-Fallback Repository Şablonu

Antigravity tüm Repository sınıflarında (`RideRepositoryImpl`, `BookingRepositoryImpl`) aşağıdaki hibrit veri akışını uygulamalıdır:

1. **Veri Okurken (`getMyRides`, `getMyBookings`):**
   - Önce `FirebaseFirestore` üzerinden veriyi çekmeyi dene.
   - Başarılı olursa: Gelen belgeleri (`Timestamp` alanlarını ISO-8601 `String` formatına dönüştürerek) `LocalCacheService` içine kaydet ve UI'a döndür.
   - İnternet yoksa veya `FirebaseException` alınırsa: `LocalCacheService.getCachedJsonList(...)` üzerinden cihazdaki son kaydedilen veriyi oku ve UI'a döndür.
2. **Veri Yazarken (`createRide`, `bookSeat`, `approveBooking`):**
   - İşlemi `FirebaseFirestore` üzerinde gerçekleştir.
   - Hemen ardından yerel önbellekteki (`LocalCacheService`) ilgili listeyi güncelle.

## 5. Firestore Güvenlik Kuralları (`firestore.rules`)

Firebase Console > Firestore Database > **Rules** sekmesine yapıştırılacak güvenlik kuralları:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    // 1. Kullanıcı Profilleri
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create, update: if isOwner(userId);
      allow delete: if false;
    }

    // 2. Araçlar
    match /vehicles/{vehicleId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && request.resource.data.ownerId == request.auth.uid;
      allow update, delete: if isSignedIn() && resource.data.ownerId == request.auth.uid;
    }

    // 3. Yolculuk İlanları
    match /rides/{rideId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && request.resource.data.driverId == request.auth.uid;
      // Sürücü kendi ilanını güncelleyebilir VEYA rezervasyon transaction'ı koltuk sayısını güncelleyebilir
      allow update: if isSignedIn();
      allow delete: if isSignedIn() && resource.data.driverId == request.auth.uid;
    }

    // 4. Rezervasyonlar
    match /bookings/{bookingId} {
      allow read: if isSignedIn() && (
        resource.data.passengerId == request.auth.uid ||
        resource.data.driverId == request.auth.uid
      );
      allow create: if isSignedIn() && request.resource.data.passengerId == request.auth.uid;
      allow update: if isSignedIn() && (
        resource.data.passengerId == request.auth.uid ||
        resource.data.driverId == request.auth.uid
      );
    }

    // 5. Sohbet Odaları ve Mesajlar
    match /chats/{chatId} {
      allow read, create, update: if isSignedIn() && request.auth.uid in resource.data.participantIds
        || (isSignedIn() && request.auth.uid in request.resource.data.participantIds);

      match /messages/{messageId} {
        allow read, create: if isSignedIn();
      }
    }

    // 6. Değerlendirmeler
    match /reviews/{reviewId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && request.resource.data.reviewerId == request.auth.uid;
    }
  }
}
```
