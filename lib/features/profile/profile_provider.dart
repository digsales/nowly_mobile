import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/repositories/user_repository.dart';
import 'package:nowly/core/services/auth_service.dart';
import 'package:nowly/core/services/auth_service_provider.dart';
import 'package:nowly/core/validators/field_controller.dart';
import 'package:nowly/core/validators/validators.dart';
import 'package:nowly/l10n/app_localizations.dart';

final profileProvider =
    NotifierProvider.autoDispose<ProfileNotifier, ProfileState>(
        ProfileNotifier.new);

class ProfileState {
  const ProfileState({
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isLoading;
  final String? errorMessage;

  ProfileState copyWith({bool? isLoading, String? errorMessage}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  late final AuthService _authService;
  late final UserRepository _userRepository;
  final password = FieldController();

  @override
  ProfileState build() {
    _authService = ref.read(authServiceProvider);
    _userRepository = ref.read(userRepositoryProvider);
    ref.onDispose(() {
      password.dispose();
    });
    return const ProfileState();
  }

  Future<void> deleteAccount(AppLocalizations l10n) async {
    password.validator = Validators.combine([
      Validators.required(l10n.validatorRequired),
    ]);

    if (!password.validate()) {
      state = state.copyWith();
      return;
    }

    state = state.copyWith(isLoading: true);

    final uid = _authService.currentUser?.uid;
    final email = _authService.currentUser?.email;

    if (uid == null || email == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      await _userRepository.deleteAllUserData(uid);
      await _authService.deleteAccount(
        email: email,
        password: password.text,
      );
    } on AuthException catch (e) {
      debugPrint('AuthException code: ${e.code}');
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message(l10n),
      );
      return;
    } on Exception catch (e) {
      debugPrint('Delete account error: $e');
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: l10n.authErrorUnknown,
      );
      return;
    }

    if (!ref.mounted) return;
    state = state.copyWith(isLoading: false);
  }

  void onPasswordChanged(String value) {
    password.onChanged(value);
    state = state.copyWith();
  }

  Future<void> signout() async {
    await _authService.signout();
  }
}
