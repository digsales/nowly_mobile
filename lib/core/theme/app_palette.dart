import 'package:flutter/material.dart';

abstract final class AppPalette {
  // Brand (seu verde principal)
  static const Color primary = Color(0xFF7A5FA6);
  static const Color primaryLight = Color(0xFF4B3A6A);
  static const Color primaryDark = Color(0xFFA996C7);

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
  static const Color highContrastPrimaryLight = Color(0xFF3E2A5F);
  static const Color inputFillHighContrastLight = Color(0xFFE0E0E0);

  // High contrast dark theme
  static const Color highContrastBlack = Color(0xFF000000);
  static const Color highContrastPrimaryDark = Color(0xFFD6C8F2);
  static const Color inputFillHighContrastDark = Color(0xFF333333);

  // Semantic
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);
}
