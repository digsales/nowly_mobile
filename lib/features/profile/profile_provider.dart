import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/models/user.dart';
import 'package:nowly/core/repositories/user_repository.dart';
import 'package:nowly/core/services/auth_service.dart';
import 'package:nowly/core/services/auth_service_provider.dart';
import 'package:nowly/core/validators/field_controller.dart';
import 'package:nowly/core/validators/validators.dart';
import 'package:nowly/l10n/app_localizations.dart';

final currentUserProvider = StreamProvider<User?>((ref) {
  final uid = ref.watch(authStateProvider).asData?.value?.uid;
  if (uid == null) return Stream.value(null);

  final repo = ref.watch(userRepositoryProvider);

  return repo.watchUser(uid);
});

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

  Future<bool> deleteAccount(AppLocalizations l10n) async {
    password.validator = Validators.combine([
      Validators.required(l10n.validatorRequired),
      Validators.minLength(8, l10n.validatorMinLength(8)),
    ]);

    if (!password.validate()) {
      state = state.copyWith();
      return false;
    }

    state = state.copyWith(isLoading: true);

    final uid = _authService.currentUser?.uid;
    final email = _authService.currentUser?.email;

    if (uid == null || email == null) {
      state = state.copyWith(isLoading: false);
      return false;
    }

    try {
      // 1. Verify password first (fails fast if wrong)
      await _authService.reauthenticate(
        email: email,
        password: password.text,
      );
      // 2. Delete Firestore data (user is authenticated)
      await _userRepository.deleteAllUserData(uid);
      // 3. Delete Auth account (already re-authenticated)
      await _authService.deleteCurrentUser();
    } on AuthException catch (e) {
      debugPrint('AuthException code: ${e.code}');
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message(l10n),
      );
      return false;
    } on Exception catch (e) {
      debugPrint('Delete account error: $e');
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        errorMessage: l10n.authErrorUnknown,
      );
      return false;
    }

    if (!ref.mounted) return true;
    state = state.copyWith(isLoading: false);
    return true;
  }

  void onPasswordChanged(String value) {
    password.onChanged(value);
    state = state.copyWith();
  }

  Future<bool> updateAvatar(String? avatarUrl) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return false;

    try {
      await _userRepository.updateUser(uid, {'avatarUrl': avatarUrl});
      return true;
    } on Exception {
      return false;
    }
  }

  Future<bool> updateName(String name) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null || name.trim().isEmpty) return false;

    try {
      await _userRepository.updateUser(uid, {'name': name.trim()});
      return true;
    } on Exception {
      return false;
    }
  }

  Future<void> changeEmail({
    required String currentPassword,
    required String newEmail,
  }) async {
    final email = _authService.currentUser?.email;
    if (email == null) throw AuthException('user-not-found');

    final exists = await _userRepository.emailExists(newEmail);
    if (exists) throw AuthException('email-already-in-use');

    await _authService.reauthenticate(email: email, password: currentPassword);
    await _authService.updateEmail(newEmail);
    await _authService.signout();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final email = _authService.currentUser?.email;
    if (email == null) throw AuthException('user-not-found');

    await _authService.reauthenticate(email: email, password: currentPassword);
    await _authService.updatePassword(newPassword);
  }

  Future<void> signout() async {
    await _authService.signout();
  }
}
