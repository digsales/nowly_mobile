import 'package:flutter/material.dart';
import 'package:nowly/core/theme/primary_colors.dart';

abstract final class AppPalette {
  // Brand
  static Color primary = AppPrimaryColors.purple.primary;
  static Color primaryLight = AppPrimaryColors.purple.light;
  static Color primaryDark = AppPrimaryColors.purple.dark;

  static void applyPrimaryColors(PrimaryColors colors) {
    primary = colors.primary;
    primaryLight = colors.light;
    primaryDark = colors.dark;
  }

  // Light theme
  static const Color backgroundLight = Color(0xFFF1EDF8);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF393E46);
  static const Color textSecondaryLight = Color(0xFF616161);
  static const Color inputFillLight = Color(0xFFE5DFF0);

  // Dark theme
  static const Color backgroundDark = Color(0xFF212121);
  static const Color cardDark = Color(0xFF000000);
  static const Color textPrimaryDark = Color(0xFFD1D1D1);
  static const Color textSecondaryDark = Color(0xFF888888);
  static const Color inputFillDark = Color(0xFF2E2E2E);

  // High contrast light theme
  static const Color highContrastWhite = Color(0xFFFFFFFF);
  static const Color inputFillHighContrastLight = Color(0xFFE0E0E0);

  // High contrast dark theme
  static const Color highContrastBlack = Color(0xFF000000);
  static const Color inputFillHighContrastDark = Color(0xFF333333);

  // Category colors
  static const List<Color> categoryColors = [
    Color(0xFF5C8DFF),
    Color(0xFFE05A5A),
    Color(0xFF4CAF7D),
    Color(0xFF9C6ADE),
    Color(0xFFFFB74D),
    Color(0xFF4DD0C8),
  ];

  // Semantic
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);
}
