import 'package:flutter/foundation.dart';

enum WorkoutType {
  running('Koşu', 10),      // dakika başına ~10 kcal
  cycling('Bisiklet', 8),   // dakika başına ~8 kcal
  gym('Ağırlık', 7),        // dakika başına ~7 kcal
  swimming('Yüzme', 11),    // dakika başına ~11 kcal
  yoga('Yoga / Esneme', 4); // dakika başına ~4 kcal

  const WorkoutType(this.label, this.caloriesPerMinute);
  final String label;
  final int caloriesPerMinute;
}

@immutable
final class WorkoutItem {
  const WorkoutItem({
    required this.id,
    required this.type,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.timestamp,
  });

  final String id;
  final WorkoutType type;
  final int durationMinutes;
  final int caloriesBurned;
  final DateTime timestamp;
}
