import 'package:flutter/material.dart';

abstract final class AppPalette {
  // Brand (seu verde principal)
  static const Color primary = Color(0xFF1F8D69);
  static const Color primaryLight = Color(0xFF2AB382);
  static const Color primaryDark = Color(0xFF14694D);

  // Light theme
  static const Color backgroundLight = Color(0xFFF7F7F7);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF616161);

  // Dark theme
  static const Color backgroundDark = Color(0xFF212121);
  static const Color cardDark = Color(0xFF000000);
  static const Color textPrimaryDark = Color(0xFFD1D1D1);
  static const Color textSecondaryDark = Color(0xFF888888);

  // High contrast
  static const Color highContrastWhite = Color(0xFFFFFFFF);
  static const Color highContrastBlack = Color(0xFF000000);
  static const Color highContrastPrimaryLight = Color(0xFF006B45);
  static const Color highContrastPrimaryDark = Color(0xFF4ADE80);

  // Semantic
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);
}
