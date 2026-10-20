import 'package:flutter/material.dart';

/// AppColors defines the 'Crimson & Obsidian Slate' palette from design.md
/// with both dark and light mode tone mappings.
class AppColors {
  AppColors._();

  // --- Dark Mode / Crimson & Obsidian Brand Colors ---
  /// #8B0000 Primary deep red for main actions, tabs, borders
  static const Color crimsonPrimary = Color(0xFF8B0000);

  /// #B71C1C Accent vibrant dark red for badges, pins, active chips
  static const Color crimsonAccent = Color(0xFFB71C1C);

  /// #3A0A0E Deep burgundy container / card highlight
  static const Color crimsonSurface = Color(0xFF3A0A0E);

  /// #EF5350 Soft coral red for icons, telemetry accents
  static const Color crimsonLight = Color(0xFFEF5350);

  /// #121417 Obsidian darkest grey / scaffold background
  static const Color obsidianGrey = Color(0xFF121417);

  /// #1C1F24 Charcoal grey for AppBars, BottomBars, NavPanels
  static const Color charcoalGrey = Color(0xFF1C1F24);

  /// #262A30 Metallic dark grey for cards, dialogs, bubbles
  static const Color slateCardGrey = Color(0xFF262A30);

  /// #323740 Gunmetal grey for TextFields, dropdowns, input containers
  static const Color gunmetalGrey = Color(0xFF323740);

  /// #454C59 Steel border grey for 1px outlines and dividers
  static const Color steelBorderGrey = Color(0xFF454C59);

  /// #F1F3F5 Platinum off-white text for titles & prices
  static const Color platinumText = Color(0xFFF1F3F5);

  /// #ADB5BD Silver grey for subtitles, labels, secondary info
  static const Color silverText = Color(0xFFADB5BD);

  /// #6C757D Muted grey for placeholders, timestamps, passive icons
  static const Color mutedGreyText = Color(0xFF6C757D);

  // Status Colors
  /// #2E7D32 Emerald for active / available / running
  static const Color statusEmerald = Color(0xFF2E7D32);

  /// #C68400 Amber for pending confirmation / waiting
  static const Color statusAmber = Color(0xFFC68400);

  /// #D32F2F Red for cancelled / rejected
  static const Color statusRed = Color(0xFFD32F2F);

  /// #0288D1 Sky Blue for Air transport highlights
  static const Color airBlue = Color(0xFF0288D1);

  /// #0097A7 Sea Cyan for Sea transport highlights
  static const Color seaCyan = Color(0xFF0097A7);

  // --- Light Mode Mappings ---
  static const Color lightScaffoldBg = Color(0xFFF6F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightInputBg = Color(0xFFEEF1F5);
  static const Color lightBorder = Color(0xFFD0D7DE);
  static const Color lightTextPrimary = Color(0xFF1F2328);
  static const Color lightTextSecondary = Color(0xFF57606A);
}
