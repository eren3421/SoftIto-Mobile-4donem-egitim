import 'package:flutter_test/flutter_test.dart';
import 'package:susadim/features/water_tracker/controller/water_tracker_controller.dart';
import 'package:susadim/features/workout/controller/workout_controller.dart';
import 'package:susadim/features/workout/models/workout_item.dart';
import 'package:susadim/main.dart';

void main() {
  group('WaterTrackerController Tests', () {
    test('Başlangıç değerleri doğru olmalı', () {
      final controller = WaterTrackerController(initialTargetMl: 2000);
      expect(controller.dailyTargetMl, 2000);
      expect(controller.currentAmountMl, 0);
      expect(controller.progressRatio, 0.0);
      expect(controller.remainingMl, 2000);
    });

    test('Su eklendiğinde miktar ve ilerleme artmalı', () {
      final controller = WaterTrackerController(initialTargetMl: 1000);
      controller.addWater(500);

      expect(controller.currentAmountMl, 500);
      expect(controller.progressRatio, 0.5);
      expect(controller.remainingMl, 500);
      expect(controller.logs.length, 1);
    });

    test('Log silindiğinde miktar düşmeli', () {
      final controller = WaterTrackerController(initialTargetMl: 1000);
      controller.addWater(300);
      final logId = controller.logs.first.id;

      controller.removeLog(logId);
      expect(controller.currentAmountMl, 0);
      expect(controller.logs.isEmpty, isTrue);
    });
  });

  group('WorkoutController Tests', () {
    test('Egzersiz eklendiğinde kalori ve süre doğru hesaplanmalı', () {
      final controller = WorkoutController(initialTargetCalories: 500);
      // Koşu: 10 kcal/dk, 30 dk = 300 kcal
      controller.addWorkout(type: WorkoutType.running, durationMinutes: 30);

      expect(controller.totalCaloriesBurned, 300);
      expect(controller.totalDurationMinutes, 30);
      expect(controller.calorieProgress, 300 / 500);
    });
  });

  group('Widget Tests', () {
    testWidgets('Susadım uygulaması başarıyla render edilmeli', (tester) async {
      await tester.pumpWidget(const SusadimApp());
      expect(find.text('💧 Susadım - Su Takibi'), findsOneWidget);
      expect(find.text('Günlük Hedef'), findsOneWidget);
    });
  });
}
