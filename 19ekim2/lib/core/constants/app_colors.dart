import 'package:flutter/material.dart';

/// Dinamik tema renk paleti (Koyu Mod: Dark Obsidian & Neon; Aydınlık Mod: Soft Arctic & Electric Accents)
abstract final class AppColors {
  // --- Koyu Tema (Dark Obsidian) ---
  static const Color darkBackground = Color(0xFF0A0D14);
  static const Color darkSurface = Color(0xFF121722);
  static const Color darkSurfaceCard = Color(0xFF182030);
  static const Color darkBorder = Color(0xFF26334D);
  static const Color darkTextPrimary = Color(0xFFF2F5FA);
  static const Color darkTextSecondary = Color(0xFF8E9BAE);
  static const Color darkTextMuted = Color(0xFF5A6678);

  // --- Aydınlık Tema (Soft Arctic & Crisp Slate) ---
  static const Color lightBackground = Color(0xFFF6F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // --- Ortak Neon / Canlı Vurgu Renkleri ---
  static const Color neonCyan = Color(0xFF00B4D8);
  static const Color neonCyanBright = Color(0xFF00F0FF);
  static const Color neonLime = Color(0xFF10B981);
  static const Color neonLimeBright = Color(0xFF4EFE1E);
  static const Color neonOrange = Color(0xFFFF7A00);
  static const Color neonPink = Color(0xFFFF2A85);

  // Geriye dönük uyumluluk sabitleri (Dark tema varsayılanları)
  static const Color background = darkBackground;
  static const Color surface = darkSurface;
  static const Color surfaceCard = darkSurfaceCard;
  static const Color border = darkBorder;
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color textMuted = darkTextMuted;
}
