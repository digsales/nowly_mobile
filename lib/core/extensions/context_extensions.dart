import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  EdgeInsets get paddingScreen {
    final padding = MediaQuery.paddingOf(this);
    return EdgeInsets.only(
      left: padding.left + 32,
      right: padding.right + 32,
      top: padding.top,
      bottom: padding.bottom,
    );
  }
}
