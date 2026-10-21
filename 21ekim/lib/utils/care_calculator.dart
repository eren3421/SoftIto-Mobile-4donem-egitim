import 'package:flutter/material.dart';

enum CareAlertLevel {
  overdue, // Red
  dueSoon, // Amber
  healthy, // Green
}

class CareStatus {
  final CareAlertLevel level;
  final int daysDelta; // abs days or remaining days
  final String labelTr;
  final String labelEn;
  final Color primaryColor;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;

  const CareStatus({
    required this.level,
    required this.daysDelta,
    required this.labelTr,
    required this.labelEn,
    required this.primaryColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
  });

  String getLabel(String lang) => lang == 'en' ? labelEn : labelTr;
}

class CareCalculator {
  static CareStatus evaluate({
    required DateTime lastActionDate,
    required int intervalDays,
    DateTime? today,
  }) {
    final now = today ?? DateTime.now();
    // Normalize to date only (ignoring time)
    final nowDate = DateTime(now.year, now.month, now.day);
    final actionDate =
        DateTime(lastActionDate.year, lastActionDate.month, lastActionDate.day);

    final elapsedDays = nowDate.difference(actionDate).inDays;
    final remainingDays = intervalDays - elapsedDays;

    if (remainingDays < 0) {
      final overdueDays = remainingDays.abs();
      return CareStatus(
        level: CareAlertLevel.overdue,
        daysDelta: overdueDays,
        labelTr: '$overdueDays Gün Gecikti!',
        labelEn: '$overdueDays Days Overdue!',
        primaryColor: const Color(0xFFEF4444),
        backgroundColor: const Color(0xFFFEF2F2),
        borderColor: const Color(0xFFFCA5A5),
        icon: Icons.error_outline_rounded,
      );
    } else if (remainingDays <= 1) {
      final isToday = remainingDays == 0;
      return CareStatus(
        level: CareAlertLevel.dueSoon,
        daysDelta: remainingDays,
        labelTr: isToday ? 'Bugün Yapılmalı' : 'Yarın Yapılmalı',
        labelEn: isToday ? 'Due Today' : 'Due Tomorrow',
        primaryColor: const Color(0xFFF59E0B),
        backgroundColor: const Color(0xFFFFFBEB),
        borderColor: const Color(0xFFFCD34D),
        icon: Icons.access_time_rounded,
      );
    } else {
      return CareStatus(
        level: CareAlertLevel.healthy,
        daysDelta: remainingDays,
        labelTr: '$remainingDays Gün Sonra',
        labelEn: 'In $remainingDays Days',
        primaryColor: const Color(0xFF10B981),
        backgroundColor: const Color(0xFFECFDF5),
        borderColor: const Color(0xFF6EE7B7),
        icon: Icons.check_circle_outline_rounded,
      );
    }
  }
}
