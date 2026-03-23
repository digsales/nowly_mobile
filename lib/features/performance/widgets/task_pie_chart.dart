import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/theme/primary_colors.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';
import 'package:nowly/features/performance/performance_provider.dart';
import 'package:nowly/features/performance/widgets/task_pie_chart_skeleton.dart';

class TaskPieChart extends ConsumerWidget {
  const TaskPieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(filteredTaskStatsProvider);
    final filter = ref.watch(progressFilterProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 600;

        return Column(
          children: [
            _FilterChips(filter: filter, ref: ref),
            const SizedBox(height: 32),
            switch (statsAsync) {
              AsyncLoading(:final value?) => _buildChart(wide, value, ref),
              AsyncLoading() => TaskPieChartSkeleton(wide: wide, ref: ref),
              AsyncError() => Padding(
                  padding: const EdgeInsets.only(top: 64),
                  child: Text(
                    context.l10n.progressEmpty,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              AsyncData(:final value) when value.isEmpty => Padding(
                  padding: const EdgeInsets.only(top: 64),
                  child: Text(
                    context.l10n.progressEmpty,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              AsyncData(:final value) => _buildChart(wide, value, ref),
            },
          ],
        );
      },
    );
  }

  Widget _buildChart(bool wide, TaskStats value, WidgetRef ref) {
    return wide
        ? Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: _Chart(stats: value, ref: ref),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(child: _Legend(stats: value, ref: ref)),
                ],
              ),
            ],
          )
        : Column(
            children: [
              SizedBox(
                height: 200,
                child: _Chart(stats: value, ref: ref),
              ),
              const SizedBox(height: 32),
              _Legend(stats: value, ref: ref),
            ],
          );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.filter, required this.ref});

  final ProgressFilter filter;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: ProgressFilter.values.map((f) {
        final isSelected = f == filter;
        return TouchableOpacity(
          onTap: () => ref.read(progressFilterProvider.notifier).set(f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colorScheme.primary
                  : context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _filterLabel(context, f),
              style: context.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? context.colorScheme.onPrimary
                    : context.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _filterLabel(BuildContext context, ProgressFilter f) {
    return switch (f) {
      ProgressFilter.lastMonth => context.l10n.progressFilterLastMonth,
      ProgressFilter.last6Months => context.l10n.progressFilterLast6Months,
      ProgressFilter.lastYear => context.l10n.progressFilterLastYear,
      ProgressFilter.allTime => context.l10n.progressFilterAllTime,
    };
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.stats, required this.ref});

  final TaskStats stats;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 40,
        sections: [
            PieChartSectionData(
              value: stats.expired.toDouble(),
              color: ref.usePrimaryColor('red'),
              title: '${stats.expired}',
              titleStyle: _sectionTextStyle(context),
              radius: 40,
            ),
            PieChartSectionData(
              value: stats.completed.toDouble(),
              color: ref.usePrimaryColor('green'),
              title: '${stats.completed}',
              titleStyle: _sectionTextStyle(context),
              radius: 50,
            ),
            PieChartSectionData(
              value: stats.cancelled.toDouble(),
              color: ref.usePrimaryColor('orange'),
              title: '${stats.cancelled}',
              titleStyle: _sectionTextStyle(context),
              radius: 45,
            ),
        ],
      ),
    );
  }

  TextStyle _sectionTextStyle(BuildContext context) {
    return context.textTheme.headlineMedium!.copyWith(
      color: context.colorScheme.onPrimary,
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.stats, required this.ref});

  final TaskStats stats;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LegendItem(
          color: ref.usePrimaryColor('green'),
          label: context.l10n.progressCompleted,
          count: stats.completed,
        ),
        const SizedBox(height: 12),
        _LegendItem(
          color: ref.usePrimaryColor('orange'),
          label: context.l10n.progressCancelled,
          count: stats.cancelled,
        ),
        const SizedBox(height: 12),
        _LegendItem(
          color: ref.usePrimaryColor('red'),
          label: context.l10n.progressExpired,
          count: stats.expired,
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.progressTotal(stats.total),
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
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
        Text(
          '$count',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
