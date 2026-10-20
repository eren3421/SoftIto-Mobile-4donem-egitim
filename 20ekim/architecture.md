#Girişimciler için proje ve kaynak yönetimi takip uygulaması
Bu Doküman flutter projeside geliştirme yapacak olan Ajan (antigravity) yapay zeka ve yazılım geliştiriciler için bağlayıcı bir kılavuzdur. Projede üretilen her kod satırı burdaki kurallara UYMAM ZORUNDADIR.
##1.Proje Özeti ve Teknolojiler
-**Uygulama adı** Asistan(akıllı portföy ve kaynak yönetim uygulaması)
-**Temel Amaç** Girişimcilerin projelerini, parasal kaynaklarını ve bağlantılı oldukları kişileri akıllıca yönetmelerine yardımcı olmak.
-**Hedef platform** Android ve iOS öncelikli ardından web ve masaüstü platformları
-**Fluttter SDK** 3.29.0
-**Dart SDK** 3.0.0
* ** Kod Düzeni ve Mimari**
```text
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart
│   └── theme/
│       ├── app_theme.dart
│       └── theme_controller.dart
├── features/
│   ├── tablo/
│   │   ├── controllers/
│   │   ├── models/
│   |    ├── views/
│   |    └── widgets/
│   └── notlar/
│   |    ├── controllers/
│   |   ├── models/
│   |   ├── views/
│   |    └── widgets/
│   └── kişiler/
│        ├── controllers/
│        ├── models/
│        ├── views/
│        └── widgets/
│   
└── main.dart
``` 
bu yapıyı baz alarak tablo, şema ve diğer aklıma gelmeyen özellikleri ve her proje için ayrı paydaşlar, müşteriler,bütçe, kaynak yönetimi, tablolar, not defteri raporlar ve genel kullanım için de ayrı not alma, tablolar, takvimli randevu, ve saat gösterecek şekilde kişiler, ve bu kişilerle sohbet ve genel sohbet amaçlı video meeting özelliklerini bu klasör yapısını baz alarak ve mimariye aykırı gelmeyecek şekilde tasarka ve bunların daha sonra inceleme için depola özelleştir.
Kodlar kesinlikle tek bir dosyada veya klasörde toplanmayacaktır. Her modül kendi `feature` klasöründe, katmanlarına ayrılmış olarak kodlanacaktır.


