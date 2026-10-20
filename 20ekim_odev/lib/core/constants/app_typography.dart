import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AppTypography defines typography guidelines from design.md
class AppTypography {
  AppTypography._();

  // Headings with modern tech feel (Space Grotesk / Montserrat fallback)
  static TextStyle displayHeader({Color color = AppColors.platinumText}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: -0.5,
    );
  }

  static TextStyle sectionTitle({Color color = AppColors.platinumText}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: -0.3,
    );
  }

  static TextStyle cardTitle({Color color = AppColors.platinumText}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  // Body & Details (Inter)
  static TextStyle bodyRegular({Color color = AppColors.silverText}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle bodyMedium({Color color = AppColors.platinumText}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle caption({Color color = AppColors.mutedGreyText}) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  // Monospace for License Plates, Tracking Numbers & Telemetry (JetBrains Mono)
  static TextStyle telemetryCode({
    Color color = AppColors.crimsonLight,
    FontWeight fontWeight = FontWeight.w600,
    double fontSize = 13,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 0.8,
    );
  }

  static TextStyle plateCode({Color color = AppColors.platinumText}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 1.2,
    );
  }
}
