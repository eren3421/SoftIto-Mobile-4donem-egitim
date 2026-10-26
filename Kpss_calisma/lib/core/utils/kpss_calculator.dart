// KPSS net ve başarı yüzdesi hesaplamalarını gerçekleştiren yardımcı matematiksel sınıf
class KpssCalculator {
  /// Standart KPSS net hesaplama kuralı: 4 yanlış 1 doğruyu götürür
  static double calculateNet(int correct, int wrong) {
    // Doğru sayısından yanlış sayısının 4'e bölümü çıkarılır ve net sonuç döndürülür
    return correct - (wrong / 4.0);
  }

  /// Çözülen toplam soru içindeki doğru yüzdesini (0-100 arası) hesaplar
  static double calculateAccuracy(int correct, int total) {
    // Toplam soru sayısı sıfır veya negatifse sıfıra bölme hatasını önlemek için 0.0 döner
    if (total <= 0) return 0.0;

    // Doğru sayısını toplama bölüp 100 ile çarparak yüzdeyi buluruz
    final accuracy = (correct / total) * 100.0;

    // Yüzdenin 0 ile 100 sınırları arasında kalmasını garanti altına alıyoruz
    return accuracy > 100.0 ? 100.0 : (accuracy < 0.0 ? 0.0 : accuracy);
  }

  /// Tarih nesnesinin saat, dakika, saniye ve milisaniye kısımlarını sıfırlayarak sadece gün bilgisini alır
  static DateTime normalizeDate(DateTime date) {
    // Yıl, ay ve gün değerleriyle saat kısmı 00:00:00 olan saf bir tarih nesnesi oluşturur
    return DateTime(date.year, date.month, date.day);
  }

  /// İki tarih nesnesinin aynı güne denk gelip gelmediğini kontrol eder
  static bool isSameDay(DateTime a, DateTime b) {
    // İki tarihin yıl, ay ve gün değerleri birbirine eşitse true, değilse false döner
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
