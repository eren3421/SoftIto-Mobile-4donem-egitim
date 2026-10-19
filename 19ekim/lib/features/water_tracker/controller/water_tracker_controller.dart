import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/water_log.dart';

final class WaterTrackerController extends ChangeNotifier {
  WaterTrackerController({int initialTargetMl = 2500})
      : _dailyTargetMl = initialTargetMl;

  int _dailyTargetMl;
  final List<WaterLog> _logs = [];

  int get dailyTargetMl => _dailyTargetMl;
  List<WaterLog> get logs => List.unmodifiable(_logs);

  int get currentAmountMl => _logs.fold(0, (sum, log) => sum + log.amountMl);

  double get progressRatio =>
      _dailyTargetMl == 0 ? 0.0 : math.min(currentAmountMl / _dailyTargetMl, 1.0);

  int get remainingMl => math.max(0, _dailyTargetMl - currentAmountMl);

  void addWater(int amountMl) {
    if (amountMl <= 0) return;
    final log = WaterLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      amountMl: amountMl,
      timestamp: DateTime.now(),
    );
    _logs.insert(0, log);
    notifyListeners();
  }

  void removeLog(String id) {
    _logs.removeWhere((log) => log.id == id);
    notifyListeners();
  }

  void updateTarget(int newTargetMl) {
    if (newTargetMl <= 0) return;
    _dailyTargetMl = newTargetMl;
    notifyListeners();
  }

  void reset() {
    _logs.clear();
    notifyListeners();
  }
}
