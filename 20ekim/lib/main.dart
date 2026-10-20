import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/home/views/home_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController();
  runApp(AsistanApp(themeController: themeController));
}

/// Asistan uygulamasının kök widget'ı.
/// Yalnızca ThemeController dinlemesi ve başlangıç yönlendirmesi yapar.
class AsistanApp extends StatelessWidget {
  final ThemeController themeController;

  const AsistanApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController.themeMode,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Asistan',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: HomeView(themeController: themeController),
        );
      },
    );
  }
}
