import 'package:flutter/material.dart';

import 'app_palette.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.primary,
          primary: AppPalette.primary,
          surface: AppPalette.backgroundLight,
          onSurface: AppPalette.textPrimaryLight,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppPalette.primary,
        fontFamily: 'Poppins',
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.primary,
          primary: AppPalette.primary,
          surface: AppPalette.backgroundDark,
          onSurface: AppPalette.textPrimaryDark,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppPalette.backgroundDark,
        fontFamily: 'Poppins',
      );
}
