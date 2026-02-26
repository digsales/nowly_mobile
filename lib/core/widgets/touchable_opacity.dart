import 'package:flutter/material.dart';

/// Reduces opacity on press, similar to React Native's `TouchableOpacity`.
///
/// ```dart
/// TouchableOpacity(
///   onTap: () => print('pressed'),
///   child: Text('Forgot password?'),
/// )
/// ```
class TouchableOpacity extends StatefulWidget {
  const TouchableOpacity({
    super.key,
    required this.child,
    required this.onTap,
    this.activeOpacity = 0.4,
  });

  /// Child widget that receives the opacity effect.
  final Widget child;

  /// Callback fired on tap release.
  final VoidCallback onTap;

  /// Opacity applied while pressing. Defaults to `0.4`.
  final double activeOpacity;

  @override
  State<TouchableOpacity> createState() => _TouchableOpacityState();
}

class _TouchableOpacityState extends State<TouchableOpacity> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _isPressed ? widget.activeOpacity : 1.0,
        child: widget.child,
      ),
    );
  }
}
