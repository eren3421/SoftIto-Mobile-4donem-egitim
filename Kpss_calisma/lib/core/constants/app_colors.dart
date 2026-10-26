// Flutter'ın renk ve arayüz çizim kütüphanesini içe aktarıyoruz
import 'package:flutter/material.dart';

// Uygulama genelindeki renk paletini ve ders renklerini yöneten yardımcı sınıf
class AppColors {
  // --- Marka ve Vurgu (Accent) Renkleri ---
  // Ana tema rengi (İndigo / Gece Mavisi tonu)
  static const Color primary = Color(0xFF6366F1);

  // Ana rengin açık tonu (Vurgulamalar ve buton açık durumları için)
  static const Color primaryLight = Color(0xFF818CF8);

  // Ana rengin koyu tonu (Gece modu ve gölgeler için)
  static const Color primaryDark = Color(0xFF4338CA);

  // İkincil renk (Camgöbeği / Canlı mavi tonu)
  static const Color secondary = Color(0xFF06B6D4);

  // Altın / Kehribar sarısı (Ödül, hedef ve dikkat çekici kartlar için)
  static const Color accentGold = Color(0xFFF59E0B);

  // --- KPSS Derslerine Özel Renkler ---
  // Türkçe dersi rengi (Canlı mavi)
  static const Color courseTurkce = Color(0xFF2196F3);

  // Matematik dersi rengi (Mor)
  static const Color courseMatematik = Color(0xFF9C27B0);

  // Tarih dersi rengi (Sıcak turuncu)
  static const Color courseTarih = Color(0xFFFF9800);

  // Coğrafya dersi rengi (Doğa yeşili)
  static const Color courseCografya = Color(0xFF4CAF50);

  // Vatandaşlık dersi rengi (Bayrak kırmızısı)
  static const Color courseVatandaslik = Color(0xFFF44336);

  // --- Konu Tamamlanma Durum Renkleri ---
  // Henüz başlanmadı durumu için gri renk
  static const Color notStarted = Color(0xFF94A3B8);

  // Tekrar edilecek durumu için kehribar sarısı renk
  static const Color needsReview = Color(0xFFF59E0B);

  // Bitirildi / tamamlandı durumu için zümrüt yeşili renk
  static const Color completed = Color(0xFF10B981);

  // --- Soru ve Net Takibi Renkleri ---
  // Doğru cevap rengi (Yeşil)
  static const Color correct = Color(0xFF10B981);

  // Yanlış cevap rengi (Kırmızı)
  static const Color wrong = Color(0xFFEF4444);

  // Boş bırakılan soru rengi (Açık gri)
  static const Color empty = Color(0xFF94A3B8);

  // --- Koyu Tema (Dark Theme) Zemin ve Kart Renkleri ---
  // Koyu tema ana arka plan rengi (Koyu arduvaz mavisi)
  static const Color darkBackground = Color(0xFF0F172A);

  // Koyu tema yüzey rengi (Kartlar ve paneller için)
  static const Color darkSurface = Color(0xFF1E293B);

  // Koyu tema kart arka plan rengi
  static const Color darkCard = Color(0xFF1E293B);

  // Koyu tema ikincil yüzey rengi (Giriş kutuları, ayırıcılar için)
  static const Color darkSurfaceVariant = Color(0xFF334155);

  // Koyu tema ana metin rengi (Açık kırık beyaz)
  static const Color darkTextPrimary = Color(0xFFF8FAFC);

  // Koyu tema ikincil/açıklama metin rengi (Açık gri)
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // --- Açık Tema (Light Theme) Zemin ve Kart Renkleri ---
  // Açık tema ana arka plan rengi (Çok açık buz mavisi/beyaz)
  static const Color lightBackground = Color(0xFFF8FAFC);

  // Açık tema yüzey rengi (Saf beyaz)
  static const Color lightSurface = Colors.white;

  // Açık tema kart arka plan rengi (Saf beyaz)
  static const Color lightCard = Colors.white;

  // Açık tema ikincil yüzey rengi (Hafif gri kutucuklar için)
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);

  // Açık tema ana metin rengi (Koyu lacivert-siyah)
  static const Color lightTextPrimary = Color(0xFF0F172A);

  // Açık tema ikincil metin rengi (Orta ton gri)
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Ders kimliğine (id) göre ilgili dersin rengini döndüren yardımcı fonksiyon
  static Color getCourseColor(String courseId) {
    // Gelen ders kimliğini küçük harfe çevirerek eşleştirme yapıyoruz
    switch (courseId.toLowerCase()) {
      case 'turkce': // Türkçe dersi seçilmişse
        return courseTurkce;
      case 'matematik': // Matematik dersi seçilmişse
        return courseMatematik;
      case 'tarih': // Tarih dersi seçilmişse
        return courseTarih;
      case 'cografya': // Coğrafya dersi seçilmişse
        return courseCografya;
      case 'vatandaslik': // Vatandaşlık dersi seçilmişse
        return courseVatandaslik;
      default: // Tanımsız veya genel bir ders ise ana temayı döndür
        return primary;
    }
  }
}
