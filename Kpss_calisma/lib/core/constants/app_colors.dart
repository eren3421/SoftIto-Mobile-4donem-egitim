import 'package:flutter/material.dart';

class AppColors {
  // Brand & Accent Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color accentGold = Color(0xFFF59E0B); // Amber / Gold

  // Course Specific Colors (Strictly adhering to SKILL.md)
  static const Color courseTurkce = Color(0xFF2196F3); // Mavi
  static const Color courseMatematik = Color(0xFF9C27B0); // Mor
  static const Color courseTarih = Color(0xFFFF9800); // Turuncu
  static const Color courseCografya = Color(0xFF4CAF50); // Yeşil
  static const Color courseVatandaslik = Color(0xFFF44336); // Kırmızı

  // Status Colors
  static const Color notStarted = Color(0xFF94A3B8); // Slate 400
  static const Color needsReview = Color(0xFFF59E0B); // Amber 500
  static const Color completed = Color(0xFF10B981); // Emerald 500

  // Net / Question Colors
  static const Color correct = Color(0xFF10B981);
  static const Color wrong = Color(0xFFEF4444);
  static const Color empty = Color(0xFF94A3B8);

  // Dark Theme Backgrounds & Surfaces
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155); // Slate 700
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Light Theme Backgrounds & Surfaces
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Colors.white;
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Helper method to get color by course id
  static Color getCourseColor(String courseId) {
    switch (courseId.toLowerCase()) {
      case 'turkce':
        return courseTurkce;
      case 'matematik':
        return courseMatematik;
      case 'tarih':
        return courseTarih;
      case 'cografya':
        return courseCografya;
      case 'vatandaslik':
        return courseVatandaslik;
      default:
        return primary;
    }
  }
}
