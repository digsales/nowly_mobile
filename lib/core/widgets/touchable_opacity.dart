import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.onLongPress,
    this.activeOpacity = 0.4,
  });

  /// Child widget that receives the opacity effect.
  final Widget child;

  /// Callback fired on tap release. When `null`, the widget is inert
  /// (no opacity change, no gesture handling).
  final VoidCallback? onTap;

  /// Callback fired on long press.
  final VoidCallback? onLongPress;

  /// Opacity applied while pressing. Defaults to `0.4`.
  final double activeOpacity;

  @override
  State<TouchableOpacity> createState() => _TouchableOpacityState();
}

class _TouchableOpacityState extends State<TouchableOpacity> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null && widget.onLongPress == null) return widget.child;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress == null 
        ? null
        : () {
            HapticFeedback.mediumImpact();
            widget.onLongPress?.call();
          },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _isPressed ? widget.activeOpacity : 1.0,
        child: widget.child,
      ),
      ),
    );
  }
}
