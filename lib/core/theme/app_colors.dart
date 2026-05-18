import 'package:flutter/material.dart';

/// App color palette — mapped from constants/theme.ts Colors object.
class AppColors {
  AppColors._();

  // ─── Brand Colors ───
  static const Color primary = Color(0xFF003D5B);
  static const Color primaryLight = Color(0xFF4A7C94);
  static const Color accent = Color(0xFF90D4EA);

  // ─── Light Theme ───
  static const Color lightText = Color(0xFF11181C);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightTint = Color(0xFF0A7EA4);
  static const Color lightIcon = Color(0xFF687076);
  static const Color lightTabIconDefault = Color(0xFF687076);

  // ─── Dark Theme ───
  static const Color darkText = Color(0xFFECEDEE);
  static const Color darkBackground = Color(0xFF151718);
  static const Color darkTint = Color(0xFFFFFFFF);
  static const Color darkIcon = Color(0xFF9BA1A6);
  static const Color darkTabIconDefault = Color(0xFF9BA1A6);

  // ─── Tab Bar (from user/(tabs)/_layout.tsx) ───
  static const Color tabBarBackground = Color(0xFF003D5B);
  static const Color tabBarActive = Color(0xFFFFFFFF);
  static const Color tabBarInactive = Color(0xFFB0C4DE);
  static const Color tabBarIndicator = Color(0xFF90D4EA);

  // ─── Alert Theme Colors (from CustomAlertProvider.tsx) ───
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color infoColor = Color(0xFF1976D2);

  // ─── Splash ───
  static const Color splashBackground = Color(0xFFFDFEFF);
}
