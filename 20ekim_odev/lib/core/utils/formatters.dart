import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  static String currency(double amount, [String suffix = '/ Gün']) {
    return '${_currencyFormat.format(amount)} $suffix';
  }

  static String date(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  static String dateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  static String time(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  static String dateRange(DateTime start, DateTime end) {
    return '${_dateFormat.format(start)} - ${_dateFormat.format(end)}';
  }

  static String coordinates(double lat, double lng) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lngDir = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}° $latDir, ${lng.abs().toStringAsFixed(4)}° $lngDir';
  }
}
