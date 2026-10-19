# Dijital Günlük (Defterim) Uygulaması — Proje Anayasası

Bu doküman, Flutter projesinde geliştirme yapacak olan **Antigravity** yapay zeka ajanı ve yazılım geliştiriciler için bağlayıcı bir kılavuzdur. Projede üretilen her kod satırı buradaki kurallara **KESİNLİKLE UYMAK ZORUNDADIR**.

## 1. Proje Özeti ve Teknolojiler

* **Uygulama Adı:** Defterim (Gerçek defter hissiyatlı dijital günlük, anı ve duygu durumu takip uygulaması)
* **Temel Konsept:** Fiziksel bir çizgili/noktalı deftere günlük yazma deneyimini dijital ortama taşıyan; tarih bazlı sayfa çevirme, günlük başlığı ve metni yazma, duygu durumu (mood) seçme ve özel anıları favorilere ekleme özelliklerine sahip kişisel günlük uygulaması.
* **Hedef Platform:** Android ve iOS öncelikli, ardından Web ve Masaüstü platformları
* **Flutter SDK:** 3.29.0
* **Dart SDK:** 3.0.0
* **Tasarım Dili:** Material 3, Gerçek Defter Dokulu Çift Tema Desteği:
  * **Aydınlık Mod (Klasik Defter Paleti):** Sıcak fildişi/krem kağıt arka planı (`#FAF6F0`), dolma kalem laciverti/koyu kahve mürekkep metinler (`#2C221E`), eskitme deri cilt kahvesi (`#8B5A2B`) ve altın ayraç vurguları (`#D4AF37`).
  * **Koyu Mod (Gece Okuma & Deri Kapak Paleti):** Koyu eskitme deri/gece karbonu arka plan (`#181512`), göz yormayan yumuşak parşömen metinler (`#E6DEC8`), sıcak kehribar/amber vurguları (`#E09F3E`).

## 2. Mimari Yapı: Özellik Bazlı (Feature-First)

Kodlar kesinlikle tek bir dosyada veya klasörde toplanmayacaktır. Her modül kendi `feature` klasöründe, katmanlarına ayrılmış olarak kodlanacaktır.

```text
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart
│   └── theme/
│       ├── app_theme.dart
│       └── theme_controller.dart
├── features/
│   ├── diary/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── views/
│   │   └── widgets/
│   └── mood_tracker/
│       ├── controllers/
│       ├── models/
│       ├── views/
│       └── widgets/
└── main.dart
```

* **`lib/main.dart` Kuralı:** `main.dart` dosyasında yalnızca uygulama başlatma (`runApp`), `ThemeController` dinlemesi ve başlangıç ekranı yönlendirmesi yer alacaktır. İçerisine iş mantığı veya ekran tasarımı yazılması yasaktır.
* **`lib/core/` Kuralı:** Uygulama genelinde kullanılan kağıt/mürekkep renk sabitleri, tipografi tanımları ve tema kontrolcüsü yalnızca bu klasörde tutulacaktır.

## 3. Kırmızı Çizgiler ve Kod Kalite Standartları

### 1 - State Yönetim Standartları
* Sayfa düzeyinde ağır ve tüm ekranı yeniden çizen `setState` **KULLANILMAYACAKTIR**.
* Durum yönetimi için Flutter'ın yerleşik `ValueNotifier` ve `ValueListenableBuilder` yapıları kullanılacaktır.
* Sadece yerel arayüz durumunu ve animasyonlarını yöneten (örneğin sayfa çevirme animasyonu, `TextEditingController` odak yönetimi vb.) küçük `StatefulWidget` yapılarına izin verilir.

### 2 - UI ve Performans Kuralları
* Statik olan tüm widget'larda `const` anahtar kelimesi **zorunludur**.
* Renk, gölge, kenarlık ve metin stilleri (defter satır çizgileri, başlık ve tarih font stilleri) kesinlikle widget içine sabit (hardcoded) yazılmayacak; `app_colors.dart` ve `app_theme.dart` dosyalarından çekilecektir.
* Büyük `build` metotları yasaktır. **40 satırı geçen `build` metotları**, `widgets/` klasörü altında özel alt widget'lara (örneğin `DiaryPageCard`, `LinedPaperBackground`, `MoodSelectorBar`) bölünecektir.

### 3 - Yasaklı Paketler
* Projeye kullanıcıdan açık onay alınmadan harici ağır state yönetimi paketleri (`Provider`, `Riverpod`, `Bloc`, `GetX` vb.) veya üçüncü parti UI paketleri **EKLENMEYECEKTİR**.
* Dart'ın ve Flutter'ın yerel çekirdek API'lerini (`flutter/foundation.dart`, `flutter/material.dart`) kullanmak esastır.

## 4. Geliştirme, Analiz ve Test Komutları

Ajan, yaptığı herhangi bir kod değişikliğinden sonra mutlaka aşağıdaki komutların hatasız çalıştığını doğrulamalıdır:

* **Statik Kod Analizi (0 uyarı ve 0 hata ile geçmelidir):**
```bash
flutter analyze
```

* **Birim ve Widget Testleri:**
```bash
flutter test
```

* **Projeyi Çalıştırma:**
```bash
flutter run
```

## 5. Ajanın Çıktı ve Yanıt Verme Standartları

* **Açıklama Dili:** Tüm yanıtlar Türkçe olacak; teknik terimlerin (Widget, Controller, ValueNotifier, Immutable vb.) özünü bozmadan net, anlaşılır ve doğrudan bir dil kullanılacaktır.
* **Değişiklik Sunumları:** Örneğin 300 satırlık bir dosyada 5 satır değiştiyse tüm dosyayı baştan sona yazdırma; yalnızca hedef satırları ve `diff` (fark) yapısını göster.
* **Dosya Yolları:** Bahsedilen, düzenlenen ve üretilen her dosya için mutlaka proje kök dizinine göre tıklanabilir bağlantı (örn. `lib/features/diary/views/diary_view.dart`) ver.
* **Doğrulama Yönergesi:** Herhangi bir kod değişikliğinde tüm analiz ve test kurallarına uyulduğunu kontrol et. Kod yazdıktan sonra kullanıcıya *"Şimdi `flutter analyze` ve `flutter test` komutları ile kontrol edebilirsin."* şeklinde doğrulama yönergesi sun.
