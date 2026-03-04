import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides the [SharedPreferences] instance initialized in `main()`.
///
/// Must be overridden in [ProviderScope] before use:
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// ProviderScope(
///   overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
///   child: const MyApp(),
/// );
/// ```
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);
