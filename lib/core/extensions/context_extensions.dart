import 'package:flutter/material.dart';
import 'package:nowly/l10n/app_localizations.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  double get paddingTop => MediaQuery.paddingOf(this).top;
  double get paddingBottom => MediaQuery.paddingOf(this).bottom;
  double get paddingLeft => MediaQuery.paddingOf(this).left;
  double get paddingRight => MediaQuery.paddingOf(this).right;

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
