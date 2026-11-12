# Paylaşımlı Yolculuk Uygulaması — Antigravity Geliştirme Kılavuzu ve Görev Planı

Bu doküman, Flutter tabanlı paylaşımlı yolculuk uygulamasını **Antigravity** (AI kodlama asistanı/ajanı) kullanarak sıfırdan, hatasız ve modüler bir şekilde yazdırmak için hazırlanmış sistem kurallarını, klasör yapısını ve aşamalı (Faz 1 - Faz 6) görev istemlerini (prompt) içerir.

> **Nasıl Kullanılır?**
> `01_sistem_analizi_ve_mimari.md`, `02_veri_depolama_ve_sema.md` ve bu dosyayı (`03_antigravity_gelistirme_kilavuzu.md`) proje çalışma dizininize (`docs/` klasörüne veya kök dizine) ekleyin. Ardından Antigravity'ye aşağıdaki fazları sırasıyla uygulatın.

## 1. Antigravity İçin Mimari ve Kodlama Kuralları (System Rules)

Antigravity kodu üretirken aşağıdaki kurallara kesin olarak uymalıdır:

1. **Teknoloji Yığını ve Paketler:**
   - **Durum Yönetimi (State Management):** `flutter_riverpod` ve `riverpod_annotation` (AsyncNotifier / StreamNotifier mimarisi).
   - **Yönlendirme (Routing):** `go_router` (Auth state dinleyen redirect guard yapısı ile).
   - **Veri Modelleme:** `freezed_annotation` ve `json_annotation` (Immutable veri sınıfları ve `copyWith` desteği).
   - **Uzak Veritabanı ve Kimlik Doğrulama:** `firebase_core`, `firebase_auth`, `cloud_firestore`.
   - **Yerel Veri Depolama (Offline Storage):** `hive_flutter` (veya `isar`), `shared_preferences`, `flutter_secure_storage`.
   - **Harita ve Konum:** `flutter_map` (OpenStreetMap tabanlı, API anahtarı gerektirmeden hemen çalışabilen yapı) veya `google_maps_flutter`, `geolocator`, `latlong2`.
   - **Arayüz ve İkonlar:** Material 3 (`useMaterial3: true`), `google_fonts`, `lucide_icons` veya standart Material ikonları, `intl` (tarih ve para birimi formatlama).

2. **Kod Kalitesi İlkeleri:**
   - Hiçbir UI dosyasında (`presentation/screens` veya `widgets`) doğrudan `FirebaseFirestore.instance` veya `Hive.box` çağrısı yapılmamalıdır. Tüm veri akışı `Repository -> UseCase -> Riverpod Notifier -> UI` zincirini takip etmelidir.
   - Tüm asenkron işlemlerde hata yönetimi (`try/catch` veya `Either<Failure, T>`) uygulanmalı, UI katmanında `AsyncValue.when(data: ..., loading: ..., error: ...)` ile kullanıcı dostu durumlar gösterilmelidir.
   - Uygulama hem **Gerçek Firebase** modunda hem de yerel değerlendirme/jüri sunumu için **Mock/Demo Veri Modunda** (`useMockData` bayrağı ile) sorunsuz çalışabilmelidir.

## 2. Hedef Proje Klasör Yapısı (`lib/`)

Antigravity projeyi oluştururken aşağıdaki dizin ağacını kurmalıdır:

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── storage_keys.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── storage/
│   │   ├── local_cache_service.dart
│   │   └── secure_storage_service.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── date_formatter.dart
│       └── validators.dart
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/
    │   │   ├── models/
    │   │   └── repositories/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   └── presentation/
    │       ├── providers/
    │       ├── screens/
    │       └── widgets/
    ├── rides/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── bookings/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── chat/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    └── profile/
        ├── data/
        ├── domain/
        └── presentation/
```

## 3. Aşamalı Uygulama ve Antigravity Prompt Planı

Kodu tek seferde yazdırmak yerine aşağıdaki 6 adımı sırasıyla Antigravity'ye vererek her adımı doğrulayın:

### Faz 1: Proje İskeleti, Bağımlılıklar ve Yerel Depolama Altyapısı
**Antigravity'ye Verilecek Komut (Prompt 1):**
> "`01_sistem_analizi_ve_mimari.md`, `02_veri_depolama_ve_sema.md` ve `03_antigravity_gelistirme_kilavuzu.md` dosyalarını incele. İlk adım olarak Flutter projesinin `pubspec.yaml` dosyasını gerekli tüm paketlerle güncelle. Ardından `lib/core/` altındaki tema (`Material 3`, modern zümrüt yeşili ve koyu lacivert renk paleti), hata sınıfları (`Failure`), `Hive` tabanlı `LocalCacheService` (`box_user_session`, `box_my_rides`, `box_search_history` kutularını başlatan servis) ve `FlutterSecureStorage` sarmalayıcısını oluştur. `main.dart` içinde yerel depolama servislerini başlatıp `ProviderScope` ile uygulamayı ayağa kaldır."

### Faz 2: Veri Modelleri ve Kimlik Doğrulama (Auth & Profile)
**Antigravity'ye Verilecek Komut (Prompt 2):**
> "`02_veri_depolama_ve_sema.md` içindeki JSON şemalarına birebir sadık kalarak `UserEntity`, `VehicleEntity` ve bunların JSON/Hive serileştirmesini destekleyen `UserModel` ile `VehicleModel` sınıflarını oluştur. Ardından `features/auth/` ve `features/profile/` modüllerini kodla. Giriş (Login), Kayıt Ol (Register), Profil Düzenleme ve Sürücü Araç Ekleme ekranlarını oluştur. Oturum açıldığında kullanıcı bilgisini hem `LocalCacheService` hem de `SecureStorageService` içine kaydet. `GoRouter` üzerinde oturum kontrolü (Auth Guard) yapılandır."

### Faz 3: Yolculuk İlanı Oluşturma, Arama ve Çevrimdışı Önbellek (Rides Module)
**Antigravity'ye Verilecek Komut (Prompt 3):**
> "`features/rides/` modülünü Clean Architecture katmanlarıyla oluştur. `RideEntity` ve `RideModel` sınıflarını (`origin`, `destination`, `waypoints`, `availableSeats`, `pricePerSeat`, `status`, `rules` alanlarıyla) yaz. `RideRepositoryImpl` içinde hem uzak veri kaynağını hem de çevrimdışı çalışma için `LocalCacheService` (`box_my_rides` ve `box_search_history`) entegrasyonunu kodla.
> Arayüz tarafında:
> 1. Kalkış/varış noktası, tarih ve koltuk sayısına göre filtreleme yapan **Yolculuk Arama Ana Ekranı**,
> 2. Harita önizlemesi (`flutter_map`), güzergah özeti, sürücü puanı ve kuralları gösteren **Yolculuk Detay Ekranı**,
> 3. Sürücülerin adım adım (Kalkış -> Varış -> Tarih/Saat -> Koltuk & Ücret) ilan açabildiği **Yolculuk Oluşturma Ekranı** bileşenlerini tamamla."

### Faz 4: Atomik Koltuk Rezervasyonu ve Yolculuk Yönetimi (Bookings Module)
**Antigravity'ye Verilecek Komut (Prompt 4):**
> "`features/bookings/` modülünü oluştur. `BookingEntity` ve `BookingModel` sınıflarını kodla. Yolcunun koltuk talep etmesi (`createBooking`), sürücünün gelen talepleri görüntüleyip onaylaması (`approveBooking`) veya reddetmesi (`rejectBooking`) ve iptal işlemlerini ekle. Koltuk onaylama işleminde `02_veri_depolama_ve_sema.md` bölüm 3.1'de belirtilen atomik `Transaction` mantığını uygula; böylece `availableSeats` sayısı güvenli şekilde düşürülsün ve sıfırlandığında yolculuk durumu `full` olsun. 'Yolculuklarım' ekranında hem 'Yolcu Olarak Katıldıklarım' hem de 'Sürücü Olarak Açtıklarım' sekmelerini çevrimdışı önbellek destekli olarak oluştur."

### Faz 5: Uygulama İçi Mesajlaşma ve Değerlendirme Sistemi (Chat & Reviews)
**Antigravity'ye Verilecek Komut (Prompt 5):**
> "`features/chat/` modülünü ve değerlendirme (`Review`) akışını kodla. Onaylanmış rezervasyona sahip yolcu ve sürücünün gerçek zamanlı mesajlaşabileceği Sohbet Listesi ve Sohbet Detay ekranlarını oluştur. Son mesajları çevrimdışı görüntüleme için yerel önbelleğe kaydet. Ayrıca tamamlanan (`completed`) yolculuklar için 1-5 yıldız ve yorum içeren Değerlendirme Modal'ını ve sürücü/yolcu profilindeki ortalama puan hesaplama mantığını ekle."

### Faz 6: Demo/Jüri Sunum Modu ve Testlerin Yazılması
**Antigravity'ye Verilecek Komut (Prompt 6):**
> "Bitirme projesi sunumunda internet veya Firebase bağlantısı olmasa bile tüm özelliklerin (arama, ilan açma, koltuk rezervasyonu, onaylama, mesajlaşma, değerlendirme ve yerel depolama) canlı olarak test edilebilmesi için gerçekçi Türkiye/İstanbul rotaları içeren kapsamlı bir `SeedDataService` / `MockDataSource` modülü entegre et. Son olarak `BookSeatUseCase`, `SearchRidesUseCase` ve `LocalCacheService` için birim testlerini (`test/` klasörü altında) yaz ve `flutter analyze` kontrolünden sıfır hata ile geçtiğini doğrula."

## 4. Bitirme Projesi Raporu ve Sunumu İçin Kabul Kriterleri (Checklist)

- [ ] **Mimari Ayrım:** Presentation, Domain ve Data katmanları birbirinden bağımsız mı?
- [ ] **Veri Depolama Kanıtı:** İnternet kapatıldığında (Uçak Modu) kullanıcının aktif rezervasyonları ve geçmiş aramaları yerel veritabanından (`Hive`/`Isar`) yükleniyor mu?
- [ ] **Koltuk Kontenjan Kontrolü:** Onaylanan her rezervasyonda boş koltuk sayısı düşüyor ve kontenjan dolduğunda yeni rezervasyon engelleniyor mu?
- [ ] **Harita ve Rota:** Yolculuk detay ekranında kalkış ve varış noktaları harita üzerinde işaretçilerle (Marker) ve çizgiyle (Polyline) gösteriliyor mu?
- [ ] **Hata ve Yükleme Durumları:** Tüm ekranlarda veri yüklenirken Skeleton/Shimmer veya `CircularProgressIndicator`, boş durumda ise bilgilendirici Empty State gösteriliyor mu?
