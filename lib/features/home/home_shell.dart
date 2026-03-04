import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/widgets/user_level_bar.dart';
import 'package:nowly/features/home/widgets/home_bottom_nav_bar.dart';
import 'package:nowly/features/profile/profile_provider.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(32, context.paddingTop + 12, 32, 20),
            child: UserLevelBar(
              totalPoints: userAsync.asData?.value?.totalPoints ?? 0,
              isLoading: userAsync is! AsyncData,
              textColor: context.colorScheme.onPrimary,
              subtitleColor: context.colorScheme.onPrimary.withValues(alpha: 0.7),
              trackColor: context.colorScheme.onPrimary.withValues(alpha: 0.3),
              indicatorColor: context.colorScheme.onPrimary,
            ),
          ),
          Expanded(child: navigationShell),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: abrir tela de adicionar task
        },
        tooltip: context.l10n.fabAddTask,
        foregroundColor: context.colorScheme.onPrimary,
        backgroundColor: context.colorScheme.primary,
        shape: const CircleBorder(),
        child: const Icon(Ionicons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: HomeBottomNavBar(
        activeIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
