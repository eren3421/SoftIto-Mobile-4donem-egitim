#Fitness Su takip uygulaması
Bu Doküman flutter projeside geliştirme yapacak olan Ajan (antigravity) yapay zeka ve yazılım geliştiriciler için bağlayıcı bir kılavuzdur. Projede üretilen her kod satırı burdaki kurallara UYMAM ZORUNDADIR.
##1.Proje Özeti ve Teknolojiler
-**Uygulama adı** Susadım(akıllı su egzersiz ve kalori takibi uygulaması)
-**Hedef platform** Android ve iOS öncelikli ardından web ve masaüstü platformları
-**Fluttter SDK** 3.29.0
-**Dart SDK** 3.0.0
-**Tasarım dili** Material 3, Koyu Tema (gece spor salonu paleti, dark obsidian & neon);
#Mimari Yapı: Özellik bazlı
kodlar kesinlikle tek bir yerde toplanmayacaktır. Her modül kendi feature klasöründe kodlanacaktır.
``` text
lib/
core/
extension'lar
         constants/app_colors.dart
        theme/app_theme.dart
    features/
            water_tracker/
                controller/
                 models/
                 view/
                 widget/
            workout/
                controller/
                models/
                view/
                widget/
        main.dart
```
### sadece başlatma ve tema bölümleri 

## 3 Kırmızı çizgiler kod kalite standartları
1 - **State Yönetim Standartları**
Sayfa düzeyinde ağır 'setState' KULLANILMAYACAKTIR.
Sadece yerel arayüz durumunu yöneten (örneğin buton animasyonları vb.) statefulwidget kabul edilir.

2 - **UI ve Performans kuralları**
Statik tüm widget'larda 'const' zorunludur.
Renk ve metin stilleri kessinlikle tema dosyalarına yazılacaktır
Büyük build methodları yasaktır 40 satırı geçen build metodları özel widgetlara yazılacaktır

3 - **Yasaklı Paketler**
Projeye onay almadan harici ağır state paketleri EKLENMEYECEKTİR
Dart'ın ve Flutter'ın yerel çekirdek apilerini kullanmak esastır.

## 4 Geliştirme analiz ve test komutları
Ajan yaptığı herhangi bir kod değişikliklerinden sonra mutlaka alltaki komutların çalıştığını doğrulamalıdır.


* **Statik kod analizi(0 uyarı ve 0 hata işareti ile)**
``` bash
fluttter analyze
* **birim ve widget testleri**
```bash
flutter test 
* **Projeyi çalıştırma**
``` bash
flutter run

## 5 Ajanın çıktı ve yanıt verme standartları
**Açıklama** Türkçe teknik terimlerin özünü bozmadan net ve doğrudan olacaktır.
** Değişikllik Sunumları:** Örnek 500 satırlık bir dosayda 3 satır değiştiyse tüm dosyaları baştan sona basma; hedef satırları ve diff yapısını göster.
**Dosya yolları** Bahsedilen ve üretilen her dosya için mutlaka projeye göre tıklanabilir link ver.
**Doğrulama**: Herhangi bir kod değişikliğinde mutlaka tüm analizleri ve testleri yap.Kod yazdıktan sonra kullanıcıyı "Şimdi flutter analiz ile kontrol edebilirsin" şeklinde doğrulama yönergeleri ver
        
