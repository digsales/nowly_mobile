import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../extensions/context_extensions.dart';

enum AppButtonVariant { filled, outlined }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.width,
    this.detailColor,
    this.textColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final double? width;
  final Color? detailColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      AppButtonVariant.filled => ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(width ?? 100.w, 31.sp),
            backgroundColor: detailColor ?? context.colorScheme.primary,
            foregroundColor: textColor ?? context.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Text(
            text,
            style: context.textTheme.labelLarge?.copyWith(
              color: textColor ?? context.colorScheme.surface,
            ),
          ),
        ),
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(width ?? 100.w, 31.sp),
            side: BorderSide(
              color: detailColor ?? context.colorScheme.primary,
              width: 2
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Text(
            text,
            style: context.textTheme.labelLarge?.copyWith(
              color: textColor ?? context.colorScheme.primary,
            ),
          ),
        ),
    };
  }
}
