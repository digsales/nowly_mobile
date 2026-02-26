import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';

/// Visual variants for [AppSnackBar].
enum SnackBarType { success, warning, error }

/// Utility for showing themed snack bars.
///
/// Uses `colorScheme` colors so it adapts to light/dark mode automatically.
///
/// ```dart
/// AppSnackBar.show(context, 'Invalid credentials', type: SnackBarType.error);
/// ```
abstract final class AppSnackBar {
  /// Shows a themed [SnackBar] at the bottom of the screen.
  ///
  /// [message] is the text displayed inside the snack bar.
  /// [type] controls the background color (defaults to [SnackBarType.error]).
  /// [duration] controls how long it stays visible.
  static void show(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.error,
    Duration duration = const Duration(seconds: 3),
  }) {
    final colors = context.colorScheme;

    final (backgroundColor, textColor) = switch (type) {
      SnackBarType.success => (colors.primary, colors.onPrimary),
      SnackBarType.warning => (colors.onSurface, colors.surface),
      SnackBarType.error => (colors.error, colors.onError),
    };

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: context.textTheme.bodyMedium?.copyWith(color: textColor),
          ),
          backgroundColor: backgroundColor,
          dismissDirection: DismissDirection.down,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: duration,
        ),
      );
  }

  /// Removes any currently visible snack bar.
  static void clear(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}
