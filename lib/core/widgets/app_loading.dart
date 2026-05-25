import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Animated rotating hourglass spinner.
///
/// Starts/stops the rotation automatically based on lifecycle.
/// Use [color] to tint the hourglass and [size] to control dimensions.
///
/// ```dart
/// AppLoading(color: Colors.white, size: 24)
/// ```
class AppLoading extends StatefulWidget {
  const AppLoading({
    super.key,
    this.color,
    this.size,
  });

  /// Hourglass color. Defaults to `colorScheme.primary`.
  final Color? color;

  /// Width and height. Defaults to `24`.
  final double? size;

  @override
  State<AppLoading> createState() => _AppLoadingState();
}

class _AppLoadingState extends State<AppLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedColor = widget.color ?? Theme.of(context).colorScheme.primary;
    final resolvedSize = widget.size ?? 24;

    return RotationTransition(
      turns: _controller,
      child: SvgPicture.asset(
        'assets/images/svg/hourglass.svg',
        colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn),
        height: resolvedSize,
        width: resolvedSize,
      ),
    );
  }
}
