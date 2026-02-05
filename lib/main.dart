import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  static const double _baseFontSize = 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final fontScale = ref.watch(fontScaleProvider);
    final fontSize = _baseFontSize * fontScale;

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Monno Money',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(fontSize),
          darkTheme: AppTheme.dark(fontSize),
          themeMode: themeMode,
          home: const OnboardingScreen(),
        );
      },
    );
  }
}
