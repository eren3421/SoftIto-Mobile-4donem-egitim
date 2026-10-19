import 'package:flutter/foundation.dart';
import '../models/workout_item.dart';

final class WorkoutController extends ChangeNotifier {
  WorkoutController({int initialTargetCalories = 500})
      : _targetCalories = initialTargetCalories;

  int _targetCalories;
  final List<WorkoutItem> _workouts = [];

  int get targetCalories => _targetCalories;
  List<WorkoutItem> get workouts => List.unmodifiable(_workouts);

  int get totalCaloriesBurned =>
      _workouts.fold(0, (sum, item) => sum + item.caloriesBurned);

  int get totalDurationMinutes =>
      _workouts.fold(0, (sum, item) => sum + item.durationMinutes);

  double get calorieProgress =>
      _targetCalories == 0 ? 0.0 : (totalCaloriesBurned / _targetCalories).clamp(0.0, 1.0);

  void addWorkout({
    required WorkoutType type,
    required int durationMinutes,
  }) {
    if (durationMinutes <= 0) return;
    final calories = durationMinutes * type.caloriesPerMinute;
    final workout = WorkoutItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      durationMinutes: durationMinutes,
      caloriesBurned: calories,
      timestamp: DateTime.now(),
    );
    _workouts.insert(0, workout);
    notifyListeners();
  }

  void removeWorkout(String id) {
    _workouts.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updateTargetCalories(int newTarget) {
    if (newTarget <= 0) return;
    _targetCalories = newTarget;
    notifyListeners();
  }

  void reset() {
    _workouts.clear();
    notifyListeners();
  }
}
