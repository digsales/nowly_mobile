import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/user.dart';
import 'package:nowly/core/models/user_badge.dart';
import 'package:nowly/core/theme/primary_colors.dart';
import 'package:nowly/features/profile/profile_provider.dart';
import 'package:shimmer/shimmer.dart';

/// The user's streak and badge collection, side by side.
///
/// Sits above the statistics section, which is filtered by period — these
/// two are all-time values and deliberately stand apart from it.
class PerformanceHighlights extends ConsumerWidget {
  const PerformanceHighlights({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return switch (userAsync) {
      AsyncData(:final value) when value != null => _Highlights(user: value),
      AsyncError() => const SizedBox.shrink(),
      _ => const _HighlightsSkeleton(),
    };
  }
}

class _Highlights extends ConsumerWidget {
  const _Highlights({required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = user.liveStreak;
    // Counted from the badge list, not from user.unlockedBadges: that field
    // holds raw keys and may still carry badges the app no longer defines.
    final unlocked = UserBadges.values.where((b) => b.isUnlocked(user)).length;
    final totalBadges = UserBadges.values.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _StatTile(
            icon: streak > 0 ? Ionicons.flame : Ionicons.flame_outline,
            color: streak > 0
                ? ref.usePrimaryColor('orange')
                : context.colorScheme.onSurfaceVariant,
            value: '$streak',
            label: context.l10n.streakDaysLabel(streak),
          ),
        ),
        Expanded(
          child: _StatTile(
            icon: unlocked > 0 ? Ionicons.medal : Ionicons.medal_outline,
            color: unlocked > 0
                ? context.colorScheme.primary
                : context.colorScheme.onSurfaceVariant,
            value: context.l10n.badgeProgressLabel(unlocked, totalBadges),
            label: context.l10n.statsBadgesLabel,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 40),
        const SizedBox(height: 12),
        Text(
          value,
          style: context.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _HighlightsSkeleton extends StatelessWidget {
  const _HighlightsSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget shimmer({required Widget child}) => Shimmer.fromColors(
          baseColor: context.colorScheme.onSurface.withValues(alpha: 0.08),
          highlightColor: context.colorScheme.onSurface.withValues(alpha: 0.16),
          child: child,
        );

    Widget bar(double width, double height) => shimmer(
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        );

    final tile = Column(
      children: [
        shimmer(
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 12),
        bar(48, 28),
        const SizedBox(height: 8),
        bar(80, 12),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: tile),
        Expanded(child: tile),
      ],
    );
  }
}
