// Flutter'ın temel Material bileşenlerini içe aktarır
import 'package:flutter/material.dart';

// Bir ürünün stokta olup olmadığını renkli rozet (badge) olarak gösteren tekrar kullanılabilir widget
class StokRozeti extends StatelessWidget {
  // Ürünün stokta var olup olmadığını belirten boolean değer
  final bool stoktaVarMi;

  // StokRozeti sınıfının değişmez (const) kurucu metodu
  const StokRozeti({
    // Widget ağacı için opsiyonel anahtar parametresi
    super.key,
    // Stok bilgisinin zorunlu parametre olduğunu belirtir
    required this.stoktaVarMi,
  // Kurucu metodun kapanış parantezi
  });

  // Widget'ın görsel ağacını inşa eden build metodu
  @override
  // BuildContext parametresi ile Build metodunun gövdesi
  Widget build(BuildContext context) {
    // Rozetin dış kutusunu ve kenarlık/arka plan özelliklerini belirleyen Container
    return Container(
      // Rozet içi kenar boşlukları (iç padding)
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      // Rozetin görsel dekorasyon özellikleri
      decoration: BoxDecoration(
        // Stokta varsa yeşil, tükenmişse kırmızı arka plan rengi
        color: stoktaVarMi
            // Stokta var ise açık yeşil tonu
            ? Colors.green.shade50
            // Tükendi ise açık kırmızı tonu
            : Colors.red.shade50,
        // Rozetin köşelerini yuvarlatan yarıçap tanımı
        borderRadius: BorderRadius.circular(12),
        // Rozetin dışına ince zarif bir çerçeve çizgisi çizer
        border: Border.all(
          // Çerçeve rengini duruma göre yeşil veya kırmızı yapar
          color: stoktaVarMi
              // Stokta var ise yeşil çerçeve
              ? Colors.green.shade300
              // Tükendi ise kırmızı çerçeve
              : Colors.red.shade300,
          // Çerçeve kalınlığı (1 piksel)
          width: 1,
        // Border.all kapanışı
        ),
      // BoxDecoration kapanışı
      ),
      // Rozet içindeki metin widget'ı
      child: Text(
        // Stok durumuna göre ekranda gösterilecek metin
        stoktaVarMi ? 'Stokta Var' : 'Tükendi',
        // Metin stil özellikleri
        style: TextStyle(
          // Yazı tipi boyutu
          fontSize: 11,
          // Yazı kalınlığı (yarı kalın)
          fontWeight: FontWeight.w600,
          // Metin rengini duruma göre koyu yeşil veya koyu kırmızı yapar
          color: stoktaVarMi
              // Koyu yeşil metin rengi
              ? Colors.green.shade800
              // Koyu kırmızı metin rengi
              : Colors.red.shade800,
        // TextStyle kapanışı
        ),
      // Text widget kapanışı
      ),
    // Container widget kapanışı
    );
  // build metodu kapanış parantezi
  }
// StokRozeti sınıfının kapanış parantezi
}
