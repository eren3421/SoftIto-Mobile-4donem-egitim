import 'package:flutter/material.dart';

/// Temanın reaktif durumunu yerel ValueNotifier ile yönetir
class ThemeController {
  final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.dark);

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  void toggleTheme() {
    if (themeMode.value == ThemeMode.dark) {
      themeMode.value = ThemeMode.light;
    } else {
      themeMode.value = ThemeMode.dark;
    }
  }

  void setTheme(ThemeMode mode) {
    themeMode.value = mode;
  }

  void dispose() {
    themeMode.dispose();
  }
}
