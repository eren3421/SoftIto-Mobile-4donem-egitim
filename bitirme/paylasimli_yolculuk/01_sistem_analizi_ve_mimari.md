# Paylaşımlı Yolculuk (Carpooling) Mobil Uygulaması — Sistem Analizi ve Mimari Tasarım

Bu doküman, bitirme projesi kapsamında geliştirilecek olan Flutter tabanlı paylaşımlı yolculuk (carpooling / ridesharing) mobil uygulamasının uçtan uca sistem analizini, fonksiyonel ve fonksiyonel olmayan gereksinimlerini, mimari katmanlarını ve iş akışlarını tanımlar.

## 1. Proje Vizyonu ve Kapsamı

Paylaşımlı yolculuk uygulaması, aynı güzergahta seyahat eden sürücüler ile yolcuları güvenli, ekonomik ve çevreci bir şekilde buluşturan mobil platformdur. Üniversite kampüs içi/dışı ulaşım veya şehir içi/şehirlerarası ortak seyahat senaryolarını destekleyecek şekilde ölçeklenebilir bir mimariyle tasarlanmıştır.

| Özellik Alanı | Kapsam Özeti |
| :--- | :--- |
| **Platform** | iOS ve Android (Flutter Tek Kod Tabanı - Cross-Platform) |
| **Temel Kullanıcı Rolleri** | Yolcu (Passenger), Sürücü (Driver), Sistem Yöneticisi (Admin - Denetim) |
| **Mimari Desen** | Feature-First Clean Architecture (Presentation, Domain, Data) |
| **State Management** | Riverpod (`flutter_riverpod` + `riverpod_annotation`) |
| **Veri Depolama** | Bulut Senkronizasyonu (Firebase Firestore / Supabase) + Çevrimdışı Önbellek (Hive / Isar & Secure Storage) |
| **Konum ve Harita** | Google Maps SDK / OpenStreetMap (`flutter_map`) + Geolocator + Polyline Rota Çizimi |

## 2. Paydaşlar ve Kullanıcı Rolleri (Aktörler)

1. **Yolcu (Passenger):**
   - Başlangıç ve varış noktası ile tarih/saat seçerek uygun yolculuk ilanlarını arar.
   - Sürücü profilini, araç bilgilerini, geçmiş değerlendirmeleri ve koltuk ücretini inceler.
   - Boş koltuklar için rezervasyon talebi gönderir ve anlık onay durumunu takip eder.
   - Yolculuk sırasında canlı konumu izler, sürücü ile uygulama içi mesajlaşır ve yolculuk sonunda puanlama yapar.

2. **Sürücü (Driver):**
   - Araç bilgilerini (plaka, marka/model, renk, koltuk kapasitesi) ve sürücü belgesi doğrulamasını sisteme kaydeder.
   - Kalkış noktası, varış noktası, ara duraklar, tarih/saat, boş koltuk sayısı ve yolcu başı katkı payı tutarını belirterek yolculuk ilanı açar.
   - Gelen rezervasyon taleplerini onaylar veya reddeder.
   - Yolculuğu başlatır, tamamlar ve yolcuları değerlendirir.

3. **Sistem (Arka Plan Servisleri & Veritabanı Kuralları):**
   - Koltuk kontenjanlarını atomik işlemlerle (transaction) yönetir; çifte rezervasyonu (overbooking) engeller.
   - Yolculuk durumu değiştiğinde (Onaylandı, Başladı, İptal Edildi, Tamamlandı) ilgili kullanıcılara anlık bildirim (Push Notification) gönderir.
   - Çevrimdışı durumda yerel önbellekten (Local Cache) okuma yapar ve bağlantı sağlandığında verileri senkronize eder.

## 3. Fonksiyonel Gereksinimler (Functional Requirements)

| Kod | Modül | Gereksinim Açıklaması | Öncelik |
| :--- | :--- | :--- | :--- |
| **FR-01** | Kimlik Doğrulama | Kullanıcılar e-posta/şifre, telefon numarası (OTP) veya kurumsal/üniversite e-postası ile kayıt olabilmeli ve giriş yapabilmelidir. | Yüksek |
| **FR-02** | Profil ve Araç Yönetimi | Kullanıcılar profil fotoğrafı, biyografi ve tercihlerini (sigara, müzik, evcil hayvan) güncelleyebilmeli; sürücüler araç tanımlayabilmelidir. | Yüksek |
| **FR-03** | Yolculuk İlanı Oluşturma | Sürücüler harita üzerinden kalkış/varış noktası seçerek, güzergah polyline verisi, tarih, saat, koltuk sayısı ve fiyat ile ilan yayınlayabilmelidir. | Yüksek |
| **FR-04** | Gelişmiş Yolculuk Arama | Yolcular başlangıç/varış koordinatlarına (yakınlık yarıçapı ile), tarihe, boş koltuk sayısına ve fiyat aralığına göre filtreleme yapabilmelidir. | Yüksek |
| **FR-05** | Rezervasyon ve Koltuk Yönetimi | Yolcular koltuk talep edebilmeli; sürücü onayladığında veritabanı transaction yapısı ile `availableSeats` değeri güvenli şekilde azaltılmalıdır. | Yüksek |
| **FR-06** | Gerçek Zamanlı Mesajlaşma | Rezervasyonu onaylanan yolcu ve sürücü, uygulama içi sohbet (chat) odasında anlık mesajlaşabilmeli ve konum paylaşabilmelidir. | Orta |
| **FR-07** | Canlı Yolculuk Durumu | Yolculuk durumları (`planned`, `ongoing`, `completed`, `cancelled`) adım adım güncellenmeli ve aktif yolculukta konum takibi yapılabilmelidir. | Orta |
| **FR-08** | Değerlendirme ve Yorum | Tamamlanan yolculuk sonrasında taraflar birbirine 1-5 arası yıldız ve metin yorumu bırakabilmeli; kullanıcının ortalama puanı otomatik hesaplanmalıdır. | Yüksek |
| **FR-09** | Çevrimdışı Veri Erişimi | Aktif rezervasyonlar, bilet/yolculuk detayları ve geçmiş mesajlar cihazda yerel olarak (`Isar` / `Hive`) saklanmalı, internet yokken görüntülenebilmelidir. | Yüksek |

## 4. Fonksiyonel Olmayan Gereksinimler (Non-Functional Requirements)

- **Performans (NFR-01):** Harita üzerinde rota çizimi ve yolculuk arama sorguları 1.5 saniyenin altında yanıt vermelidir. Liste ekranlarında sayfalama (pagination / infinite scroll) kullanılmalıdır.
- **Veri Tutarlılığı ve Eşzamanlılık (NFR-02):** Son kalan koltuğa aynı anda iki yolcunun başvurması durumunda veritabanı düzeyinde `Transaction` / `Optimistic Locking` kullanılarak tutarsızlık önlenmelidir.
- **Güvenlik (NFR-03):** JWT oturum anahtarları ve hassas kullanıcı verileri `flutter_secure_storage` ile şifreli saklanmalıdır. Veritabanı erişim kuralları (Firestore Security Rules / RLS) yalnızca yetkili kullanıcıların kendi verilerini değiştirmesine izin vermelidir.
- **Kullanılabilirlik ve Erişilebilirlik (NFR-04):** Material 3 tasarım dili, karanlık/aydınlık tema (Dark/Light Mode) desteği ve duyarlı (responsive) ekran yerleşimleri uygulanmalıdır.
- **Test Edilebilirlik (NFR-05):** Domain katmanındaki tüm UseCase'ler ve Repository arayüzleri dış bağımlılıklardan izole olmalı, Unit ve Widget testleri yazılabilir yapıda olmalıdır.

## 5. Sistem Mimarisi (Clean Architecture + Riverpod)

Uygulama, sürdürülebilirliği ve akademik standartları en üst düzeye çıkarmak için **Feature-First Clean Architecture** yaklaşımıyla 3 ana katmana ayrılmıştır:

```
+-------------------------------------------------------------------+
|                      PRESENTATION LAYER                           |
|   Pages / Screens  <-->  Riverpod Controllers / Notifiers  <-->   |
|   Custom Widgets         UI State (AsyncValue / Freezed)          |
+-------------------------------------------------------------------+
                                 |
                                 v
+-------------------------------------------------------------------+
|                         DOMAIN LAYER                              |
|   Entities (Pure Dart)  <--  UseCases (Business Logic)  -->       |
|                              Repository Interfaces (Abstract)     |
+-------------------------------------------------------------------+
                                 ^
                                 |
+-------------------------------------------------------------------+
|                          DATA LAYER                               |
|   Repository Implementations  <-->  DTOs / Models (JSON/Local)    |
|         |                                        |                |
|   Remote Data Source                       Local Data Source      |
|   (Firebase Firestore / Auth)              (Isar / Hive / Secure) |
+-------------------------------------------------------------------+
```

### Katman Sorumlulukları

1. **Domain Katmanı (İş Mantığı Çekirdeği):**
   - Hiçbir Flutter UI paketine veya veritabanı kütüphanesine bağımlı değildir.
   - `Entities`: `UserEntity`, `VehicleEntity`, `RideEntity`, `BookingEntity`, `MessageEntity`, `ReviewEntity`.
   - `Repositories`: Veri katmanının uygulayacağı soyut sözleşmeler (`IRideRepository`, `IBookingRepository`).
   - `UseCases`: Tek sorumluluk prensibine (SRP) uygun iş kuralları (`CreateRideUseCase`, `BookSeatUseCase`, `SearchRidesUseCase`).

2. **Data Katmanı (Veri Yönetimi ve Depolama):**
   - `Models / DTOs`: JSON serileştirme (`freezed` & `json_serializable`) ve yerel veritabanı adaptörlerini içerir.
   - `RemoteDataSource`: Uzak sunucu (Cloud Firestore) ile gerçek zamanlı veri akışlarını (`Stream`) ve CRUD işlemlerini yönetir.
   - `LocalDataSource`: Çevrimdışı çalışma (Offline-First) için `Hive` veya `Isar` üzerinde önbellekleme yapar; oturum bilgilerini `FlutterSecureStorage` üzerinde tutar.
   - `Repository Implementation`: İnternet bağlantısını kontrol eder; çevrimiçi ise uzak sunucudan veriyi alıp yerel veritabanını günceller, çevrimdışı ise yerel önbellekten veri sunar.

3. **Presentation Katmanı (Kullanıcı Arayüzü ve Durum Yönetimi):**
   - `Riverpod Providers / Notifiers`: `AsyncNotifier` ve `StreamNotifier` kullanarak asenkron veri durumlarını (`loading`, `data`, `error`) yönetir.
   - `GoRouter`: Kimlik doğrulama durumuna göre yönlendirme (Auth Guard) ve derin bağlantı (Deep Linking) yönetimini sağlar.

## 6. Temel İş Akışları ve Durum Makinesi (State Machine)

### 6.1. Rezervasyon ve Koltuk Onay Akışı
1. Yolcu, arama sonuçlarından bir `Ride` seçer ve `BookSeat` isteği gönderir (`BookingStatus.pending`).
2. Sürücüye bildirim düşer; sürücü talebi onaylar (`ApproveBookingUseCase`).
3. Veritabanı Transaction bloğu çalışır:
   - İlgili yolculuğun `availableSeats` değeri kontrol edilir (`availableSeats >= requestedSeats`).
   - Koşul sağlanıyorsa `availableSeats` düşürülür ve `BookingStatus.approved` olarak güncellenir.
   - Eğer koltuk kalmamışsa işlem geri alınır (`Rollback`) ve kullanıcıya hata mesajı döner.

### 6.2. Yolculuk Yaşam Döngüsü (Ride Status Lifecycle)
- `PLANNED`: Sürücü ilanı oluşturdu, rezervasyon alımına açık.
- `FULL`: Tüm koltuklar doldu (`availableSeats == 0`), yeni talep alınamaz; iptal olursa tekrar `PLANNED` durumuna döner.
- `ONGOING`: Sürücü başlangıç saatinde yolculuğu başlattı.
- `COMPLETED`: Varış noktasına ulaşıldı, değerlendirme (Review) modülü tetiklendi.
- `CANCELLED`: Sürücü tarafından iptal edildi; onaylı tüm yolculara iptal bildirimi gönderildi.
