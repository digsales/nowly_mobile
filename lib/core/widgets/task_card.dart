import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/category.dart';
import 'package:nowly/core/models/task.dart';
import 'package:nowly/core/theme/theme_provider.dart';
import 'package:nowly/features/home/home_provider.dart';

class TaskCard extends ConsumerWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = task.status == TaskStatus.pending;
    final isExpired = isPending && task.endDate.isBefore(DateTime.now());

    final category = _findCategory(ref);
    final categoryColor = category?.resolveColor(
      brightness: Theme.of(context).brightness,
      highContrast: ref.watch(highContrastProvider),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Center(
                child: FractionallySizedBox(
                  heightFactor: 1,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: categoryColor ?? context.colorScheme.surface,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (category != null) ...[
                          Icon(
                            category.icon,
                            size: 12,
                            color: categoryColor ?? context.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              category.name,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '·',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ] else ...[
                          Flexible(
                            child: Text(
                              context.l10n.taskFormCategoryNone,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '·',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        _StatusLabel(task: task, isExpired: isExpired),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _statusIcon(task.status, isExpired),
                size: 20,
                color: _statusColor(context, task.status, isExpired),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Category? _findCategory(WidgetRef ref) {
    final categoryId = task.categoryId;
    if (categoryId == null) return null;

    final categories = ref.watch(categoriesProvider).asData?.value;
    if (categories == null) return null;

    try {
      return categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  IconData _statusIcon(TaskStatus status, bool isExpired) {
    if (isExpired) return Ionicons.alert_circle_outline;
    return switch (status) {
      TaskStatus.pending => Ionicons.time_outline,
      TaskStatus.completed => Ionicons.checkmark_circle_outline,
      TaskStatus.expired => Ionicons.alert_circle_outline,
      TaskStatus.cancelled => Ionicons.close_circle_outline,
    };
  }

  Color _statusColor(BuildContext context, TaskStatus status, bool isExpired) {
    if (isExpired) return context.colorScheme.error;
    return switch (status) {
      TaskStatus.pending => context.colorScheme.onSurfaceVariant,
      TaskStatus.completed => context.colorScheme.primary,
      TaskStatus.expired => context.colorScheme.error,
      TaskStatus.cancelled => context.colorScheme.onSurfaceVariant,
    };
  }
}

class _StatusLabel extends StatefulWidget {
  const _StatusLabel({required this.task, required this.isExpired});

  final Task task;
  final bool isExpired;

  @override
  State<_StatusLabel> createState() => _StatusLabelState();
}

class _StatusLabelState extends State<_StatusLabel> {
  Timer? _timer;

  bool get _needsLiveCountdown {
    if (widget.task.status != TaskStatus.pending || widget.isExpired) {
      return false;
    }
    final remaining = widget.task.endDate.difference(DateTime.now());
    return remaining.inHours < 5 && !remaining.isNegative;
  }

  @override
  void initState() {
    super.initState();
    _startTimerIfNeeded();
  }

  @override
  void didUpdateWidget(_StatusLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id ||
        oldWidget.task.endDate != widget.task.endDate ||
        oldWidget.task.status != widget.task.status) {
      _timer?.cancel();
      _startTimerIfNeeded();
    }
  }

  void _startTimerIfNeeded() {
    if (_needsLiveCountdown) {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) {
          if (!_needsLiveCountdown) {
            _timer?.cancel();
            _timer = null;
          }
          if (mounted) setState(() {});
        },
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _resolveText(context);
    final isUrgent = _needsLiveCountdown;
    final color = widget.isExpired || isUrgent
        ? context.colorScheme.error
        : context.colorScheme.onSurfaceVariant;

    return Text(
      text,
      style: context.textTheme.labelSmall?.copyWith(color: color),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _resolveText(BuildContext context) {
    if (widget.task.status == TaskStatus.completed) {
      return context.l10n.taskCompleted;
    }
    if (widget.task.status == TaskStatus.cancelled) {
      return context.l10n.taskCancelled;
    }
    if (widget.task.status == TaskStatus.expired || widget.isExpired) {
      return context.l10n.taskExpired;
    }

    final remaining = widget.task.endDate.difference(DateTime.now());

    if (remaining.inHours < 5 && !remaining.isNegative) {
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes.remainder(60);
      final seconds = remaining.inSeconds.remainder(60);
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    if (remaining.inDays > 0) {
      return context.l10n.taskTimeRemainingDays(remaining.inDays);
    }
    if (remaining.inHours > 0) {
      return context.l10n.taskTimeRemainingHours(remaining.inHours);
    }
    return context.l10n.taskTimeRemainingMinutes(
      remaining.inMinutes.clamp(1, 59),
    );
  }
}
