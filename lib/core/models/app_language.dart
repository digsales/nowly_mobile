import 'package:flutter/material.dart';

/// Represents a supported app language.
class AppLanguage {
  const AppLanguage({
    required this.locale,
    required this.nativeName,
    required this.flag,
  });

  /// The Flutter locale for this language.
  final Locale locale;

  /// The language name written in its own language (e.g. "Português (Brasil)").
  final String nativeName;

  /// Emoji flag for visual identification.
  final String flag;

  /// All languages currently supported by the app.
  /// Add new entries here when a new translation is ready.
  static const List<AppLanguage> supported = [
    AppLanguage(
      locale: Locale('pt', 'BR'),
      nativeName: 'Português (Brasil)',
      flag: '🇧🇷',
    ),
    // AppLanguage(
    //   locale: Locale('en', 'US'),
    //   nativeName: 'English (US)',
    //   flag: '🇺🇸',
    // ),
  ];
}
