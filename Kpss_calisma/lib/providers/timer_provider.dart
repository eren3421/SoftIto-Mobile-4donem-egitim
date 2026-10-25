import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

enum StudyTimerMode { pomodoro, shortBreak, stopwatch }

class TimerProvider with ChangeNotifier {
  StudyTimerMode _mode = StudyTimerMode.pomodoro;
  Timer? _timer;

  // Seconds
  int _pomodoroDuration = AppConstants.defaultPomodoroMinutes * 60;
  final int _shortBreakDuration = AppConstants.defaultShortBreakMinutes * 60;
  int _remainingSeconds = AppConstants.defaultPomodoroMinutes * 60;

  int _stopwatchElapsedSeconds = 0;

  bool _isRunning = false;
  bool _isFinished = false;

  StudyTimerMode get mode => _mode;
  bool get isRunning => _isRunning;
  bool get isFinished => _isFinished;
  int get remainingSeconds => _remainingSeconds;
  int get stopwatchElapsedSeconds => _stopwatchElapsedSeconds;

  int get currentDisplaySeconds {
    if (_mode == StudyTimerMode.stopwatch) {
      return _stopwatchElapsedSeconds;
    }
    return _remainingSeconds;
  }

  double get progress {
    if (_mode == StudyTimerMode.stopwatch) return 1.0;
    final total = _mode == StudyTimerMode.pomodoro ? _pomodoroDuration : _shortBreakDuration;
    if (total == 0) return 0.0;
    return (_remainingSeconds / total).clamp(0.0, 1.0);
  }

  String get formattedTime {
    final secs = currentDisplaySeconds;
    final minutes = secs ~/ 60;
    final seconds = secs % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int get elapsedStudyMinutes {
    if (_mode == StudyTimerMode.stopwatch) {
      final mins = (_stopwatchElapsedSeconds / 60).round();
      return mins < 1 ? 1 : mins;
    } else {
      final total = _mode == StudyTimerMode.pomodoro ? _pomodoroDuration : _shortBreakDuration;
      final elapsed = total - _remainingSeconds;
      final mins = (elapsed / 60).round();
      return mins < 1 ? 1 : mins;
    }
  }

  void switchMode(StudyTimerMode newMode) {
    if (_mode == newMode) return;
    _stopTimer();
    _mode = newMode;
    _isFinished = false;
    _resetCurrentMode();
    notifyListeners();
  }

  void startTimer() {
    if (_isRunning) return;
    _isRunning = true;
    _isFinished = false;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_mode == StudyTimerMode.stopwatch) {
        _stopwatchElapsedSeconds++;
        notifyListeners();
      } else {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          notifyListeners();
        } else {
          _stopTimer();
          _isFinished = true;
          notifyListeners();
        }
      }
    });
  }

  void pauseTimer() {
    _stopTimer();
    notifyListeners();
  }

  void resetTimer() {
    _stopTimer();
    _isFinished = false;
    _resetCurrentMode();
    notifyListeners();
  }

  void setPomodoroMinutes(int minutes) {
    _pomodoroDuration = minutes * 60;
    if (_mode == StudyTimerMode.pomodoro && !_isRunning) {
      _remainingSeconds = _pomodoroDuration;
      notifyListeners();
    }
  }

  void _resetCurrentMode() {
    if (_mode == StudyTimerMode.pomodoro) {
      _remainingSeconds = _pomodoroDuration;
    } else if (_mode == StudyTimerMode.shortBreak) {
      _remainingSeconds = _shortBreakDuration;
    } else {
      _stopwatchElapsedSeconds = 0;
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
