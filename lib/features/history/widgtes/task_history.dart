import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/task.dart';
import 'package:nowly/core/widgets/app_loading.dart';
import 'package:nowly/core/widgets/task_card.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';
import 'package:nowly/features/history/history_provider.dart';
import 'package:nowly/features/home/widgets/task_list_skeleton.dart';

class TaskHistory extends ConsumerWidget {
  const TaskHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    final filter = ref.watch(historyFilterProvider);

    return Column(
      children: [
        _FilterChips(filter: filter, ref: ref),
        const SizedBox(height: 24),
        switch (historyAsync) {
          AsyncData(:final value) when value.tasks.isEmpty => Text(
              context.l10n.historyTasksEmpty,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          AsyncData(:final value) => LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 600;
                return Column(
                  children: [
                    if (wide)
                      _buildGrid(value.tasks)
                    else
                      _buildList(value.tasks),
                    if (value.isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: AppLoading(),
                      ),
                  ],
                );
              },
            ),
          AsyncError() => Text(
              context.l10n.errorMessage,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.error,
              ),
            ),
          _ => const TaskListSkeleton(),
        },
      ],
    );
  }

  Widget _buildList(List<Task> tasks) {
    return Column(
      children: [
        for (int i = 0; i < tasks.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          TaskCard(task: tasks[i]),
        ],
      ],
    );
  }

  Widget _buildGrid(List<Task> tasks) {
    final left = <Task>[];
    final right = <Task>[];
    for (int i = 0; i < tasks.length; i++) {
      (i.isEven ? left : right).add(tasks[i]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildList(left)),
        const SizedBox(width: 12),
        Expanded(child: _buildList(right)),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.filter, required this.ref});

  final HistoryFilter filter;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: HistoryFilter.values.map((f) {
        final isSelected = f == filter;
        return TouchableOpacity(
          onTap: () => ref.read(historyFilterProvider.notifier).set(f),
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

  String _filterLabel(BuildContext context, HistoryFilter f) {
    return switch (f) {
      HistoryFilter.all => context.l10n.historyTasksFilterAll,
      HistoryFilter.completed => context.l10n.progressCompleted,
      HistoryFilter.cancelled => context.l10n.progressCancelled,
      HistoryFilter.expired => context.l10n.progressExpired,
    };
  }
}
