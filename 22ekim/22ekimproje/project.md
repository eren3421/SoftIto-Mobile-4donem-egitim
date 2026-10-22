# MENTOR - Alışkanlık Takibi (Habit Tracker) Proje Dokümanı

## 1. Proje Özeti
**MENTOR**, kullanıcıların günlük yeni pozitif alışkanlıklar kazanmasını (kitap okuma, su içme, spor, ders çalışma vb.) ve zinciri kırmadan (streak) devam ettirmesini sağlayan, yapay zeka destekli (Hugging Face API) bir **Flutter** mobil/çoklu platform uygulamasıdır. Uygulama; kullanıcı kimlik doğrulama ve e-posta doğrulama servisi, yerel veri depolama (LocalStorage), alışkanlık bazlı ve genel not yönetimi, AI Mentor/Chatbot koçluğu ve içinde uzman görüşü ile grafiklerin yer aldığı indirilebilir/saklanabilir PDF raporlama sistemini tek bir çatı altında sunar.

## 2. Proje Amacı
Mikro alışkanlıklar yoluyla kişisel gelişimi desteklemek, motivasyon serisi (streak) sistemiyle devamlılık sağlamak ve yapay zeka destekli analiz/uzman görüşü raporlarıyla (PDF) kullanıcının öz farkındalığını artırmak.

## 3. Ekran ve Sayfa Sayısı
Toplam **6 Ana Ekran** ve **5 Yardımcı Modal / Alt Görünüm**:
1. **Giriş Yap (Login) Ekranı**
2. **Kayıt Ol (Register) Ekranı**
3. **Şifre Yenile - E-posta Doğrulama Ekranı (Adım 1)**
4. **Şifre Yenile - Yeni Şifre Belirleme Ekranı (Adım 2)**
5. **Yapılacaklar / Genel Alışkanlıklar (Ana Sayfa) Ekranı**
6. **Alışkanlık Detay ve Takvim Ekranı**
- **Yardımcı Modallar:** Alışkanlık Ekle/Düzenle Modalı, Genel/Özel Notlar Paneli, AI Mentor/Chatbot Sohbet Ekranı, Genel & Özel PDF Rapor Önizleme/Arşiv Modalı, Bilgi & Yasal Metinler (Gizlilik Politikası, S.S.S., İletişim, Hesap Silme) Modalı.

## 4. Temel Özellikler
- **Kimlik Doğrulama & E-posta Doğrulama Servisi:** Kullanıcı adı, e-posta ve şifre ile kayıt olma; kayıt ve şifre sıfırlama aşamalarında e-posta adresine doğrulama kodu (OTP) gönderen mail servisi entegrasyonu.
- **Günlük Tek Dokunuşla Tamamlama Kontrolü:** Ana ekranda ve alışkanlık detay takviminde yapılan günleri tek dokunuşla onaylama.
- **Aktif Zincir (Streak) Sayacı & Takvim Görünümü:** Alışkanlığın kaç gündür aralıksız yapıldığını takip eden sayaç ve etkileşimli takvim.
- **Haftalık ve Aylık Tamamlama Yüzdesi Izgarası:** GitHub katkı grafiği (heatmap) tarzı görsel tamamlama ızgarası ve istatistik grafikleri.
- **Çift Katmanlı Not Sistemi (LocalStorage):**
  - *Alışkanlık Detay Sayfası:* Sadece ilgili alışkanlığa özel not ekleme ve görüntüleme.
  - *Genel Alışkanlıklar Sayfası:* Hem genel notları hem de tüm alışkanlıklara ait notları tek merkezden görüntüleme ve yeni not ekleme.
- **Hugging Face API Destekli AI Mentor / Chatbot:** Kullanıcının genel ilerlemesine veya seçili alışkanlığına özel tavsiye veren, sorularını yanıtlayan ve motivasyon sağlayan yapay zeka sohbet asistanı.
- **AI Uzman Görüşlü & Grafikli PDF Raporlama ve Depolama Sistemi:**
  - *Genel Değerlendirme PDF'i:* Ana sayfada tüm alışkanlıkların grafiklerini, tamamlama yüzdelerini ve Hugging Face API tarafından üretilen genel uzman görüşünü içeren PDF oluşturma ve cihazda saklama.
  - *Alışkanlığa Özel PDF:* Detay sayfasında ilgili alışkanlığın takvim/zincir istatistiklerini, grafiklerini, notlarını ve AI uzman değerlendirmesini içeren PDF oluşturma, saklama ve geçmiş PDF raporlarını listeleme.
- **Kişiselleştirilebilir Hatırlatma Bildirimleri:** Genel ve alışkanlık bazlı yerel bildirimler (Local Notifications).
- **Hesap ve Gizlilik Yönetimi:** Gizlilik Politikası, S.S.S., İletişim bilgileri, Çıkış Yapma ve tüm yerel verileri temizleyen Hesabı Silme özelliği.

## 5. Hedef Kitle
Günlük rutinlerini düzene sokmak isteyen genel kullanıcılar, sınav/ders takibi yapan öğrenciler ve iş/üretkenlik alışkanlıklarını ölçümlemek isteyen profesyoneller.

## 6. Öğrenci Çalışma ve Detay Alanı

### 6.1. Kullanılacak Teknolojiler & Kütüphaneler
| Katman / Alan | Seçilen Teknoloji & Paketler | Kullanım Amacı |
| :--- | :--- | :--- |
| **Frontend Framework** | Flutter (Dart 3.x), Material 3 | Çoklu platform arayüz geliştirme ve Koyu Pembe (Deep Rose) özel tema |
| **Durum Yönetimi (State)** | `flutter_riverpod` veya `provider` | Alışkanlık, not, oturum ve AI sohbet durumlarının reaktif yönetimi |
| **Yerel Veri Depolama (LocalStorage)** | `hive`, `hive_flutter`, `shared_preferences`, `path_provider` | Kullanıcılar, alışkanlıklar, günlük kayıtlar, genel/özel notlar ve PDF dosya yollarının çevrimdışı saklanması |
| **Mail & Doğrulama Servisi** | `mailer` (SMTP) veya `http` üzerinden EmailJS / Resend REST API | Kayıt ve şifre sıfırlama adımlarında e-postaya 6 haneli doğrulama kodu (OTP) gönderimi |
| **Yapay Zeka (Mentor & Uzman Görüşü)** | `http` / `dio` + **Hugging Face Inference API** (`Mistral-7B-Instruct` / `Qwen2.5-72B-Instruct`) | Chatbot sohbeti ve PDF raporları için veri odaklı "Uzman Görüşü" metni üretimi |
| **PDF Oluşturma & Saklama** | `pdf`, `printing`, `open_filex` | İçinde grafikler ve AI uzman görüşü bulunan A4 PDF raporlarının oluşturulması, yerel dizine kaydedilmesi ve görüntülenmesi |
| **Grafik & Takvim Görselleştirme** | `fl_chart`, `table_calendar`, özel Heatmap Grid Widget | Haftalık/aylık başarı grafikleri, GitHub tarzı katkı ızgarası ve yapılan günleri onaylama takvimi |
| **Bildirim Sistemi** | `flutter_local_notifications`, `timezone` | Alışkanlık bazlı ve günlük hatırlatma bildirimleri |
| **Güvenlik & Yardımcılar** | `crypto`, `uuid`, `intl` | Şifre özetleme (SHA-256), benzersiz ID üretimi ve Türkçe tarih formatlama |

### 6.2. Sayfa Hiyerarşisi ve Akış Planı
- [x] **Sayfa 1: Kimlik Doğrulama Akışı (`AuthFlow`)**
  - **1A - Giriş Yap (`LoginScreen`):** Kullanıcı adı ve şifre girişi, "Giriş Yap" butonu, "Kayıt Ol" ve "Şifre Değiştir" yönlendirmeleri.
  - **1B - Kayıt Ol (`RegisterScreen`):** Kullanıcı adı, e-posta ve şifre girişi; kayıt sonrası e-posta doğrulama kodu kontrolü.
  - **1C - Şifre Yenile - E-posta Gir (`ForgotPasswordEmailScreen`):** E-posta girişi ve "Doğrula" butonu ile mail servisinden doğrulama kodu gönderimi.
  - **1D - Şifre Yenile - Yeni Şifre (`ResetPasswordScreen`):** Doğrulama sonrası yeni şifre girişi ve "Onayla" butonu.
- [x] **Sayfa 2: Yapılacaklar / Genel Alışkanlıklar Ana Sayfası (`HomeHabitsScreen`)**
  - **Sol/Ana Panel:** Günlük alışkanlıklar listesi (Alışkanlık Adı, tek dokunuşla onay, `Görüntüle`, `Sil`), alt barda `Rapor Oluştur` ve `Ekle` butonları.
  - **Sağ İkon Menüsü:** Bildirimler, Not Ekle / Tüm Notları Görüntüle, Mentor / Chatbot, Gizlilik Politikası / S.S.S. / İletişim, Hesabı Sil / Çıkış Yap.
  - **Alışkanlık Ekle Modalı:** Alışkanlık adı, hedef/kategori girişi, `İptal` ve `Onayla` butonları.
  - **Genel Grafik & AI Uzman Raporu Modalı:** Tüm alışkanlıkların grafikleri, AI Uzman Görüşü ve PDF olarak oluşturup saklama aksiyonu.
- [x] **Sayfa 3: Alışkanlık Detay Sayfası (`HabitDetailScreen`)**
  - **Sol/Ana Panel:** Alışkanlık başlığı, aktif zincir (streak) sayacı, GitHub tarzı tamamlama ızgarası, etkileşimli `Takvim (Yapılan Günleri Onayla)` bileşeni, alt barda `Raporla` ve `Geri` butonları.
  - **Sağ İkon Menüsü:** Alışkanlık Bildirimleri, Alışkanlığa Özel Not Ekle/Görüntüle, Alışkanlığa Özel Mentor, Kayıtlı PDF Raporları, Hesabı Sil / Çıkış Yap.
- [x] **Sayfa 4: AI Mentor / Chatbot & PDF Rapor Arşivi Görünümleri (`MentorChatSheet` & `PdfArchiveModal`)**
  - Genel veya alışkanlık bağlamlı Hugging Face AI sohbet ekranı ve üretilen tüm PDF raporlarının (`Genel` ve `Alışkanlığa Özel`) listelenip açılabildiği yerel arşiv ekranı.

### 6.3. Veri Modeli ve Bileşen Tasarımı
Uygulama çevrimdışı öncelikli (offline-first) **Hive / LocalStorage** kutuları (boxes) üzerinde aşağıdaki 5 temel veri modelini kullanır:
1. **`UserModel` (`users_box`):** `id`, `username`, `email`, `passwordHash`, `isEmailVerified`, `createdAt`.
2. **`HabitModel` (`habits_box`):** `id`, `userId`, `title`, `description`, `completedDates` (`List<String>` - `YYYY-MM-DD`), `currentStreak`, `longestStreak`, `reminderTime`, `createdAt`.
3. **`NoteModel` (`notes_box`):** `id`, `userId`, `habitId` (`null` ise genel not, dolu ise ilgili alışkanlığa özel not; genel notlar ekranında her ikisi de listelenir), `title`, `content`, `createdAt`.
4. **`PdfReportModel` (`reports_box`):** `id`, `userId`, `habitId` (`null` ise genel değerlendirme raporu, dolu ise alışkanlığa özel rapor), `title`, `filePath` (cihaz içi `.pdf` dosya yolu), `aiExpertSummary`, `completionRate`, `createdAt`.
5. **`ChatMessageModel` (`chat_box`):** `id`, `userId`, `habitId` (opsiyonel bağlam), `isUser`, `message`, `timestamp`.

### 6.4. Proje Takvimi ve Teslim Aşamaları
- **Aşama 1 (Tasarım & Wireframe - 1. Hafta):** El çizimi wireframe'lerin Flutter widget ağacına aktarılması, Koyu Pembe (`#C2185B` / `#FF4081` / `#140A10`) tema sisteminin (`AppTheme`) ve yerel depolama (`Hive`) şemalarının kurulması.
- **Aşama 2 (Temel Fonksiyonlar & Arayüz - 2. Hafta):** Giriş, Kayıt, E-posta doğrulamalı Şifre Yenileme akışlarının, Ana Sayfa (`YAPILACAKLAR`), Alışkanlık Detay (`Takvim`), sağ dikey aksiyon menüsü ve çift katmanlı Not sisteminin kodlanması.
- **Aşama 3 (AI, Mail & PDF Entegrasyonu - 3. Hafta):** Hugging Face API ile Mentor Chatbot ve Uzman Görüşü servisinin bağlanması, SMTP/EmailJS doğrulama maili entegrasyonu, `fl_chart` + `pdf` kütüphaneleriyle grafikli PDF üretimi ve yerel dosya sistemine kaydedilmesi.
- **Aşama 4 (Test & Final Teslim - 4. Hafta):** Zincir (streak) algoritması uç durum testleri, çevrimdışı veri kalıcılığı kontrolü, bildirim testleri, Gizlilik Politikası/S.S.S./Hesap Silme akışlarının doğrulanması ve final paketleme.

### 6.5. Notlar & Karşılaşılan Zorluklar ve Çözüm Yolları
- **Not Senkronizasyonu:** Alışkanlık detay sayfasında eklenen notların (`habitId != null`) hem o alışkanlığın detayında hem de ana sayfadaki "Tüm Notlar" ekranında görünmesi için `NoteRepository` içinde birleşik sorgu (`getAllNotesForUser` ve `getNotesByHabit`) tasarlandı.
- **PDF İçinde Grafik Render Etme:** Flutter'ın ekran widget'ları doğrudan PDF'e basılamadığı için, `pdf` paketinin kendi vektörel çizim API'leri (`pw.Chart`, `pw.Container`, özel ilerleme çubukları) veya `RepaintBoundary` üzerinden alınan grafik görüntüsü (`Uint8List`) kullanılarak PDF içinde yüksek çözünürlüklü grafikler ve AI uzman görüşü kutuları oluşturuldu.
- **Hugging Face API Yanıt Süresi ve Yedekleme:** Ücretsiz/serverless Hugging Face Inference uç noktalarında model soğuk başlatma (cold start) gecikmelerine karşı yükleme animasyonu (shimmer/typing indicator) ve zaman aşımı durumunda yerel kural tabanlı yedek uzman değerlendirmesi (fallback) eklendi.
