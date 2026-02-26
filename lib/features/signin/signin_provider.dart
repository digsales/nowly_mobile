import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monno_money/core/validators/validators.dart';
import 'package:monno_money/l10n/app_localizations.dart';

final signinProvider = ChangeNotifierProvider.autoDispose((_) => SigninController());

class SigninController extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  bool _submitted = false;

  bool get isLoading => _isLoading;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;

  void validateEmail(AppLocalizations l10n) {
    final validator = Validators.combine([
      Validators.required(l10n.validatorRequired),
      Validators.email(l10n.validatorEmail),
    ]);
    _emailError = validator(emailController.text);
    notifyListeners();
  }

  void validatePassword(AppLocalizations l10n) {
    final validator = Validators.combine([
      Validators.required(l10n.validatorRequired),
      Validators.minLength(8, l10n.validatorPasswordMin),
      Validators.hasUppercase(l10n.validatorPasswordUppercase),
      Validators.hasLowercase(l10n.validatorPasswordLowercase),
      Validators.hasDigit(l10n.validatorPasswordDigit),
      Validators.hasSpecialChar(l10n.validatorPasswordSpecial),
    ]);
    _passwordError = validator(passwordController.text);
    notifyListeners();
  }

  void onEmailChanged(AppLocalizations l10n) {
    if (_submitted) validateEmail(l10n);
  }

  void onPasswordChanged(AppLocalizations l10n) {
    if (_submitted) validatePassword(l10n);
  }

  Future<void> signin(AppLocalizations l10n) async {
    _submitted = true;
    validateEmail(l10n);
    validatePassword(l10n);

    if (_emailError != null || _passwordError != null) return;

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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
