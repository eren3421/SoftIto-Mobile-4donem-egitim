import 'dart:math';

class HarvestCountdownInfo {
  final int elapsedDays;
  final int remainingDays;
  final double progressPercent; // 0 to 100
  final DateTime estimatedHarvestDate;
  final String stageTr;
  final String stageEn;
  final bool isReadyForHarvest;

  const HarvestCountdownInfo({
    required this.elapsedDays,
    required this.remainingDays,
    required this.progressPercent,
    required this.estimatedHarvestDate,
    required this.stageTr,
    required this.stageEn,
    required this.isReadyForHarvest,
  });

  String getStage(String lang) => lang == 'en' ? stageEn : stageTr;
}

class HarvestCalculator {
  static HarvestCountdownInfo calculate({
    required DateTime plantedAt,
    required int expectedHarvestDays,
    DateTime? today,
  }) {
    final now = today ?? DateTime.now();
    final nowDate = DateTime(now.year, now.month, now.day);
    final plantDate = DateTime(plantedAt.year, plantedAt.month, plantedAt.day);

    final rawElapsed = nowDate.difference(plantDate).inDays;
    final elapsedDays = max(0, rawElapsed);
    final remainingDays = max(0, expectedHarvestDays - elapsedDays);

    final progressRatio = (elapsedDays / expectedHarvestDays).clamp(0.0, 1.0);
    final progressPercent = (progressRatio * 100).roundToDouble();

    String stageTr;
    String stageEn;

    if (progressPercent <= 20) {
      stageTr = 'Çimlenme ve Fide Evresi';
      stageEn = 'Germination & Seedling Stage';
    } else if (progressPercent <= 55) {
      stageTr = 'Vejetatif Gelişim (Gövde/Yaprak)';
      stageEn = 'Vegetative Growth Stage';
    } else if (progressPercent <= 85) {
      stageTr = 'Çiçeklenme ve Meyve Tutumu';
      stageEn = 'Flowering & Fruiting Stage';
    } else {
      stageTr = 'Hasat Zamanı Geldi!';
      stageEn = 'Ready for Harvest!';
    }

    final estimatedHarvestDate =
        plantDate.add(Duration(days: expectedHarvestDays));

    return HarvestCountdownInfo(
      elapsedDays: elapsedDays,
      remainingDays: remainingDays,
      progressPercent: progressPercent,
      estimatedHarvestDate: estimatedHarvestDate,
      stageTr: stageTr,
      stageEn: stageEn,
      isReadyForHarvest: remainingDays == 0 || progressPercent >= 100,
    );
  }
}
