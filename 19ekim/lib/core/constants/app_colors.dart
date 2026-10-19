import 'package:flutter/material.dart';

/// Gece spor salonu paleti (Dark Obsidian & Neon)
abstract final class AppColors {
  // Zemin ve Yüzeyler (Obsidian tonları)
  static const Color background = Color(0xFF0A0C10);
  static const Color surface = Color(0xFF141923);
  static const Color surfaceLight = Color(0xFF1E2638);
  static const Color border = Color(0xFF283347);

  // Neon Vurgu Renkleri
  static const Color neonCyan = Color(0xFF00E5FF);       // Su / Hidrasyon
  static const Color neonGreen = Color(0xFF00E676);      // Başarı / Kalori
  static const Color neonOrange = Color(0xFFFF5722);     // Egzersiz / Ateş
  static const Color neonPurple = Color(0xFF7C4DFF);     // Hedef / İlerleme

  // Metin Renkleri
  static const Color textPrimary = Color(0xFFF0F4F8);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Fonksiyonel
  static const Color error = Color(0xFFFF5252);
}
