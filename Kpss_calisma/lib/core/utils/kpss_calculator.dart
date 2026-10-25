class KpssCalculator {
  /// Standard KPSS 4 Wrong cancels 1 Correct rule
  static double calculateNet(int correct, int wrong) {
    return correct - (wrong / 4.0);
  }

  /// Calculates accuracy percentage with division by zero safety
  static double calculateAccuracy(int correct, int total) {
    if (total <= 0) return 0.0;
    final accuracy = (correct / total) * 100.0;
    return accuracy > 100.0 ? 100.0 : (accuracy < 0.0 ? 0.0 : accuracy);
  }

  /// Normalizes date by clearing hour, minute, second and millisecond
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Checks if two dates are on the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
