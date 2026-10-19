import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/water_tracker/controllers/water_tracker_controller.dart';
import 'features/water_tracker/views/water_tracker_view.dart';
import 'features/workout/controllers/workout_controller.dart';
import 'features/workout/views/workout_view.dart';

void main() {
  runApp(const SusadimApp());
}

class SusadimApp extends StatefulWidget {
  const SusadimApp({super.key});

  @override
  State<SusadimApp> createState() => _SusadimAppState();
}

class _SusadimAppState extends State<SusadimApp> {
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = ThemeController();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeController.themeMode,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Susadım v1',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: MainNavigationScreen(themeController: _themeController),
        );
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final ThemeController themeController;

  const MainNavigationScreen({
    super.key,
    required this.themeController,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late final WaterTrackerController _waterController;
  late final WorkoutController _workoutController;

  @override
  void initState() {
    super.initState();
    _waterController = WaterTrackerController();
    _workoutController = WorkoutController();
  }

  @override
  void dispose() {
    _waterController.dispose();
    _workoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          WaterTrackerView(controller: _waterController),
          WorkoutView(controller: _workoutController),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/icons/app_icon.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          const Text('Susadım v1'),
        ],
      ),
      actions: [
        _buildThemeToggleButton(),
        if (_currentIndex == 0)
          IconButton(
            tooltip: 'Sıfırla',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _waterController.resetWater(),
          )
        else
          IconButton(
            tooltip: 'Temizle',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _workoutController.resetWorkouts(),
          ),
      ],
    );
  }

  Widget _buildThemeToggleButton() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: widget.themeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return IconButton(
          tooltip: isDark ? 'Aydınlık Moda Geç' : 'Karanlık Moda Geç',
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: isDark ? AppColors.neonOrange : AppColors.neonCyan,
          ),
          onPressed: () => widget.themeController.toggleTheme(),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cyan = isDark ? AppColors.neonCyanBright : AppColors.neonCyan;
    final lime = isDark ? AppColors.neonLimeBright : AppColors.neonLime;

    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.water_drop_outlined),
          selectedIcon: Icon(Icons.water_drop_rounded, color: cyan),
          label: 'Su Takibi',
        ),
        NavigationDestination(
          icon: const Icon(Icons.fitness_center_outlined),
          selectedIcon: Icon(Icons.fitness_center_rounded, color: lime),
          label: 'Antrenman',
        ),
      ],
    );
  }
}
