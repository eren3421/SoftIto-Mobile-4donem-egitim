import 'package:flutter/foundation.dart';
import 'sample_model.dart';

/// Örnek ValueNotifier Controller Sınıfı (Susadım Standartı)
class SampleActivityController {
  final ValueNotifier<int> currentCount = ValueNotifier<int>(250);
  final ValueNotifier<List<SampleActivityModel>> activities =
      ValueNotifier<List<SampleActivityModel>>([]);

  final int targetGoal = 1000;

  double get progressRatio => (currentCount.value / targetGoal).clamp(0.0, 1.0);
  bool get isGoalReached => currentCount.value >= targetGoal;

  void addActivity(String title, int amount) {
    if (amount <= 0) return;
    currentCount.value += amount;

    final newActivity = SampleActivityModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      value: amount,
      timestamp: DateTime.now(),
    );

    // Koleksiyon güncellenirken yeni referans atanarak listener'lar tetiklenir:
    activities.value = [newActivity, ...activities.value];
  }

  void reset() {
    currentCount.value = 0;
    activities.value = [];
  }

  /// Bellek sızıntılarını önlemek için tüm notifier'lar mutlaka dispose edilmelidir.
  void dispose() {
    currentCount.dispose();
    activities.dispose();
  }
}
