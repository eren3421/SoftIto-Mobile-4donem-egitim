import 'package:flutter/material.dart';

/// MENTOR - Koyu Pembe (Dark Pink / Deep Rose) Renk Paleti
/// DESIGN.md spesifikasyonuna birebir uygundur.
class AppColors {
  AppColors._();

  // Primary (Ana Renk)
  static const Color primary = Color(0xFFC2185B); // Deep Rose / Koyu Pembe

  // Primary Variant
  static const Color primaryVariant = Color(0xFF880E4F); // Crimson Berry / Bordo Pembe

  // Accent / Secondary
  static const Color accent = Color(0xFFFF4081); // Vibrant Pink / Canlı Pembe
  static const Color secondary = Color(0xFFFF4081);

  // Soft Pink Tint
  static const Color softPink = Color(0xFFF8BBD0); // Blush Rose / Açık Gül
  static const Color softPinkTint = Color(0xFFF8BBD0);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFF12090E); // Dark Plum Night
  static const Color surface = Color(0xFF1E1118); // Elevated Mulberry (Kartlar, Modallar)
  static const Color surfaceVariant = Color(0xFF2C1923); // Muted Rose Gray (Giriş alanları)
  static const Color surfaceLight = Color(0xFF381F2D); // Hafif aydınlık yüzey

  // Text Colors
  static const Color textPrimary = Color(0xFFFCE4EC); // Snow Pink White
  static const Color textSecondary = Color(0xFFCE93D8); // Dusty Mauve
  static const Color textMuted = Color(0xFFBCAAA4); // Nötr soluk pembe gri

  // Indicators / Status
  static const Color success = Color(0xFF00E676); // Emerald Mint (Zincir, tamamlandı)
  static const Color danger = Color(0xFFFF5252); // Coral Red (Sil, hata)
  static const Color warning = Color(0xFFFFB74D); // Turuncu uyarı

  // Borders & Dividers
  static const Color border = Color(0xFF4A154B); // Pembe tonlu ince kenarlık
  static const Color borderHighlight = Color(0xFFC2185B); // Vurgulu kenarlık

  // Gradients
  static const LinearGradient logoGradient = LinearGradient(
    colors: [Color(0xFFFF4081), Color(0xFFC2185B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1118), Color(0xFF2C1923)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFFC2185B), Color(0xFF880E4F)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
