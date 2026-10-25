import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/services/hive_service.dart';
import '../core/utils/kpss_calculator.dart';

import '../models/question_log.dart';
import '../models/study_session.dart';

class CourseStats {
  final String courseId;
  int totalCorrect = 0;
  int totalWrong = 0;
  int totalEmpty = 0;

  CourseStats({required this.courseId});

  int get totalQuestions => totalCorrect + totalWrong + totalEmpty;
  double get netScore => KpssCalculator.calculateNet(totalCorrect, totalWrong);
  double get accuracyRate => KpssCalculator.calculateAccuracy(totalCorrect, totalQuestions);
}

class QuestionProvider with ChangeNotifier {
  List<QuestionLog> _logs = [];
  List<StudySession> _sessions = [];
  final _uuid = const Uuid();

  QuestionProvider() {
    loadData();
  }

  List<QuestionLog> get logs => List.unmodifiable(_logs);
  List<StudySession> get sessions => List.unmodifiable(_sessions);

  void loadData() {
    // Load question logs
    final questionBox = HiveService.questionLogsBox;
    final List<QuestionLog> loadedLogs = [];
    for (final key in questionBox.keys) {
      final raw = questionBox.get(key);
      if (raw is Map) {
        loadedLogs.add(QuestionLog.fromMap(raw));
      }
    }
    // Sort descending by date
    loadedLogs.sort((a, b) => b.date.compareTo(a.date));
    _logs = loadedLogs;

    // Load study sessions
    final sessionBox = HiveService.studySessionsBox;
    final List<StudySession> loadedSessions = [];
    for (final key in sessionBox.keys) {
      final raw = sessionBox.get(key);
      if (raw is Map) {
        loadedSessions.add(StudySession.fromMap(raw));
      }
    }
    loadedSessions.sort((a, b) => b.date.compareTo(a.date));
    _sessions = loadedSessions;

    notifyListeners();
  }

  // --- QUESTION LOGS ---

  Future<void> addQuestionLog({
    required String courseId,
    required int correct,
    required int wrong,
    required int empty,
    required DateTime date,
    String? note,
  }) async {
    final id = _uuid.v4();
    final log = QuestionLog(
      id: id,
      courseId: courseId,
      correct: correct,
      wrong: wrong,
      empty: empty,
      date: date,
      note: note,
    );

    await HiveService.questionLogsBox.put(id, log.toMap());
    _logs.insert(0, log);
    notifyListeners();
  }

  Future<void> deleteQuestionLog(String id) async {
    await HiveService.questionLogsBox.delete(id);
    _logs.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  // --- STUDY SESSIONS ---

  Future<void> addStudySession({
    required String courseId,
    required int durationInMinutes,
    required DateTime date,
    required String type,
    String? note,
  }) async {
    final id = _uuid.v4();
    final session = StudySession(
      id: id,
      courseId: courseId,
      durationInMinutes: durationInMinutes,
      date: date,
      type: type,
      note: note,
    );

    await HiveService.studySessionsBox.put(id, session.toMap());
    _sessions.insert(0, session);
    notifyListeners();
  }

  // --- TODAY'S STATS ---

  List<QuestionLog> get todayLogs {
    final now = DateTime.now();
    return _logs.where((l) => KpssCalculator.isSameDay(l.date, now)).toList();
  }

  int get todayTotalQuestions {
    return todayLogs.fold(0, (sum, l) => sum + l.totalQuestions);
  }

  int get todayTotalCorrect {
    return todayLogs.fold(0, (sum, l) => sum + l.correct);
  }

  int get todayTotalWrong {
    return todayLogs.fold(0, (sum, l) => sum + l.wrong);
  }

  int get todayTotalEmpty {
    return todayLogs.fold(0, (sum, l) => sum + l.empty);
  }

  double get todayNetScore {
    return KpssCalculator.calculateNet(todayTotalCorrect, todayTotalWrong);
  }

  int get todayStudyDurationMinutes {
    final now = DateTime.now();
    final todaySessions = _sessions.where((s) => KpssCalculator.isSameDay(s.date, now));
    return todaySessions.fold(0, (sum, s) => sum + s.durationInMinutes);
  }

  // --- OVERALL & STATISTICAL AGGREGATIONS ---

  int get totalAllQuestions {
    return _logs.fold(0, (sum, l) => sum + l.totalQuestions);
  }

  int get totalAllCorrect {
    return _logs.fold(0, (sum, l) => sum + l.correct);
  }

  int get totalAllWrong {
    return _logs.fold(0, (sum, l) => sum + l.wrong);
  }

  double get totalAllNetScore {
    return KpssCalculator.calculateNet(totalAllCorrect, totalAllWrong);
  }

  double get overallAccuracyRate {
    return KpssCalculator.calculateAccuracy(totalAllCorrect, totalAllQuestions);
  }

  int get totalAllStudyMinutes {
    return _sessions.fold(0, (sum, s) => sum + s.durationInMinutes);
  }

  // Last 7 days question counts: returns map of normalized date -> count
  Map<DateTime, int> getLast7DaysQuestionCounts() {
    final result = <DateTime, int>{};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = KpssCalculator.normalizeDate(now.subtract(Duration(days: i)));
      result[day] = 0;
    }

    for (final log in _logs) {
      final normalized = KpssCalculator.normalizeDate(log.date);
      if (result.containsKey(normalized)) {
        result[normalized] = (result[normalized] ?? 0) + log.totalQuestions;
      }
    }
    return result;
  }

  // Breakdown by course
  Map<String, CourseStats> getCourseStats() {
    final stats = <String, CourseStats>{};
    for (final log in _logs) {
      final courseId = log.courseId;
      final stat = stats.putIfAbsent(courseId, () => CourseStats(courseId: courseId));
      stat.totalCorrect += log.correct;
      stat.totalWrong += log.wrong;
      stat.totalEmpty += log.empty;
    }
    return stats;
  }
}
