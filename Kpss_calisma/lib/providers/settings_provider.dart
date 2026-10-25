import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/services/hive_service.dart';

class SettingsProvider with ChangeNotifier {
  late int _dailyGoal;
  late bool _isDarkTheme;

  SettingsProvider() {
    _loadSettings();
  }

  int get dailyGoal => _dailyGoal;
  bool get isDarkTheme => _isDarkTheme;

  void _loadSettings() {
    final box = HiveService.settingsBox;
    _dailyGoal = box.get(AppConstants.keyDailyGoal, defaultValue: AppConstants.defaultDailyGoal) as int;
    _isDarkTheme = box.get(AppConstants.keyIsDarkTheme, defaultValue: false) as bool;
  }

  Future<void> setDailyGoal(int newGoal) async {
    if (newGoal <= 0) return;
    _dailyGoal = newGoal;
    await HiveService.settingsBox.put(AppConstants.keyDailyGoal, newGoal);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    await HiveService.settingsBox.put(AppConstants.keyIsDarkTheme, _isDarkTheme);
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkTheme = isDark;
    await HiveService.settingsBox.put(AppConstants.keyIsDarkTheme, _isDarkTheme);
    notifyListeners();
  }
}
