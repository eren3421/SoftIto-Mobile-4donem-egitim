# Bahçecilik ve Sera Yönetimi (Bahçıvan) — Proje Spesifikasyonu

## 1. Proje Özeti
Evde, balkonda veya hobi/profesyonel seralarda bitki yetiştiren kullanıcıların **sera bazlı bitki envanterlerini**, **sulama, gübreleme ve budama takvimlerini**, **ekimden hasada tahmini gün sayaçlarını** ve **zararlı/hastalık teşhis süreçlerini** tek bir merkezden yönetmelerini sağlayan çok dilli (TR/EN) tarımsal rehber ve sera yönetim uygulamasıdır.

## 2. Proje Amacı
Bitkilerin ihtiyaç duyduğu kritik bakım döngülerinin (sulama, gübreleme, budama) kaçırılmasını renkli aciliyet kartları ve takvim hatırlatıcıları ile engellemek; bitki türüne özel bakım rehberi, hastalık teşhis modülü ve hasat verim günlüğü sayesinde sağlıklı ürün yetiştirme verimini yükseltmektir.

## 3. Tahmini Ekran ve Sayfa Sayısı
Uygulama, el çizimi mimari eskizlerdeki kimlik doğrulama ve sera yönetimi akışlarını temel alarak eksik olan **Bitki Detayları ve Teşhis** modülleriyle birlikte toplam **5 Ana Sayfa Grubu (10 Alt Görünüm/Modal)** içerir:

1. **Kimlik Doğrulama (Auth) Ekranları:** Kullanıcı Giriş (`Login`), Kayıt Oluştur (`Register`), Şifre Değiştir - E-posta Kontrol (`Forgot Password`), Yeni Şifre Gir (`Reset Password`)
2. **Bahçeler / Seralar Ana Ekranı (`Greenhouse List`):** Sera listesi, `Sera Ekle` (fotoğraflı modal), Sağ Aksiyon Paneli (`Not Ekle`, `Kullanım Kılavuzu ve Yardım`, `TR/EN Dil Ayarı`, `Çıkış`) ve 3 aşamalı `Genel Kullanım ve Yardım` (S.S.S. & İletişim) rehberi
3. **Sera İçi Bitki Listesi Ekranı (`Greenhouse Detail`):** Seçili seradaki bitkilerin listesi, hızlı durum rozetleri, `Bitki Ekle` modalı, `Ana Menü` dönüşü ve Sağ Aksiyon Paneli (`Not Ekle`, `Takvim ve Hatırlatıcı`, `Çıkış`)
4. **Bitki Detayları, Bakım Profili ve Teşhis Ekranı (`Plant Detail`):**
   - Ekimden hasada tahmini gün sayacı ve büyüme evresi çubuğu
   - Sulama, gübreleme ve budama için renkli uyarı kartları (Kırmızı / Sarı / Yeşil) ve tek tıkla bakım tamamlama
   - Bitki türüne göre sulama, güneş, sıcaklık ve toprak ihtiyacı rehberi
   - Zararlı böcek ve hastalık belirtisi teşhis rehberi (semptom filtreli)
   - Hasat ve verim günlüğü + bitki özel notları
5. **Bitki Bakım Takvimi ve Hatırlatıcı Ekranı (`Calendar & Alerts`):** Seradaki tüm bitkilerin yaklaşan ve geciken bakım görevlerini gösteren takvim ve bildirim merkezi

## 4. Temel Özellikler
- **Çoklu Sera ve Bahçe Yönetimi:** İsteğe bağlı fotoğraf ve isim ile birden fazla sera/bahçe oluşturma, görüntüleme ve kalıcı silme onayı.
- **Bitki Türüne Göre Sulama ve Güneş İhtiyacı Rehberi:** Hazır bitki kütüphanesinden (Domates, Biber, Çilek, Salatalık, Fesleğen, Orkide vb.) seçilen bitkinin günlük güneş saati, ışık tipi, sulama periyodu, ideal sıcaklık/nem ve budama kurallarını otomatik yükleme.
- **Sulama / Gübreleme / Budama Zamanı İçin Renkli Uyarı Kartları:** Son bakım tarihine ve bitki periyoduna göre otomatik hesaplanan **Kırmızı (Gecikti/Acil)**, **Sarı (Bugün/Yaklaşıyor)** ve **Yeşil (Güvende/Tamamlandı)** durum kartları.
- **Ekimden Hasada Tahmini Gün Sayacı:** Ekim tarihinden itibaren geçen günü, hasada kalan tahmini günü, tamamlanma yüzdesini (`%`) ve bitkinin mevcut gelişim evresini (Çimlenme, Fide, Çiçeklenme, Meyve/Hasat) gösteren dinamik sayaç.
- **Zararlı Böcek veya Hastalık Belirtisi Teşhis Rehberi:** Yaprak sararması, beyaz lekeler, yaprak delikleri, örümcek ağı gibi görsel semptomlara göre olası hastalık/zararlıyı tespit eden ve organik/kültürel mücadele yöntemleri sunan etkileşimli rehber.
- **Hasat ve Verim Günlüğü & Not Sistemi:** Hem sera genelinde hem de bitki özelinde tarihli notlar ekleme; hasat edilen ürün miktarını (kg/gram/adet) ve verim kalitesini kaydetme.
- **Çoklu Dil (TR / EN) ve Yardım Merkezi:** Sağ menü üzerinden anlık Türkçe/İngilizce dil geçişi ve 3 kartlı etkileşimli Kullanım Kılavuzu / S.S.S. modülü.

## 5. Hedef Kitle
Evde veya balkonda bitki yetiştiren hobi bahçıvanları, tarım/botanik öğrencileri ve küçük ölçekli sera yöneticileri.

## 6. Öğrenci Çalışma ve Detay Alanı

### 6.1. Kullanılacak Teknolojiler & Kütüphaneler

| Katman | Seçilen Teknoloji | Kullanım Amacı ve Gerekçesi |
| :--- | :--- | :--- |
| **Frontend Çatısı** | HTML5, Modern CSS3 (Tailwind CSS), JavaScript (ES6+ Modüler Mimari veya React + Vite) | Hızlı prototipleme, bileşen tabanlı ekran geçişleri ve mobil/masaüstü uyumlu (responsive) sera arayüzü |
| **Veri Depolama (Backend / Storage)** | `LocalStorage` + JSON Seed Veritabanı *(Opsiyonel: Supabase / Firebase)* | İnternet bağlantısı gerektirmeden seraların, bitkilerin, bakım kayıtlarının ve kullanıcı oturumunun tarayıcıda kalıcı tutulması |
| **İkon ve Görsel Kütüphanesi** | Lucide Icons / FontAwesome | Bitki, su damlası, güneş, gübre, budama makası, böcek/teşhis, takvim ve sağ menü aksiyon ikonları |
| **Tarih ve Sayaç Yönetimi** | Native `Intl.DateTimeFormat` & Özel `DateCalculator` Yardımcı Modülü | Ekim-hasat gün farkı hesaplama, sulama/gübreleme gecikme analizi ve takvim görünümü oluşturma |
| **Çoklu Dil (i18n)** | Özel `i18n` JSON Sözlük Modülü (`TR` / `EN`) | Sağ yan menüdeki `TR \| EN` dil değiştirici buton ile tüm arayüz metinlerinin anında çevrilmesi |

### 6.2. Sayfa Hiyerarşisi ve Akış Planı

- [x] **Sayfa 1 — Kimlik Doğrulama (Login / Kayıt / Şifre Sıfırlama Akışı):**
  - **1A. Kullanıcı Giriş (`Login`):** Üstte yaprak/damla logosu ve **Bahçıvan** başlığı. E-posta ve şifre giriş alanları, altında **Giriş Yap** butonu. Hatalı girişte kırmızı uyarı mesajı gösterilir. Alt kısımda **Şifremi Unuttum** ve **Kayıt Oluştur** bağlantıları yer alır. Başarılı girişte doğrudan **Bahçeler (Seralar) Ana Sayfasına** yönlendirir.
  - **1B. Kayıt Oluştur (`Register`):** E-posta ve şifre belirleme alanları ile **Kayıt Ol** butonu. Kayıt tamamlandığında kullanıcıyı otomatik giriş yaptırarak ana sayfaya veya giriş ekranına yönlendirir.
  - **1C. Şifre Değiştir - E-posta Kontrol (`Forgot Password`):** E-posta adresini doğrulama ve kontrol etme bilgilendirme ekranı; onay sonrası **Yeni Şifre Gir** ekranına aktarır.
  - **1D. Yeni Şifre Gir (`Reset Password`):** Yeni şifre giriş alanı ve **Yenile** butonu. Şifre güncellendiğinde **Bahçeler (Seralar)** ekranına yönlendirir.
- [x] **Sayfa 2 — Bahçeler / Seralar Ana Sayfası (`Greenhouse Dashboard`):**
  - Kullanıcının mevcut seralarını (`Sera Adı`, bitki sayısı, acil bakım uyarısı rozeti, **Detay** ve **Sil** butonları) listeler.
  - Alt kısımdaki **Sera Ekle** butonu ile açılan pencerede `Sera Adı` ve isteğe bağlı `Fotoğraf Ekle` alanı bulunur; **Onayla** veya **İptal X** ile işlem tamamlanır.
  - Sağ dikey aksiyon menüsünde: **Not Ekle**, **Kullanım Kılavuzu ve Yardım** (3 kartlı yatay rehber: *1. Nasıl sera eklerim?*, *2. Sildiğim seraları geri getirebilir miyim?*, *3. S.S.S. ve İletişim*), **TR | EN Dil Ayarı** ve **Çıkış** butonları yer alır.
- [x] **Sayfa 3 — Sera İçi Bitki Listesi ve Yeni Bitki Ekleme (`Greenhouse Detail & Add Plant`):**
  - Seçilen seranın adı başlıkta yazar. İçindeki bitkiler (`Bitki Adı`, anlık sulama/gübreleme renk rozeti, hasada kalan gün özeti, **Detay** ve **Sil** butonları) listelenir.
  - Alt kısımda **Ana Menü** (Bahçeler listesine döner) ve **Bitki Ekle** butonu yer alır.
  - **Bitki Ekle** tıklandığında bitki türü seçimi (hazır profil şablonlarından veya özel), ekim tarihi ve saksı/bölüm bilgisi girilerek bitki seraya eklenir.
  - Sağ dikey aksiyon menüsünde: **Not Ekle**, **Takvim ve Hatırlatıcı** ve **Çıkış** butonları bulunur.
- [x] **Sayfa 4 — Bitki Detayları, Bakım Rehberi, Renkli Uyarılar ve Hastalık Teşhis Sayfası (`Plant Detail View`):**
  - Sera içindeki bir bitkinin **Detay** butonuna tıklandığında açılır.
  - **Modül 4A (Ekimden Hasada Gün Sayacı):** Ekim tarihi, tahmini hasat tarihi, geçen/kalan gün sayacı, ilerleme yüzdesi (`%`) ve büyüme evresi rozeti.
  - **Modül 4B (Renkli Bakım Uyarı Kartları):** Sulama, Gübreleme ve Budama için Kırmızı (Gecikti), Sarı (Bugün) ve Yeşil (Zamanı Var) renkli uyarı kartları ve tek tıkla **"Tamamlandı İşaretle"** butonları.
  - **Modül 4C (Bitki Türüne Göre Sulama ve Güneş İhtiyacı Rehberi):** Günlük güneş ihtiyacı (saat/ışık türü), sulama sıklığı ve su miktarı, ideal sera sıcaklığı, nem ve toprak/budama rehberi.
  - **Modül 4D (Zararlı Böcek ve Hastalık Belirtisi Teşhis Rehberi):** Yapraktaki veya gövdedeki belirtileri seçerek olası hastalık/zararlıyı teşhis etme ve organik tedavi adımlarını görüntüleme.
- [x] **Sayfa 5 — Bitki Bakım Takvimi ve Hasat/Verim Günlüğü (`Care Calendar & Harvest Log`):**
  - Sağ menüdeki **Takvim ve Hatırlatıcı** butonundan veya Bitki Detay sayfasındaki **Hasat Günlüğü** sekmesinden erişilir.
  - Günlük/haftalık sulama, gübreleme, budama görevlerini renk kodlarıyla takvim üzerinde gösterir; hasat edilen ürünlerin miktar ve kalite geçmişini listeler.

### 6.3. Veri Modeli ve Bileşen Tasarımı

| Veri Varlığı (Entity) | Temel Alanlar (Fields) | İlişkiler ve Açıklama |
| :--- | :--- | :--- |
| `User` | `id`, `email`, `passwordHash`, `language` (`tr`/`en`), `createdAt` | Kullanıcının oturum ve dil tercihlerini tutar |
| `Greenhouse` (Sera) | `id`, `userId`, `name`, `photoUrl`, `createdAt` | Bir kullanıcının birden fazla serası olabilir; silindiğinde altındaki tüm bitkiler ve notlar silinir (Cascade Delete) |
| `PlantCatalog` (Bitki Rehberi) | `speciesId`, `nameTr`, `nameEn`, `wateringIntervalDays`, `fertilizingIntervalDays`, `pruningIntervalDays`, `sunlightHours`, `sunlightType`, `harvestDays`, `idealTemp`, `soilGuide` | Bitki türüne göre otomatik yüklenen standart sulama, güneş ve hasat profili şablonu |
| `Plant` (Ekilen Bitki) | `id`, `greenhouseId`, `speciesId`, `customName`, `plantedAt`, `lastWateredAt`, `lastFertilizedAt`, `lastPrunedAt`, `healthStatus`, `locationNote` | Seraya eklenen tekil bitki; renkli uyarı kartları ve hasat sayacı bu tarihlerden dinamik hesaplanır |
| `PestDiagnosis` (Teşhis Rehberi) | `id`, `nameTr`, `nameEn`, `type` (`pest`/`disease`), `symptoms[]`, `affectedParts[]`, `severity`, `organicSolution`, `preventionTips` | Belirti bazlı zararlı böcek ve hastalık teşhis veri tabanı |
| `HarvestAndNote` (Günlük & Not) | `id`, `greenhouseId`, `plantId` (opsiyonel), `type` (`note`/`harvest`/`care`), `title`, `content`, `harvestAmountGrams`, `qualityRating`, `createdAt` | Sağ menüdeki `Not Ekle` ve Bitki Detayındaki `Hasat ve Verim Günlüğü` kayıtlarını tutar |

### 6.4. Proje Takvimi ve Teslim Aşamaları

- **Aşama 1 (Tasarım & Wireframe — 1. Hafta):** El çizimi eskizlerin dijital UI kurallarına dönüştürülmesi, renkli uyarı kartları ve Bitki Detay sayfası yerleşiminin tamamlanması (`DESIGN.md`).
- **Aşama 2 (Temel Fonksiyonlar & Arayüz — 2. ve 3. Hafta):** Kimlik doğrulama ekranları, Bahçeler/Seralar CRUD işlemleri, Sera İçi Bitki Listesi, TR/EN dil geçişi ve 3 kartlı Yardım/SSS modülünün kodlanması.
- **Aşama 3 (Bakım Motoru, Sayaç ve Teşhis Rehberi — 4. Hafta):** Bitki Detay sayfası, ekimden hasada gün sayacı, kırmızı/sarı/yeşil sulama-gübreleme uyarı algoritması, zararlı/hastalık teşhis rehberi ve takvim görünümünün entegrasyonu.
- **Aşama 4 (Test & Final Teslim — 5. Hafta):** Hatalı giriş kontrolleri, sera silme geri döndürülemezlik uyarı testleri, veri kalıcılığı (`LocalStorage`) doğrulaması ve proje sunumu.

### 6.5. Notlar & Karşılaşılan Zorluklar

- **Sera Silme Veri Güvenliği:** Eskizdeki Yardım Kartı 2'de belirtildiği üzere, bir sera silindiğinde içindeki tüm bitki, takvim ve not verileri kalıcı olarak silinmektedir. Kullanıcının yanlışlıkla veri kaybetmemesi için `Sil` butonuna tıklandığında açık uyarı içeren bir onay penceresi (`Modal`) zorunlu kılınmıştır.
- **Dinamik Bakım Tarihi Hesaplama:** Sabit bildirimler yerine, kullanıcının "Sulandı" veya "Gübrelendi" butonuna bastığı andan itibaren bir sonraki bakım tarihini bitki türünün periyoduna göre otomatik yeniden hesaplayan tarih motoru tasarlanmıştır.
- **Eksik Bitki Detay Sayfasının Mimariye Uyumu:** El çizimi akışta `Sera Adı` ekranındaki `Bitki Adı -> Detay` butonunun açacağı ekran boş bırakılmıştı; bu ekran proje özetindeki 4 temel özelliği (Sulama/Güneş rehberi, Renkli uyarı kartları, Hasat gün sayacı, Zararlı/Hastalık teşhis rehberi) tek bir sekme/kart yapısında birleştirecek şekilde mimariye bağlanmıştır.
