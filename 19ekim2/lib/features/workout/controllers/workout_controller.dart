import 'package:flutter/foundation.dart';
import '../models/workout_model.dart';

class WorkoutController {
  final ValueNotifier<List<WorkoutSession>> workouts =
      ValueNotifier<List<WorkoutSession>>([
    WorkoutSession(
      id: 'w1',
      title: 'Kuvvet Antrenmanı (Push)',
      category: 'Ağırlık',
      durationMinutes: 45,
      caloriesBurned: 320,
      date: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    WorkoutSession(
      id: 'w2',
      title: 'HIIT Kardiyo & İp Atlama',
      category: 'Kardiyo',
      durationMinutes: 20,
      caloriesBurned: 190,
      date: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ]);

  final int dailyCalorieGoal = 600;

  int get totalCaloriesBurned =>
      workouts.value.fold(0, (sum, item) => sum + item.caloriesBurned);

  int get totalMinutes =>
      workouts.value.fold(0, (sum, item) => sum + item.durationMinutes);

  void addWorkout({
    required String title,
    required String category,
    required int durationMinutes,
    required int caloriesBurned,
  }) {
    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      durationMinutes: durationMinutes,
      caloriesBurned: caloriesBurned,
      date: DateTime.now(),
    );
    workouts.value = [session, ...workouts.value];
  }

  void resetWorkouts() {
    workouts.value = [];
  }

  void dispose() {
    workouts.dispose();
  }
}
