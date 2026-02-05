import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monno_money/core/extensions/context_extensions.dart';
import 'package:sizer/sizer.dart';

import '../../core/widgets/app_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Padding(
          padding: context.paddingScreen,
          child: Column(
            children: [
              const Spacer(flex: 1),
              // Logo
              SvgPicture.asset(
                context.isDark
                    ? 'assets/images/svg/logo_dark.svg'
                    : 'assets/images/svg/logo_light.svg',
                height: 40.h,
              ),
              const Spacer(flex: 1),
              // Welcome text
              Text(
                'Seja Bem Vindo!',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Já tenho conta',
                variant: AppButtonVariant.outlined,
                onPressed: () {
                  // TODO: navigate to login
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Criar conta',
                onPressed: () {
                  // TODO: navigate to register
                },
              ),
              const Spacer(),
              // Footer
              Text.rich(
                TextSpan(
                  text: 'Criado por ',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  children: [
                    TextSpan(
                      text: 'Diogo Sales',
                      style: context.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.primary
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
    );
  }
}
