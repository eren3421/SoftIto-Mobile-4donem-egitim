import 'package:flutter/material.dart';

/// Tema durumunu yöneten controller sınıfı.
/// project.md kurallarına uygun olarak ValueNotifier ile reaktif yönetim sağlar.
class ThemeController {
  final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  void toggleTheme() {
    themeMode.value =
        themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void setThemeMode(ThemeMode mode) {
    if (themeMode.value != mode) {
      themeMode.value = mode;
    }
  }

  void dispose() {
    themeMode.dispose();
  }
}
