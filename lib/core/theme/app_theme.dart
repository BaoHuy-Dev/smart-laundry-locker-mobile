import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Application ThemeData — replaces the DarkTheme/DefaultTheme from
/// @react-navigation/native used in user/_layout.tsx.
class AppTheme {
  AppTheme._();

  // ─── Light Theme ───
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightText,
    ),
    textTheme: AppTypography.textTheme,
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.tabBarBackground,
      indicatorColor: AppColors.accent.withValues(alpha: 0.3),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.tabLabel.copyWith(color: AppColors.tabBarActive);
        }
        return AppTypography.tabLabel.copyWith(color: AppColors.tabBarInactive);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.tabBarActive, size: 26);
        }
        return const IconThemeData(color: AppColors.tabBarInactive, size: 26);
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );

  // ─── Dark Theme ───
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkText,
    ),
    textTheme: AppTypography.textTheme.apply(
      bodyColor: AppColors.darkText,
      displayColor: AppColors.darkText,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      centerTitle: true,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.darkBackground,
      indicatorColor: AppColors.accent.withValues(alpha: 0.3),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.tabLabel.copyWith(color: AppColors.darkTint);
        }
        return AppTypography.tabLabel.copyWith(
          color: AppColors.darkTabIconDefault,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.darkTint, size: 26);
        }
        return const IconThemeData(
          color: AppColors.darkTabIconDefault,
          size: 26,
        );
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );
}
