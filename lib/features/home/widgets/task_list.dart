import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
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
      AsyncData(:final value) => Column(
          children: value.map((task) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TaskCard(task: task),
            );
          }).toList(),
        ),
      AsyncLoading() => const TaskListSkeleton(),
      AsyncError() => Text(
          context.l10n.errorMessage,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.error,
          ),
        ),
    };
  }
}
