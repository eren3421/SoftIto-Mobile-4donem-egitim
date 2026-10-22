# MENTOR - Sistem ve Yazılım Mimarisi (ARCHITECTURE.md)

Bu doküman, **MENTOR Alışkanlık Takip Uygulaması**'nın klasör yapısını, katmanlı mimarisini, veri modellerini, yerel depolama (LocalStorage) şemasını ve dış servis (Mail, Hugging Face API, PDF Engine) bağlantılarını tanımlar.

## 1. Mimari Yaklaşım
Uygulama, **Feature-First Clean Architecture (Özellik Odaklı Temiz Mimari)** ve **Riverpod** durum yönetimi desenini kullanır. Veri akışı tek yönlüdür:
`UI (Screens & Widgets)` ➔ `State Notifiers / Controllers (Riverpod)` ➔ `Repositories` ➔ `Services (Hive LocalStorage / Hugging Face API / Mail Service / PDF Service)`.

## 2. Proje Klasör Yapısı (`lib/`)
```text
lib/
├── main.dart
├── core/
│   ├── config/
│   │   └── app_config.dart          # API anahtarları (HF Token, SMTP/EmailJS ayarları)
│   ├── theme/
│   │   ├── app_colors.dart          # Koyu Pembe (Dark Pink) renk sabitleri
│   │   └── app_theme.dart           # Material 3 ThemeData yapılandırması
│   ├── utils/
│   │   ├── date_utils.dart          # Streak hesaplama ve YYYY-MM-DD yardımcıları
│   │   └── validators.dart          # E-posta, kullanıcı adı ve şifre doğrulayıcılar
│   └── widgets/
│       ├── right_action_sidebar.dart # El çizimindeki 5 ikonlu sağ dikey menü
│       └── custom_Pink_button.dart   # Standart koyu pembe buton bileşeni
├── data/
│   ├── local/
│   │   └── hive_storage_service.dart # Hive kutularının başlatılması ve CRUD işlemleri
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── habit_model.dart
│   │   ├── note_model.dart
│   │   ├── pdf_report_model.dart
│   │   └── chat_message_model.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── habit_repository.dart
│   │   ├── note_repository.dart
│   │   └── report_repository.dart
│   └── services/
│       ├── mail_service.dart         # E-posta doğrulama kodu (OTP) gönderim servisi
│       ├── huggingface_service.dart  # Mentor Chatbot & PDF Uzman Görüşü AI servisi
│       ├── pdf_generator_service.dart# Grafikli ve uzman görüşlü PDF üretim/kayıt servisi
│       └── notification_service.dart # Yerel hatırlatma bildirimleri servisi
└── features/
    ├── auth/
    │   ├── login_screen.dart                 # Giriş Yap ekranı
    │   ├── register_screen.dart              # Kayıt Ol ekranı
    │   ├── forgot_password_email_screen.dart # Şifre Yenile - E-postanı Gir
    │   └── reset_password_screen.dart        # Şifre Yenile - Yeni Şifre Onayla
    ├── habits/
    │   ├── home_habits_screen.dart           # YAPILACAKLAR (Ana Sayfa)
    │   ├── habit_detail_screen.dart          # ALIŞKANLIK DETAY (Takvim & Analiz)
    │   └── widgets/
    │       ├── add_habit_dialog.dart         # Alışkanlık 1 [İptal] [Onayla] modalı
    │       ├── streak_calendar_widget.dart   # Yapılan günleri onaylama takvimi
    │       └── github_heatmap_grid.dart      # Haftalık/aylık tamamlama yüzdesi ızgarası
    ├── notes/
    │   └── notes_modal_sheet.dart            # Genel (Tüm Notlar) ve Alışkanlığa Özel Notlar
    ├── mentor/
    │   └── mentor_chat_screen.dart           # Hugging Face destekli AI Mentor sohbet ekranı
    ├── reports/
    │   ├── report_preview_dialog.dart        # Grafikler + Uzman Görüşü + PDF Oluştur/Sakla
    │   └── pdf_archive_modal.dart            # Saklanan PDF raporlarını görüntüleme/açma
    └── settings/
        └── legal_and_account_dialog.dart     # Gizlilik Politikası, S.S.S., İletişim, Hesap Sil
```

## 3. Veri Modelleri ve Yerel Depolama (LocalStorage) Şeması

Uygulama çevrimdışı çalışabilirlik için **Hive** NoSQL yerel veritabanını ve cihaz dosya sistemini (`path_provider`) kullanır.

### 3.1. `UserModel` (`users_box` & `session_box`)
```dart
class UserModel {
  final String id;
  final String username;
  final String email;
  final String passwordHash; // SHA-256
  final bool isVerified;
  final DateTime createdAt;
}
```
- `session_box`: Aktif oturum açmış kullanıcının `currentUserId` bilgisini ve bekleyen e-posta doğrulama kodlarını (`pending_otp_<email>`) tutar.

### 3.2. `HabitModel` (`habits_box`)
```dart
class HabitModel {
  final String id;
  final String userId;
  final String title;                  // Örn: "Kitap Okuma", "Su İçme"
  final List<String> completedDates;   // ["2026-10-20", "2026-10-21", "2026-10-22"]
  final String? reminderTime;          // Örn: "20:30"
  final DateTime createdAt;

  // Hesaplanan Özellikler (Computed Getters):
  int get currentStreak;               // Kesintisiz aktif gün sayısı
  int get longestStreak;               // En uzun seri
  double get weeklyCompletionRate;     // Son 7 gün tamamlama oranı (0.0 - 1.0)
  double get monthlyCompletionRate;    // Son 30 gün tamamlama oranı (0.0 - 1.0)
}
```

### 3.3. `NoteModel` (`notes_box`)
```dart
class NoteModel {
  final String id;
  final String userId;
  final String? habitId;   // null = Genel Not, dolu = Alışkanlığa Özel Not
  final String? habitName; // Tüm Notlar ekranında rozet olarak göstermek için
  final String content;
  final DateTime createdAt;
}
```
- **Sorgu Mantığı:**
  - *Alışkanlık Detay Sayfası:* `notesBox.values.where((n) => n.userId == uid && n.habitId == currentHabitId)`
  - *Genel Alışkanlıklar Sayfası (Tüm Notlar):* `notesBox.values.where((n) => n.userId == uid)` (Hem genel notları hem de tüm alışkanlıkların özel notlarını kronolojik olarak getirir).

### 3.4. `PdfReportModel` (`reports_box` + File System)
```dart
class PdfReportModel {
  final String id;
  final String userId;
  final String? habitId;       // null = Genel Rapor, dolu = Alışkanlığa Özel Rapor
  final String title;          // Örn: "Genel Değerlendirme Raporu - 22.10.2026"
  final String filePath;       // "/data/.../app_flutter/mentor_reports/report_123.pdf"
  final String expertOpinion;  // Hugging Face API'den gelen uzman görüşü metni
  final double completionRate; // Rapor anındaki başarı yüzdesi
  final DateTime createdAt;
}
```

## 4. Dış Servis ve API Entegrasyon Mimarisi

### 4.1. E-posta Doğrulama Servisi (`MailService`)
- **Kullanım Noktaları:**
  1. `Kayıt Ol` ekranında hesap oluşturulduğunda e-posta doğrulaması için.
  2. `Şifre Yenile - E-postanı Gir` ekranında `Doğrula` butonuna basıldığında.
- **Teknik Akış:**
  1. `generateOtp()` ile 6 haneli kod üretilir ve 5 dakika geçerlilik süresiyle `session_box` içine kaydedilir.
  2. `mailer` paketi (Gmail/ Özel SMTP) veya EmailJS REST API (`https://api.emailjs.com/api/v1.0/email/send`) üzerinden koyu pembe HTML şablonlu doğrulama e-postası gönderilir.
  3. Kullanıcı kodu doğruladığında `ResetPasswordScreen` ekranına yönlendirilir ve yeni şifresini `Onayla` butonu ile kaydeder.

### 4.2. Hugging Face API Servisi (`HuggingFaceService`)
- **Temel Yapılandırma:**
  - URL: `https://router.huggingface.co/hf-inference/models/mistralai/Mistral-7B-Instruct-v0.3/v1/chat/completions`
  - Header: `Authorization: Bearer ${AppConfig.huggingFaceToken}`, `Content-Type: application/json`
- **Mod 1: Mentor / Chatbot (`sendMessage`)**
  - Sistem İstem Şablonu:
    > *"Sen MENTOR uygulamasının empatik, motive edici ve disiplinli alışkanlık koçusun. Kullanıcının mevcut alışkanlık verileri: {habitContext}. Kullanıcının notları: {notesContext}. Kısa, uygulanabilir ve Türkçe yanıtlar ver."*
- **Mod 2: PDF Uzman Görüşü Üretici (`generateExpertEvaluation`)**
  - Sistem İstem Şablonu:
    > *"Sen davranış bilimleri ve alışkanlık kazanımı uzmanısın. Aşağıdaki alışkanlık tamamlama verilerini analiz et ve PDF raporuna basılmak üzere; 1) Mevcut Durum Analizi, 2) Güçlü Yönler, 3) Zinciri Kırmamak İçin 3 Somut Tavsiye başlıklarında Türkçe uzman görüşü yaz."*

### 4.3. PDF Oluşturma ve Depolama Motoru (`PdfGeneratorService`)
1. **Veri Toplama:** İlgili alışkanlığın (veya tüm alışkanlıkların) son 7 ve 30 günlük tamamlanma yüzdeleri, aktif ve en uzun zincir (streak) sayıları ve notları toplanır.
2. **AI Uzman Görüşü Alma:** `HuggingFaceService.generateExpertEvaluation()` çağrılarak uzman değerlendirmesi alınır.
3. **Ekranda Önizleme Modalı:** Kullanıcının el çiziminde belirttiği gibi önce ekranda `[X]` kapatma butonlu önizleme kartında `Grafikler` ve `Uzman Görüşü` gösterilir.
4. **PDF Çizimi (`pdf/widgets.dart`):**
   - Koyu pembe başlık bandı (`#AD1457`), MENTOR logosu ve tarih.
   - İstatistik özet kartları (Toplam Alışkanlık, Aktif Zincir, Haftalık/Aylık Başarı %).
   - Vektörel çubuk grafikler (haftalık/aylık tamamlama oranları) ve 30 günlük takvim ızgarası.
   - "Uzman Görüşü (AI Değerlendirmesi)" özel çerçeveli metin alanı.
   - Alışkanlığa ait son notlar tablosu.
5. **Yerel Kayıt:** `Directory('${appDocDir.path}/mentor_reports')` içine `.pdf` olarak yazılır ve `reports_box` içine `PdfReportModel` kaydı eklenir.

## 5. Ekranlar Arası Navigasyon Akışı
```text
[Giriş Yap] ──(Kayıt Ol)──> [Kayıt Ol] ──(Mail Doğrulama)──> [YAPILACAKLAR (Ana Sayfa)]
    │                                                                │
    └──(Şifre Değiştir)──> [Şifre Yenile: E-posta Gir & Doğrula]     ├──(Ekle)──> [Alışkanlık Ekle Modalı]
                                      │                              ├──(Rapor Oluştur)──> [Genel Grafik & Uzman Görüşü PDF Modalı]
                                 (OTP Onayı)                         ├──(Sağ Menü İkonları)──> [Bildirim / Tüm Notlar / Mentor / Gizlilik / Hesap Sil]
                                      ▼                              └──(Görüntüle)──> [ALIŞKANLIK DETAY (Takvim)]
                           [Şifre Yenile: Yeni Şifre Onayla]                                 │
                                                                                             ├──(Takvim Hücresi Tıkla)──> [Günü Onayla / Streak Güncelle]
                                                                                             ├──(Raporla)──> [Alışkanlığa Özel Grafik & Uzman PDF]
                                                                                             ├──(Sağ Menü İkonları)──> [Özel Not / Özel Mentor / PDF Raporları]
                                                                                             └──(Geri)──> [YAPILACAKLAR (Ana Sayfa)]
```
