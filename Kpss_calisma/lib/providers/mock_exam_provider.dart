import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/services/hive_service.dart';
import '../models/mock_exam.dart';

class MockExamProvider with ChangeNotifier {
  List<MockExam> _exams = [];
  final _uuid = const Uuid();

  MockExamProvider() {
    loadExams();
  }

  List<MockExam> get exams => List.unmodifiable(_exams);

  void loadExams() {
    final box = HiveService.mockExamsBox;
    final List<MockExam> loaded = [];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        loaded.add(MockExam.fromMap(raw));
      }
    }
    // Sort descending by date
    loaded.sort((a, b) => b.date.compareTo(a.date));
    _exams = loaded;
    notifyListeners();
  }

  Future<void> addExam({
    required String title,
    required DateTime date,
    required int gyCorrect,
    required int gyWrong,
    required int gkCorrect,
    required int gkWrong,
    String? note,
  }) async {
    final id = _uuid.v4();
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

    await HiveService.mockExamsBox.put(id, exam.toMap());
    _exams.insert(0, exam);
    notifyListeners();
  }

  Future<void> deleteExam(String id) async {
    await HiveService.mockExamsBox.delete(id);
    _exams.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  double get averageTotalNet {
    if (_exams.isEmpty) return 0.0;
    final sum = _exams.fold(0.0, (acc, e) => acc + e.totalNet);
    return sum / _exams.length;
  }

  double get highestTotalNet {
    if (_exams.isEmpty) return 0.0;
    return _exams.map((e) => e.totalNet).reduce((a, b) => a > b ? a : b);
  }

  double get averageGyNet {
    if (_exams.isEmpty) return 0.0;
    final sum = _exams.fold(0.0, (acc, e) => acc + e.gyNet);
    return sum / _exams.length;
  }

  double get averageGkNet {
    if (_exams.isEmpty) return 0.0;
    final sum = _exams.fold(0.0, (acc, e) => acc + e.gkNet);
    return sum / _exams.length;
  }
}
