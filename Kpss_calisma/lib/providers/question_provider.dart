// Flutter temel arayüz sınıflarını içe aktarıyoruz
import 'package:flutter/material.dart';
// Benzersiz kimlik (UUID) üretmek için uuid paketini içe aktarıyoruz
import 'package:uuid/uuid.dart';
// Hive yerel veritabanı servisini içe aktarıyoruz
import '../core/services/hive_service.dart';
// KPSS net hesaplayıcı ve tarih yardımcı fonksiyonlarını içe aktarıyoruz
import '../core/utils/kpss_calculator.dart';

// Soru kaydı ve çalışma oturumu modellerini içe aktarıyoruz
import '../models/question_log.dart';
import '../models/study_session.dart';

// Belirli bir ders için toplanmış soru istatistiklerini (Doğru, Yanlış, Boş, Net) tutan yardımcı sınıf
class CourseStats {
  // İlgili dersin kimliği (Örn: 'turkce')
  final String courseId;

  // Dersten çözülen toplam doğru sayısı
  int totalCorrect = 0;

  // Dersten çözülen toplam yanlış sayısı
  int totalWrong = 0;

  // Dersten boş bırakılan toplam soru sayısı
  int totalEmpty = 0;

  // Kurucu fonksiyon; ders kimliği zorunludur
  CourseStats({required this.courseId});

  // Toplam soru adedini veren getter
  int get totalQuestions => totalCorrect + totalWrong + totalEmpty;

  // Derse ait toplam neti hesaplayan getter (Doğru - Yanlış / 4)
  double get netScore => KpssCalculator.calculateNet(totalCorrect, totalWrong);

  // Derse ait doğru çözme yüzdesini hesaplayan getter
  double get accuracyRate => KpssCalculator.calculateAccuracy(totalCorrect, totalQuestions);
}

// Soru çözümlerini, çalışma sürelerini ve genel istatistikleri yöneten merkezi Provider
class QuestionProvider with ChangeNotifier {
  // Kaydedilen soru çözümlerinin listesi
  List<QuestionLog> _logs = [];

  // Kaydedilen çalışma oturumlarının listesi
  List<StudySession> _sessions = [];

  // Benzersiz kimlik (UUID) oluşturucu nesne
  final _uuid = const Uuid();

  // Kurucu fonksiyon; oluşturulduğunda yerel veritabanındaki verileri yükler
  QuestionProvider() {
    loadData();
  }

  // Soru çözümlerini dışarıya değiştirilemez liste olarak açan getter
  List<QuestionLog> get logs => List.unmodifiable(_logs);

  // Çalışma sürelerini dışarıya değiştirilemez liste olarak açan getter
  List<StudySession> get sessions => List.unmodifiable(_sessions);

  // Hive veritabanından soru ve çalışma kayıtlarını çeken fonksiyon
  void loadData() {
    // Soru kayıtları kutusuna erişiyoruz
    final questionBox = HiveService.questionLogsBox;
    final List<QuestionLog> loadedLogs = [];
    for (final key in questionBox.keys) {
      final raw = questionBox.get(key);
      if (raw is Map) {
        loadedLogs.add(QuestionLog.fromMap(raw));
      }
    }
    // Soru çözümlerini tarihe göre yeniden eskiye (azalan sırada) sıralıyoruz
    loadedLogs.sort((a, b) => b.date.compareTo(a.date));
    _logs = loadedLogs;

    // Çalışma oturumları kutusuna erişiyoruz
    final sessionBox = HiveService.studySessionsBox;
    final List<StudySession> loadedSessions = [];
    for (final key in sessionBox.keys) {
      final raw = sessionBox.get(key);
      if (raw is Map) {
        loadedSessions.add(StudySession.fromMap(raw));
      }
    }
    // Oturumları tarihe göre yeniden eskiye sıralıyoruz
    loadedSessions.sort((a, b) => b.date.compareTo(a.date));
    _sessions = loadedSessions;

    // Dinleyicilere verilerin yüklendiğini bildiriyoruz
    notifyListeners();
  }

  // --- SORU KAYITLARI (QUESTION LOGS) METOTLARI ---

  // Yeni bir soru çözümü kaydı ekleyen ve kalıcı olarak saklayan fonksiyon
  Future<void> addQuestionLog({
    required String courseId,
    required int correct,
    required int wrong,
    required int empty,
    required DateTime date,
    String? note,
  }) async {
    // Benzersiz bir kimlik oluşturuyoruz
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

    // Hive veritabanına kaydediyoruz
    await HiveService.questionLogsBox.put(id, log.toMap());
    // Bellekteki listenin başına ekliyoruz
    _logs.insert(0, log);
    // Dinleyicileri haberdar ederek arayüzün anında güncellenmesini sağlıyoruz
    notifyListeners();
  }

  // Belirli bir soru kaydını silen fonksiyon
  Future<void> deleteQuestionLog(String id) async {
    // Hive veritabanından siliyoruz
    await HiveService.questionLogsBox.delete(id);
    // Bellekteki listeden de siliyoruz
    _logs.removeWhere((l) => l.id == id);
    // Ekranı güncelliyoruz
    notifyListeners();
  }

  // --- ÇALIŞMA OTURUMLARI (STUDY SESSIONS) METOTLARI ---

  // Yeni bir çalışma süresi kaydı ekleyen fonksiyon
  Future<void> addStudySession({
    required String courseId,
    required int durationInMinutes,
    required DateTime date,
    required String type,
    String? note,
  }) async {
    // Benzersiz kimlik oluşturuyoruz
    final id = _uuid.v4();
    final session = StudySession(
      id: id,
      courseId: courseId,
      durationInMinutes: durationInMinutes,
      date: date,
      type: type,
      note: note,
    );

    // Hive kutusuna yazıyoruz
    await HiveService.studySessionsBox.put(id, session.toMap());
    // Listenin başına ekliyoruz
    _sessions.insert(0, session);
    // Dinleyicileri haberdar ediyoruz
    notifyListeners();
  }

  // --- BUGÜNE AİT İSTATİSTİKLER (TODAY'S STATS) ---

  // Sadece bugün çözülen soru kayıtlarını filtreleyen getter
  List<QuestionLog> get todayLogs {
    final now = DateTime.now();
    return _logs.where((l) => KpssCalculator.isSameDay(l.date, now)).toList();
  }

  // Bugün çözülen toplam soru sayısını veren getter
  int get todayTotalQuestions {
    return todayLogs.fold(0, (sum, l) => sum + l.totalQuestions);
  }

  // Bugün yapılan toplam doğru sayısını veren getter
  int get todayTotalCorrect {
    return todayLogs.fold(0, (sum, l) => sum + l.correct);
  }

  // Bugün yapılan toplam yanlış sayısını veren getter
  int get todayTotalWrong {
    return todayLogs.fold(0, (sum, l) => sum + l.wrong);
  }

  // Bugün bırakılan toplam boş soru sayısını veren getter
  int get todayTotalEmpty {
    return todayLogs.fold(0, (sum, l) => sum + l.empty);
  }

  // Bugünün toplam KPSS netini hesaplayan getter
  double get todayNetScore {
    return KpssCalculator.calculateNet(todayTotalCorrect, todayTotalWrong);
  }

  // Bugün çalışılan toplam süreyi (dakika) hesaplayan getter
  int get todayStudyDurationMinutes {
    final now = DateTime.now();
    final todaySessions = _sessions.where((s) => KpssCalculator.isSameDay(s.date, now));
    return todaySessions.fold(0, (sum, s) => sum + s.durationInMinutes);
  }

  // --- GENEL TOPLAM VE ANALİZ METOTLARI ---

  // Bugüne kadar çözülmüş tüm soruların toplam adedini veren getter
  int get totalAllQuestions {
    return _logs.fold(0, (sum, l) => sum + l.totalQuestions);
  }

  // Bugüne kadarki toplam doğru sayısını veren getter
  int get totalAllCorrect {
    return _logs.fold(0, (sum, l) => sum + l.correct);
  }

  // Bugüne kadarki toplam yanlış sayısını veren getter
  int get totalAllWrong {
    return _logs.fold(0, (sum, l) => sum + l.wrong);
  }

  // Bugüne kadarki toplam KPSS net puanını hesaplayan getter
  double get totalAllNetScore {
    return KpssCalculator.calculateNet(totalAllCorrect, totalAllWrong);
  }

  // Genel toplamdaki başarı (doğru cevap) yüzdesini hesaplayan getter
  double get overallAccuracyRate {
    return KpssCalculator.calculateAccuracy(totalAllCorrect, totalAllQuestions);
  }

  // Bugüne kadar yapılan tüm çalışmaların toplam dakikasını veren getter
  int get totalAllStudyMinutes {
    return _sessions.fold(0, (sum, s) => sum + s.durationInMinutes);
  }

  // Son 7 günün soru sayılarını gün bazında harita (Tarih -> Soru Sayısı) olarak döndüren metot
  Map<DateTime, int> getLast7DaysQuestionCounts() {
    final result = <DateTime, int>{};
    final now = DateTime.now();

    // Son 7 günü geriye doğru döngüyle oluşturup başlangıçta 0 atıyoruz
    for (int i = 6; i >= 0; i--) {
      final day = KpssCalculator.normalizeDate(now.subtract(Duration(days: i)));
      result[day] = 0;
    }

    // Kayıtlı soruları gezip ait oldukları günün toplamına ekliyoruz
    for (final log in _logs) {
      final normalized = KpssCalculator.normalizeDate(log.date);
      if (result.containsKey(normalized)) {
        result[normalized] = (result[normalized] ?? 0) + log.totalQuestions;
      }
    }
    return result;
  }

  // Soru çözümlerini ders bazında gruplayıp CourseStats nesneleri olarak döndüren metot
  Map<String, CourseStats> getCourseStats() {
    final stats = <String, CourseStats>{};
    for (final log in _logs) {
      final courseId = log.courseId;
      // İlgili ders haritada yoksa oluşturur, varsa mevcut istatistiği getirir
      final stat = stats.putIfAbsent(courseId, () => CourseStats(courseId: courseId));
      // Doğru, yanlış ve boş sayılarını toplar
      stat.totalCorrect += log.correct;
      stat.totalWrong += log.wrong;
      stat.totalEmpty += log.empty;
    }
    return stats;
  }
}
