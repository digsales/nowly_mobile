import 'package:flutter/material.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_button.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';

/// Reusable dialog with a floating icon badge (half inside, half outside),
/// a title, scrollable body content, and action buttons.
///
/// [color] and [onColor] tint the badge and button consistently.
/// Defaults to `colorScheme.primary` / `colorScheme.onPrimary`.
///
/// Use [actionsBuilder] for full control over the actions area.
///
/// ```dart
/// AppDialog(
///   icon: Icons.check,
///   color: Colors.green,
///   onColor: Colors.white,
///   title: 'Success',
///   subtitle: 'Congratulations!',
///   buttonText: 'Done',
///   onPressed: () => Navigator.of(context).pop(),
/// )
/// ```
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.icon,
    this.color,
    this.onColor,
    required this.title,
    this.subtitle,
    this.body,
    this.buttonText,
    this.onPressed,
    this.isProcessing = false,
    this.cancelText,
    this.onCancel,
    this.actionsBuilder,
  });

  /// Icon displayed in the floating circle badge at the top.
  final IconData icon;

  /// Badge and button background color. Defaults to `colorScheme.primary`.
  final Color? color;

  /// Icon and button text color. Defaults to `colorScheme.onPrimary`.
  final Color? onColor;

  /// Dialog title.
  final String title;

  /// Optional subtitle below the title (inside the scroll area).
  final String? subtitle;

  /// Optional scrollable content below the subtitle.
  final Widget? body;

  /// Primary button text. Used when [actionsBuilder] is null.
  final String? buttonText;

  /// Primary button callback. Used when [actionsBuilder] is null.
  final VoidCallback? onPressed;

  /// Shows spinner on the primary button.
  final bool isProcessing;

  /// Cancel text below the primary button. Used when [actionsBuilder] is null.
  final String? cancelText;

  /// Cancel callback. Used when [actionsBuilder] is null.
  final VoidCallback? onCancel;

  /// Full control over the actions area. When provided, overrides
  /// [buttonText], [onPressed], [cancelText] and [onCancel].
  final List<Widget> Function(BuildContext context)? actionsBuilder;

  static const double _badgeSize = 64;
  static const double _badgeOverlap = _badgeSize / 2;

  List<Widget> _buildDefaultActions(BuildContext context) {
    final accent = color ?? context.colorScheme.primary;
    final onAccent = onColor ?? context.colorScheme.onPrimary;

    return [
      if (buttonText != null)
        AppButton(
          text: buttonText!,
          detailColor: accent,
          textColor: onAccent,
          isProcessing: isProcessing,
          onPressed: onPressed,
        ),
      if (cancelText != null) ...[
        const SizedBox(height: 16),
        TouchableOpacity(
          onTap: isProcessing ? () {} : (onCancel ?? () {}),
          child: Text(
            cancelText!,
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final accent = color ?? context.colorScheme.primary;
    final onAccent = onColor ?? context.colorScheme.onPrimary;
    final actions = actionsBuilder?.call(context) ?? _buildDefaultActions(context);

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 50),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: IntrinsicHeight(
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: _badgeOverlap),
                  child: Material(
                    color: context.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        24, _badgeOverlap + 16, 24, 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (subtitle != null || body != null) ...[
                            const SizedBox(height: 12),
                            Flexible(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (subtitle != null)
                                      Text(
                                        subtitle!,
                                        style: context.textTheme.bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                    if (body != null) ...[
                                      if (subtitle != null) const SizedBox(height: 16),
                                      body!,
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                          if (actions.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            ...actions,
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Container(
                    width: _badgeSize,
                    height: _badgeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent,
                    ),
                    child: Icon(icon, color: onAccent, size: 38),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
