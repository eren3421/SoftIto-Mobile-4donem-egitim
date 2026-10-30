// Flutter temel Material tasarım kütüphanesini içe aktarır
import 'package:flutter/material.dart';
// Gösterilecek ürün verisini temsil eden modeli içe aktarır
import '../models/urun.dart';
// Ürünün kategori Türkçe adını almak için kategori modelini içe aktarır
import '../models/kategori.dart';
// Stok durumunu gösteren rozet bileşenini içe aktarır
import 'stok_rozeti.dart';

// Ürün bilgilerini şık bir kart düzeninde sergileyen ve Hero animasyonunu destekleyen widget
class UrunKarti extends StatelessWidget {
  // Kart üzerinde bilgileri gösterilecek olan ürün nesnesi
  final Urun urun;
  // Kullanıcı karta tıkladığında tetiklenecek geri çağırma (callback) fonksiyonu
  final VoidCallback? onTap;

  // UrunKarti sınıfının kurucu metodu
  const UrunKarti({
    // Üst sınıfa anahtar parametresini iletir
    super.key,
    // Gösterilecek ürünün zorunlu olduğunu belirtir
    required this.urun,
    // Tıklama eyleminin opsiyonel olduğunu belirtir
    this.onTap,
  // Kurucu metodun kapanış parantezi
  });

  // Widget'ın görsel yapısını inşa eden build metodu
  @override
  // BuildContext parametresini alan build fonksiyonu
  Widget build(BuildContext context) {
    // Hafif gölgeli ve yuvarlatılmış köşeli Material Card bileşeni
    return Card(
      // Kartın dış kenar boşlukları (margin)
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // Kartın gölge derinliği
      elevation: 2,
      // Kartın köşe ovalliğini belirleyen şekil tanımı
      shape: RoundedRectangleBorder(
        // Köşeleri 16 piksel yuvarlatır
        borderRadius: BorderRadius.circular(16),
      // RoundedRectangleBorder kapanışı
      ),
      // Kartın köşelerinden taşan çocuk bileşenleri kırpar (clip)
      clipBehavior: Clip.antiAlias,
      // Kartın tamamına tıklanabilirlik ve dalgalanma (ripple) efekti veren InkWell
      child: InkWell(
        // Tıklama olduğunda üstten gelen onTap fonksiyonunu çalıştırır
        onTap: onTap,
        // Kart içeriğinin iç boşluklarını (padding) ayarlayan Padding widget'ı
        child: Padding(
          // 12 piksellik iç boşluk verir
          padding: const EdgeInsets.all(12),
          // Resim ile metinleri yatayda yan yana dizen Row bileşeni
          child: Row(
            // Çocuk bileşenleri dikeyde üst hizaya yaslar
            crossAxisAlignment: CrossAxisAlignment.start,
            // Row içindeki yatay sıralı bileşenler listesi
            children: [
              // Sayfalar arası akıcı geçiş sağlayan Hero animasyon widget'ı
              Hero(
                // Detay ekranındaki görselle eşleşecek benzersiz etiket (tag)
                tag: 'urun_resim_${urun.id}',
                // Görselin yuvarlatılmış köşeli çerçevesi
                child: ClipRRect(
                  // Görselin köşelerini 12 piksel yuvarlatır
                  borderRadius: BorderRadius.circular(12),
                  // Görseli sabit boyutlu bir kutu içine alan SizedBox
                  child: SizedBox(
                    // Görsel genişliği (80 piksel)
                    width: 80,
                    // Görsel yüksekliği (80 piksel)
                    height: 80,
                    // Uzaktaki resmi internetten yükleyen Image.network widget'ı
                    child: Image.network(
                      // Ürünün FakeStore'daki internet bağlantı adresi
                      urun.resimUrl,
                      // Görselin kutu içine orantılı biçimde sığmasını sağlar
                      fit: BoxFit.contain,
                      // Görsel yüklenirken çalışan inşa edici (loading builder)
                      loadingBuilder: (context, child, loadingProgress) {
                        // Yükleme tamamlandıysa doğrudan görseli ekrana basar
                        if (loadingProgress == null) return child;
                        // Yükleme devam ederken dönen ilerleme çubuğu gösterir
                        return const Center(
                          // Dairesel ilerleme çubuğu
                          child: CircularProgressIndicator(strokeWidth: 2),
                        // Center kapanışı
                        );
                      // loadingBuilder kapanışı
                      },
                      // Görsel yüklenemediğinde veya internet koptuğunda devreye giren hata inşa edicisi
                      errorBuilder: (context, error, stackTrace) {
                        // Gri arka planlı hata kutusu gösterir
                        return Container(
                          // Açık gri zemin rengi
                          color: Colors.grey.shade200,
                          // Ortalanmış kırık resim simgesi
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        // Container kapanışı
                        );
                      // errorBuilder kapanışı
                      },
                    // Image.network kapanışı
                    ),
                  // SizedBox kapanışı
                  ),
                // ClipRRect kapanışı
                ),
              // Hero widget kapanışı
              ),
              // Resim ile metinler arasına 12 piksel yatay boşluk bırakır
              const SizedBox(width: 12),
              // Kalan tüm yatay alanı kaplayan Expanded widget'ı
              Expanded(
                // Metinleri alt alta sıralayan Column bileşeni
                child: Column(
                  // Metinleri sola yaslar
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Column içindeki dikey bileşenler listesi
                  children: [
                    // Üst sıra: Kategori adı ve Stok rozetini yan yana dizer
                    Row(
                      // Kategori adı ile rozet arasını maksimum açar
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // Üst sıra bileşenleri
                      children: [
                        // Kategori adı metni
                        Text(
                          // Kategorinin Türkçe görünen adı
                          urun.kategori.gorunenAd,
                          // Kategori metin stili
                          style: TextStyle(
                            // Yazı boyutu
                            fontSize: 12,
                            // Yazı kalınlığı
                            fontWeight: FontWeight.w500,
                            // Koyu gri yazı rengi
                            color: Colors.grey.shade600,
                          // TextStyle kapanışı
                          ),
                        // Text kapanışı
                        ),
                        // Stok durumunu gösteren özel rozet bileşeni
                        StokRozeti(stoktaVarMi: urun.stoktaVarMi),
                      // Row çocukları kapanışı
                      ],
                    // Row kapanışı
                    ),
                    // 4 piksel dikey boşluk
                    const SizedBox(height: 4),
                    // Ürünün başlığını gösteren metin widget'ı
                    Text(
                      // Ürün başlığı metni
                      urun.baslik,
                      // En fazla 2 satır görünmesini sağlar
                      maxLines: 2,
                      // 2 satırı aşan kısmı üç nokta (...) ile kırpar
                      overflow: TextOverflow.ellipsis,
                      // Başlık metin stili
                      style: const TextStyle(
                        // Yazı boyutu
                        fontSize: 14,
                        // Kalın yazı tipi
                        fontWeight: FontWeight.bold,
                      // TextStyle kapanışı
                      ),
                    // Text kapanışı
                    ),
                    // 6 piksel dikey boşluk
                    const SizedBox(height: 6),
                    // Puan ve Oy sayısını yan yana gösteren satır
                    Row(
                      // Elemanları dikeyde ortalar
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // Sıra elemanları
                      children: [
                        // Sarı renkli yıldız simgesi
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        // Yıldız ile puan arasına 4 piksel boşluk
                        const SizedBox(width: 4),
                        // Ortalama puan metni
                        Text(
                          // Puanı tek ondalık basamakla yazar (Örnek: 4.5)
                          urun.degerlendirme.puan.toStringAsFixed(1),
                          // Puan stili
                          style: const TextStyle(
                            // Yazı boyutu
                            fontSize: 12,
                            // Yarı kalın font
                            fontWeight: FontWeight.bold,
                          // TextStyle kapanışı
                          ),
                        // Text kapanışı
                        ),
                        // Puan ile oy sayısı arasına 4 piksel boşluk
                        const SizedBox(width: 4),
                        // Oy sayısını parantez içinde gösteren metin
                        Text(
                          // Oy sayısı metni (Örnek: (120))
                          '(${urun.degerlendirme.oySayisi})',
                          // Oy sayısı stili
                          style: TextStyle(
                            // Yazı boyutu
                            fontSize: 12,
                            // Gri metin rengi
                            color: Colors.grey.shade500,
                          // TextStyle kapanışı
                          ),
                        // Text kapanışı
                        ),
                      // Row çocukları kapanışı
                      ],
                    // Row kapanışı
                    ),
                    // 8 piksel dikey boşluk
                    const SizedBox(height: 8),
                    // Ürün fiyatını vurgulayan metin widget'ı
                    Text(
                      // Fiyatı 2 basamaklı formatlayıp para birimi ekler
                      '${urun.fiyat.toStringAsFixed(2)} ₺',
                      // Fiyat stili
                      style: TextStyle(
                        // Yazı boyutu (büyük ve dikkat çekici)
                        fontSize: 16,
                        // Çok kalın yazı tipi
                        fontWeight: FontWeight.w800,
                        // Uygulama tema rengiyle uyumlu indigo rengi
                        color: Colors.indigo.shade700,
                      // TextStyle kapanışı
                      ),
                    // Text kapanışı
                    ),
                  // Column çocukları kapanışı
                  ],
                // Column kapanışı
                ),
              // Expanded kapanışı
              ),
            // Row çocukları kapanışı
            ],
          // Row kapanışı
          ),
        // Padding kapanışı
        ),
      // InkWell kapanışı
      ),
    // Card kapanışı
    );
  // build metodu kapanış parantezi
  }
// UrunKarti sınıfının kapanış parantezi
}
