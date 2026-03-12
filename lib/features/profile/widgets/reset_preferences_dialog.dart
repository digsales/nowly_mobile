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

    return AppDialog(
      icon: Ionicons.refresh_outline,
      title: context.l10n.settingsRestoreDefaults,
      subtitle: context.l10n.settingsRestoreDefaultsMessage,
      buttonText: context.l10n.settingsRestoreDefaultsConfirm,
      cancelText: context.l10n.deleteAccountCancel,
      onPressed: () {
        resetThemeDefaults(ref);
        Navigator.of(context).pop();
      },
      onCancel: () => Navigator.of(context).pop(),
    );
  }
}
