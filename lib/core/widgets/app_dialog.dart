import 'package:flutter/material.dart';
import 'package:nowly/core/extensions/context_extensions.dart';

/// Reusable dialog with a floating icon badge (half inside, half outside),
/// a title, scrollable body content, and action buttons.
///
/// The [color] tints the icon badge and defaults to `colorScheme.primary`.
///
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => AppDialog(
///     icon: Icons.check,
///     color: Colors.green,
///     title: 'Success',
///     body: Text('Congratulations!'),
///     actions: [
///       AppButton(
///         text: 'Done',
///         onPressed: () => Navigator.of(context).pop(),
///       ),
///     ],
///   ),
/// );
/// ```
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.icon,
    this.color,
    required this.title,
    this.body,
    this.actions = const [],
  });

  /// Icon displayed in the floating circle badge at the top.
  final IconData icon;

  /// Accent color for the icon badge. Defaults to `colorScheme.primary`.
  final Color? color;

  /// Dialog title.
  final String title;

  /// Optional scrollable content below the title.
  final Widget? body;

  /// Action buttons at the bottom.
  final List<Widget> actions;

  static const double _badgeSize = 64;
  static const double _badgeOverlap = _badgeSize / 2;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? context.colorScheme.primary;

    return Center(
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
                        if (body != null) ...[
                          const SizedBox(height: 12),
                          Flexible(
                            child: SingleChildScrollView(child: body),
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
                  child: Icon(icon, color: context.colorScheme.surface, size: 38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
