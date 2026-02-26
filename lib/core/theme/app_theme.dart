import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static const _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );

  static ThemeData light(double baseFontSize) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.primary,
          primary: AppPalette.primary,
          onPrimary: AppPalette.backgroundLight,
          surface: AppPalette.backgroundLight,
          surfaceContainerHighest: AppPalette.inputFillLight,
          onSurface: AppPalette.textPrimaryLight,
          onSurfaceVariant: AppPalette.textSecondaryLight,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppPalette.primary,
        fontFamily: 'Poppins',
        textTheme: AppTypography.textTheme(baseFontSize),
        pageTransitionsTheme: _pageTransitionsTheme,
      );

  static ThemeData dark(double baseFontSize) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.primary,
          primary: AppPalette.primary,
          onPrimary: AppPalette.textPrimaryDark,
          surface: AppPalette.backgroundDark,
          surfaceContainerHighest: AppPalette.inputFillDark,
          onSurface: AppPalette.textPrimaryDark,
          onSurfaceVariant: AppPalette.textSecondaryDark,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppPalette.primary,
        fontFamily: 'Poppins',
        textTheme: AppTypography.textTheme(baseFontSize),
        pageTransitionsTheme: _pageTransitionsTheme,
      );

  static ThemeData lightHighContrast(double baseFontSize) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.highContrastPrimaryLight,
          primary: AppPalette.highContrastPrimaryLight,
          onPrimary: AppPalette.highContrastWhite,
          surface: AppPalette.highContrastWhite,
          surfaceContainerHighest: AppPalette.inputFillHighContrastLight,
          onSurface: AppPalette.highContrastBlack,
          onSurfaceVariant: AppPalette.highContrastBlack,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppPalette.highContrastPrimaryLight,
        fontFamily: 'Poppins',
        textTheme: AppTypography.textTheme(baseFontSize),
        pageTransitionsTheme: _pageTransitionsTheme,
      );

  static ThemeData darkHighContrast(double baseFontSize) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.highContrastPrimaryDark,
          primary: AppPalette.highContrastPrimaryDark,
          onPrimary: AppPalette.highContrastBlack,
          surface: AppPalette.highContrastBlack,
          surfaceContainerHighest: AppPalette.inputFillHighContrastDark,
          onSurface: AppPalette.highContrastWhite,
          onSurfaceVariant: AppPalette.highContrastWhite,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppPalette.highContrastPrimaryDark,
        fontFamily: 'Poppins',
        textTheme: AppTypography.textTheme(baseFontSize),
        pageTransitionsTheme: _pageTransitionsTheme,
      );
}
