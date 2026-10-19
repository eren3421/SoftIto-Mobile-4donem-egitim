import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/water_tracker/controller/water_tracker_controller.dart';
import 'features/water_tracker/view/water_tracker_view.dart';
import 'features/workout/controller/workout_controller.dart';
import 'features/workout/view/workout_view.dart';

void main() {
  runApp(const SusadimApp());
}

class SusadimApp extends StatelessWidget {
  const SusadimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Susadım',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
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
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? '💧 Susadım - Su Takibi' : '🔥 Fitness & Kalori'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          WaterTrackerView(controller: _waterController),
          WorkoutView(controller: _workoutController),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: AppColors.surface,
        indicatorColor: _currentIndex == 0 ? AppColors.neonCyan : AppColors.neonOrange,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop, color: AppColors.background),
            label: 'Su Takibi',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center, color: AppColors.background),
            label: 'Egzersiz',
          ),
        ],
      ),
    );
  }
}
