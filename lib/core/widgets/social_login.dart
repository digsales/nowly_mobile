import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/providers/social_login_provider.dart';
import 'package:nowly/core/widgets/app_snack_bar.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';

/// Row of social login provider buttons (Google, Facebook, Apple).
///
/// Handles authentication internally via [socialLoginProvider].
///
/// ```dart
/// // Uses default providers (Google, Facebook, Apple):
/// SocialLogin()
///
/// // Custom providers:
/// SocialLogin(
///   providers: [
///     SocialLoginPin(image: 'assets/images/social/google.png', onPressed: () {}),
///   ],
/// )
/// ```
class SocialLogin extends ConsumerWidget {
  const SocialLogin({
    super.key,
    this.providers,
    this.spacing = 30,
    this.runSpacing = 20,
  });

  final List<SocialLoginPin>? providers;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(socialLoginProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        AppSnackBar.show(context, next.errorMessage!);
      }
    });

    final l10n = context.l10n;
    final notifier = ref.read(socialLoginProvider.notifier);

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: spacing,
        runSpacing: runSpacing,
        children: providers ??
            [
              SocialLoginPin(
                image: 'assets/images/social/google.png',
                onPressed: () => notifier.signIn(SocialProvider.google, l10n),
              ),

              // // TODO: Add Facebook sign in configuration in firebase.
              // SocialLoginPin(
              //   image: 'assets/images/social/facebook.png',
              //   onPressed: () => notifier.signIn(SocialProvider.facebook, l10n),
              // ),

              // // TODO: Add Apple sign in configuration in firebase.
              // SocialLoginPin(
              //   image: 'assets/images/social/apple.png',
              //   onPressed: () => notifier.signIn(SocialProvider.apple, l10n),
              // ),
            ],
      ),
    );
  }
}

class SocialLoginPin extends StatelessWidget {
  const SocialLoginPin({
    super.key,
    required this.image,
    this.onPressed,
  });

  final String image;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: onPressed,
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
    );
  }
}
