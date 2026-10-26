// Flutter test kütüphanesini içe aktarıyoruz
import 'package:flutter_test/flutter_test.dart';
// Test edilecek KPSS net ve doğruluk hesaplayıcı sınıfını içe aktarıyoruz
import 'package:kpss/core/utils/kpss_calculator.dart';
// Test edilecek Deneme sınavı modelini içe aktarıyoruz
import 'package:kpss/models/mock_exam.dart';
// Test edilecek Soru kaydı modelini içe aktarıyoruz
import 'package:kpss/models/question_log.dart';

// Test paketinin başlangıç fonksiyonu
void main() {
  // KPSS Hesaplayıcı ve Veri Modellerini kapsayan test grubu
  group('KPSS Calculator & Model Tests', () {
    // 1. Test: 4 yanlış 1 doğruyu götürür kuralının doğruluğunu test eder
    test('calculateNet calculates standard 4 wrong 1 correct rule correctly', () {
      // 20 doğru, 4 yanlış -> 20 - (4/4) = 19.0 net beklenir
      expect(KpssCalculator.calculateNet(20, 4), 19.0);
      // 30 doğru, 2 yanlış -> 30 - (2/4) = 29.5 net beklenir
      expect(KpssCalculator.calculateNet(30, 2), 29.5);
      // 0 doğru, 4 yanlış -> 0 - (4/4) = -1.0 net beklenir
      expect(KpssCalculator.calculateNet(0, 4), -1.0);
      // 0 doğru, 0 yanlış -> 0.0 net beklenir
      expect(KpssCalculator.calculateNet(0, 0), 0.0);
      // 40 doğru, 1 yanlış -> 40 - (1/4) = 39.75 net beklenir
      expect(KpssCalculator.calculateNet(40, 1), 39.75);
    });

    // 2. Test: Doğruluk yüzdesinin sıfıra bölme hatası vermeden güvenle hesaplandığını test eder
    test('calculateAccuracy calculates percentage safely without division by zero', () {
      // Toplam 0 iken 0.0 dönmeli (hata fırlatmamalı)
      expect(KpssCalculator.calculateAccuracy(0, 0), 0.0);
      // 100 soruda 50 doğru -> %50.0 başarı
      expect(KpssCalculator.calculateAccuracy(50, 100), 50.0);
      // 40 soruda 30 doğru -> %75.0 başarı
      expect(KpssCalculator.calculateAccuracy(30, 40), 75.0);
    });

    // 3. Test: QuestionLog nesnesinin toMap ve fromMap serileştirme döngüsünün kayıpsız çalıştığını test eder
    test('QuestionLog serialization toMap and fromMap works seamlessly', () {
      final now = DateTime(2026, 10, 24);
      final log = QuestionLog(
        id: 'test_1',
        courseId: 'turkce',
        correct: 25,
        wrong: 4,
        empty: 1,
        date: now,
        note: 'Paragraf çözümü',
      );

      // Toplam soru sayısı 25 + 4 + 1 = 30 olmalıdır
      expect(log.totalQuestions, 30);
      // Net skoru 25 - (4/4) = 24.0 olmalıdır
      expect(log.netScore, 24.0);

      // Map nesnesine dönüştürülüp tekrar model nesnesine çevrilir
      final map = log.toMap();
      final fromMap = QuestionLog.fromMap(map);

      // Çözümleme sonrası tüm alanların orijinaliyle aynı kaldığı doğrulanır
      expect(fromMap.id, 'test_1');
      expect(fromMap.courseId, 'turkce');
      expect(fromMap.correct, 25);
      expect(fromMap.wrong, 4);
      expect(fromMap.empty, 1);
      expect(fromMap.netScore, 24.0);
    });

    // 4. Test: MockExam modelinin Genel Yetenek, Genel Kültür ve Toplam Net puanlarını doğru hesapladığını test eder
    test('MockExam calculates GY, GK and Total Net accurately', () {
      final now = DateTime(2026, 10, 24);
      final exam = MockExam(
        id: 'exam_1',
        title: 'Pegem TG-1',
        date: now,
        gyCorrect: 45,
        gyWrong: 8,
        gkCorrect: 50,
        gkWrong: 4,
      );

      // GY Net: 45 - (8/4) = 43.0 olmalıdır
      expect(exam.gyNet, 43.0);
      // GK Net: 50 - (4/4) = 49.0 olmalıdır
      expect(exam.gkNet, 49.0);
      // Toplam Net: 43.0 + 49.0 = 92.0 olmalıdır
      expect(exam.totalNet, 92.0);

      // Map serileştirmesinin doğruluğu test edilir
      final map = exam.toMap();
      final fromMap = MockExam.fromMap(map);
      expect(fromMap.totalNet, 92.0);
      expect(fromMap.title, 'Pegem TG-1');
    });
  });
}
