import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

import '../extensions/context_extensions.dart';

/// Visual variants for [AppButton].
enum AppButtonVariant { filled, outlined }

/// Reusable button with two variants: [filled] and [outlined].
///
/// Shows an animated hourglass spinner when [isProcessing] is `true`,
/// disabling interaction until processing completes.
///
/// ```dart
/// AppButton(
///   text: 'Sign in',
///   onPressed: () => controller.signin(),
///   isProcessing: state.isLoading,
/// )
/// ```
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.width,
    this.detailColor,
    this.textColor,
    this.isProcessing = false,
  });

  /// Text displayed on the button.
  final String text;

  /// Tap callback. If `null`, the button is disabled.
  final VoidCallback? onPressed;

  /// Visual variant: [AppButtonVariant.filled] (default) or [AppButtonVariant.outlined].
  final AppButtonVariant variant;

  /// Custom width. Defaults to full screen width.
  final double? width;

  /// Background color (filled) or border color (outlined). Defaults to `colorScheme.primary`.
  final Color? detailColor;

  /// Text color. Default depends on the variant.
  final Color? textColor;

  /// When `true`, shows the spinner and disables interaction.
  final bool isProcessing;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isProcessing) _rotationController.repeat();
  }

  @override
  void didUpdateWidget(AppButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isProcessing && !oldWidget.isProcessing) {
      _rotationController.repeat();
    } else if (!widget.isProcessing && oldWidget.isProcessing) {
      _rotationController.stop();
      _rotationController.reset();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Color _resolveTextColor(BuildContext context) {
    return switch (widget.variant) {
      AppButtonVariant.filled => widget.textColor ?? context.colorScheme.onPrimary,
      AppButtonVariant.outlined => widget.textColor ?? context.colorScheme.primary,
    };
  }

  Widget _buildChild(BuildContext context) {
    if (widget.isProcessing) {
      final color = _resolveTextColor(context);
      return RotationTransition(
        turns: _rotationController,
        child: SvgPicture.asset(
          'assets/images/svg/hourglass.svg',
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          height: 20.sp,
          width: 20.sp,
        ),
      );
    }

    return Text(
      widget.text,
      style: context.textTheme.labelLarge?.copyWith(
        color: _resolveTextColor(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.variant) {
      AppButtonVariant.filled => ElevatedButton(
          onPressed: widget.isProcessing ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(widget.width ?? 100.w, 31.sp),
            backgroundColor: widget.detailColor ?? context.colorScheme.primary,
            foregroundColor: widget.textColor ?? context.colorScheme.surface,
            disabledBackgroundColor: widget.detailColor ?? context.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: _buildChild(context),
        ),
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: widget.isProcessing ? null : widget.onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(widget.width ?? 100.w, 31.sp),
            side: BorderSide(
              color: widget.detailColor ?? context.colorScheme.primary,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: _buildChild(context),
        ),
    };
  }
}
