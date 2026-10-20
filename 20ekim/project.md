#Girişimciler için proje ve kaynak yönetimi takip uygulaması
Bu Doküman flutter projeside geliştirme yapacak olan Ajan (antigravity) yapay zeka ve yazılım geliştiriciler için bağlayıcı bir kılavuzdur. Projede üretilen her kod satırı burdaki kurallara UYMAM ZORUNDADIR.
##1.Proje Özeti ve Teknolojiler
-**Uygulama adı** Asistan(akıllı portföy ve kaynak yönetim uygulaması)
-**Temel Amaç** Girişimcilerin projelerini, parasal kaynaklarını ve bağlantılı oldukları kişileri akıllıca yönetmelerine yardımcı olmak.
-**Hedef platform** Android ve iOS öncelikli ardından web ve masaüstü platformları
-**Fluttter SDK** 3.29.0
-**Dart SDK** 3.0.0

  
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
