import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_dialog.dart';
import 'package:nowly/core/widgets/app_text_field.dart';
import 'package:nowly/features/profile/profile_provider.dart';

class DeleteAccountDialog extends ConsumerWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return AppDialog(
      icon: Ionicons.trash_outline,
      color: context.colorScheme.error,
      onColor: context.colorScheme.onError,
      title: context.l10n.deleteAccountTitle,
      subtitle: context.l10n.deleteAccountMessage,
      buttonText: context.l10n.deleteAccountConfirm,
      isProcessing: state.isLoading,
      onPressed: () async {
        final success = await notifier.deleteAccount(context.l10n);
        if (context.mounted && success) {
          Navigator.of(context).pop();
        }
      },
      cancelText: context.l10n.deleteAccountCancel,
      onCancel: () => Navigator.of(context).pop(),
      body: AppTextField(
        controller: notifier.password.controller,
        hintText: context.l10n.textFieldHintPassword,
        label: context.l10n.textFieldLabelPassword,
        prefixIcon: Ionicons.lock_closed_outline,
        isPassword: true,
        onChanged: notifier.onPasswordChanged,
        errorText: notifier.password.error ?? state.errorMessage,
      ),
    );
  }
}
