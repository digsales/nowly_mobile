import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';

class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  final int activeIndex;
  final ValueChanged<int> onTap;

  static const _icons = [
    Ionicons.home_outline,
    Ionicons.trophy_outline,
    Ionicons.stats_chart_outline,
    Ionicons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: AnimatedBottomNavigationBar(
        icons: _icons,
        activeIndex: activeIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: onTap,
        activeColor: context.colorScheme.primary,
        inactiveColor: context.colorScheme.onSurfaceVariant,
        backgroundColor: context.colorScheme.surface,
        splashRadius: 0,
        scaleFactor: 0.5,
        iconSize: 26,
      ),
    );
  }
}
