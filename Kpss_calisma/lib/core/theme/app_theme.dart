// Flutter'ın temel Material Design bileşenlerini içe aktarıyoruz
import 'package:flutter/material.dart';
// Modern tipografi için Google Fonts paketini içe aktarıyoruz
import 'package:google_fonts/google_fonts.dart';
// Uygulama renk paletini içeren sabit sınıfımızı içe aktarıyoruz
import '../constants/app_colors.dart';

// Açık (Light) ve Koyu (Dark) Material 3 temalarını yapılandıran sınıf
class AppTheme {
  // Açık tema yapılandırmasını döndüren getter
  static ThemeData get lightTheme {
    // Plus Jakarta Sans yazı tipini Google Fonts üzerinden alıyoruz
    final fontFamily = GoogleFonts.plusJakartaSans().fontFamily;

    return ThemeData(
      // Material 3 tasarım kurallarını etkinleştiriyoruz
      useMaterial3: true,
      // Temanın parlaklık düzeyini açık (light) olarak belirliyoruz
      brightness: Brightness.light,
      // Uygulama genelinde kullanılacak varsayılan yazı tipini atıyoruz
      fontFamily: fontFamily,
      // Açık tema renk şemasını yapılandırıyoruz
      colorScheme: const ColorScheme.light(
        // Birincil marka rengi
        primary: AppColors.primary,
        // İkincil vurgu rengi
        secondary: AppColors.secondary,
        // Yüzey ve kart arka plan rengi
        surface: AppColors.lightSurface,
        // Alternatif ve daha koyu yüzey rengi (inputlar vb. için)
        surfaceContainerHighest: AppColors.lightSurfaceVariant,
        // Yüzey üzerindeki metin rengi
        onSurface: AppColors.lightTextPrimary,
        // Hata durumlarındaki uyarı rengi
        error: AppColors.wrong,
      ),
      // Sayfaların varsayılan arka plan rengi
      scaffoldBackgroundColor: AppColors.lightBackground,
      // Üst çubuk (AppBar) varsayılan görünümü
      appBarTheme: const AppBarTheme(
        // AppBar arka planını şeffaf yapıyoruz
        backgroundColor: Colors.transparent,
        // Gölgeyi kaldırıyoruz
        elevation: 0,
        // Sayfa kaydırıldığında oluşan ek gölgeyi de sıfırlıyoruz
        scrolledUnderElevation: 0,
        // Başlığı sola hizalıyoruz
        centerTitle: false,
        // AppBar başlık metni stili
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.lightTextPrimary,
        ),
        // AppBar üzerindeki simgelerin rengi
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
      ),
      // Kart (Card) bileşenlerinin varsayılan tasarımı
      cardTheme: CardThemeData(
        // Kartın zemin rengi
        color: AppColors.lightCard,
        // Kart gölgesini kaldırıp düz modern çizgi stili veriyoruz
        elevation: 0,
        // Kart kenarlarını yuvarlatıyoruz ve ince sınır çizgisi ekliyoruz
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        // Kart dış boşluğunu sıfırlıyoruz
        margin: EdgeInsets.zero,
      ),
      // Alt gezinti çubuğu (NavigationBar) tasarımı
      navigationBarTheme: NavigationBarThemeData(
        // Alt çubuk zemin rengi
        backgroundColor: Colors.white,
        // Seçilen sekmenin arka planındaki dairesel vurgu rengi
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        // Sekme altındaki metinlerin seçili ve seçili olmama durumlarına göre rengi
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          );
        }),
        // Sekme simgelerinin seçili ve seçili olmama durumlarına göre rengi
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: Color(0xFF64748B));
        }),
      ),
      // Vurgulu butonların (ElevatedButton) genel tema stili
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          // Buton zemin rengi
          backgroundColor: AppColors.primary,
          // Buton üzerindeki yazı ve ikon rengi
          foregroundColor: Colors.white,
          // Buton gölgesini kaldırıyoruz (modern düz tasarım)
          elevation: 0,
          // Buton köşelerini yuvarlatıyoruz
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // Buton iç boşluğu (padding)
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          // Buton yazı tipi ve boyutu
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      // Metin giriş alanlarının (TextField / TextFormField) genel tasarımı
      inputDecorationTheme: InputDecorationTheme(
        // Giriş kutusunun arkasının renkli olmasını sağlar
        filled: true,
        // Giriş kutusu zemin dolgu rengi
        fillColor: AppColors.lightSurfaceVariant,
        // Giriş kutusu iç boşluğu
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        // Varsayılan kenarlık stili
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        // Odaklanılmamış (pasif) durumdaki kenarlık stili
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        // Kullanıcı tıkladığında (odaklandığında) görünen kenarlık stili
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  // Koyu (Dark) tema yapılandırmasını döndüren getter
  static ThemeData get darkTheme {
    // Plus Jakarta Sans yazı tipini Google Fonts üzerinden alıyoruz
    final fontFamily = GoogleFonts.plusJakartaSans().fontFamily;

    return ThemeData(
      // Material 3 kurallarını etkinleştiriyoruz
      useMaterial3: true,
      // Temanın parlaklık düzeyini koyu (dark) olarak ayarlıyoruz
      brightness: Brightness.dark,
      // Varsayılan yazı tipini atıyoruz
      fontFamily: fontFamily,
      // Koyu tema renk şemasını yapılandırıyoruz
      colorScheme: const ColorScheme.dark(
        // Koyu modda daha iyi okunan açık ton birincil renk
        primary: AppColors.primaryLight,
        // İkincil vurgu rengi
        secondary: AppColors.secondary,
        // Kart ve panel yüzey rengi
        surface: AppColors.darkSurface,
        // Alternatif koyu yüzey rengi
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
        // Yüzey üzerindeki açık metin rengi
        onSurface: AppColors.darkTextPrimary,
        // Hata durumlarındaki uyarı rengi
        error: AppColors.wrong,
      ),
      // Koyu temanın ana sayfa arka plan rengi
      scaffoldBackgroundColor: AppColors.darkBackground,
      // Koyu tema üst çubuk tasarımı
      appBarTheme: const AppBarTheme(
        // Arka planı şeffaf yapıyoruz
        backgroundColor: Colors.transparent,
        // Gölgeyi kaldırıyoruz
        elevation: 0,
        // Kaydırma gölgesini kaldırıyoruz
        scrolledUnderElevation: 0,
        // Başlığı sola dayalı yapıyoruz
        centerTitle: false,
        // Koyu tema başlık metin stili
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
        ),
        // Simgelerin rengi
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      ),
      // Koyu tema kart bileşeni tasarımı
      cardTheme: CardThemeData(
        // Koyu kart zemin rengi
        color: AppColors.darkCard,
        // Düz tasarım için gölgeyi sıfırlıyoruz
        elevation: 0,
        // Köşeleri yuvarlatıp koyu gri ince kenarlık ekliyoruz
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        // Kart dış boşluğunu sıfırlıyoruz
        margin: EdgeInsets.zero,
      ),
      // Koyu tema alt gezinti çubuğu (NavigationBar)
      navigationBarTheme: NavigationBarThemeData(
        // Alt çubuk arka planı
        backgroundColor: AppColors.darkSurface,
        // Seçili sekmenin altındaki vurgu rengi
        indicatorColor: AppColors.primary.withValues(alpha: 0.3),
        // Sekme metinlerinin seçili veya seçili olmama durumuna göre stili
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryLight,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.darkTextSecondary,
          );
        }),
        // Sekme simgelerinin seçili veya seçili olmama durumuna göre stili
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryLight);
          }
          return const IconThemeData(color: AppColors.darkTextSecondary);
        }),
      ),
      // Koyu tema buton tasarımı
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          // Buton ana rengi
          backgroundColor: AppColors.primary,
          // Buton üzerindeki yazı rengi
          foregroundColor: Colors.white,
          // Gölgeyi sıfırlıyoruz
          elevation: 0,
          // Köşeleri yuvarlatıyoruz
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // Buton iç boşluğu
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          // Buton metin biçimlendirmesi
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      // Koyu tema giriş kutuları (Input) tasarımı
      inputDecorationTheme: InputDecorationTheme(
        // Dolgulu arka planı aktif ediyoruz
        filled: true,
        // Dolgu rengi
        fillColor: AppColors.darkSurfaceVariant,
        // Giriş kutusu iç boşluğu
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        // Varsayılan kenarlık stili
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        // Pasif kenarlık stili
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        // Odaklanılmış aktif kenarlık stili
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
      ),
    );
  }
}
