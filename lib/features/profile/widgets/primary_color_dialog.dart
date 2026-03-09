import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/theme/theme_provider.dart';
import 'package:nowly/core/widgets/app_dialog.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';

class PrimaryColorDialog extends ConsumerWidget {
  const PrimaryColorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentKey = ref.read(primaryColorProvider.notifier).currentKey;

    return AppDialog(
      icon: Ionicons.color_palette_outline,
      title: context.l10n.settingsPrimaryColor,
      body: Column(
        children: PrimaryColorNotifier.options.entries.map((entry) {
          final isSelected = entry.key == currentKey;
          return _ColorTile(
            color: entry.value.primary,
            label: entry.key,
            selected: isSelected,
            onTap: () {
              ref.read(primaryColorProvider.notifier).set(entry.key);
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
      cancelText: context.l10n.deleteAccountCancel,
      onCancel: () => Navigator.of(context).pop(),
    );
  }
}

class _ColorTile extends StatelessWidget {
  const _ColorTile({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label[0].toUpperCase() + label.substring(1),
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (selected)
              Icon(
                Ionicons.checkmark_outline,
                size: 18,
                color: context.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
