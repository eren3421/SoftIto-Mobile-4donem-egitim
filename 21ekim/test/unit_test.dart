import 'package:flutter_test/flutter_test.dart';
import 'package:bahcivan/utils/care_calculator.dart';
import 'package:bahcivan/utils/harvest_calculator.dart';
import 'package:bahcivan/data/seed_data.dart';

void main() {
  group('CareCalculator Tests', () {
    test('Overdue care returns RED status', () {
      final now = DateTime(2026, 10, 21);
      final lastAction = DateTime(2026, 10, 16); // 5 days ago, interval 3 days
      final status = CareCalculator.evaluate(
        lastActionDate: lastAction,
        intervalDays: 3,
        today: now,
      );

      expect(status.level, CareAlertLevel.overdue);
      expect(status.daysDelta, 2); // 2 days overdue
      expect(status.labelTr, '2 Gün Gecikti!');
      expect(status.labelEn, '2 Days Overdue!');
    });

    test('Due today or tomorrow returns AMBER status', () {
      final now = DateTime(2026, 10, 21);
      final lastAction = DateTime(2026, 10, 19); // 2 days ago, interval 3 days (1 day left)
      final status = CareCalculator.evaluate(
        lastActionDate: lastAction,
        intervalDays: 3,
        today: now,
      );

      expect(status.level, CareAlertLevel.dueSoon);
      expect(status.daysDelta, 1);
      expect(status.labelTr, 'Yarın Yapılmalı');
    });

    test('Healthy care returns GREEN status', () {
      final now = DateTime(2026, 10, 21);
      final lastAction = DateTime(2026, 10, 20); // 1 day ago, interval 14 days (13 days left)
      final status = CareCalculator.evaluate(
        lastActionDate: lastAction,
        intervalDays: 14,
        today: now,
      );

      expect(status.level, CareAlertLevel.healthy);
      expect(status.daysDelta, 13);
      expect(status.labelTr, '13 Gün Sonra');
      expect(status.labelEn, 'In 13 Days');
    });
  });

  group('HarvestCalculator Tests', () {
    test('Calculates elapsed, remaining and stage correctly', () {
      final now = DateTime(2026, 10, 21);
      final planted = DateTime(2026, 9, 25); // 26 days elapsed
      final info = HarvestCalculator.calculate(
        plantedAt: planted,
        expectedHarvestDays: 70,
        today: now,
      );

      expect(info.elapsedDays, 26);
      expect(info.remainingDays, 44);
      expect(info.isReadyForHarvest, false);
      // 26 / 70 = ~37% -> Vegetative growth
      expect(info.stageTr, 'Vejetatif Gelişim (Gövde/Yaprak)');
    });

    test('Identifies ready for harvest state', () {
      final now = DateTime(2026, 10, 21);
      final planted = DateTime(2026, 8, 1); // 81 days ago, expected 70
      final info = HarvestCalculator.calculate(
        plantedAt: planted,
        expectedHarvestDays: 70,
        today: now,
      );

      expect(info.remainingDays, 0);
      expect(info.isReadyForHarvest, true);
      expect(info.stageTr, 'Hasat Zamanı Geldi!');
    });
  });

  group('SeedData Integrity', () {
    test('Initial catalog contains 6 plant species and 6 pest diagnoses', () {
      expect(SeedData.plantSpeciesList.length, 6);
      expect(SeedData.pestDiagnosisList.length, 6);
      expect(SeedData.getInitialGreenhouses().length, 2);
      expect(SeedData.getInitialPlants().length, 4);
    });
  });
}
