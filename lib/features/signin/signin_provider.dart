import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monno_money/core/services/auth_service.dart';
import 'package:monno_money/core/services/auth_service_provider.dart';
import 'package:monno_money/core/validators/field_controller.dart';
import 'package:monno_money/core/validators/validators.dart';
import 'package:monno_money/l10n/app_localizations.dart';

final signinProvider =
    NotifierProvider<SigninNotifier, SigninState>(SigninNotifier.new);

class SigninState {
  const SigninState({
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isLoading;
  final String? errorMessage;

  SigninState copyWith({bool? isLoading, String? errorMessage}) {
    return SigninState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class SigninNotifier extends Notifier<SigninState> {
  late final AuthService _authService;
  final email = FieldController();
  final password = FieldController();

  @override
  SigninState build() {
    _authService = ref.read(authServiceProvider);
    ref.onDispose(() {
      email.dispose();
      password.dispose();
    });
    return const SigninState();
  }

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
      state = state.copyWith();
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      await _authService.signin(
        email: email.text,
        password: password.text,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message(l10n),
      );
      return;
    }

    state = state.copyWith(isLoading: false);
  }

  void onEmailChanged(String value) {
    email.onChanged(value);
    state = state.copyWith();
  }

  void onPasswordChanged(String value) {
    password.onChanged(value);
    state = state.copyWith();
  }
}
