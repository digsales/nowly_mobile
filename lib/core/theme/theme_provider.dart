import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/shared_preferences_provider.dart';

import 'package:nowly/core/theme/app_palette.dart';
import 'package:nowly/core/theme/primary_colors.dart';

const _kThemeMode = 'theme_mode';
const _kHighContrast = 'high_contrast';
const _kFontScale = 'font_scale';
const _kLocale = 'locale';
const _kPrimaryColor = 'primary_color';

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

// ─── Primary Color ────────────────────────────────────────────────────────────

final primaryColorProvider =
    NotifierProvider<PrimaryColorNotifier, PrimaryColors>(
        PrimaryColorNotifier.new);

class PrimaryColorNotifier extends Notifier<PrimaryColors> {
  late final SharedPreferences _prefs;

  PrimaryColors _findByKey(String? key) =>
      AppPrimaryColors.values.firstWhere(
        (color) => color.key == key,
        orElse: () => AppPrimaryColors.purple,
      );

  @override
  PrimaryColors build() {
    _prefs = ref.read(sharedPreferencesProvider);
    final colors = _findByKey(_prefs.getString(_kPrimaryColor));
    AppPalette.applyPrimaryColors(colors);
    return colors;
  }

  void set(PrimaryColors colors) {
    state = colors;
    AppPalette.applyPrimaryColors(colors);
    _prefs.setString(_kPrimaryColor, colors.key);
  }

  void reset() {
    _prefs.remove(_kPrimaryColor);
    AppPalette.applyPrimaryColors(AppPrimaryColors.purple);
    state = AppPrimaryColors.purple;
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
  late final SharedPreferences _prefs;

  @override
  Locale? build() {
    _prefs = ref.read(sharedPreferencesProvider);
    final saved = _prefs.getString(_kLocale);
    if (saved == null) return null;
    final parts = saved.split('_');
    return Locale(parts[0], parts.length > 1 ? parts[1] : null);
  }

  void set(Locale? locale) {
    state = locale;
    if (locale == null) {
      _prefs.remove(_kLocale);
    } else {
      final tag = locale.countryCode != null
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode;
      _prefs.setString(_kLocale, tag);
    }
  }

  void reset() {
    _prefs.remove(_kLocale);
    state = null;
  }
}

// ─── Reset all ───────────────────────────────────────────────────────────────

/// Resets all theme preferences to device/system defaults and clears cache.
void resetThemeDefaults(WidgetRef ref) {
  ref.read(themeModeProvider.notifier).reset();
  ref.read(highContrastProvider.notifier).reset();
  ref.read(primaryColorProvider.notifier).reset();
  ref.read(fontScaleProvider.notifier).reset();
  ref.read(localeProvider.notifier).reset();
}
