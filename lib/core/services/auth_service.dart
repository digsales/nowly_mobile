import 'package:firebase_auth/firebase_auth.dart';
import 'package:nowly/l10n/app_localizations.dart';

class AuthException implements Exception {
  AuthException(this.code);
  final String code;

  String message(AppLocalizations l10n) {
    return switch (code) {
      'user-not-found' => l10n.authErrorUserNotFound,
      'wrong-password' => l10n.authErrorWrongPassword,
      'invalid-email' => l10n.authErrorInvalidEmail,
      'user-disabled' => l10n.authErrorUserDisabled,
      'too-many-requests' => l10n.authErrorTooManyRequests,
      'invalid-credential' => l10n.authErrorInvalidCredential,
      'email-already-in-use' => l10n.authErrorEmailAlreadyInUse,
      'weak-password' => l10n.authErrorWeakPassword,
      'requires-recent-login' => l10n.authErrorRequiresRecentLogin,
      _ => l10n.authErrorUnknown,
    };
  }
}

class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signin({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  Future<UserCredential> signup({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  Future<void> signout() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw AuthException('user-not-found');
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }
}
