import 'package:flutter/material.dart';
import 'package:nowly/core/extensions/context_extensions.dart';

/// A settings list tile with a circular icon on the left,
/// a label, and an optional trailing widget (toggle, chevron, etc.).
///
/// Use [trailingText] for a simple text + chevron trailing layout that
/// handles overflow automatically. Use [trailing] for custom widgets
/// (Switch, Slider, etc.).
///
/// ```dart
/// AppSettingTile(
///   icon: Icons.dark_mode_outlined,
///   label: 'Dark mode',
///   trailing: Switch(value: isDark, onChanged: ...),
/// )
/// ```
class AppSettingTile extends StatelessWidget {
  const AppSettingTile({
    super.key,
    required this.icon,
    required this.label,
    this.trailing,
    this.trailingText,
    this.onTap,
  });

  /// Icon displayed in a tinted circle on the left.
  final IconData icon;

  /// Setting label text.
  final String label;

  /// Trailing widget (Switch, Icon, Slider, etc.).
  final Widget? trailing;

  /// Optional trailing text displayed with a chevron.
  /// Handles overflow with ellipsis automatically.
  final String? trailingText;

  /// Tap callback for the entire row. Ignored if null.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: context.textTheme.bodyLarge!.fontSize! * 2.21,
              height: context.textTheme.bodyLarge!.fontSize! * 2.21,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                color: context.colorScheme.surfaceContainerHighest,
              ),
              child: Icon(
                icon,
                color: context.colorScheme.onSurface,
                size: context.textTheme.bodyLarge!.fontSize! * 1.2,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: context.textTheme.bodyLarge,
              ),
            ),
            if (trailingText != null)
            Expanded(
              child: Text(
                trailingText!,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 4),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
