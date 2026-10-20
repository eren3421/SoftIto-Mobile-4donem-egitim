# Çok Modlu Araç Kiralama Sistemi (Kara, Hava ve Deniz Taşıtları) — Proje Spesifikasyonu (`project.md`)

## 1. Proje Özeti ve Vizyon

Bu proje, **Flutter** kullanılarak geliştirilecek; **kara, hava ve deniz taşıtlarını** tek bir çatı altında toplayan kapsamlı, çift taraflı (C2C ve B2C) bir araç kiralama, rezervasyon, gerçek zamanlı telemetri/takip ve mesajlaşma platformudur. Sistemde hem **sivil kullanıcılar (bireysel)** hem de **kurumsal firmalar (şube bazlı)** kendi araçlarını kiraya verebilirken, **sivil kullanıcılar** sistemdeki tüm uygun araçları kiralayabilmektedir.

Bu doküman, **Anti-Gravity** geliştirme ortamının projeyi uçtan uca, eksiksiz ve kurallara tam uyumlu şekilde inşa etmesi için gereken iş kurallarını, kullanıcı rollerini, fonksiyonel gereksinimleri ve uygulama fazlarını tanımlar.

## 2. Temel İş Kuralları ve Kapsam Matrisi

Sistemdeki aktörlerin yetkileri ve sorumlulukları aşağıdaki kurallarla kesin olarak sınırlandırılmıştır:

| Özellik / Yetki Alanı | Sivil Kullanıcı (Bireysel) | Firma (Kurumsal Şube) | Sistem / Kural Açıklaması |
| :--- | :--- | :--- | :--- |
| **Giriş (Login) Akışı** | Sivil Giriş Ekranı (TC No / Telefon + Şifre) | Firma Giriş Ekranı (Firma/Şube Kodu veya Kurumsal E-posta + Şifre) | İki rol için tamamen ayrıştırılmış kimlik doğrulama ve kayıt formları bulunur. |
| **Araç Kiraya Verme (Araç Sahibi Rolü)** | Evet | Evet | Hem siviller hem firmalar kara, hava ve deniz taşıtı ekleyip kiraya verebilir. |
| **Araç Kiralama (Kiracı Rolü)** | Evet | Hayır | Yalnızca sivil kullanıcılar araç kiralama talebi ve rezervasyonu oluşturabilir. |
| **Gerçek Zamanlı Araç Takibi** | Evet (Kendi araçları için) | Evet (Şube araçları için) | Araç sahipleri, kendilerine ait araçları **Takip Numarası (`trackingNumber`)** ile canlı harita/panel üzerinden izler. |
| **Rezervasyon Yönetimi** | Kiracı ve Araç Sahibi görünümü | Sadece Araç Sahibi görünümü | Rezervasyon paneli; **Araç**, **Kiralayan (Sivil)** ve **Araç Sahibi (Sivil/Firma)** üçlüsünü tek kayıtta birleştirir. |
| **Mesajlaşma Paneli** | Evet (Araç sahipleri ve kiracılarla) | Evet (Kiralayan sivil kullanıcılarla) | Araç sahibi ile kiralayan arasında rezervasyon veya araç bazlı anlık iletişim sağlar. |

## 3. Kullanıcı Rolleri ve Veri Gereksinimleri

### 3.1. Sivil Kullanıcı (Civilian User)
Sivil kullanıcılar sisteme hem **Araç Sahibi (Lessor)** hem de **Kiralayan (Renter/Lessee)** olarak katılabilir. Sivil kullanıcı profili aşağıdaki zorunlu alanları içerir:
- **Ad (`firstName`)**: Kullanıcının adı.
- **Soyad (`lastName`)**: Kullanıcının soyadı.
- **T.C. Kimlik Numarası (`tcIdentityNumber`)**: 11 haneli, sadece rakamlardan oluşan ve algoritma doğrulamasından geçen benzersiz kimlik numarası.
- **İletişim Numarası (`phoneNumber`)**: Uluslararası formatta doğrulanan telefon numarası (Örn: `+90 5XX XXX XX XX`).
- **Adres (`address`)**: Ülke, şehir, ilçe ve açık adres bilgilerini barındıran yapılandırılmış adres nesnesi.
- **Araç Listesi (`vehicleList`)**: Kullanıcının kiraya vermek üzere sisteme kaydettiği kara, hava veya deniz taşıtlarının listesi (hiç aracı yoksa boş liste olabilir).

### 3.2. Kurumsal Firma (Company / Branch User)
Firmalar sisteme şube bazlı kayıt olur ve yalnızca **Araç Sahibi (Lessor)** sıfatıyla filo yönetimi ve kiralama hizmeti sunar. Firma profili aşağıdaki zorunlu alanları içerir:
- **Firma Adı (`companyName`)**: Kurumsal firmanın resmi unvanı / marka adı ve şube tanımlayıcısı.
- **Firmanın O Şubesinin Adresi (`branchAddress`)**: Şubenin bulunduğu ülke, şehir, ilçe, açık adres ve konum koordinatları.
- **Araç Listesi (`vehicleList`)**: İlgili şubenin envanterinde bulunan ve kiraya sunulan kara, hava ve deniz taşıtlarının listesi.

## 4. Araç Envanteri ve Taşıt Kategorileri

Sistemde üç ana taşıt kategorisi yer alır:
1. **Kara Taşıtları (`Land`)**: Otomobil, SUV, motosiklet, karavan, ticari araç, VIP minibüs vb.
2. **Hava Taşıtları (`Air`)**: Helikopter, özel jet, turboprop uçak, hafif spor uçak, deniz uçağı vb.
3. **Deniz Taşıtları (`Sea`)**: Motoryat, yelkenli tekne, katamaran, sürat teknesi, gulet, jet-ski vb.

### 4.1. Zorunlu Araç Özellikleri
Her araç kaydı (ister sivil kullanıcıya ister bir firma şubesine ait olsun) aşağıdaki alanlara sahip olmalıdır:
- **Tür (`vehicleType`)**: `Kara`, `Hava` veya `Deniz`.
- **Marka (`brand`)**: Taşıtın üretici markası (Örn: Mercedes-Benz, Cessna, Azimut).
- **Model (`model`)**: Taşıtın modeli ve serisi (Örn: G63 AMG, Citation CJ4, Grande 27M).
- **Plaka / Tescil Numarası (`plateNumber`)**: Kara taşıtları için resmi plaka (Örn: `34 VR 1923`), hava taşıtları için kuyruk tescil numarası (Örn: `TC-HAA`), deniz taşıtları için bağlama kütüğü / sicil plaka numarası (Örn: `IST-DNZ-408`).
- **Birim Fiyat (`unitPrice`)**: Günlük veya saatlik kiralama birim ücreti ve para birimi.
- **Takip Numarası (`trackingNumber`)**: Araca özel benzersiz telemetri/GPS takip kodu (Örn: `TRK-KARA-84920`, `TRK-HAVA-10492`, `TRK-DENIZ-55301`).
- **Bulunduğu Ülke ve Şehir (`country`, `city`)**: Aracın teslim alınacağı / bulunduğu ülke ve şehir.
- **Araç Sahibi Bilgisi (`ownerId`, `ownerName`, `ownerType`)**: Aracın bağlı olduğu sivil kişi veya firma şubesi.

## 5. Modüller ve Fonksiyonel Gereksinimler

### 5.1. Ayrı Kimlik Doğrulama (Dual Login & Onboarding) Modülü
- Açılış ekranında kullanıcıya **"Sivil Kullanıcı Girişi"** ve **"Kurumsal Firma (Şube) Girişi"** olmak üzere iki belirgin sekme/mod sunulur.
- **Sivil Kayıt Formu**: Ad, Soyad, T.C. Kimlik Numarası (11 hane kontrolü), İletişim Numarası, Ülke/Şehir/Açık Adres alanlarını zorunlu tutar. Kayıt sonrası profil üzerinden araç listesine araç eklenebilir.
- **Firma Kayıt Formu**: Firma Adı, Şube Adı/Kodu, Şube Ülke/Şehir/Açık Adresi ve kurumsal iletişim bilgilerini zorunlu tutar.

### 5.2. Gelişmiş Araç Arama ve Filtreleme Paneli
Kullanıcıların tüm envanteri inceleyebildiği ve anlık olarak daraltabildiği merkezi keşif panelidir. Panelde aşağıdaki **7 temel filtre** birlikte (AND mantığıyla) veya tekil olarak çalışmalıdır:
1. **Araç Sahibine Göre Filtreleme**: Sivil / Firma ayrımı veya doğrudan belirli bir araç sahibinin/firmanın adına göre filtreleme.
2. **Ülkeye Göre Filtreleme**: Aracın bulunduğu ülkeye göre seçim (Örn: Türkiye, İtalya, Yunanistan).
3. **Şehre Göre Filtreleme**: Seçilen ülkeye bağlı veya bağımsız şehir filtresi (Örn: İstanbul, Muğla, Antalya, İzmir).
4. **Türe Göre Filtreleme**: `Tümü`, `Kara`, `Hava`, `Deniz` hızlı kategori seçicileri.
5. **Markaya Göre Filtreleme**: Dinamik marka listesi veya metin araması.
6. **Modele Göre Filtreleme**: Seçilen markaya ait veya serbest metin tabanlı model filtresi.
7. **Plaka Numarasına Göre Filtreleme**: Plaka / kuyruk / sicil numarası üzerinden tam veya kısmi eşleşme araması.

### 5.3. Gerçek Zamanlı Araç Takip Paneli (Owner Tracking Dashboard)
- Yalnızca **araç sahipleri** (aracı olan sivil kullanıcılar ve firmalar) kendi araçlarını bu panelden izleyebilir.
- Panelde **Takip Numarası (`trackingNumber`)** arama ve hızlı seçim kutusu bulunur.
- Araç sahibi listeden bir aracını seçtiğinde veya takip numarasını girdiğinde:
  - Aracın canlı harita üzerindeki anlık konumu (enlem/boylam),
  - Hız (km/s veya knot), yön (heading), irtifa (hava taşıtları için) veya deniz durumu,
  - Motor/kontak durumu (Hareket Halinde, Park Halinde, Hangarda/Marinada),
  - Aktif bir kiralamada olup olmadığı ve kiralayan bilgisi gerçek zamanlı akış (`Stream`) ile güncellenir.

### 5.4. Üç Taraflı Rezervasyon Paneli (Reservation Hub)
Rezervasyon paneli, sistemin kalbidir ve her rezervasyon nesnesinde şu üç bileşeni açıkça birbirine bağlar:
1. **Araç (`Vehicle`)**: Marka, model, plaka no, tür, birim fiyat, takip no, teslim ülke/şehri.
2. **Kiralayan (`Renter` - Sivil Kullanıcı)**: Ad soyad, T.C. kimlik no (maskelenmiş/yetkiye göre görünür), iletişim numarası, adres.
3. **Araç Sahibi (`Owner` - Sivil veya Firma)**: Sivil ise ad soyad ve iletişim; firma ise firma adı ve ilgili şube adresi.
- **Rezervasyon Yaşam Döngüsü**:
  - `Talep Edildi (Pending)`: Sivil kullanıcı tarih aralığını seçip rezervasyon oluşturur. Toplam tutar `birim fiyat x süre` olarak hesaplanır.
  - `Onaylandı (Approved)`: Araç sahibi (sivil veya firma) talebi onaylar.
  - `Aktif Kirada (Active)`: Araç teslim edilir, takip panelinde aktif kiralama rozeti yanar.
  - `Tamamlandı (Completed)` / `İptal Edildi (Cancelled)`: Kiralama süreci sonlanır.
- Kullanıcılar rezervasyon kartı üzerinden tek dokunuşla ilgili araç sahibi/kiracı ile **Mesajlaşma Paneline** veya (araç sahibi ise) **Takip Paneline** geçebilir.

### 5.5. Gerçek Zamanlı Mesajlaşma Paneli (Messaging Center)
- Araç sahipleri (sivil/firma) ile kiralayanların (sivil) rezervasyon öncesi soru sorma veya aktif kiralama sırasında iletişim kurma panelidir.
- Her sohbet odası (`ChatRoom`), ilgili **Araç** ve varsa **Rezervasyon** bağlamına (`vehicleId`, `reservationId`) sahiptir; sohbet ekranının üst barında aracın marka/model/plaka bilgisi ve birim fiyatı özet kart olarak sabitlenir.
- Okunmamış mesaj sayacı, zaman damgaları, hızlı hazır mesaj şablonları ("Aracı teslim almaya geliyorum", "Konum paylaşır mısınız?", "Rezervasyon onaylandı") desteklenir.

## 6. Anti-Gravity İçin Adım Adım Uygulama Yol Haritası

Anti-Gravity bu projeyi oluştururken aşağıdaki sırayı takip etmelidir:

1. **Faz 1 — Proje İskeleti ve Tema Kurulumu**:
   - `architecture.md` içerisindeki klasör yapısını ve paket bağımlılıklarını (`flutter_riverpod`, `go_router`, `freezed_annotation`, `google_fonts`, `flutter_map` / `latlong2`, `intl`) yapılandır.
   - `design.md` içerisindeki **Koyu Kırmızı ve Gri Tonları** renk paletini `AppTheme` ve `ThemeData` olarak kodla.
2. **Faz 2 — Veri Modelleri ve Mock/Gerçek Zamanlı Servis Katmanı**:
   - `CivilianUser`, `CompanyUser`, `Vehicle`, `Reservation`, `TrackingTelemetry` ve `ChatMessage` modellerini oluştur.
   - Kara, hava ve deniz taşıtlarını, örnek sivil ve firma hesaplarını ve simüle edilmiş gerçek zamanlı GPS telemetri akışını (`Stream`) sağlayan servisleri yaz.
3. **Faz 3 — Kimlik Doğrulama (Ayrı Sivil ve Firma Girişleri)**:
   - Sivil ve Firma sekmeli Login/Register ekranlarını, TC Kimlik / Telefon / Şube Adresi doğrulama kurallarıyla inşa et.
4. **Faz 4 — Ana Keşif ve 7 Kriterli Filtreleme Paneli**:
   - Ülke, şehir, araç sahibi, tür (Kara/Hava/Deniz), marka, model ve plaka filtrelerini içeren reaktif araç keşif ekranını ve araç ekleme/yönetim modüllerini kodla.
5. **Faz 5 — Rezervasyon, Takip Numarası ile Canlı Takip ve Mesajlaşma Panelleri**:
   - Araç + Kiralayan + Araç Sahibi detaylı rezervasyon panelini, takip numarası (`trackingNumber`) ile çalışan canlı harita/telemetri panelini ve taraflar arası anlık mesajlaşma ekranını tamamla.

## 7. Kabul Kriterleri (Definition of Done)

- [ ] Sivil kullanıcılar ve firmalar için iki ayrı giriş ve kayıt ekranı eksiksiz çalışıyor mu?
- [ ] Sivil profilinde Ad, Soyad, TC No, İletişim No, Adres ve Araç Listesi; Firma profilinde Firma Adı, Şube Adresi ve Araç Listesi yer alıyor mu?
- [ ] Hem sivil kullanıcılar hem firmalar araç kiraya verebiliyor, ancak sadece sivil kullanıcılar araç kiralayabiliyor mu?
- [ ] Araçlarda Marka, Model, Plaka No, Tür (Kara/Hava/Deniz), Birim Fiyat ve Takip Numarası alanları mevcut mu?
- [ ] Filtreleme panelinde Sahip, Ülke, Şehir, Tür, Marka, Model ve Plaka bazlı filtreleme anlık çalışıyor mu?
- [ ] Araç sahipleri Takip Numarası ile gerçek zamanlı takip panelinden araçlarının canlı konum ve telemetri verilerini izleyebiliyor mu?
- [ ] Rezervasyon panelinde Araç, Kiralayan ve Araç Sahibi bilgileri bir arada görüntülenip yönetilebiliyor mu?
- [ ] Araç sahipleri ile kiralayanlar mesajlaşma panelinden anlık yazışabiliyor mu?
- [ ] Tüm arayüz `design.md` dosyasında tanımlanan koyu kırmızı ve gri tonlarındaki temaya tam uyumlu mu?
