// Kategori numaralandırmasının (enum) ve extension metodunun tanımlandığı dosyayı içe aktarır
import 'kategori.dart';
// Ürünün puan ve oy bilgilerini tutan Degerlendirme modelini içe aktarır
import 'degerlendirme.dart';

// Mağazada satılan bir ürünü temsil eden değişmez (immutable) veri modeli
class Urun {
  // Ürünün REST API'deki benzersiz kimlik numarası
  final int id;
  // Ürünün adı / başlığı (Örnek: Fjallraven Çanta)
  final String baslik;
  // Ürünün para birimi cinsinden satış fiyatı
  final double fiyat;
  // Ürünün detaylı açıklaması
  final String aciklama;
  // Ürünün ait olduğu tip güvenli kategori
  final Kategori kategori;
  // Ürünün uzaktaki fotoğrafına işaret eden doğrudan URL bağlantısı
  final String resimUrl;
  // Ürünün puan ve oy adedini barındıran alt (nested) model
  final Degerlendirme degerlendirme;
  // Ürünün depoda fiziksel olarak bulunup bulunmadığı bilgisi
  final bool stoktaVarMi;

  // Urun sınıfının const kurucu (constructor) metodu
  const Urun({
    // Benzersiz kimliğin zorunlu olduğunu belirten alan
    required this.id,
    // Başlık alanının zorunlu olduğunu belirten parametre
    required this.baslik,
    // Fiyat alanının zorunlu olduğunu belirten parametre
    required this.fiyat,
    // Açıklama alanının zorunlu olduğunu belirten parametre
    required this.aciklama,
    // Kategori alanının zorunlu olduğunu belirten parametre
    required this.kategori,
    // Resim bağlantısının zorunlu olduğunu belirten parametre
    required this.resimUrl,
    // Değerlendirme nesnesinin zorunlu olduğunu belirten parametre
    required this.degerlendirme,
    // Stok bilgisinin varsayılan olarak true geldiği opsiyonel parametre
    this.stoktaVarMi = true,
  // Yapıcı metodun kapanış parantezi
  });

  // FakeStore REST API'den gelen dinamik JSON haritasını tip güvenli Urun nesnesine çeviren fabrika kurucu
  factory Urun.fromJson(Map<String, dynamic> json) {
    // Yeni bir Urun nesnesi inşa ederek geriye döndürür
    return Urun(
      // int gelebilecek id değerini num üzerinden güvenle int'e dönüştürür
      id: (json['id'] as num).toInt(),
      // API'den gelen title alanını String olarak okur, null ise boş metin atar
      baslik: json['title'] as String? ?? 'İsimsiz Ürün',
      // API'den gelen fiyat tam sayı (109) veya ondalıklı (109.95) gelse de tip çökmesini önlemek için num.toDouble() kullanılır
      fiyat: (json['price'] as num?)?.toDouble() ?? 0.0,
      // API'den gelen description alanını güvenle okur
      aciklama: json['description'] as String? ?? '',
      // API'den gelen ham String kategori metnini enum değerine dönüştürür
      kategori: KategoriExtension.apiMetnindenUret(json['category'] as String? ?? ''),
      // API'den gelen resim URL bağlantısını okur
      resimUrl: json['image'] as String? ?? '',
      // rating alanındaki iç içe JSON nesnesini Degerlendirme modeline dönüştürür
      degerlendirme: json['rating'] != null
          // rating nesnesi varsa Degerlendirme.fromJson ile çözümler
          ? Degerlendirme.fromJson(json['rating'] as Map<String, dynamic>)
          // rating nesnesi yoksa varsayılan 0 puanlı güvenli nesne üretir
          : const Degerlendirme(puan: 0.0, oySayisi: 0),
      // FakeStore API'de stok alanı bulunmadığından oy sayısı 0 olan ürünler temsili olarak stok dışı sayılır
      stoktaVarMi: ((json['rating']?['count'] as num?)?.toInt() ?? 10) > 0,
    // Urun inşa çağrısının kapanışı
    );
  // fromJson fabrika metodunun kapanış parantezi
  }

  // Mevcut ürün nesnesini kopyalayıp sadece istenen alanları güncelleyen yardımcı metot
  Urun copyWith({
    // Yeni id (verilmezse eskisi korunur)
    int? id,
    // Yeni başlık (verilmezse eskisi korunur)
    String? baslik,
    // Yeni fiyat (verilmezse eskisi korunur)
    double? fiyat,
    // Yeni açıklama (verilmezse eskisi korunur)
    String? aciklama,
    // Yeni kategori (verilmezse eskisi korunur)
    Kategori? kategori,
    // Yeni resim URL (verilmezse eskisi korunur)
    String? resimUrl,
    // Yeni değerlendirme bilgisi (verilmezse eskisi korunur)
    Degerlendirme? degerlendirme,
    // Yeni stok durumu (verilmezse eskisi korunur)
    bool? stoktaVarMi,
  // copyWith parametre listesi kapanışı
  }) {
    // Güncellenmiş alanlarla yeni bir Urun nesnesi üretir
    return Urun(
      // Verilmişse yeni id'yi, verilmemişse mevcut id'yi kullanır
      id: id ?? this.id,
      // Verilmişse yeni başlığı, verilmemişse mevcut başlığı kullanır
      baslik: baslik ?? this.baslik,
      // Verilmişse yeni fiyatı, verilmemişse mevcut fiyatı kullanır
      fiyat: fiyat ?? this.fiyat,
      // Verilmişse yeni açıklamayı, verilmemişse mevcut açıklamayı kullanır
      aciklama: aciklama ?? this.aciklama,
      // Verilmişse yeni kategoriyi, verilmemişse mevcut kategoriyi kullanır
      kategori: kategori ?? this.kategori,
      // Verilmişse yeni resim linkini, verilmemişse mevcut resim linkini kullanır
      resimUrl: resimUrl ?? this.resimUrl,
      // Verilmişse yeni değerlendirmeyi, verilmemişse mevcut değerlendirmeyi kullanır
      degerlendirme: degerlendirme ?? this.degerlendirme,
      // Verilmişse yeni stok durumunu, verilmemişse mevcut stok durumunu kullanır
      stoktaVarMi: stoktaVarMi ?? this.stoktaVarMi,
    // Urun nesnesi üretimi kapanışı
    );
  // copyWith metodunun kapanış parantezi
  }
// Urun sınıfının kapanış parantezi
}
