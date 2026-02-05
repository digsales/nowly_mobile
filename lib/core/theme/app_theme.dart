import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData light(double baseFontSize) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.primary,
          primary: AppPalette.primary,
          surface: AppPalette.backgroundLight,
          onSurface: AppPalette.textPrimaryLight,
          onSurfaceVariant: AppPalette.textSecondaryLight,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppPalette.primary,
        fontFamily: 'Poppins',
        textTheme: AppTypography.textTheme(baseFontSize),
      );

  static ThemeData dark(double baseFontSize) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.primary,
          primary: AppPalette.primary,
          surface: AppPalette.backgroundDark,
          onSurface: AppPalette.textPrimaryDark,
          onSurfaceVariant: AppPalette.textSecondaryDark,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppPalette.primary,
        fontFamily: 'Poppins',
        textTheme: AppTypography.textTheme(baseFontSize),
      );
}
