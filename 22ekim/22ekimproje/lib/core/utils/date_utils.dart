import 'package:intl/intl.dart';

class HabitDateUtils {
  HabitDateUtils._();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _turkishDisplayFormat = DateFormat('d MMMM yyyy, EEEE', 'tr_TR');
  static final DateFormat _shortFormat = DateFormat('d MMM', 'tr_TR');

  /// DateTime'ı YYYY-MM-DD formatında normalize string'e çevirir
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// YYYY-MM-DD string'ini DateTime'a çevirir
  static DateTime parseDate(String dateStr) {
    return _dateFormat.parse(dateStr);
  }

  /// Bugünün tarihini YYYY-MM-DD olarak döner
  static String get todayString => formatDate(DateTime.now());

  /// Dünün tarihini YYYY-MM-DD olarak döner
  static String get yesterdayString =>
      formatDate(DateTime.now().subtract(const Duration(days: 1)));

  /// Türkçe okunabilir uzun tarih
  static String formatTurkishFull(DateTime date) {
    try {
      return _turkishDisplayFormat.format(date);
    } catch (_) {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  /// Kısa tarih (örn: 22 Eki)
  static String formatShort(DateTime date) {
    try {
      return _shortFormat.format(date);
    } catch (_) {
      return '${date.day}/${date.month}';
    }
  }

  /// Aktif zincir (Streak) hesaplama:
  /// Bugün veya dünden başlayarak geriye doğru kesintisiz gün sayısını bulur.
  static int calculateCurrentStreak(List<String> completedDates) {
    if (completedDates.isEmpty) return 0;

    final Set<String> dateSet = completedDates.toSet();
    final now = DateTime.now();
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    final todayFormatted = formatDate(checkDate);
    final yesterdayFormatted = formatDate(checkDate.subtract(const Duration(days: 1)));

    // Eğer ne bugün ne de dün tamamlanmamışsa aktif seri bozulmuştur (0)
    if (!dateSet.contains(todayFormatted) && !dateSet.contains(yesterdayFormatted)) {
      return 0;
    }

    // Başlangıç noktası: Bugün yapılmışsa bugün, yapılmamışsa dün
    if (!dateSet.contains(todayFormatted)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    int streak = 0;
    while (dateSet.contains(formatDate(checkDate))) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// En uzun zincir (Longest Streak) hesaplama:
  /// Tüm geçmiş tarihlerdeki en uzun aralıksız seriyi bulur.
  static int calculateLongestStreak(List<String> completedDates) {
    if (completedDates.isEmpty) return 0;

    final List<DateTime> sortedDates = completedDates
        .map((d) {
          try {
            final parsed = _dateFormat.parse(d);
            return DateTime(parsed.year, parsed.month, parsed.day);
          } catch (_) {
            return null;
          }
        })
        .whereType<DateTime>()
        .toSet()
        .toList()
      ..sort();

    if (sortedDates.isEmpty) return 0;

    int longest = 1;
    int current = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final prev = sortedDates[i - 1];
      final curr = sortedDates[i];

      final diff = curr.difference(prev).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) {
          longest = current;
        }
      } else if (diff > 1) {
        current = 1;
      }
    }

    return longest;
  }

  /// Son [daysCount] gün içindeki tamamlanma oranını döner (0.0 - 1.0)
  static double calculateCompletionRate(List<String> completedDates, int daysCount) {
    if (daysCount <= 0) return 0.0;
    final Set<String> dateSet = completedDates.toSet();
    final now = DateTime.now();

    int completed = 0;
    for (int i = 0; i < daysCount; i++) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      if (dateSet.contains(formatDate(d))) {
        completed++;
      }
    }

    return completed / daysCount;
  }

  /// Son 7 gün için gün adı ve tamamlanma durumu listesi
  static List<Map<String, dynamic>> getLast7DaysStatus(List<String> completedDates) {
    final Set<String> dateSet = completedDates.toSet();
    final now = DateTime.now();
    final List<Map<String, dynamic>> list = [];

    const weekDays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    for (int i = 6; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final dateStr = formatDate(d);
      final isDone = dateSet.contains(dateStr);
      final dayName = weekDays[(d.weekday - 1) % 7];

      list.add({
        'date': d,
        'dateStr': dateStr,
        'dayName': dayName,
        'isDone': isDone,
        'dayNumber': d.day,
      });
    }

    return list;
  }

  /// Son [lookbackDays] gün içindeki hafta içi vs. hafta sonu ve gün bazlı dağılımı analiz eder
  static Map<String, dynamic> analyzeDayPatterns(
    List<String> completedDates, {
    int lookbackDays = 30,
  }) {
    if (completedDates.isEmpty) {
      return {
        'weekdayRate': 0.0,
        'weekendRate': 0.0,
        'weekdayPercent': '0.0',
        'weekendPercent': '0.0',
        'bestDayName': 'Belirlenmedi',
        'worstDayName': 'Belirlenmedi',
        'bestDayRate': 0.0,
        'worstDayRate': 0.0,
        'summary': 'Yeterli veri bulunmuyor (Henüz tamamlama kaydı girilmemiş).',
        'weekendComparison': 'Veri yetersiz.',
      };
    }

    final Set<String> dateSet = completedDates.toSet();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    const dayNames = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar'
    ];

    final dayTotalOccurrences = List.filled(7, 0);
    final dayCompletedCounts = List.filled(7, 0);

    int weekdayCompleted = 0;
    int weekdayTotal = 0;
    int weekendCompleted = 0;
    int weekendTotal = 0;

    for (int i = 0; i < lookbackDays; i++) {
      final d = today.subtract(Duration(days: i));
      final dayIndex = (d.weekday - 1); // 0: Pzt, ..., 6: Paz
      dayTotalOccurrences[dayIndex]++;

      final isCompleted = dateSet.contains(formatDate(d));
      if (isCompleted) {
        dayCompletedCounts[dayIndex]++;
      }

      if (d.weekday <= 5) {
        weekdayTotal++;
        if (isCompleted) weekdayCompleted++;
      } else {
        weekendTotal++;
        if (isCompleted) weekendCompleted++;
      }
    }

    final double weekdayRate =
        weekdayTotal > 0 ? (weekdayCompleted / weekdayTotal) : 0.0;
    final double weekendRate =
        weekendTotal > 0 ? (weekendCompleted / weekendTotal) : 0.0;

    int bestDayIndex = 0;
    double bestRate = -1.0;
    int worstDayIndex = 0;
    double worstRate = 2.0;

    for (int i = 0; i < 7; i++) {
      final rate = dayTotalOccurrences[i] > 0
          ? (dayCompletedCounts[i] / dayTotalOccurrences[i])
          : 0.0;
      if (rate > bestRate) {
        bestRate = rate;
        bestDayIndex = i;
      }
      if (rate < worstRate) {
        worstRate = rate;
        worstDayIndex = i;
      }
    }

    final weekdayPercent = (weekdayRate * 100).toStringAsFixed(1);
    final weekendPercent = (weekendRate * 100).toStringAsFixed(1);
    final bestDayName = dayNames[bestDayIndex];
    final worstDayName = dayNames[worstDayIndex];

    String weekendComparison;
    if (weekdayRate > weekendRate + 0.15) {
      weekendComparison = 'Hafta sonları belirgin bir motivasyon/rutin düşüşü yaşanıyor (Hafta sonu sendromu).';
    } else if (weekendRate > weekdayRate + 0.15) {
      weekendComparison = 'Hafta sonu odaklanması hafta içine göre belirgin şekilde daha yüksek.';
    } else {
      weekendComparison = 'Hafta içi ve hafta sonu istikrarı birbirine dengeli seyrediyor.';
    }

    final summary =
        'Hafta içi başarı: %$weekdayPercent, Hafta sonu başarı: %$weekendPercent ($weekendComparison). En istikrarlı gün: $bestDayName (%${(bestRate * 100).toStringAsFixed(0)}), En çok aksatılan gün: $worstDayName (%${(worstRate * 100).toStringAsFixed(0)}).';

    return {
      'weekdayRate': weekdayRate,
      'weekendRate': weekendRate,
      'weekdayPercent': weekdayPercent,
      'weekendPercent': weekendPercent,
      'bestDayName': bestDayName,
      'worstDayName': worstDayName,
      'bestDayRate': bestRate,
      'worstDayRate': worstRate,
      'summary': summary,
      'weekendComparison': weekendComparison,
    };
  }
}
