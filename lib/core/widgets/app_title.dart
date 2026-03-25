import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_help_sheet.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';

/// Section title styled with the Ultra font family.
///
/// Displays a bold heading with an optional help icon on the right.
/// When [onRefresh] is provided, tapping the refresh icon do the action.
/// When [helpText] is provided, tapping the help icon opens an [AppHelpSheet]
/// with the given text. The sheet title defaults to [title] but can be
/// overridden with [helpTitle].
///
/// ```dart
/// AppTitle(
///   title: 'Categories',
///   helpText: 'Organize your tasks into categories.',
/// )
/// ```
class AppTitle extends StatefulWidget {
  const AppTitle({
    super.key,
    required this.title,
    this.titleColor,
    this.onRefresh,
    this.helpTitle,
    this.helpText,
  });

  /// The heading text displayed on the left.
  final String title;

  /// The heading text color on the left. Defaults to [onSurface] when omitted.
  final Color? titleColor;

  /// Refresh function that when not omitted, show a refresh icon
  /// on the right side of the title.
  final Future<void> Function()? onRefresh;

  /// Custom title for the help sheet. Defaults to [title] when omitted.
  final String? helpTitle;

  /// Explanatory text shown in the help sheet. When non-null, a help icon
  /// appears on the right side of the title.
  final String? helpText;

  @override
  State<AppTitle> createState() => _AppTitleState();
}

class _AppTitleState extends State<AppTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    _spinController.repeat();

    try {
      await widget.onRefresh!();
    } finally {
      if (mounted) {
        _spinController.stop();
        _spinController.reset();
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.titleColor ?? context.colorScheme.onSurface;
    final iconSize = context.textTheme.displaySmall!.fontSize;

    return Row(
      children: [
        Expanded(
          child: Text(
            widget.title,
            style: context.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontFamily: 'Ultra',
              color: color,
            ),
          ),
        ),
        if (widget.onRefresh != null) ...[
          const SizedBox(width: 8),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: _isRefreshing ? 0.4 : 1.0,
            child: TouchableOpacity(
              onTap: _isRefreshing ? null : _handleRefresh,
              child: RotationTransition(
                turns: _spinController,
                child: Icon(
                  Ionicons.refresh_circle_outline,
                  color: color,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ],
        if (widget.helpText != null) ...[
          const SizedBox(width: 8),
          TouchableOpacity(
            onTap: () => AppHelpSheet.show(
              context: context,
              title: widget.helpTitle ?? widget.title,
              text: widget.helpText!,
            ),
            child: Icon(
              Ionicons.help_circle_outline,
              color: color,
              size: iconSize,
            ),
          ),
        ],
      ],
    );
  }
}
