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

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _currentPassword = FieldController();
  final _newPassword = FieldController();
  final _confirmPassword = FieldController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _currentPassword.validator = Validators.combine([
      Validators.required(context.l10n.validatorRequired),
    ]);

    _newPassword.validator = Validators.combine([
      Validators.required(context.l10n.validatorRequired),
      Validators.minLength(8, context.l10n.validatorPasswordMin),
      Validators.hasUppercase(context.l10n.validatorPasswordUppercase),
      Validators.hasLowercase(context.l10n.validatorPasswordLowercase),
      Validators.hasDigit(context.l10n.validatorPasswordDigit),
      Validators.hasSpecialChar(context.l10n.validatorPasswordSpecial),
    ]);

    _confirmPassword.validator = Validators.combine([
      Validators.required(context.l10n.validatorRequired),
      Validators.match(_newPassword.controller, context.l10n.validatorPasswordMatch),
    ]);

    return AppDialog(
      icon: Ionicons.lock_closed_outline,
      title: context.l10n.settingsChangePasswordTitle,
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
              _error = null;
            }),
            errorText: _currentPassword.error ?? _error,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _newPassword.controller,
            hintText: context.l10n.settingsNewPasswordHint,
            label: context.l10n.settingsNewPassword,
            prefixIcon: Ionicons.key_outline,
            isPassword: true,
            onChanged: (_) => setState(() {
              if (_confirmPassword.error != null) _confirmPassword.validate();
              if (_newPassword.error != null) _newPassword.validate();
            }),
            errorText: _newPassword.error,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _confirmPassword.controller,
            hintText: context.l10n.settingsConfirmNewPasswordHint,
            label: context.l10n.settingsConfirmNewPassword,
            prefixIcon: Ionicons.key_outline,
            isPassword: true,
            onChanged: (_) => setState(() {
              if (_confirmPassword.error != null) _confirmPassword.validate();
            }),
            errorText: _confirmPassword.error,
          ),
        ],
      ),
      buttonText: context.l10n.settingsChangePasswordButton,
      isProcessing: _isLoading,
      onPressed: () async {
        final valid = validateAll([_currentPassword, _newPassword, _confirmPassword]);
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
          await notifier.changePassword(
            currentPassword: _currentPassword.text,
            newPassword: _newPassword.text,
          );
          if (context.mounted) Navigator.of(context).pop(true);
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
