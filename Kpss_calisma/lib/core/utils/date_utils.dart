import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  static final DateFormat _dayMonthFormat = DateFormat('d MMM');
  static final DateFormat _dayNameFormat = DateFormat('EEEE');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatDayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }

  static String formatDayName(DateTime date) {
    return _dayNameFormat.format(date);
  }

  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes dk';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours sa';
    }
    return '$hours sa $remainingMinutes dk';
  }

  static String getRelativeDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = today.difference(target).inDays;

    if (difference == 0) return 'Bugün';
    if (difference == 1) return 'Dün';
    if (difference == -1) return 'Yarın';
    return formatDate(date);
  }
}
