import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:susadim/core/theme/theme_controller.dart';
import 'package:susadim/features/water_tracker/controllers/water_tracker_controller.dart';
import 'package:susadim/features/workout/controllers/workout_controller.dart';
import 'package:susadim/main.dart';

void main() {
  group('Susadım v1 Smoke & Unit Tests', () {
    testWidgets('App renders correctly with navigation, title and theme toggle', (WidgetTester tester) async {
      await tester.pumpWidget(const SusadimApp());
      await tester.pumpAndSettle();

      expect(find.text('Susadım v1'), findsOneWidget);
      expect(find.text('Su Takibi'), findsOneWidget);
      expect(find.text('Antrenman'), findsOneWidget);

      // Verify theme toggle button exists
      final themeToggleFinder = find.byTooltip('Aydınlık Moda Geç');
      expect(themeToggleFinder, findsOneWidget);

      // Tap theme toggle button
      await tester.tap(themeToggleFinder);
      await tester.pumpAndSettle();

      // Now tooltip should show switch back to dark mode
      expect(find.byTooltip('Karanlık Moda Geç'), findsOneWidget);
    });

    test('ThemeController toggles between dark and light mode', () {
      final themeController = ThemeController();
      expect(themeController.themeMode.value, ThemeMode.dark);
      expect(themeController.isDarkMode, isTrue);

      themeController.toggleTheme();
      expect(themeController.themeMode.value, ThemeMode.light);
      expect(themeController.isDarkMode, isFalse);

      themeController.toggleTheme();
      expect(themeController.themeMode.value, ThemeMode.dark);
      expect(themeController.isDarkMode, isTrue);

      themeController.dispose();
    });

    test('WaterTrackerController increments and resets water', () {
      final controller = WaterTrackerController();
      final initial = controller.currentWater.value;

      controller.addWater(250);
      expect(controller.currentWater.value, initial + 250);
      expect(controller.logs.value.first.amountMl, 250);

      controller.resetWater();
      expect(controller.currentWater.value, 0);
      expect(controller.logs.value, isEmpty);
      controller.dispose();
    });

    test('WorkoutController adds workout and recalculates calories', () {
      final controller = WorkoutController();
      final initialCalories = controller.totalCaloriesBurned;

      controller.addWorkout(
        title: 'Yüzme',
        category: 'Kardiyo',
        durationMinutes: 30,
        caloriesBurned: 200,
      );

      expect(controller.totalCaloriesBurned, initialCalories + 200);
      expect(controller.workouts.value.first.title, 'Yüzme');
      controller.dispose();
    });
  });
}
