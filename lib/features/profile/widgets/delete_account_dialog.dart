import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/app_button.dart';
import 'package:nowly/core/widgets/app_dialog.dart';
import 'package:nowly/core/widgets/app_text_field.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';
import 'package:nowly/features/profile/profile_provider.dart';

class DeleteAccountDialog extends ConsumerWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);
    final l10n = context.l10n;

    return AppDialog(
      icon: Ionicons.trash_outline,
      color: context.colorScheme.error,
      title: l10n.deleteAccountTitle,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.deleteAccountMessage,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
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
        AppButton(
          text: l10n.deleteAccountConfirm,
          detailColor: context.colorScheme.error,
          textColor: context.colorScheme.onError,
          isProcessing: state.isLoading,
          onPressed: () async {
            final success = await notifier.deleteAccount(l10n);
            if (context.mounted && success) {
              Navigator.of(context).pop();
            }
          },
        ),
        const SizedBox(height: 16),
        TouchableOpacity(
          onTap: state.isLoading
            ? () {}
            : () => Navigator.of(context).pop(),
          child: Text(
            l10n.deleteAccountCancel,
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
