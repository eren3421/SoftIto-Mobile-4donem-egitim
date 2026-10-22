# Antigravity AI Geliştirici Yetenek ve Kurallar Dosyası (SKILL.md)

Bu dosya, **MENTOR - Alışkanlık Takip Uygulaması** geliştirilirken Antigravity AI ajanının uyması gereken teknik standartları, servis kurallarını, entegrasyon kalıplarını ve kodlama prensiplerini tanımlar.

## 1. Rol ve Temel Misyon
Sen kıdemli bir **Flutter & Dart Tam Yığın (Full-Stack) Mobil Uygulama Mimarı** olarak görev yapıyorsun. Amacın; el çizimi ekran tasarımlarına (wireframe), koyu pembe tasarım sistemine (`design.md`), mimari yapıya (`architecture.md`) ve proje isterlerine (`project.md`) birebir sadık kalarak hatasız, modüler ve üretime hazır bir Flutter uygulaması inşa etmektir.

## 2. Teknoloji Yığını ve Zorunlu Paketler (`pubspec.yaml`)
Projeyi oluştururken aşağıdaki paketleri kur ve yapılandır:
- **Durum Yönetimi:** `flutter_riverpod: ^2.5.1`
- **Yerel Veritabanı & Depolama:** `hive: ^2.2.3`, `hive_flutter: ^1.1.0`, `shared_preferences: ^2.2.3`, `path_provider: ^2.1.3`
- **Ağ & API İstekleri:** `dio: ^5.4.3+1` veya `http: ^1.2.1`
- **E-posta Servisi:** `mailer: ^6.1.0` (SMTP) ve REST tabanlı EmailJS / Resend yedekli servis yapısı
- **Takvim & Grafikler:** `table_calendar: ^3.1.1`, `fl_chart: ^0.68.0`
- **PDF Oluşturma, Kaydetme ve Açma:** `pdf: ^3.10.8`, `printing: ^5.12.0`, `open_filex: ^4.4.0`
- **Bildirimler:** `flutter_local_notifications: ^17.1.2`, `timezone: ^0.9.3`
- **Yardımcı Paketler:** `intl: ^0.19.0`, `uuid: ^4.4.0`, `crypto: ^3.0.3`, `google_fonts: ^6.2.1`

## 3. Modül Bazlı Uygulama Kuralları

### 3.1. Kimlik Doğrulama ve E-posta Doğrulama Servisi (`AuthService` & `MailService`)
- **Ekran Sadakati:**
  - `Giriş Yap` ekranında: `Kullanıcı adı`, `Şifre` alanları, `Giriş Yap` butonu, altında `Kayıt Ol` ve `Şifre Değiştir` bağlantıları bulunmalıdır.
  - `Kayıt Ol` ekranında: `Kullanıcı adı`, `E-posta`, `Şifre` alanları bulunmalıdır.
  - `Şifre Yenile (1. Adım)` ekranında: `E-posta` giriş alanı ve `Doğrula` butonu yer almalıdır.
  - `Şifre Yenile (2. Adım)` ekranında: Yeni `Şifre` giriş alanı ve `Onayla` butonu yer almalıdır.
- **Doğrulama Kodu (OTP) Akışı:**
  - Kullanıcı kayıt olduğunda veya şifre yenileme ekranında e-postasını girip `Doğrula` butonuna bastığında, `MailService` 6 haneli rastgele bir doğrulama kodu üretmeli ve kullanıcının e-postasına göndermelidir.
  - SMTP/API anahtarları `.env` veya `AppConfig` üzerinden okunmalı; geliştirme/test ortamında SMTP bilgisi henüz girilmemişse konsola/ekrana güvenli bir geliştirici bilgi bildirimi (Debug OTP Banner) düşerek akışın kesintisiz test edilmesine izin vermelidir.
- **Hesap Silme (`Hesabı Sil`) ve Çıkış (`Çıkış Yap`):**
  - Sağ aksiyon menüsündeki bilgi/hesap ikonundan tetiklenir.
  - `Hesabı Sil` onaylandığında kullanıcıya ait alışkanlıklar, notlar, sohbet geçmişi, cihazdaki PDF dosyaları ve kullanıcı kaydı LocalStorage'dan tamamen silinir.

### 3.2. Yerel Depolama (LocalStorage) ve Çift Katmanlı Not Sistemi
- Tüm kullanıcı verileri, alışkanlıklar, yapılan günler (`completedDates`), notlar ve oluşturulan PDF raporlarının meta verileri **Hive** kutularında (`users_box`, `habits_box`, `notes_box`, `reports_box`, `chat_box`) saklanmalıdır.
- **Not Sistemi Kuralı:**
  - `NoteModel` içinde `String? habitId` alanı bulunur.
  - **Alışkanlık Detay Sayfasında (`Not Ekle`):** Oluşturulan notlara ilgili alışkanlığın `habitId` değeri atanır. Bu sayfada yalnızca o alışkanlığa ait notlar listelenir.
  - **Genel Alışkanlıklar Sayfasında (`Not Ekle / Notları Görüntüle - Tüm Notlar`):** Kullanıcı hem genel not (`habitId == null`) ekleyebilir hem de tüm alışkanlıklara ait notları (hangi alışkanlığa ait olduğunu belirten etiketle birlikte) tek listede görüntüleyebilir, düzenleyebilir ve silebilir.

### 3.3. Alışkanlık Takibi, Zincir (Streak) ve Takvim Kuralları
- **Genel Alışkanlıklar (`YAPILACAKLAR`) Ekranı:**
  - Her alışkanlık satırında: Günlük tek dokunuşla tamamlama onay kutusu, `Alışkanlık Adı`, aktif streak rozeti, `Görüntüle` butonu (Detay sayfasına gider) ve `Sil` butonu yer alır.
  - Alt kısımda yan yana `Rapor Oluştur` ve `Ekle` butonları bulunur.
- **Alışkanlık Detay (`ALIŞKANLIK DETAY`) Ekranı:**
  - Merkezde `Takvim (Yapılan Günleri Onayla)` bileşeni yer alır. Kullanıcı geçmiş veya bugünkü bir güne dokunarak o günü tamamlandı/tamamlanmadı olarak işaretleyebilir.
  - Takvimin yanında/altında GitHub katkı grafiği tarzı haftalık ve aylık tamamlama yüzdesi ızgarası (heatmap grid) gösterilir.
  - Alt kısımda yan yana `Raporla` ve `Geri` butonları bulunur.
- **Streak Hesaplama Algoritması:**
  - Bugün (veya dün) itibarıyla geriye doğru kesintisiz tamamlanan gün sayısı `currentStreak` olarak hesaplanır. Tarihler saat dilimi farklarından etkilenmemek için `YYYY-MM-DD` (UTC/Local normalize) formatında saklanır.

### 3.4. Hugging Face API Entegrasyonu (`HuggingFaceService`)
- **Bağlantı Yapısı:**
  - Endpoint: `https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.3` (veya `Qwen/Qwen2.5-72B-Instruct` / OpenAI uyumlu HF Router `/v1/chat/completions`).
  - İsteklerde `Authorization: Bearer <HF_API_TOKEN>` başlığı kullanılır.
- **İki Temel Görev:**
  1. **Mentor / Chatbot:**
     - Ana sayfadaki sağ menüden açıldığında kullanıcının *tüm alışkanlıklarını, genel başarı yüzdesini ve son notlarını* sistem istemine (system prompt) ekleyerek genel yaşam/alışkanlık koçluğu yapar.
     - Alışkanlık Detay sayfasındaki sağ menüden açıldığında *sadece o alışkanlığın adını, zincir süresini, tamamlama takvimini ve o alışkanlığa özel notlarını* bağlam olarak alır ve odaklanmış mentorluk verir.
  2. **PDF Raporları İçin "Uzman Görüşü" Üretimi:**
     - Kullanıcı `Rapor Oluştur` (Genel) veya `Raporla` (Alışkanlığa Özel) butonuna bastığında, istatistik verileri Hugging Face API'ye gönderilir ve Türkçe, yapıcı, bilimsel temelli 2-3 paragraflık bir **"Uzman Görüşü ve Eylem Planı"** metni üretilir.

### 3.5. Grafikli ve Uzman Görüşlü PDF Oluşturma ve Saklama (`PdfReportService`)
- **Genel Rapor (`Rapor Oluştur`):**
  - Önce ekranda `[X]` ile kapatılabilen önizleme/analiz penceresinde `Grafikler` ve `Uzman Görüşü` gösterilir, ardından PDF dosyası üretilir ve kaydedilir.
  - İçerik: Rapor tarihi, kullanıcı özeti, tüm alışkanlıkların haftalık/aylık tamamlanma oranları tablosu, görsel çubuk/yüzde grafikleri, GitHub tarzı aktivite özeti ve Hugging Face AI Uzman Görüşü.
- **Alışkanlığa Özel Rapor (`Raporla`):**
  - İçerik: Alışkanlık adı, mevcut ve en uzun zincir (streak), aylık takvim tamamlama ızgarası, haftalık/aylık grafikler, o alışkanlığa ait kullanıcı notları ve o alışkanlığa özel AI Uzman Görüşü.
- **Depolama (Storage):**
  - Üretilen her PDF dosyası `getApplicationDocumentsDirectory()` altında `/mentor_reports/` klasörüne benzersiz bir isimle (`mentor_genel_rapor_20261022.pdf` veya `mentor_aliskanlik_<id>_20261022.pdf`) kaydedilir.
  - Dosya yolu ve rapor özeti Hive içindeki `reports_box` kutusuna kaydedilir. Kullanıcı sağ menüdeki `PDF Raporları` ikonuna tıkladığında geçmiş tüm PDF'leri görüntüleyebilir, açabilir (`open_filex` / `printing`) veya silebilir.

## 4. Kod Kalitesi ve Hata Yönetimi Kuralları
1. **Boş Yer Tutucu Bırakma:** Hiçbir buton `onPressed: () {}` şeklinde boş bırakılmamalıdır. El çizimindeki her buton (`Rapor Oluştur`, `Ekle`, `Raporla`, `Geri`, sağ menüdeki 5 ikon, `İptal`, `Onayla`, `Doğrula`) eksiksiz çalışmalıdır.
2. **Türkçe Arayüz:** Tüm ekran metinleri, hata mesajları, bildirimler ve AI istemleri (prompts) akıcı ve doğru Türkçe ile yazılmalıdır.
3. **Çevrimdışı Dayanıklılık:** İnternet bağlantısı olmadığında veya Hugging Face / SMTP API anahtarı girilmediğinde uygulama çökmemeli; yerel verilerle çalışmaya devam etmeli ve anlamlı bir yerel uzman analizi / doğrulama simülasyonu sunmalıdır.
