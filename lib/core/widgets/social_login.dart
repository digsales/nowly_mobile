import 'package:flutter/material.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';

/// Row of social login provider buttons (Google, Facebook, Apple, etc.).
///
/// Each provider is rendered as a circular avatar from an asset image.
/// Wrap layout adapts to available width automatically.
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
class SocialLogin extends StatelessWidget {
  const SocialLogin({
    super.key,
    this.providers,
    this.spacing = 30,
    this.runSpacing = 20,
  });

  static const _defaultProviders = [
    SocialLoginPin(image: 'assets/images/social/google.png'),
    SocialLoginPin(image: 'assets/images/social/facebook.png'),
    SocialLoginPin(image: 'assets/images/social/apple.png'),
  ];

  final List<SocialLoginPin>? providers;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: spacing,
        runSpacing: runSpacing,
        children: providers ?? _defaultProviders,
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
