import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/services/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'main_screen.dart';
import 'providers/curriculum_provider.dart';
import 'providers/mock_exam_provider.dart';
import 'providers/question_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/timer_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => CurriculumProvider()),
        ChangeNotifierProvider(create: (_) => QuestionProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => MockExamProvider()),
      ],
      child: const KpssApp(),
    ),
  );
}

class KpssApp extends StatelessWidget {
  const KpssApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsProv.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: const MainScreen(),
    );
  }
}
