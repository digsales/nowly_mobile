import 'package:flutter/widgets.dart';
import 'validators.dart';

/// Encapsulates a [TextEditingController], a [Validator], and the current
/// error state for a single form field.
///
/// After the first call to [validate], subsequent text changes automatically
/// re-run validation so the error message updates in real time.
///
/// ```dart
/// final email = FieldController(
///   validator: Validators.combine([
///     Validators.required(l10n.validatorRequired),
///     Validators.email(l10n.validatorEmail),
///   ]),
/// );
/// ```
class FieldController {
  /// Creates a controller with an optional [validator].
  FieldController({this.validator});

  /// Underlying text editing controller bound to the text field.
  final controller = TextEditingController();

  /// Validation function applied to the field's text.
  /// Can be reassigned after construction (e.g. when l10n becomes available).
  Validator? validator;

  String? _error;
  bool _submitted = false;

  /// Current text value of the field.
  String get text => controller.text;

  /// Current error message, or `null` if the field is valid.
  String? get error => _error;

  /// Runs the [validator] against the current text and returns `true`
  /// if valid. After the first call, [onChanged] will automatically
  /// re-validate on every keystroke.
  bool validate() {
    _submitted = true;
    _error = validator?.call(controller.text);
    return _error == null;
  }

  /// Pass this to `AppTextField.onChanged` so the field re-validates
  /// after the user has submitted at least once.
  void onChanged(String _) {
    if (_submitted) validate();
  }

  /// Disposes the underlying [TextEditingController].
  /// Call this in the owner's dispose/close method.
  void dispose() {
    controller.dispose();
  }
}

/// Validates every [FieldController] in [fields] and returns `true` only
/// if all of them pass. Every field is validated even if an earlier one
/// fails, so all error messages are shown at once.
bool validateAll(List<FieldController> fields) {
  var valid = true;
  for (final field in fields) {
    if (!field.validate()) valid = false;
  }
  return valid;
}
