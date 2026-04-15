import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nowly/l10n/app_localizations.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
      'account-exists-with-different-credential' =>
        l10n.authErrorAccountExistsWithDifferentCredential,
      _ => l10n.authErrorUnknown,
    };
  }
}

class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;
  bool _googleInitialized = false;

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

  Future<void> _ensureGoogleInitialized() async {
    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize(
        clientId: kIsWeb ? '1090384398970-j960pi4j8ufmct4qqqdhs8dpg99r2atm.apps.googleusercontent.com' : null,
        serverClientId: !kIsWeb ? '1090384398970-j960pi4j8ufmct4qqqdhs8dpg99r2atm.apps.googleusercontent.com' : null,
      );
      _googleInitialized = true;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');
        return await _auth.signInWithPopup(provider);
      }

      await _ensureGoogleInitialized();
      final googleUser = await GoogleSignIn.instance.authenticate();

      final idToken = googleUser.authentication.idToken;
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AuthException('sign-in-cancelled');
      }
      throw AuthException(e.code.name);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        throw AuthException('sign-in-cancelled');
      }
      throw AuthException(e.code);
    }
  }

  Future<UserCredential> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Apple only sends name on first sign-in
      if (appleCredential.givenName != null) {
        final displayName = [
          appleCredential.givenName,
          appleCredential.familyName,
        ].where((n) => n != null).join(' ');
        await userCredential.user?.updateDisplayName(displayName);
      }

      return userCredential;
    } on SignInWithAppleAuthorizationException {
      throw AuthException('sign-in-cancelled');
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  Future<UserCredential> signInWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) {
        throw AuthException('sign-in-cancelled');
      }

      final credential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);
      return await _auth.signInWithCredential(credential);
    } on AuthException {
      rethrow;
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
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
    }
    // // TODO: Add Facebook sign in configuration in firebase.
    // await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }

  Future<void> reauthenticate({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AuthException('user-not-found');

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AuthException('user-not-found');
      await user.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AuthException('user-not-found');
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  Future<void> deleteCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AuthException('user-not-found');
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
