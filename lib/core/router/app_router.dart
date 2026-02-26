import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/onboarding_screen.dart';
import '../../features/signin/signin_screen.dart';
import '../../features/signup/signup_screen.dart';

abstract class AppRoutes {
  static const String onboarding = '/';
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
}

enum PageTransitionType {
  bottomToTop,
  cupertino,
}

CustomTransitionPage _buildPage(GoRouterState state, Widget child) {
  final transition = state.extra as PageTransitionType?;
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return switch (transition) {
        PageTransitionType.bottomToTop => SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(0, 1), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOut)),
            ),
            child: child,
          ),
        PageTransitionType.cupertino => CupertinoPageTransition(
            primaryRouteAnimation: animation,
            secondaryRouteAnimation: secondaryAnimation,
            linearTransition: true,
            child: child,
          ),
        null => FadeTransition(opacity: animation, child: child),
      };
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) =>
            _buildPage(state, const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.signin,
        pageBuilder: (context, state) =>
            _buildPage(state, const SigninPage()),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) =>
            _buildPage(state, const SignupPage()),
      ),
      // GoRoute(
      //   path: AppRoutes.forgotPassword,
      //   pageBuilder: (context, state) =>
      //       _buildPage(state, const ForgotPasswordPage()),
      // ),
    ],
  );
});
