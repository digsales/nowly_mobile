import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monno_money/core/validators/field_controller.dart';
import 'package:monno_money/core/validators/validators.dart';
import 'package:monno_money/l10n/app_localizations.dart';

final signinProvider = ChangeNotifierProvider.autoDispose((_) => SigninController());

class SigninController extends ChangeNotifier {
  final email = FieldController();
  final password = FieldController();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> signin(AppLocalizations l10n) async {
    email.validator = Validators.combine([
      Validators.required(l10n.validatorRequired),
      Validators.email(l10n.validatorEmail),
    ]);
    password.validator = Validators.combine([
      Validators.required(l10n.validatorRequired),
      Validators.minLength(8, l10n.validatorPasswordMin),
    ]);

    if (!validateAll([email, password])) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // TODO: implement signin logic
      await Future.delayed(const Duration(seconds: 2));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onEmailChanged(String value) {
    email.onChanged(value);
    notifyListeners();
  }

  void onPasswordChanged(String value) {
    password.onChanged(value);
    notifyListeners();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }
}
