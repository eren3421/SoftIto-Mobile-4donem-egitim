# Çok Modlu Araç Kiralama Sistemi — Teknik Mimari Dokümanı (`architecture.md`)

## 1. Mimari Genel Bakış

Uygulama, ölçeklenebilirlik, test edilebilirlik ve Anti-Gravity tarafından modüler kod üretimi için **Feature-First Clean Architecture (Özellik Odaklı Temiz Mimari)** ve **Reactive MVVM** desenini kullanır. Durum yönetimi (State Management) için **Riverpod (`flutter_riverpod`)**, sayfa yönlendirmeleri ve rol tabanlı erişim kontrolü (RBAC) için **GoRouter (`go_router`)** tercih edilmiştir.

### 1.1. Teknoloji Yığını ve Temel Paketler

| Katman / İhtiyaç | Önerilen Paket / Teknoloji | Kullanım Amacı |
| :--- | :--- | :--- | :--- |
| **Framework & Dil** | Flutter (3.22+) & Dart (3.4+) | Çoklu platform (Mobil, Web, Masaüstü) UI geliştirme |
| **Durum Yönetimi** | `flutter_riverpod` & `riverpod_annotation` | Reaktif durum yönetimi, filtreleme, canlı takip ve mesajlaşma akışları |
| **Yönlendirme (Routing)** | `go_router` | Sivil ve Firma rol korumalı (Guard) navigasyon, derin bağlantılar |
| **Veri Modelleme** | `freezed_annotation`, `json_annotation` | Değişmez (Immutable) veri sınıfları, Union tipler ve JSON serileştirme |
| **Harita ve Canlı Takip** | `flutter_map` & `latlong2` | Takip numarası ile kara, hava ve deniz taşıtlarının canlı harita takibi |
| **Gerçek Zamanlı Altyapı** | `StreamController` / Firebase Firestore veya WebSocket | Gerçek zamanlı GPS telemetri akışı ve anlık mesajlaşma |
| **Tipografi ve İkonlar** | `google_fonts`, `lucide_icons` / `MaterialIcons` | Koyu kırmızı & gri temaya uygun modern endüstriyel ikonografi ve fontlar |
| **Tarih & Biçimlendirme** | `intl` | Para birimi, birim fiyat ve rezervasyon tarih aralığı formatlama |

## 2. Proje Klasör Yapısı (Directory Structure)

Anti-Gravity projeyi oluştururken `lib/` altında aşağıdaki modüler dizin yapısını kurmalıdır:

```text
lib/
  main.dart
  app.dart
  core/
    constants/
      app_colors.dart
      app_typography.dart
      app_spacing.dart
    theme/
      app_theme.dart
    router/
      app_router.dart
      route_guards.dart
    utils/
      validators.dart          # TC Kimlik (11 hane), Telefon, Plaka ve Takip No doğrulayıcılar
      formatters.dart          # Fiyat, tarih ve koordinat formatlayıcılar
    widgets/
      crimson_button.dart
      slate_card.dart
      custom_text_field.dart
      vehicle_type_badge.dart
  features/
    auth/
      domain/
        models/
          user_role.dart
          address_model.dart
          civilian_user.dart
          company_user.dart
        repositories/
          auth_repository.dart
      data/
        repositories/
          auth_repository_impl.dart
      presentation/
        providers/
          auth_provider.dart
        screens/
          auth_portal_screen.dart      # Sivil ve Firma ayrı giriş/kayıt sekmeleri
          civilian_profile_screen.dart
          company_profile_screen.dart
    vehicles/
      domain/
        models/
          vehicle_type.dart            # Land (Kara), Air (Hava), Sea (Deniz)
          vehicle_model.dart
          vehicle_filter_state.dart    # 7 kriterli filtre modeli
        repositories/
          vehicle_repository.dart
      data/
        repositories/
          vehicle_repository_impl.dart
      presentation/
        providers/
          vehicle_list_provider.dart
          vehicle_filter_provider.dart
        screens/
          vehicle_discovery_screen.dart
          vehicle_detail_screen.dart
          add_edit_vehicle_screen.dart
        widgets/
          vehicle_filter_panel.dart
          vehicle_card.dart
    tracking/
      domain/
        models/
          tracking_telemetry.dart
        repositories/
          tracking_repository.dart
      data/
        repositories/
          tracking_repository_impl.dart
      presentation/
        providers/
          tracking_stream_provider.dart
        screens/
          realtime_tracking_screen.dart
        widgets/
          tracking_map_view.dart
          telemetry_status_card.dart
    reservations/
      domain/
        models/
          reservation_status.dart
          reservation_model.dart       # Araç + Kiralayan (Sivil) + Araç Sahibi (Sivil/Firma)
        repositories/
          reservation_repository.dart
      data/
        repositories/
          reservation_repository_impl.dart
      presentation/
        providers/
          reservation_provider.dart
        screens/
          reservation_panel_screen.dart
          create_reservation_sheet.dart
        widgets/
          reservation_triad_card.dart  # Üçlü taraf bilgisini gösteren kart
    messaging/
      domain/
        models/
          chat_room.dart
          chat_message.dart
        repositories/
          messaging_repository.dart
      data/
        repositories/
          messaging_repository_impl.dart
      presentation/
        providers/
          messaging_provider.dart
        screens/
          chat_list_screen.dart
          chat_conversation_screen.dart
```

## 3. Domain Veri Modelleri ve Şemalar

Tüm veri modelleri eksiksiz olarak aşağıdaki alanları barındırmalıdır:

### 3.1. Adres ve Kullanıcı Modelleri (`CivilianUser` & `CompanyUser`)

```dart
enum UserRole { civilian, company }

class AddressModel {
  final String country;      // Ülke (Örn: Türkiye)
  final String city;         // Şehir (Örn: İstanbul)
  final String district;     // İlçe (Örn: Beşiktaş)
  final String fullAddress;  // Açık Adres
  final double? latitude;
  final double? longitude;

  const AddressModel({
    required this.country,
    required this.city,
    required this.district,
    required this.fullAddress,
    this.latitude,
    this.longitude,
  });
}

/// Sivil Kullanıcı: Hem araç kiraya verebilir hem de araç kiralayabilir.
class CivilianUser {
  final String id;
  final String firstName;          // Ad
  final String lastName;           // Soyad
  final String tcIdentityNumber;   // 11 Haneli T.C. Kimlik Numarası
  final String phoneNumber;        // İletişim Numarası
  final AddressModel address;      // Adres (Ülke, Şehir, Açık Adres)
  final List<String> vehicleIds;   // Sahip olduğu (kiraya verdiği) araçların ID listesi

  String get fullName => '$firstName $lastName';

  const CivilianUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.tcIdentityNumber,
    required this.phoneNumber,
    required this.address,
    this.vehicleIds = const [],
  });
}

/// Firma Kullanıcısı: Sadece şubesine ait araçları kiraya verebilir.
class CompanyUser {
  final String id;
  final String companyName;          // Firma Adı
  final String branchName;           // Şube Adı / Kodu
  final AddressModel branchAddress;  // Firmanın O Şubesinin Adresi (Ülke, Şehir, Açık Adres)
  final String contactPhone;         // Şube İletişim Numarası
  final List<String> vehicleIds;     // Şubenin kiraya verdiği araçların ID listesi

  const CompanyUser({
    required this.id,
    required this.companyName,
    required this.branchName,
    required this.branchAddress,
    required this.contactPhone,
    this.vehicleIds = const [],
  });
}
```

### 3.2. Araç Modeli (`VehicleModel`) ve Filtre Durumu (`VehicleFilterState`)

```dart
enum VehicleCategory {
  land, // Kara Taşıtı
  air,  // Hava Taşıtı
  sea   // Deniz Taşıtı
}

class VehicleModel {
  final String id;
  final String ownerId;                // Sivil veya Firma ID
  final String ownerName;              // Sivil Ad Soyad veya Firma Adı - Şube
  final UserRole ownerRole;            // civilian veya company
  final VehicleCategory vehicleType;   // Tür: Kara, Hava, Deniz
  final String brand;                  // Marka
  final String model;                  // Model
  final String plateNumber;            // Plaka No / Kuyruk No / Deniz Sicil No
  final double unitPrice;              // Birim Fiyat (Günlük/Saatlik)
  final String pricingPeriod;          // 'Günlük' veya 'Saatlik'
  final String trackingNumber;         // Benzersiz Takip Numarası (Örn: TRK-LAND-3401)
  final String country;                // Bulunduğu Ülke
  final String city;                   // Bulunduğu Şehir
  final bool isAvailable;              // Şu an kiralanabilir mi?
  final String? imageUrl;

  const VehicleModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerRole,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.unitPrice,
    this.pricingPeriod = 'Günlük',
    required this.trackingNumber,
    required this.country,
    required this.city,
    this.isAvailable = true,
    this.imageUrl,
  });
}

/// 7 Kriterli Araç Filtreleme Durumu
class VehicleFilterState {
  final String? ownerQuery;            // 1. Sahibine göre (isim veya ID)
  final UserRole? ownerRoleFilter;     // Sahip tipi (Sivil / Firma)
  final String? country;               // 2. Bulunduğu ülkeye göre
  final String? city;                  // 3. Bulunduğu şehre göre
  final VehicleCategory? vehicleType;  // 4. Türüne göre (Kara, Hava, Deniz)
  final String? brand;                 // 5. Markaya göre
  final String? model;                 // 6. Modele göre
  final String? plateNumberQuery;      // 7. Plakaya göre

  const VehicleFilterState({
    this.ownerQuery,
    this.ownerRoleFilter,
    this.country,
    this.city,
    this.vehicleType,
    this.brand,
    this.model,
    this.plateNumberQuery,
  });
}
```

### 3.3. Gerçek Zamanlı Takip Modeli (`TrackingTelemetry`)

```dart
class TrackingTelemetry {
  final String trackingNumber;       // Aracın takip numarası
  final String vehicleId;
  final String plateNumber;
  final VehicleCategory vehicleType;
  final double latitude;             // Anlık Enlem
  final double longitude;            // Anlık Boylam
  final double speedKmh;             // Anlık Hız (km/s)
  final double headingDegrees;       // Yön açısı (0-360)
  final double? altitudeMeters;      // Hava taşıtları için irtifa (m)
  final bool isEngineRunning;        // Motor / Aktiflik durumu
  final DateTime lastUpdated;        // Son sinyal zamanı
  final String? activeReservationId; // Aktif kirada ise rezervasyon ID

  const TrackingTelemetry({
    required this.trackingNumber,
    required this.vehicleId,
    required this.plateNumber,
    required this.vehicleType,
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.headingDegrees,
    this.altitudeMeters,
    required this.isEngineRunning,
    required this.lastUpdated,
    this.activeReservationId,
  });
}
```

### 3.4. Üç Taraflı Rezervasyon Modeli (`ReservationModel`)

```dart
enum ReservationStatus { pending, approved, active, completed, cancelled }

class ReservationModel {
  final String id;
  // 1. Taraf: Araç Bilgileri
  final String vehicleId;
  final String vehicleSummary;       // Marka, Model, Tür
  final String plateNumber;
  final String trackingNumber;
  final double unitPrice;
  // 2. Taraf: Kiralayan (Yalnızca Sivil Kullanıcı)
  final String renterCivilianId;
  final String renterFullName;
  final String renterTcNumber;
  final String renterPhone;
  final String renterAddressSummary;
  // 3. Taraf: Araç Sahibi (Sivil veya Firma)
  final String ownerId;
  final UserRole ownerRole;
  final String ownerDisplayName;     // Ad Soyad veya Firma Adı
  final String ownerAddressSummary;  // Sivil Adresi veya Firma Şube Adresi
  final String ownerContactPhone;
  // Zaman ve Maliyet
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final ReservationStatus status;

  const ReservationModel({
    required this.id,
    required this.vehicleId,
    required this.vehicleSummary,
    required this.plateNumber,
    required this.trackingNumber,
    required this.unitPrice,
    required this.renterCivilianId,
    required this.renterFullName,
    required this.renterTcNumber,
    required this.renterPhone,
    required this.renterAddressSummary,
    required this.ownerId,
    required this.ownerRole,
    required this.ownerDisplayName,
    required this.ownerAddressSummary,
    required this.ownerContactPhone,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });
}
```

### 3.5. Mesajlaşma Modelleri (`ChatRoom` & `ChatMessage`)

```dart
class ChatRoom {
  final String id;
  final String vehicleId;
  final String vehicleTitle;         // Örn: "Mercedes G63 AMG (34 VR 1923)"
  final String? reservationId;
  final String ownerId;
  final String ownerName;
  final UserRole ownerRole;
  final String renterCivilianId;
  final String renterName;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  const ChatRoom({
    required this.id,
    required this.vehicleId,
    required this.vehicleTitle,
    this.reservationId,
    required this.ownerId,
    required this.ownerName,
    required this.ownerRole,
    required this.renterCivilianId,
    required this.renterName,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
  });
}

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });
}
```

## 4. İş Mantığı, Filtreleme Motoru ve Gerçek Zamanlı Akışlar

### 4.1. 7 Kriterli Reaktif Filtreleme Motoru
`filteredVehiclesProvider`, tüm araç listesini (`allVehiclesProvider`) ve aktif filtre durumunu (`vehicleFilterProvider`) dinler. Herhangi bir filtre değiştiğinde O(N) karmaşıklıkta anlık filtreleme yapar:
- **Sahip Filtresi**: `ownerQuery` doluysa `vehicle.ownerName` içinde büyük/küçük harf duyarsız arama yapar; `ownerRoleFilter` seçiliyse yalnızca `civilian` veya `company` araçlarını döndürür.
- **Ülke & Şehir Filtresi**: `country` ve `city` eşleşmelerini kontrol eder. Ülke değiştiğinde şehir dropdown listesi o ülkenin şehirleriyle dinamik güncellenir.
- **Tür Filtresi**: `Kara (land)`, `Hava (air)` veya `Deniz (sea)` seçimine göre süzer.
- **Marka, Model ve Plaka Filtresi**: Hem açılır listeden (dropdown) seçimi hem de metin kutusundan kısmi plaka/model eşleşmesini (`contains`) destekler.

### 4.2. Takip Numarası ile Gerçek Zamanlı Takip Mimari Akışı
- `TrackingRepository`, araç sahiplerinin kendi araçlarına ait `trackingNumber` değerini kullanarak abone olabileceği bir `Stream<TrackingTelemetry> watchVehicleByTrackingNumber(String trackingNumber, String currentOwnerId)` metodu sunar.
- **Güvenlik Doğrulaması**: Sorgulanan `trackingNumber` değerine sahip aracın `ownerId` alanı, oturum açmış kullanıcının (`CivilianUser.id` veya `CompanyUser.id`) ID'si ile eşleşmelidir. Aksi halde yetkisiz erişim hatası döner.
- **Simülasyon / Canlı Veri**: Geliştirme ve demo ortamında `Timer.periodic(const Duration(seconds: 2), ...)` ile çalışan bir telemetri üreteci, kara taşıtlarını şehir içi rotada, hava taşıtlarını havalimanı/heliport koridorunda (irtifa verisiyle), deniz taşıtlarını ise kıyı/boğaz hattında hareket ettirerek gerçek zamanlı koordinat üretir.

### 4.3. Yetki Korumalı Navigasyon (Role Guarding)
- **Kiralama Kısıtı**: `CreateReservationSheet` yalnızca `currentUser.role == UserRole.civilian` olduğunda açılabilir. Bir firma hesabı kendi veya başka bir firmanın aracını kiralayamaz; araç detay sayfasında firma kullanıcılarına "Kiralama Yap" butonu yerine "Kurumsal Hesaplar Yalnızca Kiraya Verebilir" bilgi rozeti veya araç kendisininkiyse "Canlı Takip Et / Düzenle" butonu gösterilir.
- **Araç Ekleme Yetkisi**: Hem `CivilianUser` hem de `CompanyUser` "Yeni Araç Kiraya Ver" ekranına erişebilir. Eklenen araç otomatik olarak ilgili kullanıcının `vehicleIds` listesine ve genel havuza kaydedilir.
![alt text](https://127.0.0.1:51734/static/artifacts/b0f1fd3e-e48f-4647-94ee-c0ed2e8a0195/.user_uploaded/media_1792504250119.png?csrf%3D10901fb3-e0ec-4041-905f-fa47141f1c85)