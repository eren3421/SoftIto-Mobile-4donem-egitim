// KPSS Genel Yetenek (GY) ve Genel Kültür (GK) deneme sınavı sonuçlarını temsil eden model
class MockExam {
  // Deneme sınavı kaydının benzersiz kimliği
  final String id;

  // Deneme sınavının adı veya yayın evi (Örn: 'Pegem TG-1')
  final String title;

  // Deneme sınavının çözüldüğü tarih ve saat
  final DateTime date;

  // Genel Yetenek (Türkçe - Matematik) doğru sayısı
  final int gyCorrect;

  // Genel Yetenek yanlış sayısı
  final int gyWrong;

  // Genel Kültür (Tarih - Coğrafya - Vatandaşlık) doğru sayısı
  final int gkCorrect;

  // Genel Kültür yanlış sayısı
  final int gkWrong;

  // Deneme hakkında isteğe bağlı not (Örn: 'Süre yetiştiremedim')
  final String? note;

  // MockExam sınıfının kurucu fonksiyonu
  MockExam({
    required this.id,
    required this.title,
    required this.date,
    required this.gyCorrect,
    required this.gyWrong,
    required this.gkCorrect,
    required this.gkWrong,
    this.note,
  });

  // Genel Yetenek netini hesaplayan getter (Doğru - Yanlış / 4)
  double get gyNet => gyCorrect - (gyWrong / 4.0);

  // Genel Kültür netini hesaplayan getter (Doğru - Yanlış / 4)
  double get gkNet => gkCorrect - (gkWrong / 4.0);

  // Genel Yetenek ve Genel Kültür netlerinin toplamını veren getter
  double get totalNet => gyNet + gkNet;

  // Denemede işaretlenen toplam soru sayısı (GY + GK doğru ve yanlışları)
  int get totalQuestions => gyCorrect + gyWrong + gkCorrect + gkWrong;

  // Denemedeki toplam doğru sayısı
  int get totalCorrect => gyCorrect + gkCorrect;

  // Denemedeki toplam yanlış sayısı
  int get totalWrong => gyWrong + gkWrong;

  // Hive veya Map verisinden MockExam nesnesi oluşturan fabrika kurucusu
  factory MockExam.fromMap(Map<dynamic, dynamic> map) {
    return MockExam(
      // Kayıt kimliği
      id: map['id']?.toString() ?? '',
      // Sınav başlığı (varsayılan: 'KPSS Denemesi')
      title: map['title']?.toString() ?? 'KPSS Denemesi',
      // Sınav tarihi (geçersizse şu anki zamanı alır)
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      // GY doğru sayısı
      gyCorrect: int.tryParse(map['gyCorrect']?.toString() ?? '0') ?? 0,
      // GY yanlış sayısı
      gyWrong: int.tryParse(map['gyWrong']?.toString() ?? '0') ?? 0,
      // GK doğru sayısı
      gkCorrect: int.tryParse(map['gkCorrect']?.toString() ?? '0') ?? 0,
      // GK yanlış sayısı
      gkWrong: int.tryParse(map['gkWrong']?.toString() ?? '0') ?? 0,
      // İsteğe bağlı not
      note: map['note']?.toString(),
    );
  }

  // MockExam nesnesini Hive'a yazmak üzere Map formatına dönüştüren metot
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Kimlik
      'title': title, // Sınav adı
      'date': date.toIso8601String(), // Tarih
      'gyCorrect': gyCorrect, // GY Doğru
      'gyWrong': gyWrong, // GY Yanlış
      'gkCorrect': gkCorrect, // GK Doğru
      'gkWrong': gkWrong, // GK Yanlış
      'note': note, // Not
    };
  }
}
