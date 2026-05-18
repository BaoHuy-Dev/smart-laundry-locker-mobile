import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// App typography — replaces the Fonts object from constants/theme.ts.
/// Uses Google Fonts (Inter) for a clean, modern look.
class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => GoogleFonts.interTextTheme();

  // ─── Splash Screen ───
  static TextStyle get splashTitle => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: 0.5,
  );

  static TextStyle get splashTagline => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryLight,
    letterSpacing: 0.2,
  );

  // ─── Tab Bar ───
  static TextStyle get tabLabel =>
      GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600);
}
