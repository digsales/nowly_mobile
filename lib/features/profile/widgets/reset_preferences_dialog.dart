import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/theme/theme_provider.dart';
import 'package:nowly/core/widgets/app_dialog.dart';

class ResetPreferencesDialog extends ConsumerWidget {
  const ResetPreferencesDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return AppDialog(
      icon: Ionicons.refresh_outline,
      title: l10n.settingsRestoreDefaults,
      subtitle: l10n.settingsRestoreDefaultsMessage,
      buttonText: l10n.settingsRestoreDefaultsConfirm,
      cancelText: l10n.deleteAccountCancel,
      onPressed: () {
        resetThemeDefaults(ref);
        Navigator.of(context).pop();
      },
      onCancel: () => Navigator.of(context).pop(),
    );
  }
}
