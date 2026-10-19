import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/diary/controllers/diary_controller.dart';
import 'features/diary/views/diary_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController();
  final diaryController = DiaryController();

  runApp(
    DefterimApp(
      themeController: themeController,
      diaryController: diaryController,
    ),
  );
}

/// Uygulama kök bileşeni.
/// project.md kuralı gereğince sadece tema dinlemesi ve ana ekran yönlendirmesi içerir.
class DefterimApp extends StatelessWidget {
  final ThemeController themeController;
  final DiaryController diaryController;

  const DefterimApp({
    super.key,
    required this.themeController,
    required this.diaryController,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController.themeMode,
      builder: (context, currentThemeMode, _) {
        return MaterialApp(
          title: 'Defterim',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
          home: DiaryView(
            controller: diaryController,
            themeController: themeController,
          ),
        );
      },
    );
  }
}
