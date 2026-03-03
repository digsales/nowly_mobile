import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_button.dart';
import 'package:nowly/core/widgets/app_text_field.dart';
import 'package:nowly/features/profile/profile_provider.dart';

class DeleteAccountDialog extends ConsumerWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.deleteAccountTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.deleteAccountMessage,
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: notifier.password.controller,
            hintText: l10n.textFieldHintPassword,
            label: l10n.textFieldLabelPassword,
            prefixIcon: Ionicons.lock_closed_outline,
            isPassword: true,
            onChanged: notifier.onPasswordChanged,
            errorText: notifier.password.error ?? state.errorMessage,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: state.isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: Text(l10n.deleteAccountCancel),
        ),
        AppButton(
          text: l10n.deleteAccountConfirm,
          detailColor: context.colorScheme.error,
          textColor: context.colorScheme.onError,
          isProcessing: state.isLoading,
          width: 120,
          onPressed: () async {
            await notifier.deleteAccount(l10n);
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
