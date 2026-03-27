import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/models/user.dart';
import 'package:nowly/core/models/user_badge.dart';
import 'package:nowly/core/repositories/category_repository.dart';
import 'package:nowly/core/repositories/user_repository.dart';
import 'package:nowly/core/services/auth_service.dart';
import 'package:nowly/core/services/auth_service_provider.dart';
import 'package:nowly/l10n/app_localizations.dart';

enum SocialProvider { google, apple, facebook }

final socialLoginProvider =
    NotifierProvider.autoDispose<SocialLoginNotifier, SocialLoginState>(
  SocialLoginNotifier.new,
);

class SocialLoginState {
  const SocialLoginState({
    this.loadingProvider,
    this.errorMessage,
  });

  final SocialProvider? loadingProvider;
  final String? errorMessage;

  bool get isLoading => loadingProvider != null;

  SocialLoginState copyWith({
    SocialProvider? Function()? loadingProvider,
    String? errorMessage,
  }) {
    return SocialLoginState(
      loadingProvider:
          loadingProvider != null ? loadingProvider() : this.loadingProvider,
      errorMessage: errorMessage,
    );
  }
}

class SocialLoginNotifier extends Notifier<SocialLoginState> {
  late final AuthService _authService;
  late final UserRepository _userRepository;
  late final CategoryRepository _categoryRepository;

  @override
  SocialLoginState build() {
    _authService = ref.read(authServiceProvider);
    _userRepository = ref.read(userRepositoryProvider);
    _categoryRepository = ref.read(categoryRepositoryProvider);
    return const SocialLoginState();
  }

  Future<void> signIn(SocialProvider provider, AppLocalizations l10n) async {
    state = state.copyWith(loadingProvider: () => provider);

    try {
      final credential = switch (provider) {
        SocialProvider.google => await _authService.signInWithGoogle(),
        SocialProvider.apple => await _authService.signInWithApple(),
        SocialProvider.facebook => await _authService.signInWithFacebook(),
      };

      if (!ref.mounted) return;

      final firebaseUser = credential.user;
      if (firebaseUser == null) return;

      // Check if user document already exists in Firestore
      final existingUser = await _userRepository.getUser(firebaseUser.uid);
      if (existingUser == null) {
        // First time: create user document and seed default categories
        final user = User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ??
              firebaseUser.email?.split('@').first ??
              '',
          email: firebaseUser.email ?? '',
          avatarUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          totalPoints: 0,
          totalCompleted: 0,
          totalExpired: 0,
          totalCancelled: 0,
          currentStreak: 0,
          highestLevel: 0,
          unlockedBadges: UserBadges.defaultKeys,
        );
        await _userRepository.createUser(user);
        await _categoryRepository.seedDefaultCategories(
          firebaseUser.uid,
          l10n,
        );
      }
    } on AuthException catch (e) {
      if (e.code != 'sign-in-cancelled' && ref.mounted) {
        debugPrint('Social login AuthException: ${e.code}');
        state = state.copyWith(errorMessage: e.message(l10n));
      }
    } on Exception catch (e) {
      debugPrint('Social login error: $e');
      if (ref.mounted) {
        state = state.copyWith(errorMessage: l10n.authErrorUnknown);
      }
    } finally {
      if (ref.mounted) {
        state = state.copyWith(loadingProvider: () => null);
      }
    }
  }
}
