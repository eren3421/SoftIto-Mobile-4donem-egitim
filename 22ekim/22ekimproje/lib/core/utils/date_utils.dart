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
}
