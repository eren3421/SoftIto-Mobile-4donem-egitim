# Paylaşımlı Yolculuk Uygulaması — Veri Depolama Mimarisi ve Veritabanı Şeması

Bu doküman, uygulamanın hem bulut (uzak veritabanı) hem de cihaz içi (yerel önbellek ve güvenli depolama) veri katmanlarını, varlık-ilişki (ER) yapısını, koleksiyon/tablo şemalarını ve çevrimdışı senkronizasyon stratejisini tanımlar. Antigravity tarafından veri modelleri (`freezed` / `json_serializable`) ve repository sınıfları oluşturulurken bu şema doğrudan referans alınmalıdır.

## 1. Hibrit Veri Depolama Stratejisi (Cloud + Local Storage)

Uygulamada veri kaybını önlemek, hızlı açılış süresi sağlamak ve internet bağlantısının zayıf olduğu yolculuk anlarında kesintisiz deneyim sunmak için **3 katmanlı veri depolama** kullanılır:

| Depolama Katmanı | Teknoloji / Paket | Saklanan Veriler | Senkronizasyon Politikası |
| :--- | :--- | :--- | :--- |
| **1. Güvenli Yerel Depolama** | `flutter_secure_storage` | Auth Token, Refresh Token, Kullanıcı ID, Biyometrik Giriş Anahtarı | Oturum açıldığında yazılır, çıkışta (`logout`) tamamen temizlenir. |
| **2. Anahtar-Değer Tercihleri** | `shared_preferences` | Tema seçimi (`dark`/`light`), Dil (`tr`/`en`), Onboarding tamamlanma durumu, Son arama filtreleri | Uygulama açılışında senkron okunur, kullanıcı değiştirdiğinde anında güncellenir. |
| **3. Yapılandırılmış Yerel Veritabanı (NoSQL Cache)** | `hive_flutter` veya `isar` | Aktif yolculuklar (`cached_rides`), Kullanıcının rezervasyonları (`my_bookings`), Son mesajlar (`recent_messages`), Kullanıcı profili | **Network-First with Local Fallback**: İnternet varken sunucudan okunup yerel kutuya (`Box`) yazılır; internet yokken yerel kutudan okunur. |
| **4. Bulut Veritabanı ve Gerçek Zamanlı Senkronizasyon** | `cloud_firestore` (Firebase) | Tüm kullanıcılar, araçlar, yolculuk ilanları, rezervasyonlar, değerlendirmeler ve anlık sohbet mesajları | Gerçek zamanlı `Stream` dinleyicileri ve atomik `Transaction` işlemleri ile yönetilir. |

## 2. Veritabanı Şeması ve Koleksiyon / Tablo Yapıları

### 2.1. `users` Koleksiyonu (Kullanıcılar)
Kullanıcıların temel profil, doğrulama ve istatistik bilgilerini tutar.

```json
{
  "id": "usr_987654321",
  "email": "ahmet.yilmaz@universite.edu.tr",
  "fullName": "Ahmet Yılmaz",
  "phoneNumber": "+905551234567",
  "avatarUrl": "https://storage.googleapis.com/.../avatar.jpg",
  "bio": "Bilgisayar Mühendisliği son sınıf öğrencisiyim. Kampüs-Kadıköy arası düzenli gidip geliyorum.",
  "role": "both",
  "isVerified": true,
  "ratingAvg": 4.85,
  "ratingCount": 14,
  "preferences": {
    "smokingAllowed": false,
    "petsAllowed": true,
    "musicPreference": "Pop / Akustik",
    "chatLevel": "moderate"
  },
  "createdAt": "2026-11-01T09:00:00Z",
  "updatedAt": "2026-11-07T10:30:00Z"
}
```

### 2.2. `vehicles` Koleksiyonu (Araçlar)
Sürücülerin sisteme kaydettiği araçların detaylarını tutar. `ownerId` alanı `users.id` ile ilişkilidir.

```json
{
  "id": "veh_123456",
  "ownerId": "usr_987654321",
  "brand": "Renault",
  "model": "Clio",
  "year": 2022,
  "color": "Beyaz",
  "licensePlate": "34 ABC 123",
  "totalSeats": 4,
  "isVerified": true,
  "createdAt": "2026-11-02T14:20:00Z"
}
```

### 2.3. `rides` Koleksiyonu (Yolculuk İlanları)
Sürücüler tarafından oluşturulan aktif ve geçmiş yolculukları tutar. Konum aramalarını kolaylaştırmak için hem adres metni hem de koordinat (`lat`, `lng`) ve `geohash` bilgileri saklanır.

```json
{
  "id": "ride_555666",
  "driverId": "usr_987654321",
  "driverSummary": {
    "fullName": "Ahmet Yılmaz",
    "avatarUrl": "https://storage.googleapis.com/.../avatar.jpg",
    "ratingAvg": 4.85
  },
  "vehicleId": "veh_123456",
  "vehicleSummary": {
    "brandModel": "Renault Clio",
    "color": "Beyaz",
    "licensePlate": "34 ABC 123"
  },
  "origin": {
    "name": "Kadıköy Rıhtım",
    "address": "Caferağa, Kadıköy/İstanbul",
    "lat": 40.9901,
    "lng": 29.0234,
    "geohash": "sxk9g8"
  },
  "destination": {
    "name": "İTÜ Ayazağa Kampüsü",
    "address": "Maslak, Sarıyer/İstanbul",
    "lat": 41.1055,
    "lng": 29.0252,
    "geohash": "sxk9u2"
  },
  "waypoints": [
    {
      "name": "Mecidiyeköy Metrobüs",
      "lat": 41.0668,
      "lng": 28.9963
    }
  ],
  "routePolyline": "encoded_polyline_string_here",
  "departureTime": "2026-11-08T08:00:00Z",
  "estimatedArrivalTime": "2026-11-08T08:50:00Z",
  "totalSeatsOffered": 3,
  "availableSeats": 2,
  "pricePerSeat": 75.0,
  "currency": "TRY",
  "status": "planned",
  "rules": {
    "instantApproval": false,
    "luggageSize": "medium",
    "smokingAllowed": false,
    "petsAllowed": true
  },
  "createdAt": "2026-11-07T11:00:00Z"
}
```

### 2.4. `bookings` Koleksiyonu (Rezervasyonlar)
Yolcuların belirli bir yolculuk için yaptıkları koltuk taleplerini ve durumlarını tutar.

```json
{
  "id": "bkg_777888",
  "rideId": "ride_555666",
  "driverId": "usr_987654321",
  "passengerId": "usr_111222333",
  "passengerSummary": {
    "fullName": "Zeynep Kaya",
    "avatarUrl": "https://storage.googleapis.com/.../zeynep.jpg",
    "ratingAvg": 4.92
  },
  "seatsBooked": 1,
  "totalPrice": 75.0,
  "status": "approved",
  "pickupPoint": {
    "name": "Kadıköy Rıhtım",
    "lat": 40.9901,
    "lng": 29.0234
  },
  "noteToDriver": "1 adet sırt çantam var, tam saatinde durakta olacağım.",
  "createdAt": "2026-11-07T11:15:00Z",
  "updatedAt": "2026-11-07T11:20:00Z"
}
```
- **Olası `status` Değerleri:** `pending` (Onay Bekliyor), `approved` (Onaylandı), `rejected` (Reddedildi), `cancelled_by_passenger` (Yolcu İptal Etti), `cancelled_by_driver` (Sürücü İptal Etti), `completed` (Tamamlandı).

### 2.5. `chats` ve `messages` Koleksiyonları (Mesajlaşma)
Her yolculuk veya sürücü-yolcu eşleşmesi için bir sohbet odası ve alt mesaj koleksiyonu (`chats/{chatId}/messages/{messageId}`) bulunur.

```json
{
  "id": "chat_555666_111222333",
  "rideId": "ride_555666",
  "participantIds": ["usr_987654321", "usr_111222333"],
  "lastMessage": "Tamamdır, Rıhtım ışıklarda bekliyorum.",
  "lastMessageTime": "2026-11-08T07:55:00Z",
  "unreadCounts": {
    "usr_987654321": 0,
    "usr_111222333": 1
  }
}
```

Alt koleksiyon `messages`:
```json
{
  "id": "msg_001",
  "chatId": "chat_555666_111222333",
  "senderId": "usr_987654321",
  "text": "Tamamdır, Rıhtım ışıklarda bekliyorum.",
  "type": "text",
  "isRead": false,
  "createdAt": "2026-11-08T07:55:00Z"
}
```

### 2.6. `reviews` Koleksiyonu (Değerlendirmeler)
Yolculuk tamamlandıktan sonra sürücü ve yolcuların birbirlerine verdikleri puanları tutar.

```json
{
  "id": "rev_999000",
  "rideId": "ride_555666",
  "reviewerId": "usr_111222333",
  "revieweeId": "usr_987654321",
  "rating": 5,
  "comment": "Çok güvenli ve dakik bir yolculuktu, teşekkürler.",
  "createdAt": "2026-11-08T09:30:00Z"
}
```

## 3. Kritik Veritabanı İşlemleri (Transactions & İndeksler)

### 3.1. Atomik Koltuk Rezervasyonu (Firestore Transaction)
Koltuk onaylama ve iptal etme işlemleri kesinlikle tekil `update` ile yapılmamalı, yarış durumlarını (Race Condition) önlemek için aşağıdaki mantıkla `runTransaction` içinde çalıştırılmalıdır:

```dart
Future<void> approveBookingTransaction({
  required String rideId,
  required String bookingId,
}) async {
  final rideRef = firestore.collection('rides').doc(rideId);
  final bookingRef = firestore.collection('bookings').doc(bookingId);

  await firestore.runTransaction((transaction) async {
    final rideSnapshot = await transaction.get(rideRef);
    final bookingSnapshot = await transaction.get(bookingRef);

    if (!rideSnapshot.exists || !bookingSnapshot.exists) {
      throw Exception('Yolculuk veya rezervasyon kaydı bulunamadı.');
    }

    final int availableSeats = rideSnapshot.data()!['availableSeats'] as int;
    final int seatsBooked = bookingSnapshot.data()!['seatsBooked'] as int;
    final String currentStatus = bookingSnapshot.data()!['status'] as String;

    if (currentStatus != 'pending') {
      throw Exception('Bu rezervasyon zaten işleme alınmış.');
    }

    if (availableSeats < seatsBooked) {
      throw Exception('Yeterli boş koltuk kalmadı.');
    }

    final int updatedSeats = availableSeats - seatsBooked;
    transaction.update(rideRef, {
      'availableSeats': updatedSeats,
      'status': updatedSeats == 0 ? 'full' : 'planned',
    });

    transaction.update(bookingRef, {
      'status': 'approved',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  });
}
```

### 3.2. Yerel Önbellek (Hive / Isar) Kutuları ve Senkronizasyon Akışı
- **`box_user_session`**: Oturum açmış kullanıcının profil nesnesini JSON olarak saklar.
- **`box_my_rides`**: Kullanıcının sürücü olarak açtığı veya yolcu olarak onay aldığı aktif yolculukları tutar. Uygulama çevrimdışı açıldığında "Yolculuklarım" sekmesi doğrudan bu kutudan beslenir.
- **`box_search_history`**: Kullanıcının son aradığı 10 kalkış-varış rotasını tutar; ana ekranda tek dokunuşla hızlı arama yapılmasını sağlar.

### 3.3. Güvenlik Kuralları (Firestore Security Rules Özeti)
- `users/{userId}`: Herkes okuyabilir (`read: if request.auth != null`), yalnızca kullanıcının kendisi güncelleyebilir (`write: if request.auth.uid == userId`).
- `rides/{rideId}`: Oturum açmış herkes okuyabilir; yalnızca `driverId == request.auth.uid` olan kullanıcı ilan oluşturabilir veya iptal edebilir.
- `bookings/{bookingId}`: Yalnızca ilanın sürücüsü (`driverId`) veya rezervasyonu yapan yolcu (`passengerId`) okuyabilir ve durumunu güncelleyebilir.
