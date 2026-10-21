# Bahçıvan — UI/UX Tasarım ve Ekran Spesifikasyonu (DESIGN.md)

## 1. Tasarım Felsefesi ve Görsel Dil
**Bahçıvan (Bahçecilik ve Sera Yönetimi)** uygulaması, hem ev/hobi kullanıcılarının hem de sera yetiştiricilerinin tek bakışta hangi bitkinin suya, gübreye veya müdahaleye ihtiyacı olduğunu anlamasını sağlayan **Biyofilik (Doğa Odaklı) ve Durum Güdümlü (Status-Driven)** bir arayüz tasarımına sahiptir.

### 1.1. Renk Paleti ve Renkli Uyarı Kartları Sistemi

| Renk Rolü | İsim | Hex Kodu | Kullanım Alanı |
| :--- | :--- | :--- | :--- |
| **Birincil (Primary)** | Sera Yeşili | `#1B5E20` | Üst bar, ana aksiyon butonları (`Giriş Yap`, `Sera Ekle`, `Bitki Ekle`, `Onayla`) |
| **İkincil (Secondary)** | Filiz Yeşili | `#4CAF50` | İlerleme çubukları, aktif sekmeler, büyüme evresi vurguları |
| **Zemin (Background)** | Doğal Krem / Kırık Beyaz | `#F4F7F4` | Sayfa arka planı, göz yormayan sera çalışma alanı |
| **Kart Yüzeyi (Surface)** | Saf Beyaz | `#FFFFFF` | Sera satırları, bitki kartları, modal pencereler (`#E2E8F0` kenarlık ile) |
| **Acil / Gecikti Uyarısı (Kırmızı Kart)** | Kırmızı Alarm | `#EF4444` (Arka plan: `#FEF2F2`) | Sulama veya gübreleme günü **geçmiş** bitkiler ve kritik hastalık teşhisleri |
| **Bugün / Yaklaşıyor Uyarısı (Sarı Kart)** | Kehribar Uyarı | `#F59E0B` (Arka plan: `#FFFBEB`) | Bakım günü **bugün olan** veya **24 saat içinde** yaklaşan sulama/gübreleme/budama görevleri |
| **Normal / Tamamlandı (Yeşil Kart)** | Sağlıklı Yeşil | `#10B981` (Arka plan: `#ECFDF5`) | Bakımı zamanında yapılmış, bir sonraki döngüye **2+ gün olan** sağlıklı bitkiler |
| **Güneş / İklim Vurgusu** | Güneş Sarısı & Su Mavisi | `#FBBF24` / `#0EA5E9` | Güneş ihtiyacı rehberi (saat/ışık) ve sulama miktarı (ml/sıklık) göstergeleri |

### 1.2. Tipografi ve İkonografi
- **Başlık Fontu:** `Plus Jakarta Sans` veya `Inter` (Bold / SemiBold) — Sayfa başlıkları (`BAHÇELER`, `Sera Adı`, `Bitki Detayları`).
- **Gövde ve Veri Fontu:** `Inter` (Regular / Medium) — Bakım rehberi metinleri, S.S.S. kartları, form etiketleri.
- **Sayaç ve Metrik Fontu:** `JetBrains Mono` veya `Tabular Figures` — Ekimden hasada kalan gün sayacı (`24 Gün Kaldı`) ve tarih etiketleri.

## 2. El Çizimi Eskizlerden Birebir Aktarılan Ekran Tasarımları

### 2.1. Kimlik Doğrulama (Auth) Ekranları (4 Görünüm)

```
+------------------------------------------+   +------------------------------------------+
|               (Yaprak Logo)              |   |               (Yaprak Logo)              |
|                 BAHÇIVAN                 |   |                 BAHÇIVAN                 |
|              Kullanıcı Giriş             |   |              Kayıt Oluştur               |
|                                          |   |                                          |
|  [ E-posta                            ]  |   |  [ E-posta                            ]  |
|  [ Şifre                              ]  |   |  [ Şifre gir                          ]  |
|                                          |   |                                          |
|  (!) Hatalı e-posta veya şifre girdiniz  |   |              [  Kayıt Ol  ]              |
|                                          |   |                                          |
|              [ Giriş Yap ]               |   |         Giriş ekranına geri dön          |
|                                          |   +------------------------------------------+
|            Şifremi Unuttum               |
|             Kayıt Oluştur                |
+------------------------------------------+

+------------------------------------------+   +------------------------------------------+
|              ŞİFRE DEĞİŞTİR              |   |               (Yaprak Logo)              |
|                                          |   |                 BAHÇIVAN                 |
|  [ E-posta adresinizi girin           ]  |   |              Yeni Şifre Gir              |
|                                          |   |                                          |
|   E-posta adresini kontrol et ve         |   |  [ Yeni şifre gir                     ]  |
|   doğrulama adımıyla devam et.           |   |  [ Yeni şifre tekrar                  ]  |
|                                          |   |                                          |
|        [ Doğrula ve Devam Et ]           |   |               [  Yenile  ]               |
|------------------------------------------|   +------------------------------------------+
|                  Footer                  |
+------------------------------------------+
```

- **Doğrulama Kuralları:**
  - `Kullanıcı Giriş` ekranında boş alan veya yanlış kimlik bilgisi girildiğinde formun hemen altında kırmızı uyarı kutusu (`Hatalı e-posta veya şifre!`) görünür.
  - `Şifremi Unuttum` tıklandığında `ŞİFRE DEĞİŞTİR (E-posta adresini kontrol et)` ekranına, oradan onaylandığında `Yeni Şifre Gir` ekranına geçilir; `Yenile` butonu kullanıcıyı `BAHÇELER` ana ekranına taşır.

### 2.2. Bahçeler (Seralar) Ana Ekranı ve Sağ Aksiyon Paneli
El çizimi eskizdeki ana yerleşim, sol/merkezde **Ana İçerik Alanı** ve sağda sabit **Dikey Aksiyon Paneli (Sidebar)** olacak şekilde iki sütunlu bir çerçeveden oluşur:

```
+-------------------------------------------------------------------+--------------------+
|                             BAHÇELER                              | [Not] Not Ekle     |
|-------------------------------------------------------------------|                    |
|  [Foto]  1. Kışlık Domates Serası (4 Bitki)     [Detay]   [Sil]   | [ ? ] Kullanım     |
|          Durum: 1 Sulama Gecikti (Kırmızı)                        |       Kılavuzu ve  |
|-------------------------------------------------------------------|       Yardım       |
|  [Foto]  2. Balkon Çilek & Fesleğen (3 Bitki)   [Detay]   [Sil]   |                    |
|          Durum: Tüm Bakımlar Tamam (Yeşil)                        | [TR | EN]          |
|-------------------------------------------------------------------|   Dil Ayarı        |
|                                                                   |                    |
|                          [ + Sera Ekle ]                          | ( ! ) Çıkış        |
+-------------------------------------------------------------------+--------------------+
```

- **Sera Ekle Modalı (`[+ Sera Ekle]` tıklandığında):**
  - Başlık: `BAHÇELER - Yeni Sera Ekle`
  - Girdi 1: `Sera Adı:` (Zorunlu metin alanı)
  - Girdi 2: `Fotoğraf Ekle` (Kare önizleme kutusu, isteğe bağlı görsel yükleme veya hazır sera ikonu seçimi)
  - Alt Butonlar: Sol altta `[ İptal X ]`, sağ altta `[ Onayla ]`.
- **Genel Kullanım ve Yardım (3 Kartlı Rehber — Sağ menüdeki `[?]` butonundan açılır):**
  - **Kart 1 (Nasıl Sera Eklerim?):** *"1. Nasıl sera eklerim? Cevap: Sera Ekle'ye tıkla, sera adı ve isteğe bağlı foto ekle, sonra Onayla veya İptal deyip çık."*
  - **Kart 2 (Silme Uyarısı):** *"2. Sildiğim seraları geri getirebilir miyim? Hayır, sildiğiniz seraya ait tüm bilgiler silinir ve geri getirilemez. O yüzden silmeden önce iyi düşün."*
  - **Kart 3 (S.S.S. & İletişim):** *"3. S.S.S. ve İletişim — E-posta: destek@bahcivanapp.com | Telefon: +90 (212) 555 00 00"*

### 2.3. Sera İçi Görünümü (`Sera Adı` — Bitki Listesi Ekranı)
`BAHÇELER` ekranında bir seranın `[Detay]` butonuna tıklandığında açılır:

```
+-------------------------------------------------------------------+--------------------+
|                    Sera Adı: Kışlık Domates Serası                | [Not] Not Ekle     |
|-------------------------------------------------------------------|                    |
|  Bitki Adı               Bakım Uyarı Özeti    Hasat Sayacı  İşlem | [Takvim]           |
|  ---------------------------------------------------------------- |   Takvim ve        |
|  Pembe Domates #1        [KIRMIZI: Sulama!]   24 Gün Kaldı [Detay]|   Hatırlatıcı      |
|                                                            [Sil]  |                    |
|  Sivri Biber #2          [SARI: Gübreleme]    38 Gün Kaldı [Detay]|                    |
|                                                            [Sil]  |                    |
|  Reyhan / Fesleğen       [YEŞİL: Normal]      12 Gün Kaldı [Detay]|                    |
|                                                            [Sil]  |                    |
|-------------------------------------------------------------------|                    |
|  [ <- Ana Menü ]                                  [ + Bitki Ekle ]| ( ! ) Çıkış        |
+-------------------------------------------------------------------+--------------------+
```

## 3. Eksik Olan ve Mimariye Entegre Edilen Yeni Ekranlar

### 3.1. Bitki Detayları Sayfası (`Bitki Detay` — `[Detay]` Butonundan Açılır)
Sera içindeki listede herhangi bir bitkinin `[Detay]` butonuna basıldığında açılan bu ekran, proje özetindeki **4 temel özelliği** eskizdeki sağ menü mimarisiyle birebir uyumlu şekilde tek ekranda sunar:

```
+-------------------------------------------------------------------+--------------------+
|  [<- Seraya Dön]   Pembe Domates #1 (Tür: Domates - Solanum)      | [Not] Bitkiye      |
|-------------------------------------------------------------------|       Not Ekle     |
|  1. EKİMDEN HASADA TAHMİNİ GÜN SAYACI                             |                    |
|  +-------------------------------------------------------------+  | [Takvim]           |
|  | Ekim: 25.09.2026  |  Tahmini Hasat: 04.12.2026 (Toplam 70G) |  |   Takvim ve        |
|  | [=================>          ] %65 Tamamlandı (Evre: Çiçek) |  |   Hatırlatıcı      |
|  | GEÇEN: 46 Gün     |  KALAN: 24 Gün     [+ Hasat Kaydı Ekle] |  |                    |
|  +-------------------------------------------------------------+  | [Teşhis]           |
|                                                                   |   Hastalık Rehberi |
|  2. SULAMA / GÜBRELEME / BUDAMA RENKLİ UYARI KARTLARI             |                    |
|  +-------------------+ +-------------------+ +-----------------+  | ( ! ) Çıkış        |
|  | [KIRMIZI KART]    | | [SARI KART]       | | [YEŞİL KART]    |  |                    |
|  | SULAMA ZAMANI     | | GÜBRELEME ZAMANI  | | BUDAMA ZAMANI   |  |                    |
|  | 1 Gün Gecikti!    | | Bugün Yapılmalı   | | 9 Gün Sonra     |  |                    |
|  | Periyot: 3 Günde 1| | Periyot: 14 Gün   | | Periyot: 21 Gün |  |                    |
|  | [Sulandı İşaretle]| | [Gübrelendi İşrt.]| | [Budandı İşrt.] |  |                    |
|  +-------------------+ +-------------------+ +-----------------+  |                    |
|                                                                   |                    |
|  3. BİTKİ TÜRÜNE GÖRE SULAMA VE GÜNEŞ İHTİYACI REHBERİ            |                    |
|  +-------------------------------------------------------------+  |                    |
|  | * Güneş İhtiyacı : Günde 6-8 Saat Doğrudan Güneş Işığı      |  |                    |
|  | * Sulama Rehberi : Kök bölgesine 400-500 ml, yaprak ıslatma |  |                    |
|  | * İdeal Sıcaklık : 20°C - 27°C (Gece min 14°C)              |  |                    |
|  | * Toprak & Budama: Koltuk sürgünlerini 3 haftada bir temizle|  |                    |
|  +-------------------------------------------------------------+  |                    |
|                                                                   |                    |
|  4. ZARARLI BÖCEK VE HASTALIK BELİRTİSİ TEŞHİS REHBERİ            |                    |
|  +-------------------------------------------------------------+  |                    |
|  | Belirti Seçin: [Yaprak Sararması] [Beyaz Leke] [Yaprak Delik]| |                    |
|  | -> Eşleşen Teşhis: Beyaz Sinek / Külleme (Aciliyet: Orta)   |  |                    |
|  | -> Çözüm Rehberi : Neem yağı (tesbih ağacı yağı) veya arap  |  |                    |
|  |    sabunlu su karışımını 3 gün arayla yaprak altına uygula. |  |                    |
|  +-------------------------------------------------------------+  |                    |
+-------------------------------------------------------------------+--------------------+
```

### 3.2. Bitki Detay Sayfası Alt Bileşen Kuralları

1. **Renkli Uyarı Kartları Mantığı (Color-Coded Care Cards):**
   - Her bitki detay sayfasında yan yana 3 kart bulunur: **Sulama**, **Gübreleme**, **Budama**.
   - Kart rengi otomatik belirlenir:
     - **Kırmızı Kart (`Gecikti / Acil`):** `Bugün - Son Bakım Tarihi > Periyot Gün Sayısı`. Kart üzerinde yanıp sönen uyarı ikonu ve **"X Gün Gecikti!"** yazar.
     - **Sarı Kart (`Bugün / Yaklaşıyor`):** Bakım gününe `0` veya `1` gün kalmıştır. **"Bugün Yapılmalı"** veya **"Yarın"** yazar.
     - **Yeşil Kart (`Güvende / Tamamlandı`):** Bakım gününe `2` veya daha fazla gün vardır. **"X Gün Sonra"** yazar.
   - Kullanıcı kartın altındaki `[Sulandı İşaretle]`, `[Gübrelendi İşaretle]` veya `[Budandı İşaretle]` butonuna tıkladığında kart anında **Yeşil** renge döner, son bakım tarihi bugüne güncellenir ve işlem geçmişe kaydedilir.

2. **Ekimden Hasada Tahmini Gün Sayacı (Harvest Countdown):**
   - Bitki eklenirken seçilen `Ekim Tarihi` ve bitki türünün `Tahmini Hasat Süresi (Gün)` (Örn: Domates 70 gün, Marul 45 gün, Çilek 60 gün, Biber 75 gün, Turp 30 gün) üzerinden çalışır.
   - İlerleme oranına göre bitkinin büyüme evresini otomatik etiketler:
     - `%0 - %20`: **Çimlenme / Fide Evresi**
     - `%21 - %55`: **Vejetatif Gelişim (Yaprak/Gövde) Evresi**
     - `%56 - %85`: **Çiçeklenme ve Meyve Tutumu Evresi**
     - `%86 - %100+`: **Hasat Zamanı Evresi** (Hasat geldiğinde kart altın sarısı/yeşil vurgu alır ve `[+ Hasat Kaydı Ekle]` butonu öne çıkar).

3. **Bitki Türüne Göre Sulama ve Güneş İhtiyacı Rehberi:**
   - Kullanıcı bitki eklerken bitki türünü seçtiğinde (Örn: *Domates*), sistem hazır katalogdan şu 4 bilgi kutucuğunu otomatik gösterir:
     - **Güneş İhtiyacı:** Günlük saat aralığı + Doğrudan / Yarı Gölge / Dolaylı ışık tercihi.
     - **Sulama Rehberi:** Kaç günde bir sulanacağı, kök/yaprak sulama uyarısı ve tahmini su miktarı (ml).
     - **Sera İklim & Toprak:** İdeal sıcaklık (°C), nem (%) ve pH/toprak tipi.
     - **Budama & Destek:** Sırık/ip desteği, koltuk alma veya kuru yaprak temizliği talimatı.

4. **Zararlı Böcek veya Hastalık Belirtisi Teşhis Rehberi:**
   - Kullanıcı bitki üzerinde gördüğü belirtiyi (semptom etiketlerinden) seçer:
     - `[Yaprakta Sararma]`, `[Beyaz Pamuksu Tabaka]`, `[Yapraklarda Küçük Delikler]`, `[Yaprak Altında İnce Ağ]`, `[Kök/Gövde Kararması]`, `[Yaprak Kıvrılması]`.
   - Seçilen belirtiye göre eşleşen zararlı/hastalık kartları listelenir:
     - **Teşhis Adı ve Türü:** (Örn: *Yaprak Biti - Zararlı Böcek* veya *Külleme - Mantar Hastalığı*)
     - **Risk Seviyesi Rozeti:** Düşük / Orta / Yüksek
     - **Adım Adım Mücadele Rehberi:** Doğal/organik çözüm tarifi ve serada diğer bitkilere bulaşmasını önleme kuralları.
     - **[Tedavi Notu Ekle] Butonu:** Teşhisi ve uygulanan tedaviyi bitkinin not geçmişine tek tıkla kaydeder.

### 3.3. Yeni Bitki Ekleme & İhtiyaç Profili Modalı (`[+ Bitki Ekle]`)
`Sera Adı` ekranındaki `[Bitki Ekle]` butonuna basıldığında açılır:
- **Bitki Türü Seçimi (Dropdown / Kart Seçici):** Domates, Salatalık, Sivri Biber, Çilek, Fesleğen, Marul, Orkide, Kabak, Özel Bitki. *(Tür seçildiği anda varsayılan Sulama Periyodu, Güneş İhtiyacı ve Hasat Gün Sayısı formda otomatik önizlenir; kullanıcı isterse özelleştirebilir).*
- **Bitki Takma Adı / Etiketi:** Örn: *"Doğu Köşesi Pembe Domates #1"*.
- **Ekim / Dikim Tarihi:** Tarih seçici (Varsayılan: Bugün; geçmiş tarih seçilirse gün sayacı otomatik aradaki farktan başlar).
- **Butonlar:** `[İptal X]` ve `[Bitkiyi Seraya Ekle]`.

### 3.4. Takvim ve Hatırlatıcı + Hasat/Verim Günlüğü Ekranı
Sağ menüdeki `[Takvim ve Hatırlatıcı]` butonuna tıklandığında açılır:
- **Üst Bölüm (Özet Uyarı Barı):** *"Bugün 2 Sulama, 1 Gübreleme göreviniz ve bu hafta 1 Hasat beklentiniz var."*
- **Sekme 1 — Bakım Takvimi:** Haftalık/Aylık görünümde hangi gün hangi seradaki hangi bitkinin sulanacağını, gübreleneceğini veya budanacağını renk kodlarıyla (Kırmızı/Sarı/Yeşil) listeler.
- **Sekme 2 — Hasat ve Verim Günlüğü:** Hasat edilen bitkilerin tarih, miktar (gram/kg/adet), kalite puanı (1-5 yıldız) ve kullanıcı notlarını tablo halinde sunar.
