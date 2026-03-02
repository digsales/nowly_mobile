import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/features/home/widgets/home_bottom_nav_bar.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      backgroundColor: context.colorScheme.surface,
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
