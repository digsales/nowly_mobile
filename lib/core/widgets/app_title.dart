import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_help_sheet.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';

/// Section title styled with the Ultra font family.
///
/// Displays a bold heading with an optional help icon on the right.
/// When [helpText] is provided, tapping the icon opens an [AppHelpSheet]
/// with the given text. The sheet title defaults to [title] but can be
/// overridden with [helpTitle].
///
/// ```dart
/// AppTitle(
///   title: 'Categories',
///   helpText: 'Organize your tasks into categories.',
/// )
/// ```
class AppTitle extends StatelessWidget {
  const AppTitle({
    super.key,
    required this.title,
    this.titleColor,
    this.helpTitle,
    this.helpText,
  });

  /// The heading text displayed on the left.
  final String title;

  /// The heading text color on the left. Defaults to [onSurface] when omitted.
  final Color? titleColor;

  /// Custom title for the help sheet. Defaults to [title] when omitted.
  final String? helpTitle;

  /// Explanatory text shown in the help sheet. When non-null, a help icon
  /// appears on the right side of the title.
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: context.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontFamily: 'Ultra',
              color: titleColor ?? context.colorScheme.onSurface,
            ),
          ),
        ),
        if (helpText != null)
          TouchableOpacity(
            onTap: () => AppHelpSheet.show(
              context: context,
              title: helpTitle ?? title,
              text: helpText!,
            ),
            child: Icon(
                Ionicons.help_circle_outline,
                color: titleColor ?? context.colorScheme.onSurface,
                size: context.textTheme.displaySmall!.fontSize,
              ),
          )
      ],
    );
  }
}