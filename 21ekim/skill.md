---
name: bahcivan-sera-yonetimi
description: Bahçecilik ve Sera Yönetimi (Bahçıvan) uygulamasını el çizimi wireframe eskizlerine ve PROJECT.md, DESIGN.md, ARCHITECTURE.md spesifikasyonlarına sadık kalarak geliştirmek, güncellemek veya hata ayıklamak için kullanılan Antigravity geliştirici becerisi (skill). Kullanıcı sera yönetimi, bitki detay sayfası, sulama/gübreleme renkli uyarı kartları, ekimden hasada gün sayacı veya zararlı/hastalık teşhis rehberi istediğinde bu beceriyi kullan.
---

# Bahçıvan — Sera ve Bitki Yönetimi Geliştirme Becerisi (SKILL.md)

Bu beceri (skill), **Bahçecilik ve Sera Yönetimi (Bahçıvan)** projesini Antigravity ortamında geliştirirken AI ajanının uyması gereken mimari kuralları, ekran akışlarını ve bileşen standartlarını tanımlar.

## Ne Zaman Kullanılmalı (When to Use)

- Kullanıcı `PROJECT.md`, `DESIGN.md` ve `ARCHITECTURE.md` dosyalarını referans alarak **Bahçıvan** uygulamasını sıfırdan oluşturmak istediğinde
- El çizimi eskizlerdeki ekranları (`Giriş`, `Kayıt`, `Şifre Değiştir`, `Bahçeler`, `Sera Ekle`, `Genel Kullanım ve Yardım`, `Sera Adı Bitki Listesi`) kodlarken
- Eksik olan **Bitki Detayları Sayfası** ve içindeki 4 çekirdek modülü (**Sulama/Güneş Rehberi**, **Renkli Uyarı Kartları**, **Ekimden Hasada Gün Sayacı**, **Zararlı/Hastalık Teşhis Rehberi**) mevcut mimariye entegre ederken

## Adım Adım Uygulama İş Akışı (Execution Workflow)

### Adım 1: Veri Katmanı ve Hazır Katalogları (`seedData.js` & `store.js`) Oluştur
Uygulamayı çalıştırmadan önce en az **6 hazır bitki türü profilini** ve **6 yaygın sera zararlısı/hastalığını** içeren başlangıç veritabanını (`seedData.js`) kur:

1. **Hazır Bitki Türleri (`PLANT_SPECIES_CATALOG`):**
   - **Domates:** Sulama 3 günde bir (450 ml), Gübreleme 14 günde bir, Budama 21 günde bir, Güneş 6-8 saat doğrudan ışık, Hasat süresi 70 gün.
   - **Sivri Biber:** Sulama 3 günde bir (350 ml), Gübreleme 15 günde bir, Budama 25 günde bir, Güneş 6-8 saat doğrudan ışık, Hasat süresi 75 gün.
   - **Çilek:** Sulama 2 günde bir (250 ml), Gübreleme 14 günde bir, Budama 15 günde bir (kol/sürgün temizliği), Güneş 5-7 saat doğrudan/yarı gölge, Hasat süresi 60 gün.
   - **Salatalık:** Sulama 2 günde bir (500 ml), Gübreleme 12 günde bir, Budama 14 günde bir, Güneş 6-8 saat doğrudan ışık, Hasat süresi 55 gün.
   - **Fesleğen / Reyhan:** Sulama 2 günde bir (200 ml), Gübreleme 21 günde bir, Budama 10 günde bir (uç alma), Güneş 4-6 saat güneşli/yarı gölge, Hasat süresi 40 gün.
   - **Marul:** Sulama 2 günde bir (300 ml), Gübreleme 20 günde bir, Budama 30 günde bir (dış yaprak), Güneş 4-5 saat yarı gölge, Hasat süresi 45 gün.

2. **Hazır Zararlı ve Hastalık Teşhis Kataloğu (`PEST_DISEASE_CATALOG`):**
   - **Yaprak Biti (Aphids):** Belirtiler: *Yaprak kıvrılması, yapışkan sıvı, tomurcuklarda kümeleşme*. Çözüm: *Arap sabunlu su veya Neem yağı spreyi*.
   - **Beyaz Sinek (Whitefly):** Belirtiler: *Yaprak altında beyaz uçuşan böcekler, yaprak sararması*. Çözüm: *Sarı yapışkan tuzak ve organik yağ uygulaması*.
   - **Kırmızı Örümcek (Spider Mite):** Belirtiler: *Yaprak altında ince örümcek ağı, yaprakta bronzlaşma ve nokta sararmalar*. Çözüm: *Sera nemini artırma ve kükürtlü/bitkisel ekstrakt*.
   - **Külleme (Powdery Mildew):** Belirtiler: *Yaprak üstünde beyaz un/pudra benzeri tabaka, kuruma*. Çözüm: *Havalandırmayı artırma, karbonatlı + sıvı sabunlu su karışımı*.
   - **Kök Çürüklüğü (Root Rot):** Belirtiler: *Aşırı sulamaya bağlı solgunluk, gövde dip kararması, yaprak sararması*. Çözüm: *Sulamayı durdurma, drenajı iyileştirme, hasta kökleri temizleme*.
   - **Yaprak Tırtılı / Salyangoz:** Belirtiler: *Yapraklarda düzensiz büyük delikler ve yenmiş kenarlar*. Çözüm: *Fiziksel toplama, kül/yumurta kabuğu bariyeri veya Bacillus thuringiensis*.

### Adım 2: El Çizimi Eskizdeki Navigasyon ve Sağ Aksiyon Panelini Kur
Eskizdeki sayfa düzenini bozmadan iki sütunlu ana yerleşimi uygula:

1. **Kimlik Doğrulama (Auth) Akışı:**
   - `Giriş Yap` sayfasında hatalı giriş denemesinde kullanıcıya açık hata uyarısı göster.
   - `Kayıt Oluştur` -> Kayıt sayfasına, `Şifremi Unuttum` -> `ŞİFRE DEĞİŞTİR (E-posta adresini kontrol et)` -> `Yeni Şifre Gir (Yenile)` -> `BAHÇELER` ana ekranına yönlendir.
2. **Sağ Aksiyon Paneli (`RightActionSidebar`):**
   - **BAHÇELER Ekranında:** `Not Ekle`, `Kullanım Kılavuzu ve Yardım` (3 kartlı S.S.S. akışı), `TR | EN Dil Ayarı`, `Çıkış`.
   - **Sera Adı (Bitki Listesi) ve Bitki Detay Ekranında:** `Not Ekle`, `Takvim ve Hatırlatıcı`, `Çıkış`.
3. **Sera Silme Güvenliği:**
   - Yardım Kartı 2'de yazılı olan *"Hayır, sildiğiniz seraya ait tüm bilgiler silinir ve geri getirilemez. O yüzden iyi düşün silmeden"* kuralını `Sil` butonuna basıldığında açılan onay penceresinde birebir göster.

### Adım 3: Bitki Detayları Sayfasını ve 4 Çekirdek Özelliği Entegre Et
`Sera Adı` ekranındaki bitki satırında yer alan `[Detay]` butonuna tıklandığında açılan `PlantDetailPage` ekranında şu 4 bileşeni eksiksiz render et:

1. **Bileşen 1 — Ekimden Hasada Tahmini Gün Sayacı (`HarvestCountdownBar`):**
   - Ekim tarihi, tahmini hasat tarihi, geçen gün, kalan gün ve yüzdelik ilerleme çubuğunu (`%`) göster.
   - Büyüme evresini (*Fide*, *Gelişim*, *Çiçeklenme*, *Hasat Zamanı*) otomatik hesapla ve yanında `[+ Hasat ve Verim Kaydı Ekle]` butonu sun.
2. **Bileşen 2 — Sulama / Gübreleme / Budama Renkli Uyarı Kartları (`CareAlertCard`):**
   - `ARCHITECTURE.md` içindeki `evaluateCareStatus` fonksiyonunu kullanarak geciken bakımları **Kırmızı (`#EF4444`)**, bugün/yarın yapılacakları **Sarı (`#F59E0B`)**, zamanı olanları **Yeşil (`#10B981`)** kart olarak göster.
   - Her kartın içine `[Sulandı İşaretle]`, `[Gübrelendi İşaretle]` ve `[Budandı İşaretle]` butonu koy; tıklandığında ilgili tarihi bugüne güncelle ve kartı anında yeşile çevir.
3. **Bileşen 3 — Bitki Türüne Göre Sulama ve Güneş İhtiyacı Rehberi (`PlantCareGuideCard`):**
   - Bitkinin türüne ait günlük güneş saati, ışık tipi, sulama miktarı (ml) ve sıklığı, ideal sıcaklık/nem aralığı ve budama ipuçlarını ikonlu bilgi kartlarıyla listele.
4. **Bileşen 4 — Zararlı Böcek ve Hastalık Belirtisi Teşhis Rehberi (`PestDiagnosisPanel`):**
   - Tıklanabilir semptom filtre çipleri (*Yaprak Sararması*, *Beyaz Leke*, *Yaprakta Delik*, *Örümcek Ağı*, *Yapışkan Yüzey*, *Kök Kararması*) oluştur.
   - Seçilen belirtilere uyan hastalık/zararlı kartlarını aciliyet rozeti ve organik çözüm adımlarıyla birlikte listele.

## Doğrulama ve Kalite Kontrol Listesi (Verification Checklist)

Geliştirme tamamlandığında aşağıdaki maddelerin çalıştığını doğrula:

- [ ] Hatalı e-posta/şifre girişinde uyarı mesajı çıkıyor mu ve başarılı girişte `BAHÇELER` sayfasına yönlendiriyor mu?
- [ ] `Şifremi Unuttum` -> `E-posta Kontrol` -> `Yeni Şifre Gir (Yenile)` -> `BAHÇELER` zinciri eksiksiz çalışıyor mu?
- [ ] `Sera Ekle` modalında sera adı ve isteğe bağlı fotoğraf eklenip onaylandığında sera listeye düşüyor mu?
- [ ] Sağ menüdeki `Kullanım Kılavuzu ve Yardım` tıklandığında eskizdeki 3 kart (*1. Nasıl sera eklerim?*, *2. Sildiğim seraları geri getirebilir miyim?*, *3. İletişim*) görüntüleniyor mu?
- [ ] Sağ menüdeki `TR | EN` dil butonuna tıklandığında tüm arayüz metinleri Türkçe ve İngilizce arasında anında geçiş yapıyor mu?
- [ ] Sera içindeki bir bitkinin `[Detay]` butonuna tıklandığında **Ekimden Hasada Gün Sayacı**, **Renkli Uyarı Kartları (Kırmızı/Sarı/Yeşil)**, **Sulama/Güneş İhtiyacı Rehberi** ve **Zararlı/Hastalık Teşhis Rehberi** aynı ekranda sorunsuz çalışıyor mu?
- [ ] Renkli uyarı kartlarındaki `[Sulandı İşaretle]` / `[Gübrelendi İşaretle]` butonuna basıldığında kart rengi Kırmızı/Sarı'dan Yeşil'e dönüyor ve `localStorage` güncelleniyor mu?
