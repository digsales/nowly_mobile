import 'package:flutter/material.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/utils/level_utils.dart';

class UserLevelBar extends StatelessWidget {
  const UserLevelBar({
    super.key,
    required this.totalPoints,
    this.textColor,
    this.subtitleColor,
    this.trackColor,
    this.indicatorColor,
  });

  final int totalPoints;

  /// Color for "Nível X" text. Defaults to onSurface.
  final Color? textColor;

  /// Color for "X pts para o Nível Y" text. Defaults to onSurfaceVariant.
  final Color? subtitleColor;

  /// Progress bar track (background) color. Defaults to surfaceContainerHighest.
  final Color? trackColor;

  /// Progress bar filled color. Defaults to primary.
  final Color? indicatorColor;

  @override
  Widget build(BuildContext context) {
    final level = calculateLevel(totalPoints);
    final progress = levelProgress(totalPoints);
    final remaining = pointsToNextLevel(totalPoints);

    final resolvedTextColor = textColor ?? context.colorScheme.onSurface;
    final resolvedSubtitleColor = subtitleColor ?? context.colorScheme.onSurfaceVariant;
    final resolvedTrackColor = trackColor ?? context.colorScheme.surfaceContainerHighest;
    final resolvedIndicatorColor = indicatorColor ?? context.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                context.l10n.profileLevel(level),
                key: ValueKey(level),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: resolvedTextColor,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                context.l10n.profileLevelProgress(remaining, level + 1),
                key: ValueKey(remaining),
                style: context.textTheme.labelMedium?.copyWith(
                  color: resolvedSubtitleColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: resolvedTrackColor,
              valueColor: AlwaysStoppedAnimation(resolvedIndicatorColor),
            ),
          ),
        ),
      ],
    );
  }
}
