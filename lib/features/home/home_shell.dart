import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/utils/level_utils.dart';
import 'package:nowly/features/home/widgets/level_up_banner.dart';
import 'package:nowly/features/home/widgets/user_level_bar.dart';
import 'package:nowly/features/home/widgets/home_bottom_nav_bar.dart';
import 'package:nowly/features/profile/profile_provider.dart';


class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  OverlayEntry? _levelUpEntry;

  void _showLevelUp(int newLevel) {
    _levelUpEntry?.remove();
    _levelUpEntry = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => LevelUpBanner(
        title: context.l10n.levelUpTitle(newLevel),
        onDismiss: () {
          entry.remove();
          _levelUpEntry = null;
        },
      ),
    );

    _levelUpEntry = entry;
    Overlay.of(context).insert(entry);
  }

  @override
  void dispose() {
    _levelUpEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    ref.listen(currentUserProvider, (prev, next) {
      final prevLevel = calculateLevel(prev?.asData?.value?.totalPoints ?? 0);
      final nextLevel = calculateLevel(next.asData?.value?.totalPoints ?? 0);
      if (nextLevel > prevLevel) _showLevelUp(nextLevel);
    });

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
          Expanded(child: widget.navigationShell),
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
        activeIndex: widget.navigationShell.currentIndex,
        onTap: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
      ),
    );
  }
}
