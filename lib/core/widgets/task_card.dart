import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/category.dart';
import 'package:nowly/core/models/task.dart';
import 'package:nowly/core/theme/primary_colors.dart';
import 'package:nowly/core/widgets/status_badge.dart';
import 'package:nowly/core/widgets/task_details_sheet.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';
import 'package:nowly/features/home/home_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nowly/core/router/app_router.dart';

class TaskCard extends ConsumerWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.showDetails = true,
  });

  final Task task;
  final bool showDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = task.status == TaskStatus.pending;
    final isExpired = isPending && task.endDate.isBefore(DateTime.now());

    final category = _findCategory(ref);

    final canEdit = showDetails && task.status == TaskStatus.pending && !isExpired;

    return TouchableOpacity(
      onTap: showDetails
          ? () => TaskDetailsSheet.show(context, task: task)
          : null,
      onLongPress: canEdit
          ? () => context.push(AppRoutes.taskForm, extra: task)
          : null,
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
                      color: category!= null ? ref.usePrimaryColor(category.colorKey) : context.colorScheme.onSurface,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: context.textTheme.headlineMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: task.status)
                      ],
                    ),
                    if (task.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: context.textTheme.bodyMedium,
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
                            size: context.textTheme.labelSmall!.fontSize! * 1.2,
                            fontWeight: FontWeight.bold,
                            color: ref.usePrimaryColor(category.colorKey),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              category.name,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: ref.usePrimaryColor(category.colorKey),
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
