import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/validators/field_controller.dart';
import 'package:nowly/core/validators/validators.dart';
import 'package:nowly/core/widgets/app_dialog.dart';
import 'package:nowly/core/widgets/app_text_field.dart';
import 'package:nowly/features/profile/profile_provider.dart';

class EditNameDialog extends ConsumerStatefulWidget {
  const EditNameDialog({super.key, required this.currentName});

  final String currentName;

  @override
  ConsumerState<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends ConsumerState<EditNameDialog> {
  final _name = FieldController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name.controller.text = widget.currentName;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _name.validator = Validators.combine([
      Validators.required(context.l10n.validatorRequired),
      Validators.minLength(3, context.l10n.validatorMinLength(3)),
    ]);

    return AppDialog(
      icon: Ionicons.person_outline,
      title: context.l10n.settingsEditNameTitle,
      body: AppTextField(
        controller: _name.controller,
        hintText: context.l10n.textFieldHintName,
        label: context.l10n.textFieldLabelName,
        prefixIcon: Ionicons.person_outline,
        textCapitalization: TextCapitalization.words,
        onChanged: (_) => setState(() {
          if (_name.error != null) _name.validate();
          _error = null;
        }),
        errorText: _name.error ?? _error,
      ),
      buttonText: context.l10n.settingsEditNameButton,
      isProcessing: _isLoading,
      onPressed: () async {
        if (!_name.validate()) {
          setState(() {});
          return;
        }

        setState(() => _isLoading = true);

        final notifier = ref.read(profileProvider.notifier);
        final success = await notifier.updateName(_name.text);

        if (context.mounted && success) {
          Navigator.of(context).pop();
        } else if (mounted) {
          setState(() {
            _isLoading = false;
            _error = context.l10n.authErrorUnknown;
          });
        }
      },
      cancelText: context.l10n.deleteAccountCancel,
      onCancel: () => Navigator.of(context).pop(),
    );
  }
}
