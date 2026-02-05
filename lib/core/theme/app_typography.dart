import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

abstract final class AppTypography {
  static TextTheme textTheme(double baseFontSize) {
    final base = baseFontSize.sp;

    return TextTheme(
      displayLarge: TextStyle(fontSize: base * 2.25, fontWeight: FontWeight.w400),
      displayMedium: TextStyle(fontSize: base * 1.875, fontWeight: FontWeight.w400),
      displaySmall: TextStyle(fontSize: base * 1.5, fontWeight: FontWeight.w400),
      headlineLarge: TextStyle(fontSize: base * 1.375, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(fontSize: base * 1.25, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontSize: base * 1.125, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: base * 1.125, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(fontSize: base, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(fontSize: base * 0.875, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: base, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: base * 0.875, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontSize: base * 0.75, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: base, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontSize: base * 0.75, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontSize: base * 0.6875, fontWeight: FontWeight.w500),
    );
  }
}
