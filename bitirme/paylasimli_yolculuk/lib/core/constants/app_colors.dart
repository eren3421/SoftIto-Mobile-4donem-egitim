import 'package:flutter/material.dart';

/// Modern Zümrüt Yeşili (Emerald) ve Koyu Lacivert (Deep Navy) renk paleti.
class AppColors {
  AppColors._();

  // Ana Renkler (Emerald Green & Deep Navy)
  static const Color primary = Color(0xFF059669); // Emerald 600
  static const Color primaryLight = Color(0xFF34D399); // Emerald 400
  static const Color primaryDark = Color(0xFF065F46); // Emerald 800

  static const Color secondary = Color(0xFF0F172A); // Slate / Deep Navy 900
  static const Color secondaryLight = Color(0xFF1E293B); // Slate 800
  static const Color accent = Color(0xFF0EA5E9); // Sky Blue 500

  // Durum Renkleri
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Aydınlık Tema Yüzeyleri
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Karanlık Tema Yüzeyleri
  static const Color darkBackground = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);
}

