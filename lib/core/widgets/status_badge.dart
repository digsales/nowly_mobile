import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/task.dart';
import 'package:nowly/core/theme/primary_colors.dart';

class StatusBadge extends ConsumerWidget {
  const StatusBadge({super.key, required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.usePrimaryColor(status.colorKey);

    final text = switch (status) {
      TaskStatus.pending => context.l10n.taskStatusPending,
      TaskStatus.completed => context.l10n.taskCompleted,
      TaskStatus.expired => context.l10n.taskExpired,
      TaskStatus.cancelled => context.l10n.taskCancelled,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
