// JSON çözümleme (decode) işlemleri için Dart dönüştürücü kütüphanesini içe aktarıyoruz
import 'dart:convert';
// Flutter temel arayüz sınıflarını içe aktarıyoruz
import 'package:flutter/material.dart';
// Uygulama içerisindeki varlık (asset) dosyalarını okumak için rootBundle servisini içe aktarıyoruz
import 'package:flutter/services.dart';
// Uygulama genel sabitlerini (durum kodları ve dosya yolları) içe aktarıyoruz
import '../core/constants/app_constants.dart';
// Hive yerel depolama servisini içe aktarıyoruz
import '../core/services/hive_service.dart';
// Ders ve Konu modellerini içe aktarıyoruz
import '../models/topic.dart';

// KPSS ders müfredatını, konularını ve tamamlama durumlarını yöneten Provider sınıfı
class CurriculumProvider with ChangeNotifier {
  // Yüklenen derslerin listesi
  List<Course> _courses = [];

  // Konu id'si ile durumunu (0: Başlanmadı, 1: Tekrar, 2: Bitti) eşleştiren harita
  final Map<String, int> _topicStatuses = {};

  // Müfredatın yüklenme durumunu belirten bayrak (loading state)
  bool _isLoading = true;

  // Kurucu fonksiyon; sınıf ilk çalıştığında müfredatı yükler
  CurriculumProvider() {
    loadCurriculum();
  }

  // Dersler listesine dışarıdan erişim sağlayan getter
  List<Course> get courses => _courses;

  // Yüklenme durumuna dışarıdan erişim sağlayan getter
  bool get isLoading => _isLoading;

  // Konu durum haritasına dışarıdan erişim sağlayan getter
  Map<String, int> get topicStatuses => _topicStatuses;

  // JSON dosyasından müfredatı ve Hive'dan konu tamamlama durumlarını yükleyen asenkron metot
  Future<void> loadCurriculum() async {
    // Yükleme başladığını bildiriyoruz
    _isLoading = true;
    notifyListeners();

    try {
      // Yerel kpss_topics.json dosyasını metin olarak okuyoruz
      final jsonString = await rootBundle.loadString(AppConstants.assetTopicsJson);
      // JSON metnini Map nesnesine ayrıştırıyoruz
      final Map<String, dynamic> data = json.decode(jsonString);
      // Dersler dizisini ham liste olarak alıyoruz
      final coursesRaw = data['courses'] as List<dynamic>? ?? [];
      // Her bir ders haritasını Course modeline dönüştürüp listemize aktarıyoruz
      _courses = coursesRaw.map((c) => Course.fromMap(Map<String, dynamic>.from(c as Map))).toList();

      // Hive'daki konu durum kutusunu açıyoruz
      final box = HiveService.topicStatusBox;
      // Kutudaki kayıtlı tüm anahtar ve değerleri haritamıza aktarıyoruz
      for (final key in box.keys) {
        final val = box.get(key);
        if (val is int) {
          _topicStatuses[key.toString()] = val;
        }
      }
    } catch (e) {
      // Hata oluşursa konsola hata detayını yazdırıyoruz
      debugPrint('Error loading curriculum: $e');
    } finally {
      // Yükleme tamamlandığında yükleme bayrağını kapatıp ekranı güncelliyoruz
      _isLoading = false;
      notifyListeners();
    }
  }

  // Belirli bir konunun tamamlanma durumunu döndüren fonksiyon
  int getTopicStatus(String topicId) {
    // Kayıtlı bir durum yoksa varsayılan olarak 'statusNotStarted' (0) döner
    return _topicStatuses[topicId] ?? AppConstants.statusNotStarted;
  }

  // Belirli bir konunun durumunu değiştiren ve Hive'a kalıcı olarak kaydeden fonksiyon
  Future<void> setTopicStatus(String topicId, int status) async {
    // Bellekteki haritada konunun durumunu güncelliyoruz
    _topicStatuses[topicId] = status;
    // Hive veritabanındaki kutuya yeni durumu kaydediyoruz
    await HiveService.topicStatusBox.put(topicId, status);
    // Dinleyicilere haber vererek arayüzün anında güncellenmesini sağlıyoruz
    notifyListeners();
  }

  // Bir dersin tamamen bitirilen (status == 2) konu sayısını hesaplar
  int getCourseCompletedTopics(String courseId) {
    // İlgili dersi buluruz
    final course = _courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => Course(
        id: '',
        title: '',
        category: '',
        colorHex: 0,
        iconName: '',
        questionCount: 0,
        topics: [],
      ),
    );
    // Konu yoksa 0 döner
    if (course.topics.isEmpty) return 0;
    // Durumu bitirildi (statusCompleted) olan konuların adedini sayar
    return course.topics.where((t) => getTopicStatus(t.id) == AppConstants.statusCompleted).length;
  }

  // Bir dersin konu tamamlama yüzdesini (0.0 ile 1.0 arasında) hesaplar
  double getCourseProgress(String courseId) {
    // İlgili dersi buluruz
    final course = _courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => Course(
        id: '',
        title: '',
        category: '',
        colorHex: 0,
        iconName: '',
        questionCount: 0,
        topics: [],
      ),
    );
    // Konu yoksa 0.0 döner
    if (course.topics.isEmpty) return 0.0;
    // Tamamlanan konu sayısını alır
    final completed = getCourseCompletedTopics(courseId);
    // Tamamlanan konuyu toplam konuya bölerek oranı bulur
    return completed / course.topics.length;
  }

  // Tüm KPSS müfredatının genel tamamlanma oranını (0.0 - 1.0) döndüren getter
  double get overallProgress {
    int totalTopics = 0;
    int completedTopics = 0;

    // Tüm dersleri gezip toplam ve biten konu sayılarını toplarız
    for (final course in _courses) {
      totalTopics += course.topics.length;
      completedTopics += getCourseCompletedTopics(course.id);
    }

    // Toplam konu sıfırsa sıfıra bölme hatasını engellemek için 0.0 döner
    if (totalTopics == 0) return 0.0;
    return completedTopics / totalTopics;
  }

  // Tüm müfredatta bitirilen toplam konu sayısını veren getter
  int get totalCompletedTopics {
    int count = 0;
    for (final course in _courses) {
      count += getCourseCompletedTopics(course.id);
    }
    return count;
  }

  // Tüm müfredattaki toplam alt konu adedini veren getter
  int get totalTopicsCount {
    int count = 0;
    for (final course in _courses) {
      count += course.topics.length;
    }
    return count;
  }
}
