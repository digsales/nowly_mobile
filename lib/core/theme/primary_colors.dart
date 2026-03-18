import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/theme/theme_provider.dart';

/// Represents a primary color with its high contrast variants.
///
/// - [primary]: default color, used when high contrast is off.
/// - [light]: light variant, used in dark theme with high contrast.
/// - [dark]: dark variant, used in light theme with high contrast.
///
/// To add a new color:
/// 1. Create a new [PrimaryColors] instance in [AppPrimaryColors].
/// 2. Add it to the [AppPrimaryColors.values] list.
/// 3. Use it in widgets with `ref.usePrimaryColor('key')`.
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

/// Available primary colors in the app.
///
/// Each color has three variants ([primary], [light], [dark]) that
/// adapt automatically to theme and high contrast via [usePrimaryColor].
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

  static const PrimaryColors green = PrimaryColors(
    key: 'green',
    primary: Color(0xFF3D8B5E),
    light: Color(0xFFA8D4B8),
    dark: Color(0xFF245438),
  );

  static const PrimaryColors yellow = PrimaryColors(
    key: 'yellow',
    primary: Color(0xFFB8962E),
    light: Color(0xFFE6D498),
    dark: Color(0xFF6E5A1B),
  );

  static const PrimaryColors orange = PrimaryColors(
    key: 'orange',
    primary: Color(0xFFC07030),
    light: Color(0xFFE6C4A8),
    dark: Color(0xFF754320),
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
    purple, blue, green, yellow, orange, red, pink, gray,
  ];
}

/// [WidgetRef] extension to resolve primary colors automatically.
///
/// Returns the correct color variant based on [highContrastProvider]
/// and [themeModeProvider], without needing [BuildContext].
///
/// Usage in a [ConsumerWidget] or [ConsumerStatefulWidget]:
/// ```dart
/// final green = ref.usePrimaryColor('green');
/// final red = ref.usePrimaryColor('red');
/// ```
extension PrimaryColorRef on WidgetRef {
  Color usePrimaryColor(String key) {
    final highContrast = watch(highContrastProvider);
    if (!highContrast) {
      return AppPrimaryColors.values
          .firstWhere((c) => c.key == key, orElse: () => AppPrimaryColors.purple)
          .primary;
    }
    final themeMode = watch(themeModeProvider);
    final colors = AppPrimaryColors.values
        .firstWhere((c) => c.key == key, orElse: () => AppPrimaryColors.purple);
    return themeMode == ThemeMode.dark ? colors.light : colors.dark;
  }
}
