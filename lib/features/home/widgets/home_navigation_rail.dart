import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';

class HomeNavigationRail extends StatelessWidget {
  const HomeNavigationRail({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: activeIndex,
      onDestinationSelected: onTap,
      scrollable: true,
      labelType: NavigationRailLabelType.all,
      backgroundColor: context.colorScheme.primary,
      selectedIconTheme: IconThemeData(color: context.colorScheme.primary),
      selectedLabelTextStyle: context.textTheme.labelSmall?.copyWith(
        color: context.colorScheme.onPrimary,
        fontWeight: FontWeight.w600,
      ),
      unselectedIconTheme: IconThemeData(color: context.colorScheme.onPrimary),
      unselectedLabelTextStyle: context.textTheme.labelSmall?.copyWith(
        color: context.colorScheme.onPrimary,
      ),
      indicatorColor: context.colorScheme.onPrimary,
      leading: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: SvgPicture.asset(
          'assets/images/svg/hourglass.svg',
          width: 40,
          height: 40,
          colorFilter: ColorFilter.mode(
            context.colorScheme.onPrimary,
            BlendMode.srcIn,
          ),
        ),
      ),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Ionicons.home_outline),
          selectedIcon: const Icon(Ionicons.home),
          label: Text(context.l10n.home),
        ),
        NavigationRailDestination(
          icon: const Icon(Ionicons.book_outline),
          selectedIcon: const Icon(Ionicons.trophy),
          label: Text(context.l10n.history),
        ),
        NavigationRailDestination(
          icon: const Icon(Ionicons.stats_chart_outline),
          selectedIcon: const Icon(Ionicons.stats_chart),
          label: Text(context.l10n.performance),
        ),
        NavigationRailDestination(
          icon: const Icon(Ionicons.person_outline),
          selectedIcon: const Icon(Ionicons.person),
          label: Text(context.l10n.profile),
        ),
      ],
    );
  }
}
