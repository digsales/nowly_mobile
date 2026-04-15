import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../extensions/context_extensions.dart';
import 'app_loading.dart';

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
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.leading,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.width,
    this.detailColor,
    this.textColor,
    this.isProcessing = false,
  });

  /// Optional widget rendered before the [text] (e.g. an icon or image).
  final Widget? leading;

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

  Color _resolveTextColor(BuildContext context) {
    return switch (variant) {
      AppButtonVariant.filled => textColor ?? context.colorScheme.onPrimary,
      AppButtonVariant.outlined => textColor ?? context.colorScheme.primary,
    };
  }

  Widget _buildChild(BuildContext context) {
    if (isProcessing) {
      return AppLoading(color: _resolveTextColor(context));
    }

    final label = Text(
      text,
      style: context.textTheme.labelLarge?.copyWith(
        color: _resolveTextColor(context),
      ),
      textAlign: TextAlign.center,
    );

    if (leading == null) return label;

    return Row(
      children: [
        leading!,
        Expanded(child: label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      AppButtonVariant.filled => ElevatedButton(
          onPressed: isProcessing ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(width ?? 100.w, 60),
            backgroundColor: detailColor ?? context.colorScheme.primary,
            foregroundColor: textColor ?? context.colorScheme.surface,
            disabledBackgroundColor: detailColor ?? context.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: _buildChild(context),
        ),
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: isProcessing ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(width ?? 100.w, 60),
            side: BorderSide(
              color: detailColor ?? context.colorScheme.primary,
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
