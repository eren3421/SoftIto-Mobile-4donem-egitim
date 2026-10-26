// Zamanlayıcı (Timer) işlemleri için Dart'ın asenkron kütüphanesini içe aktarıyoruz
import 'dart:async';
// Flutter temel arayüz sınıflarını içe aktarıyoruz
import 'package:flutter/material.dart';
// Pomodoro ve mola süreleri gibi sabit değerleri içe aktarıyoruz
import '../core/constants/app_constants.dart';

// Çalışma sayacı modlarını tanımlayan enum (Pomodoro, Kısa Mola, Kronometre)
enum StudyTimerMode { pomodoro, shortBreak, stopwatch }

// Pomodoro ve Kronometre mantığını, geri sayımı ve çalışma sürelerini yöneten Provider
class TimerProvider with ChangeNotifier {
  // Geçerli çalışma modu (Varsayılan olarak Pomodoro ile başlar)
  StudyTimerMode _mode = StudyTimerMode.pomodoro;

  // Her saniyede bir tetiklenecek olan periyodik zamanlayıcı nesnesi
  Timer? _timer;

  // --- Saniye Cinsinden Süre Değişkenleri ---
  // Pomodoro çalışma süresi (25 dk * 60 sn = 1500 sn)
  int _pomodoroDuration = AppConstants.defaultPomodoroMinutes * 60;

  // Kısa mola süresi (5 dk * 60 sn = 300 sn)
  final int _shortBreakDuration = AppConstants.defaultShortBreakMinutes * 60;

  // Geriye kalan saniye miktarı
  int _remainingSeconds = AppConstants.defaultPomodoroMinutes * 60;

  // Serbest kronometre modunda geçen toplam saniye miktarı
  int _stopwatchElapsedSeconds = 0;

  // Zamanlayıcının şu an çalışıp çalışmadığını belirten durum bayrağı
  bool _isRunning = false;

  // Sürenin tamamlanıp tamamlanmadığını belirten bayrak
  bool _isFinished = false;

  // Geçerli moda dışarıdan erişim sağlayan getter
  StudyTimerMode get mode => _mode;

  // Sayacın aktif olarak çalışıp çalışmadığını bildiren getter
  bool get isRunning => _isRunning;

  // Sürenin bittiğini bildiren getter
  bool get isFinished => _isFinished;

  // Kalan saniyeyi döndüren getter
  int get remainingSeconds => _remainingSeconds;

  // Kronometrede geçen saniyeyi döndüren getter
  int get stopwatchElapsedSeconds => _stopwatchElapsedSeconds;

  // Ekranda gösterilecek saniyeyi belirleyen getter (Kronometrede geçen, Pomodoro'da kalan)
  int get currentDisplaySeconds {
    if (_mode == StudyTimerMode.stopwatch) {
      return _stopwatchElapsedSeconds;
    }
    return _remainingSeconds;
  }

  // Dairesel ilerleme çubuğu için tamamlanma yüzdesini (0.0 - 1.0) hesaplayan getter
  double get progress {
    if (_mode == StudyTimerMode.stopwatch) return 1.0;
    final total = _mode == StudyTimerMode.pomodoro ? _pomodoroDuration : _shortBreakDuration;
    if (total == 0) return 0.0;
    // Kalan sürenin toplam süreye oranını 0.0 ile 1.0 arasına sıkıştırıyoruz
    return (_remainingSeconds / total).clamp(0.0, 1.0);
  }

  // Saniyeyi '00:00' formatında biçimlendiren getter
  String get formattedTime {
    final secs = currentDisplaySeconds;
    final minutes = secs ~/ 60; // Tam dakikayı alır
    final seconds = secs % 60; // Kalan saniyeyi alır
    // Sayıları çift haneli (başına 0 ekleyerek) gösterir
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Çalışılan süreyi yuvarlayarak dakika cinsinden hesaplar (oturum kaydederken kullanılır)
  int get elapsedStudyMinutes {
    if (_mode == StudyTimerMode.stopwatch) {
      final mins = (_stopwatchElapsedSeconds / 60).round();
      return mins < 1 ? 1 : mins; // En az 1 dakika olarak kaydeder
    } else {
      final total = _mode == StudyTimerMode.pomodoro ? _pomodoroDuration : _shortBreakDuration;
      final elapsed = total - _remainingSeconds;
      final mins = (elapsed / 60).round();
      return mins < 1 ? 1 : mins;
    }
  }

  // Çalışma modunu (Pomodoro, Mola, Kronometre) değiştiren fonksiyon
  void switchMode(StudyTimerMode newMode) {
    if (_mode == newMode) return;
    _stopTimer(); // Önceki zamanlayıcıyı durdurur
    _mode = newMode; // Yeni modu atar
    _isFinished = false; // Bitiş durumunu sıfırlar
    _resetCurrentMode(); // Yeni modun başlangıç süresini hazırlar
    notifyListeners(); // Arayüzü günceller
  }

  // Zamanlayıcıyı başlatan fonksiyon
  void startTimer() {
    if (_isRunning) return; // Zaten çalışıyorsa tekrar başlatma
    _isRunning = true;
    _isFinished = false;
    notifyListeners();

    // Her saniye başı tetiklenen periyodik döngü
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_mode == StudyTimerMode.stopwatch) {
        // Kronometrede süreyi 1 saniye artırır
        _stopwatchElapsedSeconds++;
        notifyListeners();
      } else {
        // Pomodoro veya molada süreyi 1 saniye eksiltir
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          notifyListeners();
        } else {
          // Süre 0'a ulaştığında sayacı durdurup bitti bayrağını açar
          _stopTimer();
          _isFinished = true;
          notifyListeners();
        }
      }
    });
  }

  // Zamanlayıcıyı duraklatan fonksiyon
  void pauseTimer() {
    _stopTimer();
    notifyListeners();
  }

  // Zamanlayıcıyı sıfırlayan ve baştan başlatan fonksiyon
  void resetTimer() {
    _stopTimer();
    _isFinished = false;
    _resetCurrentMode();
    notifyListeners();
  }

  // Pomodoro çalışma süresi uzunluğunu değiştiren fonksiyon
  void setPomodoroMinutes(int minutes) {
    _pomodoroDuration = minutes * 60;
    if (_mode == StudyTimerMode.pomodoro && !_isRunning) {
      _remainingSeconds = _pomodoroDuration;
      notifyListeners();
    }
  }

  // Seçili moda göre süre değişkenlerini sıfırlayan özel yardımcı fonksiyon
  void _resetCurrentMode() {
    if (_mode == StudyTimerMode.pomodoro) {
      _remainingSeconds = _pomodoroDuration;
    } else if (_mode == StudyTimerMode.shortBreak) {
      _remainingSeconds = _shortBreakDuration;
    } else {
      _stopwatchElapsedSeconds = 0;
    }
  }

  // Zamanlayıcıyı güvenli şekilde sonlandıran fonksiyon
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  // Provider bellekten atıldığında (dispose) sızıntı (leak) olmaması için timer'ı iptal ederiz
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
