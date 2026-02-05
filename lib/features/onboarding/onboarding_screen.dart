import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_palette.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo
              SvgPicture.asset(
                isDark
                    ? 'assets/images/svg/logo_dark.svg'
                    : 'assets/images/svg/logo_colored.svg',
              ),
              const Spacer(flex: 2),
              // Welcome text
              Text(
                'Seja Bem Vindo!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isDark
                          ? AppPalette.textPrimaryDark
                          : AppPalette.highContrastWhite,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 32),
              // Login button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: navigate to login
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark
                          ? AppPalette.textSecondaryDark
                          : AppPalette.highContrastWhite,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Já tenho conta',
                    style: TextStyle(
                      color: isDark
                          ? AppPalette.textPrimaryDark
                          : AppPalette.highContrastWhite,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Register button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: navigate to register
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppPalette.primary
                        : AppPalette.highContrastBlack,
                    foregroundColor: AppPalette.highContrastWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Criar conta'),
                ),
              ),
              const Spacer(),
              // Footer
              Text.rich(
                TextSpan(
                  text: 'Criado por ',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppPalette.textSecondaryDark
                        : AppPalette.highContrastWhite.withValues(alpha: 0.7),
                  ),
                  children: [
                    TextSpan(
                      text: 'Diogo Sales',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppPalette.primary
                            : AppPalette.highContrastWhite,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
