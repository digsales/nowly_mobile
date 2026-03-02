import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowly/core/services/auth_service_provider.dart';
import 'package:nowly/features/home/home_screen.dart';

import '../../features/forgot_password/forgot_password_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/signin/signin_screen.dart';
import '../../features/signup/signup_screen.dart';

abstract class AppRoutes {
  // auth routes
  static const String onboarding = '/';
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  
  // authenticated routes
  static const String home = '/home';
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
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    redirect: (context, state) {
      if (authState.isLoading) return null;

      final user = authState.asData?.value;

      final isLoggedIn = user != null;

      final isAuthRoute =
          state.fullPath == AppRoutes.signin ||
          state.fullPath == AppRoutes.signup ||
          state.fullPath == AppRoutes.forgotPassword ||
          state.fullPath == AppRoutes.onboarding;

      // Not logged - Only auth rotes
      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.onboarding;
      }

      // Logged - Go to authenticated routes
      if (isLoggedIn && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // auth routes
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
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) =>
            _buildPage(state, const ForgotPasswordPage()),
      ),

      // authenticated routes
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) =>
            _buildPage(state, const HomeScreen()),
      ),
    ],
  );
});
