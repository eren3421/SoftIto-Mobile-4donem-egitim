// Kullanıcının çözdüğü bir test veya soru grubuna ait sonuç kaydını tutan model sınıfı
class QuestionLog {
  // Soru kaydının benzersiz kimliği
  final String id;

  // Çözülen soruların ait olduğu dersin kimliği (Örn: 'tarih')
  final String courseId;

  // Doğru sayısı
  final int correct;

  // Yanlış sayısı
  final int wrong;

  // Boş bırakılan soru sayısı
  final int empty;

  // Soruların çözüldüğü tarih ve saat
  final DateTime date;

  // İsteğe bağlı ek açıklama veya test adı notu
  final String? note;

  // QuestionLog sınıfının kurucu fonksiyonu
  QuestionLog({
    required this.id,
    required this.courseId,
    required this.correct,
    required this.wrong,
    required this.empty,
    required this.date,
    this.note,
  });

  // Toplam soru sayısını (Doğru + Yanlış + Boş) hesaplayan getter
  int get totalQuestions => correct + wrong + empty;

  // Standart KPSS 4 yanlış 1 doğruyu götürür kuralına göre net puanı hesaplayan getter
  double get netScore => correct - (wrong / 4.0);

  // Toplam soru içerisindeki doğru cevap yüzdesini hesaplayan getter
  double get accuracyRate {
    // Soru çözülmemişse sıfıra bölme hatasını engellemek için 0 döner
    if (totalQuestions == 0) return 0.0;
    // Doğru oranını 100 ile çarparak yüzde değerini döndürür
    return (correct / totalQuestions) * 100.0;
  }

  // Veritabanından veya Map nesnesinden QuestionLog oluşturan fabrika kurucusu
  factory QuestionLog.fromMap(Map<dynamic, dynamic> map) {
    return QuestionLog(
      // Kayıt kimliğini alır
      id: map['id']?.toString() ?? '',
      // Ders kodunu alır
      courseId: map['courseId']?.toString() ?? '',
      // Doğru sayısını int'e çevirir; geçersizse 0 yapar
      correct: int.tryParse(map['correct']?.toString() ?? '0') ?? 0,
      // Yanlış sayısını int'e çevirir; geçersizse 0 yapar
      wrong: int.tryParse(map['wrong']?.toString() ?? '0') ?? 0,
      // Boş sayısını int'e çevirir; geçersizse 0 yapar
      empty: int.tryParse(map['empty']?.toString() ?? '0') ?? 0,
      // Tarih metnini DateTime'a dönüştürür
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      // Not bilgisini alır
      note: map['note']?.toString(),
    );
  }

  // QuestionLog nesnesini Hive veritabanında saklamak üzere Map'e çeviren metot
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Kimlik
      'courseId': courseId, // Ders kimliği
      'correct': correct, // Doğru sayısı
      'wrong': wrong, // Yanlış sayısı
      'empty': empty, // Boş sayısı
      'date': date.toIso8601String(), // ISO formatlı tarih
      'note': note, // Not
    };
  }
}
