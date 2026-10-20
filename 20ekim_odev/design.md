# Çok Modlu Araç Kiralama Sistemi — UI/UX ve Tasarım Sistemi (`design.md`)

## 1. Tasarım Felsefesi ve Görsel Kimlik

Uygulamanın görsel dili; **Kara, Hava ve Deniz** taşıtlarının prestijini, hızını ve güvenilirliğini yansıtan **"Crimson & Obsidian Slate" (Koyu Kırmızı ve Endüstriyel Gri Tonları)** teması üzerine inşa edilmiştir. Koyu antrasit ve metalik gri yüzeyler, göz yormayan yüksek kontrastlı bir kontrol paneli (kokpit) hissi verirken; koyu kırmızı (crimson/burgundy) vurgular birincil aksiyonları, aktif filtreleri ve canlı telemetri sinyallerini öne çıkarır.

## 2. Renk Paleti (Koyu Kırmızı ve Grinin Tonları)

Anti-Gravity, `lib/core/constants/app_colors.dart` dosyasında aşağıdaki renk sabitlerini birebir tanımlamalı ve tüm bileşenlerde kullanmalıdır:

| Renk Rolü | Sabit Adı (`AppColors`) | Hex Kodu | Kullanım Alanı |
| :--- | :--- | :--- | :--- |
| **Birincil Koyu Kırmızı (Primary)** | `crimsonPrimary` | `#8B0000` | Ana aksiyon butonları (Kiralama, Giriş), aktif sekme göstergeleri, vurgu çerçeveleri |
| **Parlak Koyu Kırmızı (Accent)** | `crimsonAccent` | `#B71C1C` | Seçili filtre çipleri, bildirim rozetleri, canlı takip harita pini, hover/basılı durumlar |
| **Derin Bordo (Container)** | `crimsonSurface` | `#3A0A0E` | Kritik bilgi kartları arka planı, aktif kiralama rozet zemini, seçili kart dolgusu |
| **Yumuşak Mercan Kırmızı** | `crimsonLight` | `#EF5350` | İkon vurguları, karanlık zeminde okunabilir kırmızı metin etiketleri |
| **Ana Arka Plan (En Koyu Gri)** | `obsidianGrey` | `#121417` | Tüm ekranların ana zemin rengi (`scaffoldBackgroundColor`) |
| **İkincil Yüzey (Koyu Antrasit)** | `charcoalGrey` | `#1C1F24` | Üst bar (AppBar), alt navigasyon barı, yan filtre çekmecesi zemini |
| **Kart Yüzeyi (Metalik Koyu Gri)** | `slateCardGrey` | `#262A30` | Araç kartları, rezervasyon kartları, mesaj balonları (karşı taraf) |
| **Yükseltilmiş Yüzey (Orta Gri)** | `gunmetalGrey` | `#323740` | Input/TextField iç dolgusu, açılır menü (Dropdown) arka planları |
| **Kenarlık ve Ayırıcı Gri** | `steelBorderGrey` | `#454C59` | Kart kenarlıkları (`1px`), tablo çizgileri, pasif input çerçeveleri |
| **Birincil Metin (Kırık Beyaz/Gri)** | `platinumText` | `#F1F3F5` | Ana başlıklar, araç marka/model isimleri, birim fiyatlar |
| **İkincil Metin (Gümüş Gri)** | `silverText` | `#ADB5BD` | Alt başlıklar, plaka/ülke/şehir etiketleri, açıklama metinleri |
| **Üçüncül / İpucu Metni** | `mutedGreyText` | `#6C757D` | Placeholder (ipucu) metinleri, zaman damgaları, pasif ikonlar |
| **Durum: Onay / Aktif** | `statusEmerald` | `#2E7D32` | "Müsait", "Motor Çalışıyor", "Rezervasyon Onaylandı" durum göstergesi |
| **Durum: Beklemede** | `statusAmber` | `#C68400` | "Onay Bekliyor" rezervasyon rozeti |

## 3. Tipografi ve İkonografi

- **Başlık Fontu (`Space Grotesk` veya `Montserrat`)**: Teknik, keskin ve modern görünüm. Araç marka/model başlıkları, birim fiyatlar ve panel başlıklarında kullanılır (`FontWeight.w700`).
- **Gövde ve Veri Fontu (`Inter`)**: Yüksek okunabilirlik. Filtre panelleri, adres bilgileri, mesajlaşma metinleri ve rezervasyon detaylarında kullanılır (`FontWeight.w400` - `w600`).
- **Monospace Veri Fontu (`JetBrains Mono`)**: **Takip Numarası (`trackingNumber`)**, **Plaka Numarası (`plateNumber`)**, **T.C. Kimlik Numarası** ve **GPS Koordinatları** gibi kod/telemetri verilerinde kokpit hissi vermek için kullanılır.

| Tipografi Stili | Boyut (`sp`/`px`) | Ağırlık | Renk | Kullanım Yeri |
| :--- | :--- | :--- | :--- | :--- |
| `DisplayHeader` | `26px` | Bold (`700`) | `#F1F3F5` | Giriş portalı başlığı, ana sayfa üst başlığı |
| `SectionTitle` | `20px` | SemiBold (`600`) | `#F1F3F5` | Panel başlıkları (Filtreleme, Canlı Takip, Rezervasyonlar) |
| `CardTitle` | `17px` | Bold (`700`) | `#F1F3F5` | Araç Marka & Model adı, Firma/Sivil sahip adı |
| `BodyRegular` | `14px` | Regular (`400`) | `#ADB5BD` | Adres, mesaj içeriği, rezervasyon açıklamaları |
| `TelemetryCode` | `13px` | SemiBold (`600`) | `#EF5350` | Plaka No, Takip No (`TRK-...`) ve canlı koordinatlar |

## 4. Temel UI Bileşenleri (Component Specifications)

### 4.1. Taşıt Türü Rozetleri (Vehicle Category Badges)
Her araç kartının sağ üst köşesinde taşıtın türünü belirten ikonlu rozet yer alır:
- **Kara Taşıtı (`Kara`)**: Koyu gri zemin (`#323740`), koyu kırmızı kenarlık (`#B71C1C`), direksiyon/otomobil ikonu.
- **Hava Taşıtı (`Hava`)**: Derin bordo zemin (`#3A0A0E`), parlak kırmızı metin (`#EF5350`), uçak/helikopter ikonu.
- **Deniz Taşıtı (`Deniz`)**: Çelik gri zemin (`#262A30`), gümüş gri kenarlık (`#ADB5BD`) ve koyu kırmızı çapa/yat ikonu.

### 4.2. Plaka ve Takip Numarası Çipleri
- **Plaka Kutusu**: Gerçek plaka estetiğinde, sol şeridinde koyu kırmızı (`#8B0000`) dikey bant bulunan, `#1C1F24` zeminli ve `JetBrains Mono` fontlu kapsül.
- **Takip No Rozeti**: Yanında canlı yanıp sönen (pulse animasyonlu) kırmızı nokta (`#B71C1C`) bulunan `#3A0A0E` zeminli tıklanabilir rozet. Araç sahibi bu rozete tıkladığında doğrudan **Gerçek Zamanlı Takip Paneline** yönlendirilir.

## 5. Ekran Bazlı Tasarım ve Yerleşim Planları (Screen Layouts)

### 5.1. Çift Modlu Giriş ve Kayıt Ekranı (`AuthPortalScreen`)
- **Üst Bölüm**: Koyu antrasit (`#121417`) zemin üzerinde koyu kırmızı radyal ışık geçişi (gradient glow) ve uygulama logosu.
- **Rol Seçici (Segmented Toggle)**: Ekranın ortasında `#1C1F24` zeminli, seçili sekmesi `#8B0000` (Koyu Kırmızı) olan iki büyük sekme:
  1. **"Sivil Kullanıcı Girişi"**: Bireysel ikonlu. Kayıt modunda: *Ad, Soyad, T.C. Kimlik No (11 hane sayacı ile), İletişim Numarası, Ülke/Şehir/Açık Adres* alanları açılır.
  2. **"Firma (Şube) Girişi"**: Kurumsal bina ikonlu. Kayıt modunda: *Firma Adı, Şube Adı, Şube Ülke/Şehir/Açık Adresi, Şube İletişim No* alanları açılır.
- **Aksiyon Butonu**: Tam genişlikte, `#8B0000` -> `#B71C1C` yatay gradyanlı, `12px` köşe yuvarlatmalı giriş/kayıt butonu.

### 5.2. Ana Keşif ve 7 Kriterli Filtreleme Paneli (`VehicleDiscoveryScreen`)
- **Üst Bar**: Aktif kullanıcının rol rozeti (`Sivil: Ahmet Yılmaz` veya `Firma: SkyJet Havacılık - Atatürk Havalimanı Şb.`), bildirim/mesaj ikonu ve **"Araç Kiraya Ver (+)"** hızlı aksiyon butonu.
- **Hızlı Tür Seçici (Yatay Bar)**: `Tümü`, `Kara Taşıtları`, `Hava Taşıtları`, `Deniz Taşıtları` sekmeleri. Seçili sekme `#B71C1C` dolgulu.
- **Gelişmiş 7 Kriterli Filtre Paneli** (Masaüstü/Tablette sol sabit panel `300px`, mobilde alttan açılan tam boy `#1C1F24` BottomSheet):
  1. **Araç Sahibi Filtresi**: "Tümü / Sivil Sahipler / Kurumsal Firmalar" seçicisi + Sahip/Firma adı arama kutusu.
  2. **Ülke Seçici**: Açılır menü (`#323740` zemin).
  3. **Şehir Seçici**: Seçilen ülkeye göre filtrelenen şehir açılır menüsü.
  4. **Taşıt Türü**: Kara / Hava / Deniz çoklu veya tekli seçim çipleri.
  5. **Marka**: Arama destekli marka seçici.
  6. **Model**: Model arama/seçim kutusu.
  7. **Plaka No**: Monospace fontlu plaka/tescil numarası arama kutusu.
  - Alt kısımda **"Filtreleri Temizle"** (`#454C59` gri çerçeveli) ve **"Uygula (X Araç)"** (`#8B0000` koyu kırmızı) butonları.
- **Araç Kartı (`VehicleCard`)**:
  - `#262A30` (`slateCardGrey`) zemin, `1px` `#454C59` kenarlık.
  - Üstte araç görseli/silüeti, Tür rozeti (`Kara`/`Hava`/`Deniz`) ve Ülke/Şehir etiketi (`📍 Türkiye / İstanbul`).
  - Ortada kalın `CardTitle` ile **Marka & Model**, hemen altında **Plaka No** ve araç sahibine özel **Takip No** etiketi.
  - Alt şeritte sol tarafta **Araç Sahibi** bilgisi (`🏢 DenizYat A.Ş. - Göcek Şb.` veya `👤 Mehmet Demir`), sağ tarafta koyu kırmızı vurguyla **Birim Fiyat** (`₺4.500 / Gün`) ve sivil kullanıcılar için **"Kirala"** butonu.

### 5.3. Gerçek Zamanlı Araç Takip Paneli (`RealtimeTrackingScreen`)
- **Üst Sorgu Barı**: `#1C1F24` zeminli panelde **"Takip Numarası (`trackingNumber`) Girin veya Aracınızı Seçin"** arama kutusu (Örn: `TRK-HAVA-10492`). Altında araç sahibinin sahip olduğu tüm araçların hızlı seçim çipleri yer alır.
- **Karanlık Mod Harita Katmanı (`TrackingMapView`)**:
  - Harita karoları (Map Tiles) koyu gri/antrasit filtreli olarak render edilir.
  - Aracın anlık konumu üzerinde koyu kırmızı (`#B71C1C`) radar dalgası (ripple effect) yayan özel taşıt ikonu (otomobil, uçak veya yat) bulunur.
  - Aracın izlediği son rota kesikli koyu kırmızı çizgiyle (`#EF5350`) haritada çizilir.
- **Alt Telemetri Kokpit Kartı (`TelemetryStatusCard`)**:
  - `#262A30` zemin üzerinde 4'lü veri ızgarası:
    - **Takip No & Plaka**: `TRK-LAND-3401` | `34 VR 1923`
    - **Anlık Hız & Durum**: `84 km/s` (Hareket Halinde - Yeşil/Kırmızı LED gösterge)
    - **Konum & İrtifa/Bölge**: `41.0082° N, 28.9784° E` (`Türkiye / İstanbul`)
    - **Aktif Kiralama Durumu**: Kirada ise kiralayan sivil kullanıcının adı ve "Mesaj Gönder" kısayolu; boşta ise "Envanterde Bekliyor" etiketi.

### 5.4. Üç Taraflı Rezervasyon Paneli (`ReservationPanelScreen`)
- Sekmeler: `Aktif Kiralamalar`, `Onay Bekleyenler`, `Geçmiş / Tamamlananlar`.
- **Üçlü Rezervasyon Kartı (`ReservationTriadCard`)**:
  - Her kart, `#262A30` zemin üzerinde 3 net sütun/bölüm (Triad) halinde tasarlanmıştır:
    1. **Bölüm 1 — Araç Özeti**: Tür ikonu, Marka/Model, Plaka No, Takip No ve Birim Fiyat x Gün = Toplam Tutar (`#EF5350` renginde belirgin).
    2. **Bölüm 2 — Kiralayan (Sivil Kullanıcı)**: Ad Soyad, T.C. Kimlik No, İletişim Numarası ve Adres bilgisi.
    3. **Bölüm 3 — Araç Sahibi (Sivil veya Firma)**: Firma ise Firma Adı ve Şube Adresi; Sivil ise Ad Soyad, İletişim ve Adres bilgisi.
  - **Alt Aksiyon Şeridi**:
    - Araç sahibi için: `Onayla` (`#2E7D32`), `Reddet/İptal` (`#8B0000`), `Canlı Takip Et` ve `Kiralayana Mesaj Yaz` butonları.
    - Kiralayan sivil kullanıcı için: `Araç Sahibine Mesaj Yaz` ve `Rezervasyon Detayı / İptal` butonları.

### 5.5. Mesajlaşma Paneli (`ChatListScreen` & `ChatConversationScreen`)
- **Sol / Liste Görünümü**: Kiralayanlar ve araç sahipleri arasındaki aktif sohbet odaları. Okunmamış mesajlar `#B71C1C` koyu kırmızı rozetle vurgulanır.
- **Sohbet Ekranı Üst Bağlam Barı (Pinned Vehicle Header)**:
  - Sohbetin en üstünde `#3A0A0E` (Derin Bordo) zeminli sabit bir şerit yer alır; hangi araç (`Marka Model - Plaka No`) ve hangi rezervasyon için konuşulduğunu gösterir.
- **Mesaj Balonları**:
  - **Gönderen (Ben)**: Sağda hizalı, `#8B0000` (Koyu Kırmızı) zeminli, `#F1F3F5` metinli, sağ alt köşesi keskin balon.
  - **Alıcı (Karşı Taraf)**: Solda hizalı, `#262A30` (Metalik Koyu Gri) zeminli, `#454C59` ince kenarlıklı balon.
- **Hızlı Yanıt Çipleri**: Mesaj yazma kutusunun hemen üstünde yatay kaydırılabilir `#323740` zeminli hazır mesaj butonları ("Aracın güncel durumu nedir?", "Teslimat şube konumunu paylaşır mısınız?", "Rezervasyon talebinizi onayladım").

## 6. Duyarlılık (Responsive) ve Etkileşim Kuralları

- **Mobil (`< 600px`)**: Alt navigasyon barı (`BottomNavigationBar`) ile 4 ana sekme: `Keşfet & Filtrele`, `Rezervasyonlar`, `Canlı Takip` (Sahipler için) / `Araçlarım`, `Mesajlar` ve `Profil`.
- **Tablet ve Masaüstü (`>= 600px`)**: Sol tarafta koyu antrasit (`#1C1F24`) `NavigationRail`, yanında sabit `VehicleFilterPanel` ve geniş içerik/harita alanı (Master-Detail görünümü).
- **Mikro Etkileşimler**: Tüm kartlarda üzerine gelindiğinde veya dokunulduğunda kenarlık rengi `#454C59` (Çelik Gri) tonundan `#B71C1C` (Parlak Koyu Kırmızı) tonuna `200ms` yumuşak geçişle döner.
