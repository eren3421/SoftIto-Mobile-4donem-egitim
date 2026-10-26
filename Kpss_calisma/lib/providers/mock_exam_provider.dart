// Flutter temel arayüz sınıflarını içe aktarıyoruz
import 'package:flutter/material.dart';
// Benzersiz kimlik (UUID v4) üretmek için uuid paketini içe aktarıyoruz
import 'package:uuid/uuid.dart';
// Hive yerel veritabanı servisini içe aktarıyoruz
import '../core/services/hive_service.dart';
// Deneme sınavı modelini içe aktarıyoruz
import '../models/mock_exam.dart';

// KPSS deneme sınavı sonuçlarını ekleme, silme ve istatistiklerini hesaplama işlerini yöneten Provider
class MockExamProvider with ChangeNotifier {
  // Kayıtlı deneme sınavlarının listesi
  List<MockExam> _exams = [];

  // Benzersiz kimlik üreteci
  final _uuid = const Uuid();

  // Kurucu fonksiyon; sınıf ilk çalıştığında mevcut denemeleri veritabanından çeker
  MockExamProvider() {
    loadExams();
  }

  // Deneme listesini dışarıya değiştirilemez (unmodifiable) kopya olarak sunan getter
  List<MockExam> get exams => List.unmodifiable(_exams);

  // Hive veritabanından tüm deneme kayıtlarını okuyan fonksiyon
  void loadExams() {
    // Hive deneme kutusuna erişiyoruz
    final box = HiveService.mockExamsBox;
    final List<MockExam> loaded = [];

    // Kutudaki tüm kayıtları döngüyle alıp modele dönüştürüyoruz
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        loaded.add(MockExam.fromMap(raw));
      }
    }

    // Denemeleri tarihe göre yeniden eskiye doğru (azalan sırada) sıralıyoruz
    loaded.sort((a, b) => b.date.compareTo(a.date));

    // Bellekteki listemize atıyoruz
    _exams = loaded;

    // Arayüzün güncellenmesi için dinleyicileri haberdar ediyoruz
    notifyListeners();
  }

  // Yeni bir deneme sınavı ekleyen ve kalıcı olarak kaydeden fonksiyon
  Future<void> addExam({
    required String title,
    required DateTime date,
    required int gyCorrect,
    required int gyWrong,
    required int gkCorrect,
    required int gkWrong,
    String? note,
  }) async {
    // Benzersiz rastgele bir id üretiyoruz
    final id = _uuid.v4();

    // Yeni deneme nesnemizi oluşturuyoruz
    final exam = MockExam(
      id: id,
      title: title.trim().isEmpty ? 'KPSS Denemesi' : title.trim(),
      date: date,
      gyCorrect: gyCorrect,
      gyWrong: gyWrong,
      gkCorrect: gkCorrect,
      gkWrong: gkWrong,
      note: note,
    );

    // Hive veritabanına id'si ile Map verisini kaydediyoruz
    await HiveService.mockExamsBox.put(id, exam.toMap());

    // Yeni denemeyi listenin en başına ekliyoruz
    _exams.insert(0, exam);

    // Dinleyicileri haberdar ediyoruz
    notifyListeners();
  }

  // Belirli bir denemeyi id'sine göre veritabanından ve listeden silen fonksiyon
  Future<void> deleteExam(String id) async {
    // Hive'dan kaydı siliyoruz
    await HiveService.mockExamsBox.delete(id);

    // Bellekteki listeden de siliyoruz
    _exams.removeWhere((e) => e.id == id);

    // Arayüzü güncelliyoruz
    notifyListeners();
  }

  // Çözülen tüm denemelerin ortalama toplam netini hesaplayan getter
  double get averageTotalNet {
    if (_exams.isEmpty) return 0.0;
    // Toplam netleri fold metoduyla toplayıp deneme sayısına bölüyoruz
    final sum = _exams.fold(0.0, (acc, e) => acc + e.totalNet);
    return sum / _exams.length;
  }

  // Çözülen denemeler arasında elde edilen en yüksek toplam neti bulan getter
  double get highestTotalNet {
    if (_exams.isEmpty) return 0.0;
    // reduce ile en büyük net değerini buluyoruz
    return _exams.map((e) => e.totalNet).reduce((a, b) => a > b ? a : b);
  }

  // Tüm denemelerdeki ortalama Genel Yetenek netini hesaplayan getter
  double get averageGyNet {
    if (_exams.isEmpty) return 0.0;
    final sum = _exams.fold(0.0, (acc, e) => acc + e.gyNet);
    return sum / _exams.length;
  }

  // Tüm denemelerdeki ortalama Genel Kültür netini hesaplayan getter
  double get averageGkNet {
    if (_exams.isEmpty) return 0.0;
    final sum = _exams.fold(0.0, (acc, e) => acc + e.gkNet);
    return sum / _exams.length;
  }
}
