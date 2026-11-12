import 'package:intl/intl.dart';

/// Tarih, saat ve para birimi formatlama yardımcı sınıfı.
class DateFormatter {
  DateFormatter._();

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime.toLocal());
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy').format(dateTime.toLocal());
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime.toLocal());
  }

  static String formatDayAndTime(DateTime dateTime) {
    final now = DateTime.now();
    final local = dateTime.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(local.year, local.month, local.day);
    final timeStr = DateFormat('HH:mm').format(local);

    if (target == today) {
      return 'Bugün, $timeStr';
    } else if (target == today.add(const Duration(days: 1))) {
      return 'Yarın, $timeStr';
    }
    return '${DateFormat('dd.MM.yyyy').format(local)} • $timeStr';
  }

  static String formatCurrency(double amount, {String currency = 'TRY'}) {
    final symbol = currency == 'TRY' ? '₺' : currency;
    return '${amount.toStringAsFixed(0)} $symbol';
  }
}

