# Paylaşımlı Yolculuk (Carpooling / Ridesharing) Mobil Uygulaması

Bu proje, `01_sistem_analizi_ve_mimari.md`, `02_veri_depolama_ve_sema.md` ve `03_antigravity_gelistirme_kilavuzu.md` dokümanlarında tanımlanan gereksinimlere birebir sadık kalınarak **Flutter**, **Feature-First Clean Architecture** ve **Riverpod** kullanılarak geliştirilmiştir.

## Öne Çıkan Özellikler (Faz 1 - Faz 6)

1. **Feature-First Clean Architecture & Riverpod (`flutter_riverpod`):**
   - `Presentation`, `Domain` ve `Data` katmanları birbirinden tamamen izole edilmiştir.
   - Tüm veri akışı `Repository -> UseCase -> Riverpod AsyncNotifier -> UI` zincirini takip eder.
2. **Hibrit Veri Depolama & Çevrimdışı Önbellek (Cloud + Hive + SecureStorage):**
   - `LocalCacheService` (`Hive`): `box_user_session`, `box_my_rides`, `box_search_history`, `box_bookings`, `box_chats`, `box_vehicles`, `box_reviews` kutularını yönetir.
   - `SecureStorageService` (`FlutterSecureStorage`): Oturum anahtarlarını (`JWT`, `RefreshToken`, `UserId`) güvenli şekilde saklar.
   - Uygulama üst barındaki veya Profil ekranındaki **Çevrimdışı (Uçak Modu) Simülasyonu** anahtarı ile internet bağlantısı kesildiğinde verilerin yerel Hive kutularından okunduğu canlı olarak test edilebilir.
3. **Atomik Koltuk Rezervasyonu (Transaction):**
   - `BookingRemoteDataSource.approveBookingTransaction` metodu, koltuk onaylama işlemlerinde `availableSeats >= seatsBooked` kontrolünü atomik olarak yapar, koltuk sayısını düşürür ve `availableSeats == 0` olduğunda yolculuk durumunu `full` olarak günceller.
4. **Harita ve Polyline Rota Çizimi (`flutter_map` & OpenStreetMap):**
   - API anahtarı gerektirmeden çalışan `RouteMapWidget` ile kalkış noktası, ara duraklar ve varış noktası işaretçileri (`MarkerLayer`) ve rota çizgisi (`PolylineLayer`) gösterilir.
5. **Gerçek Zamanlı Mesajlaşma & 1-5 Yıldız Değerlendirme (Chat & Reviews):**
   - Onaylanan rezervasyonlar için otomatik sohbet odası açılır, konum paylaşımı desteklenir ve tamamlanan yolculuklar sonunda verilen puanlar kullanıcının ortalama puanını (`ratingAvg`) otomatik günceller.
6. **Jüri / Demo Sunum Modu (`SeedDataService`):**
   - Gerçekçi İstanbul / Türkiye rotaları (Kadıköy Rıhtım → İTÜ Ayazağa Kampüsü, Beşiktaş Meydan → Sabiha Gökçen Havalimanı, Üsküdar → YTÜ Davutpaşa vb.) ve hazır demo profilleri (Ahmet Yılmaz, Zeynep Kaya, Mehmet Demir) ile anında test edilebilir.

## Çalıştırma ve Test Komutları

```bash
cd paylasimli_yolculuk
flutter pub get
flutter analyze
flutter test
flutter run
```
