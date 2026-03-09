import 'package:flutter/material.dart';

class PrimaryColors {
  final String key;
  final Color primary;
  final Color light;
  final Color dark;

  const PrimaryColors({
    required this.key,
    required this.primary,
    required this.light,
    required this.dark,
  });
}

abstract final class AppPrimaryColors {
  static const PrimaryColors purple = PrimaryColors(
    key: 'purple',
    primary: Color(0xFF7A5FA6),
    light: Color(0xFFD6C8F2),
    dark: Color(0xFF3E2A5F),
  );

  static const PrimaryColors blue = PrimaryColors(
    key: 'blue',
    primary: Color(0xFF4A7ABF),
    light: Color(0xFFB8CDE6),
    dark: Color(0xFF2A4A75),
  );

  static const PrimaryColors yellow = PrimaryColors(
    key: 'yellow',
    primary: Color(0xFFB8962E),
    light: Color(0xFFE6D498),
    dark: Color(0xFF6E5A1B),
  );

  static const PrimaryColors green = PrimaryColors(
    key: 'green',
    primary: Color(0xFF3D8B5E),
    light: Color(0xFFA8D4B8),
    dark: Color(0xFF245438),
  );

  static const PrimaryColors red = PrimaryColors(
    key: 'red',
    primary: Color(0xFFC25050),
    light: Color(0xFFE6ABAB),
    dark: Color(0xFF7A2E2E),
  );

  static const PrimaryColors pink = PrimaryColors(
    key: 'pink',
    primary: Color(0xFFB8508A),
    light: Color(0xFFE6ABD0),
    dark: Color(0xFF752E58),
  );

  static const PrimaryColors gray = PrimaryColors(
    key: 'gray',
    primary: Color(0xFF6B7280),
    light: Color(0xFFBFC4CC),
    dark: Color(0xFF3E434D),
  );

  static const List<PrimaryColors> values = [
    purple, blue, green, yellow, red, pink, gray,
  ];
}
