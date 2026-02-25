import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/onboarding_screen.dart';
import '../../features/signin/signin_screen.dart';

abstract class AppRoutes {
  static const String onboarding = '/';
  static const String signin = '/signin';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.signin,
        builder: (context, state) => const SigninPage(),
      ),
      // GoRoute(
      //   path: AppRoutes.register,
      //   builder: (context, state) => const SignupPage(),
      // ),
      // GoRoute(
      //   path: AppRoutes.forgotPassword,
      //   builder: (context, state) => const ForgotPasswordPage(),
      // ),
    ],
  );
});
