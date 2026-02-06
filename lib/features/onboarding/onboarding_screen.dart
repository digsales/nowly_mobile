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
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Padding(
            padding: context.paddingScreen,
            child: Device.orientation == Orientation.portrait ? _buildPortrait(context) : _buildLandscape(context),
          );
        },
      ),
    );
  }

  Widget _buildPortrait(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        _logo(context, height: 25.h),
        const Spacer(),
        _welcomeText(context),
        const SizedBox(height: 32),
        _buttons(context),
        const Spacer(),
        _footer(context),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLandscape(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _logo(context, width: 25.w),
                    Column(
                      children: [
                        _welcomeText(context),
                        const SizedBox(height: 32),
                        _buttons(context, buttonWidth: 40.w),
                      ],
                    ),
                  ],
                ),
                _footer(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _logo(BuildContext context, {double? height, double? width}) {
    return Semantics(
      label: context.l10n.appName,
      child: SvgPicture.asset(
        context.isDark
            ? 'assets/images/svg/logo_dark.svg'
            : 'assets/images/svg/logo_light.svg',
        height: height,
        width: width,
      ),
    );
  }

  Widget _welcomeText(BuildContext context) {
    return Text(
      context.l10n.onboardingWelcome,
      style: context.textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buttons(BuildContext context, {double? buttonWidth}) {
    return Column(
      children: [
        AppButton(
          text: context.l10n.onboardingLogin,
          variant: AppButtonVariant.outlined,
          width: buttonWidth,
          onPressed: () {
            // TODO: navigate to login
          },
        ),
        const SizedBox(height: 12),
        AppButton(
          text: context.l10n.onboardingRegister,
          width: buttonWidth,
          onPressed: () {
            // TODO: navigate to register
          },
        ),
      ],
    );
  }

  Widget _footer(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: context.l10n.onboardingCreatedBy,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
        children: [
          TextSpan(
            text: context.l10n.appCreator,
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
