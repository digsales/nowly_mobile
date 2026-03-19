import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/theme/primary_colors.dart';
import 'package:shimmer/shimmer.dart';

class TaskPieChartSkeleton extends StatelessWidget {
  const TaskPieChartSkeleton({super.key, required this.wide, required this.ref});

  final bool wide;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final shimmerBar = Shimmer.fromColors(
      baseColor: context.colorScheme.onSurface.withValues(alpha: 0.08),
      highlightColor: context.colorScheme.onSurface.withValues(alpha: 0.16),
      child: Container(
        width: 24,
        height: 14,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7),
        ),
      ),
    );

    final legend = Column(
      children: [
        _LegendItem(
          color: ref.usePrimaryColor('green'),
          label: context.l10n.progressCompleted,
          trailing: shimmerBar,
        ),
        const SizedBox(height: 12),
        _LegendItem(
          color: ref.usePrimaryColor('orange'),
          label: context.l10n.progressCancelled,
          trailing: shimmerBar,
        ),
        const SizedBox(height: 12),
        _LegendItem(
          color: ref.usePrimaryColor('red'),
          label: context.l10n.progressExpired,
          trailing: shimmerBar,
        ),
        const SizedBox(height: 20),
        Shimmer.fromColors(
          baseColor: context.colorScheme.onSurface.withValues(alpha: 0.08),
          highlightColor: context.colorScheme.onSurface.withValues(alpha: 0.16),
          child: Container(
            width: 80,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );

    final chartPlaceholder = Shimmer.fromColors(
      baseColor: context.colorScheme.onSurface.withValues(alpha: 0.08),
      highlightColor: context.colorScheme.onSurface.withValues(alpha: 0.16),
      child: Center(
        child: Container(
          width: 180,
          height: 180,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: chartPlaceholder),
          const SizedBox(width: 32),
          Expanded(child: legend),
        ],
      );
    }

    return Column(
      children: [
        chartPlaceholder,
        const SizedBox(height: 32),
        legend,
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.trailing,
  });

  final Color color;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodyMedium,
          ),
        ),
        trailing,
      ],
    );
  }
}
