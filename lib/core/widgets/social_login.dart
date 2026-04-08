import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/providers/social_login_provider.dart';
import 'package:nowly/core/widgets/app_button.dart';
import 'package:nowly/core/widgets/app_snack_bar.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';

enum _SocialLoginVariant { pin, button }

/// Social login widget with two layout variants.
///
/// Handles authentication internally via [socialLoginProvider].
///
/// ```dart
/// // Wrap of circular avatar pins (compact):
/// SocialLogin.pin()
///
/// // Column of full-width branded buttons:
/// SocialLogin.button()
/// ```
class SocialLogin extends ConsumerWidget {
  const SocialLogin.pin({
    super.key,
    this.spacing = 30,
    this.runSpacing = 20,
  })  : _variant = _SocialLoginVariant.pin,
        buttonSpacing = 12;

  const SocialLogin.button({
    super.key,
    this.buttonSpacing = 12,
  })  : _variant = _SocialLoginVariant.button,
        spacing = 30,
        runSpacing = 20;

  final _SocialLoginVariant _variant;
  final double spacing;
  final double runSpacing;
  final double buttonSpacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(socialLoginProvider);

    ref.listen(socialLoginProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        AppSnackBar.show(context, next.errorMessage!);
      }
    });

    final l10n = context.l10n;
    final notifier = ref.read(socialLoginProvider.notifier);

    return switch (_variant) {
      _SocialLoginVariant.pin => Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: spacing,
            runSpacing: runSpacing,
            children: [
              SocialLoginPin(
                image: 'assets/images/social/google.png',
                isLoading: state.loadingProvider == SocialProvider.google,
                disabled: state.isLoading,
                onPressed: () => notifier.signIn(SocialProvider.google, l10n),
              ),

              // // TODO: Add Facebook sign in configuration in firebase.
              // SocialLoginPin(
              //   image: 'assets/images/social/facebook.png',
              //   isLoading: state.loadingProvider == SocialProvider.facebook,
              //   disabled: state.isLoading,
              //   onPressed: () => notifier.signIn(SocialProvider.facebook, l10n),
              // ),

              // // TODO: Add Apple sign in configuration in firebase.
              // SocialLoginPin(
              //   image: 'assets/images/social/apple.png',
              //   isLoading: state.loadingProvider == SocialProvider.apple,
              //   disabled: state.isLoading,
              //   onPressed: () => notifier.signIn(SocialProvider.apple, l10n),
              // ),
            ],
          ),
        ),
      _SocialLoginVariant.button => Column(
          children: [
            SocialLoginButton(
              image: 'assets/images/social/google.png',
              label: l10n.socialContinueWith("Google"),
              isLoading: state.loadingProvider == SocialProvider.google,
              disabled: state.isLoading,
              onPressed: () => notifier.signIn(SocialProvider.google, l10n),
            ),

            // // TODO: Add Facebook sign in configuration in firebase.
            // SizedBox(height: buttonSpacing),
            // SocialLoginButton(
            //   image: 'assets/images/social/facebook.png',
            //   label: l10n.socialContinueWith("Facebook"),
            //   isLoading: state.loadingProvider == SocialProvider.facebook,
            //   disabled: state.isLoading,
            //   onPressed: () => notifier.signIn(SocialProvider.facebook, l10n),
            // ),

            // // TODO: Add Apple sign in configuration in firebase.
            // SizedBox(height: buttonSpacing),
            // SocialLoginButton(
            //   image: 'assets/images/social/apple.png',
            //   label: l10n.socialContinueWith("Apple"),
            //   isLoading: state.loadingProvider == SocialProvider.apple,
            //   disabled: state.isLoading,
            //   onPressed: () => notifier.signIn(SocialProvider.apple, l10n),
            // ),
          ],
        ),
    };
  }
}

class SocialLoginPin extends StatelessWidget {
  const SocialLoginPin({
    super.key,
    required this.image,
    this.onPressed,
    this.isLoading = false,
    this.disabled = false,
  });

  final String image;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: disabled ? null : onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            opacity: isLoading ? 0.3 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (isLoading)
            CircularProgressIndicator(
              color: context.colorScheme.surface,
            ),
        ],
      ),
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.image,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.disabled = false,
  });

  final String image;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      leading: Image.asset(image, width: 30, height: 30),
      text: label,
      onPressed: disabled ? null : onPressed,
      isProcessing: isLoading,
      detailColor: context.colorScheme.surfaceContainerHighest,
      textColor: context.colorScheme.onSurface,
    );
  }
}
