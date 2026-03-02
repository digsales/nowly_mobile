import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/services/auth_service.dart';
import 'package:nowly/core/services/auth_service_provider.dart';
import 'package:nowly/core/validators/field_controller.dart';
import 'package:nowly/core/validators/validators.dart';
import 'package:nowly/l10n/app_localizations.dart';

final signupProvider =
    NotifierProvider.autoDispose<SignupNotifier, SignupState>(SignupNotifier.new);

class SignupState {
  const SignupState({
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isLoading;
  final String? errorMessage;

  SignupState copyWith({bool? isLoading, String? errorMessage}) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class SignupNotifier extends Notifier<SignupState> {
  late final AuthService _authService;
  final name = FieldController();
  final email = FieldController();
  final confirmEmail = FieldController();
  final password = FieldController();
  final confirmPassword = FieldController();

  @override
  SignupState build() {
    _authService = ref.read(authServiceProvider);
    ref.onDispose(() {
      name.dispose();
      email.dispose();
      confirmEmail.dispose();
      password.dispose();
      confirmPassword.dispose();
    });
    return const SignupState();
  }

  Future<void> signup(AppLocalizations l10n) async {
    name.validator = Validators.combine([
      Validators.required(l10n.validatorRequired),
      Validators.minLength(3, l10n.validatorMinLength(3))
    ]);

    email.validator = Validators.combine([
      Validators.required(l10n.validatorRequired),
      Validators.email(l10n.validatorEmail),
    ]);
    
    confirmEmail.validator = Validators.combine([
      Validators.required(l10n.validatorRequired),
      Validators.match(email.controller, l10n.validatorEmailMatch),
    ]);

    password.validator = Validators.combine([
      Validators.required(l10n.validatorRequired),
      Validators.minLength(8, l10n.validatorPasswordMin),
      Validators.hasUppercase(l10n.validatorPasswordUppercase),
      Validators.hasLowercase(l10n.validatorPasswordLowercase),
      Validators.hasDigit(l10n.validatorPasswordDigit),
      Validators.hasSpecialChar(l10n.validatorPasswordSpecial),
    ]);

    confirmPassword.validator = Validators.combine([
      Validators.required(l10n.validatorRequired),
      Validators.match(password.controller, l10n.validatorPasswordMatch),
    ]);

    if (!validateAll([name, email, confirmEmail, password, confirmPassword])) {
      state = state.copyWith();
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      await _authService.signup(
        email: email.text,
        password: password.text,
      );
    } on AuthException catch (e) {
      debugPrint('AuthException code: ${e.code}');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message(l10n),
      );
      return;
    }

    state = state.copyWith(isLoading: false);
  }

  void onNameChanged(String value) {
    name.onChanged(value);
    state = state.copyWith();
  }

  void onEmailChanged(String value) {
    email.onChanged(value);
    state = state.copyWith();
  }
  
  void onConfirmEmailChanged(String value) {
    confirmEmail.onChanged(value);
    state = state.copyWith();
  }

  void onPasswordChanged(String value) {
    password.onChanged(value);
    state = state.copyWith();
  }

  void onConfirmPasswordChanged(String value) {
    confirmPassword.onChanged(value);
    state = state.copyWith();
  }
}
