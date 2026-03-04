import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/shared_preferences_provider.dart';

const _kThemeMode = 'theme_mode';
const _kHighContrast = 'high_contrast';
const _kFontScale = 'font_scale';

// ─── ThemeMode ───────────────────────────────────────────────────────────────

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  late final SharedPreferences _prefs;

  @override
  ThemeMode build() {
    _prefs = ref.read(sharedPreferencesProvider);
    return switch (_prefs.getString(_kThemeMode)) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  void set(ThemeMode mode) {
    state = mode;
    _prefs.setString(_kThemeMode, switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    });
  }

  void reset() {
    _prefs.remove(_kThemeMode);
    state = ThemeMode.system;
  }
}

// ─── High Contrast ───────────────────────────────────────────────────────────

final highContrastProvider =
    NotifierProvider<HighContrastNotifier, bool>(HighContrastNotifier.new);

class HighContrastNotifier extends Notifier<bool> {
  late final SharedPreferences _prefs;

  @override
  bool build() {
    _prefs = ref.read(sharedPreferencesProvider);
    return _prefs.getBool(_kHighContrast) ?? false;
  }

  void set(bool value) {
    state = value;
    _prefs.setBool(_kHighContrast, value);
  }

  void reset() {
    _prefs.remove(_kHighContrast);
    state = false;
  }
}

// ─── Font Scale ──────────────────────────────────────────────────────────────

final fontScaleProvider =
    NotifierProvider<FontScaleNotifier, double>(FontScaleNotifier.new);

class FontScaleNotifier extends Notifier<double> {
  late final SharedPreferences _prefs;

  @override
  double build() {
    _prefs = ref.read(sharedPreferencesProvider);
    return _prefs.getDouble(_kFontScale) ?? 1.0;
  }

  void set(double scale) {
    state = scale;
    _prefs.setDouble(_kFontScale, scale);
  }

  void reset() {
    _prefs.remove(_kFontScale);
    state = 1.0;
  }
}

// ─── Locale ──────────────────────────────────────────────────────────────────

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  void set(Locale? locale) => state = locale;
}

// ─── Reset all ───────────────────────────────────────────────────────────────

/// Resets all theme preferences to device/system defaults and clears cache.
void resetThemeDefaults(WidgetRef ref) {
  ref.read(themeModeProvider.notifier).reset();
  ref.read(highContrastProvider.notifier).reset();
  ref.read(fontScaleProvider.notifier).reset();
}
