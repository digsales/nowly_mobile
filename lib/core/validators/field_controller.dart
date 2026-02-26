import 'package:flutter/widgets.dart';
import 'validators.dart';

class FieldController {
  FieldController({this.validator});

  final controller = TextEditingController();
  Validator? validator;
  String? _error;
  bool _submitted = false;

  String get text => controller.text;
  String? get error => _error;

  bool validate() {
    _submitted = true;
    _error = validator?.call(controller.text);
    return _error == null;
  }

  void onChanged(String _) {
    if (_submitted) validate();
  }

  void dispose() {
    controller.dispose();
  }
}

bool validateAll(List<FieldController> fields) {
  var valid = true;
  for (final field in fields) {
    if (!field.validate()) valid = false;
  }
  return valid;
}
