import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/theme/theme_provider.dart';
import 'package:nowly/core/widgets/app_dialog.dart';

class PrimaryColorDialog extends ConsumerWidget {
  const PrimaryColorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentKey = ref.read(primaryColorProvider.notifier).currentKey;

    return AppDialog(
      icon: Ionicons.color_palette_outline,
      title: context.l10n.settingsPrimaryColor,
      subtitle: context.l10n.settingsPrimaryColorSubtitle,
      body: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: PrimaryColorNotifier.options.entries.map((entry) {
          final isSelected = entry.key == currentKey;
          return GestureDetector(
            onTap: () {
              ref.read(primaryColorProvider.notifier).set(entry.key);
              Navigator.of(context).pop();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: entry.value.primary,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(
                        color: context.colorScheme.onSurface,
                        width: 3,
                      )
                    : null,
              ),
              child: isSelected
                  ? Icon(
                      Ionicons.checkmark,
                      size: 20,
                      color: context.colorScheme.onSurface,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
      cancelText: context.l10n.deleteAccountCancel,
      onCancel: () => Navigator.of(context).pop(),
    );
  }
}
