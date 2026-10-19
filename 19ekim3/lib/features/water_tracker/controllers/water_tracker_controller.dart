import 'package:flutter/foundation.dart';
import '../models/water_log_model.dart';

class WaterTrackerController {
  final ValueNotifier<int> currentWater = ValueNotifier<int>(750);
  final ValueNotifier<List<WaterLog>> logs = ValueNotifier<List<WaterLog>>([
    WaterLog(
      id: '1',
      amountMl: 250,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    WaterLog(
      id: '2',
      amountMl: 500,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ]);

  final int dailyGoalMl = 2500;

  double get progressRatio =>
      (currentWater.value / dailyGoalMl).clamp(0.0, 1.0);

  void addWater(int amountMl) {
    currentWater.value += amountMl;
    final newLog = WaterLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amountMl: amountMl,
      timestamp: DateTime.now(),
    );
    logs.value = [newLog, ...logs.value];
  }

  void resetWater() {
    currentWater.value = 0;
    logs.value = [];
  }

  void dispose() {
    currentWater.dispose();
    logs.dispose();
  }
}
