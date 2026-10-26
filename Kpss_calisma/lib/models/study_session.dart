// Kullanıcının Pomodoro veya serbest kronometre ile yaptığı bir çalışma oturumunu temsil eden model
class StudySession {
  // Çalışma kaydının benzersiz kimliği (Örn: zaman damgalı id)
  final String id;

  // Hangi derse çalışıldığını belirten ders kimliği (Örn: 'matematik')
  final String courseId;

  // Çalışmanın dakika cinsinden toplam süresi
  final int durationInMinutes;

  // Çalışmanın yapıldığı tarih ve saat
  final DateTime date;

  // Çalışma türü ('pomodoro' veya 'stopwatch' / serbest sayaç)
  final String type;

  // Kullanıcının çalışma oturumu hakkında aldığı isteğe bağlı not
  final String? note;

  // StudySession sınıfının kurucu fonksiyonu
  StudySession({
    required this.id,
    required this.courseId,
    required this.durationInMinutes,
    required this.date,
    required this.type,
    this.note,
  });

  // Hive veritabanından veya Map nesnesinden StudySession nesnesi oluşturan fabrika kurucusu
  factory StudySession.fromMap(Map<dynamic, dynamic> map) {
    return StudySession(
      // Kayıt kimliğini string olarak alır
      id: map['id']?.toString() ?? '',
      // Ders kimliğini string olarak alır
      courseId: map['courseId']?.toString() ?? '',
      // Süre dakikasını tamsayıya çevirir, geçersizse 0 yapar
      durationInMinutes: int.tryParse(map['durationInMinutes']?.toString() ?? '0') ?? 0,
      // Tarih metnini DateTime nesnesine dönüştürür, hata varsa şimdiki zamanı alır
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      // Oturum türünü alır (varsayılan: 'pomodoro')
      type: map['type']?.toString() ?? 'pomodoro',
      // İsteğe bağlı not metnini alır
      note: map['note']?.toString(),
    );
  }

  // StudySession nesnesini Hive'a kaydetmek için Map yapısına dönüştüren fonksiyon
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Kimlik
      'courseId': courseId, // Ders kodu
      'durationInMinutes': durationInMinutes, // Süre (dk)
      'date': date.toIso8601String(), // ISO 8601 formatında tarih metni
      'type': type, // Çalışma türü
      'note': note, // Not
    };
  }
}
