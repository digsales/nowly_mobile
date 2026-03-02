import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/services/auth_service.dart';
import 'package:nowly/core/services/auth_service_provider.dart';
import 'package:nowly/core/validators/field_controller.dart';
import 'package:nowly/core/validators/validators.dart';
import 'package:nowly/l10n/app_localizations.dart';

final forgotPasswordProvider =
    NotifierProvider.autoDispose<ForgotPasswordNotifier, ForgotPasswordState>(
  ForgotPasswordNotifier.new,
);

class ForgotPasswordState {
  const ForgotPasswordState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  ForgotPasswordState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class ForgotPasswordNotifier extends Notifier<ForgotPasswordState> {
  late final AuthService _authService;
  final email = FieldController();

  @override
  ForgotPasswordState build() {
    _authService = ref.read(authServiceProvider);
    ref.onDispose(email.dispose);
    return const ForgotPasswordState();
  }

  Future<void> sendResetEmail(AppLocalizations l10n) async {
    email.validator = Validators.combine([
      Validators.required(l10n.validatorRequired),
      Validators.email(l10n.validatorEmail),
    ]);

    if (!email.validate()) {
      state = state.copyWith();
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      await _authService.resetPassword(email: email.text);
      state = state.copyWith(
        isLoading: false,
        successMessage: l10n.forgotPasswordSuccess,
      );
    } on AuthException catch (e) {
      debugPrint('AuthException code: ${e.code}');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message(l10n),
      );
    }
  }

  void onEmailChanged(String value) {
    email.onChanged(value);
    state = state.copyWith();
  }
}
