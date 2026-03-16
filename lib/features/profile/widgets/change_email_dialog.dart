import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/services/auth_service.dart';
import 'package:nowly/core/validators/field_controller.dart';
import 'package:nowly/core/validators/validators.dart';
import 'package:nowly/core/widgets/app_dialog.dart';
import 'package:nowly/core/widgets/app_text_field.dart';
import 'package:nowly/features/profile/profile_provider.dart';

class ChangeEmailDialog extends ConsumerStatefulWidget {
  const ChangeEmailDialog({super.key, required this.currentEmail});

  final String currentEmail;

  @override
  ConsumerState<ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends ConsumerState<ChangeEmailDialog> {
  final _currentPassword = FieldController();
  final _newEmail = FieldController();
  final _confirmEmail = FieldController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newEmail.dispose();
    _confirmEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _currentPassword.validator = Validators.combine([
      Validators.required(context.l10n.validatorRequired),
    ]);

    _newEmail.validator = Validators.combine([
      Validators.required(context.l10n.validatorRequired),
      Validators.email(context.l10n.validatorEmail),
    ]);

    _confirmEmail.validator = Validators.combine([
      Validators.required(context.l10n.validatorRequired),
      Validators.match(_newEmail.controller, context.l10n.validatorEmailMatch),
    ]);

    return AppDialog(
      icon: Ionicons.mail_outline,
      title: context.l10n.settingsChangeEmailTitle,
      subtitle: context.l10n.settingsChangeEmailMessage,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: _currentPassword.controller,
            hintText: context.l10n.settingsCurrentPasswordHint,
            label: context.l10n.settingsCurrentPassword,
            prefixIcon: Ionicons.lock_closed_outline,
            isPassword: true,
            onChanged: (_) => setState(() {
              if (_currentPassword.error != null) _currentPassword.validate();
            }),
            errorText: _currentPassword.error,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _newEmail.controller,
            keyboardType: TextInputType.emailAddress,
            hintText: context.l10n.settingsNewEmailHint,
            label: context.l10n.settingsNewEmail,
            prefixIcon: Ionicons.mail_outline,
            onChanged: (_) => setState(() {
              if (_confirmEmail.error != null) _confirmEmail.validate();
              if (_newEmail.error != null) _newEmail.validate();
              _error = null;
            }),
            errorText: _newEmail.error ?? _error,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _confirmEmail.controller,
            keyboardType: TextInputType.emailAddress,
            hintText: context.l10n.textFieldHintConfirmEmail,
            label: context.l10n.textFieldLabelConfirmEmail,
            prefixIcon: Ionicons.mail_outline,
            onChanged: (_) => setState(() {
              if (_confirmEmail.error != null) _confirmEmail.validate();
            }),
            errorText: _confirmEmail.error,
          ),
        ],
      ),
      buttonText: context.l10n.settingsChangeEmailButton,
      isProcessing: _isLoading,
      onPressed: () async {
        final valid = validateAll([_currentPassword, _newEmail, _confirmEmail]);
        if (!valid) {
          setState(() {});
          return;
        }

        setState(() {
          _isLoading = true;
          _error = null;
        });

        try {
          final notifier = ref.read(profileProvider.notifier);
          await notifier.changeEmail(
            currentPassword: _currentPassword.text,
            newEmail: _newEmail.text,
          );
        } on AuthException catch (e) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _error = e.message(context.l10n);
            });
          }
        } on Exception {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _error = context.l10n.authErrorUnknown;
            });
          }
        }
      },
      cancelText: context.l10n.dialogBack,
      onCancel: () => Navigator.of(context).pop(),
    );
  }
}
