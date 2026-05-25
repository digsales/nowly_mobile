import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/task.dart';
import 'package:nowly/core/widgets/task_card.dart';
import 'package:nowly/features/home/home_provider.dart';
import 'package:nowly/features/home/widgets/task_list_skeleton.dart';

class TaskList extends ConsumerWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(pendingTasksProvider);

    return switch (tasksAsync) {
      AsyncData(:final value) when value.isEmpty => Text(
          context.l10n.emptyTaskHint,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      AsyncData(:final value) => LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 600;
            if (wide) return _buildGrid(value);
            return _buildList(value);
          },
        ),
      AsyncError() => Text(
          context.l10n.errorMessage,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.error,
          ),
        ),
      _ => const TaskListSkeleton(),
    };
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
