import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowly/core/services/auth_service_provider.dart';
import 'package:nowly/features/progress/progress_screen.dart';
import 'package:nowly/features/ranking/ranking_screen.dart';
import 'package:nowly/core/models/category.dart' as models;
import 'package:nowly/features/category/category_form_screen.dart';
import 'package:nowly/core/models/task.dart';
import 'package:nowly/features/task/task_form_screen.dart';
import 'package:nowly/features/home/home_screen.dart';
import 'package:nowly/features/home/home_shell.dart';
import 'package:nowly/features/profile/profile_screen.dart';

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
  static const String categoryForm = '/home/category-form';
  static const String taskForm = '/home/task-form';
  static const String ranking = '/ranking';
  static const String progress = '/progress';
  static const String profile = '/profile';
}

class _BottomToTopPage<T> extends CustomTransitionPage<T> {
  _BottomToTopPage({required super.child, super.key})
      : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(0, 1), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOut)),
            ),
            child: child,
          ),
        );
}

class _TabSwitcher extends StatefulWidget {
  const _TabSwitcher({
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  State<_TabSwitcher> createState() => _TabSwitcherState();
}

class _TabSwitcherState extends State<_TabSwitcher> {
  int _previousIndex = 0;

  @override
  void didUpdateWidget(_TabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final goingRight = widget.currentIndex > _previousIndex;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        final isIncoming = child.key == ValueKey(widget.currentIndex);
        final begin = isIncoming
            ? Offset(goingRight ? 1.0 : -1.0, 0)
            : Offset(goingRight ? -1.0 : 1.0, 0);
        final slide = Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

        return SlideTransition(position: slide, child: child);
      },
      child: KeyedSubtree(
        key: ValueKey(widget.currentIndex),
        child: widget.children[widget.currentIndex],
      ),
    );
  }
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

      // Not logged - Only auth routes
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
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.signin,
        pageBuilder: (context, state) =>
            _BottomToTopPage(key: state.pageKey, child: const SigninPage()),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) =>
            _BottomToTopPage(key: state.pageKey, child: const SignupPage()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) =>
            const CupertinoPage(child: ForgotPasswordPage()),
      ),

      // authenticated shell
      StatefulShellRoute(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        navigatorContainerBuilder: (context, navigationShell, children) =>
            _TabSwitcher(
              currentIndex: navigationShell.currentIndex,
              children: children,
            ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HomeScreen()),
                routes: [
                  GoRoute(
                    path: 'category-form',
                    pageBuilder: (context, state) {
                      final category = state.extra as models.Category?;
                      return _BottomToTopPage(
                        child: CategoryFormScreen(category: category),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'task-form',
                    pageBuilder: (context, state) {
                      final task = state.extra as Task?;
                      return _BottomToTopPage(
                        child: TaskFormScreen(task: task),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.ranking,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: RankingScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.progress,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProgressScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
