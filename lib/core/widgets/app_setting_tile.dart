import 'package:flutter/material.dart';
import 'package:nowly/core/extensions/context_extensions.dart';

/// A settings list tile with a circular icon on the left,
/// a label, and an optional trailing widget (toggle, chevron, etc.).
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
    this.onTap,
  });

  /// Icon displayed in a tinted circle on the left.
  final IconData icon;

  /// Setting label text.
  final String label;

  /// Trailing widget (Switch, Icon, Slider, etc.).
  final Widget? trailing;

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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                color: context.colorScheme.surfaceContainerHighest,
              ),
              child: Icon(
                icon,
                color: context.colorScheme.onSurface,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodyLarge,
              ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
