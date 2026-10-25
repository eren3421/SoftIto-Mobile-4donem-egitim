import 'package:flutter_test/flutter_test.dart';
import 'package:kpss/core/utils/kpss_calculator.dart';
import 'package:kpss/models/mock_exam.dart';
import 'package:kpss/models/question_log.dart';

void main() {
  group('KPSS Calculator & Model Tests', () {
    test('calculateNet calculates standard 4 wrong 1 correct rule correctly', () {
      expect(KpssCalculator.calculateNet(20, 4), 19.0);
      expect(KpssCalculator.calculateNet(30, 2), 29.5);
      expect(KpssCalculator.calculateNet(0, 4), -1.0);
      expect(KpssCalculator.calculateNet(0, 0), 0.0);
      expect(KpssCalculator.calculateNet(40, 1), 39.75);
    });

    test('calculateAccuracy calculates percentage safely without division by zero', () {
      expect(KpssCalculator.calculateAccuracy(0, 0), 0.0);
      expect(KpssCalculator.calculateAccuracy(50, 100), 50.0);
      expect(KpssCalculator.calculateAccuracy(30, 40), 75.0);
    });

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

      expect(log.totalQuestions, 30);
      expect(log.netScore, 24.0);

      final map = log.toMap();
      final fromMap = QuestionLog.fromMap(map);

      expect(fromMap.id, 'test_1');
      expect(fromMap.courseId, 'turkce');
      expect(fromMap.correct, 25);
      expect(fromMap.wrong, 4);
      expect(fromMap.empty, 1);
      expect(fromMap.netScore, 24.0);
    });

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

      // GY: 45 - (8/4) = 43.0
      expect(exam.gyNet, 43.0);
      // GK: 50 - (4/4) = 49.0
      expect(exam.gkNet, 49.0);
      // Total: 43.0 + 49.0 = 92.0
      expect(exam.totalNet, 92.0);

      final map = exam.toMap();
      final fromMap = MockExam.fromMap(map);
      expect(fromMap.totalNet, 92.0);
      expect(fromMap.title, 'Pegem TG-1');
    });
  });
}
