import 'package:flutter/material.dart';

/// Uygulama temasını (aydınlık/koyu) yöneten reaktif kontrolcü.
/// ValueNotifier tabanlıdır ve harici paket gerektirmez.
class ThemeController {
  final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  void toggleTheme() {
    if (themeMode.value == ThemeMode.dark) {
      themeMode.value = ThemeMode.light;
    } else {
      themeMode.value = ThemeMode.dark;
    }
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
