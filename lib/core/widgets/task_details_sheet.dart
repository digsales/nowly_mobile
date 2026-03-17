import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/category.dart';
import 'package:nowly/core/models/task.dart';
import 'package:nowly/core/repositories/task_repository.dart';
import 'package:nowly/core/theme/primary_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:nowly/core/router/app_router.dart';
import 'package:nowly/core/widgets/app_bottom_sheet.dart';
import 'package:nowly/core/widgets/app_button.dart';
import 'package:nowly/core/widgets/app_dialog.dart';
import 'package:nowly/core/widgets/app_snack_bar.dart';
import 'package:nowly/core/widgets/status_badge.dart';
import 'package:nowly/core/widgets/touchable_opacity.dart';
import 'package:nowly/features/home/home_provider.dart';

class TaskDetailsSheet extends ConsumerStatefulWidget {
  const TaskDetailsSheet({super.key, required this.task});

  final Task task;

  static void show(BuildContext context, {required Task task}) {
    AppBottomSheet.show(
      context: context,
      builder: (_) => TaskDetailsSheet(task: task),
    );
  }

  @override
  ConsumerState<TaskDetailsSheet> createState() => _TaskDetailsSheetState();
}

class _TaskDetailsSheetState extends ConsumerState<TaskDetailsSheet> {
  Timer? _deleteTimer;
  int _deleteMinutesLeft = 0;

  @override
  void initState() {
    super.initState();
    _updateDeleteTimer();
    if (widget.task.canDelete) {
      _deleteTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _updateDeleteTimer(),
      );
    }
  }

  void _updateDeleteTimer() {
    if (!widget.task.canDelete) {
      _deleteTimer?.cancel();
      _deleteTimer = null;
      if (mounted) setState(() => _deleteMinutesLeft = 0);
      return;
    }
    final elapsed = DateTime.now().difference(widget.task.createdAt);
    final remaining = 30 - elapsed.inMinutes;
    if (mounted) setState(() => _deleteMinutesLeft = remaining.clamp(0, 30));
  }

  @override
  void dispose() {
    _deleteTimer?.cancel();
    super.dispose();
  }

  Future<void> _completeTask() async {
    final subtasks = ref.read(subtasksProvider(widget.task.id)).asData?.value ?? [];
    final hasSubtasks = subtasks.isNotEmpty;
    final allDone = subtasks.every((s) => s.isDone);

    if (hasSubtasks && !allDone) {
      await showDialog(
        context: context,
        builder: (ctx) => AppDialog(
          icon: Ionicons.alert_circle_outline,
          color: ref.usePrimaryColor('yellow'),
          title: context.l10n.taskDetailsComplete,
          subtitle: context.l10n.taskDetailsSubtasksPending,
          cancelText: context.l10n.dialogBack,
          onCancel: () => Navigator.of(ctx).pop(),
        ),
      );
      return;
    }

    return _confirmAndRun(
      icon: Ionicons.checkmark_circle_outline,
      color: ref.usePrimaryColor('green'),
      title: context.l10n.taskDetailsComplete,
      subtitle: context.l10n.taskDetailsCompleteConfirm(widget.task.pointsEarned),
      buttonText: context.l10n.taskDetailsComplete,
      run: () => ref.read(taskRepositoryProvider).completeTask(widget.task),
      successMessage: context.l10n.taskDetailsSuccess,
    );
  }

  Future<void> _cancelTask() => _confirmAndRun(
        icon: Ionicons.close_circle_outline,
        color: ref.usePrimaryColor('orange'),
        title: context.l10n.taskDetailsCancel,
        subtitle: context.l10n.taskDetailsCancelConfirm,
        buttonText: context.l10n.taskDetailsCancel,
        run: () => ref.read(taskRepositoryProvider).cancelTask(widget.task),
        successMessage: context.l10n.taskDetailsSuccess,
      );

  Future<void> _uncancelTask() => _confirmAndRun(
        icon: Ionicons.refresh_outline,
        color: ref.usePrimaryColor('orange'),
        title: context.l10n.taskDetailsUncancel,
        subtitle: context.l10n.taskDetailsUncancelConfirm,
        buttonText: context.l10n.taskDetailsUncancel,
        run: () => ref.read(taskRepositoryProvider).uncancelTask(widget.task),
        successMessage: context.l10n.taskDetailsSuccess,
      );

  Future<void> _deleteTask() => _confirmAndRun(
        icon: Ionicons.trash_outline,
        color: context.colorScheme.error,
        onColor: context.colorScheme.onError,
        title: context.l10n.taskDetailsDelete,
        subtitle: context.l10n.taskDetailsDeleteConfirm,
        buttonText: context.l10n.taskDetailsDelete,
        run: () => ref.read(taskRepositoryProvider).deleteTask(widget.task),
        successMessage: context.l10n.taskDetailsDeleteSuccess,
      );

  Future<void> _confirmAndRun({
    required IconData icon,
    required Color color,
    Color? onColor,
    required String title,
    required String subtitle,
    required String buttonText,
    required Future<void> Function() run,
    required String successMessage,
  }) async {
    final l10n = context.l10n;

    final success = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        var processing = false;

        return StatefulBuilder(
          builder: (ctx, setState) => AppDialog(
            icon: icon,
            color: color,
            onColor: onColor,
            title: title,
            subtitle: subtitle,
            buttonText: buttonText,
            isProcessing: processing,
            onPressed: () async {
              setState(() => processing = true);
              try {
                await run();
                if (ctx.mounted) Navigator.of(ctx).pop(true);
              } on Exception {
                if (ctx.mounted) {
                  setState(() => processing = false);
                  AppSnackBar.show(ctx, l10n.authErrorUnknown, type: SnackBarType.error);
                }
              }
            },
            cancelText: l10n.dialogBack,
            onCancel: processing ? null : () => Navigator.of(ctx).pop(false),
          ),
        );
      },
    ) ?? false;

    if (!success || !mounted) return;

    Navigator.of(context).pop();
    // AppSnackBar.show(context, successMessage, type: SnackBarType.success);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isPending = task.status == TaskStatus.pending &&
        task.endDate.isAfter(DateTime.now());
    final isCancelled = task.status == TaskStatus.cancelled;

    final category = _findCategory();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TouchableOpacity(
                onTap: () {
                  Navigator.of(context).pop();
                  context.push(AppRoutes.taskForm, extra: task);
                },
                child: Text.rich(
                  TextSpan(
                    text: task.title,
                    children: [
                      if (isPending) ...[
                        const WidgetSpan(child: SizedBox(width: 6)),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            Ionicons.create_outline,
                            size: 18,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  style: context.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(status: task.status),
          ],
        ),
        if (task.description != null) ...[
          const SizedBox(height: 8),
          Text(
            task.description!,
            style: context.textTheme.bodyMedium,
          ),
        ],
        _buildSubtasks(task, category),
        Divider(
          height: 32,
          color: context.colorScheme.outlineVariant,
        ),
        _buildInfoRow(
          icon: category?.icon,
          value: category?.name ?? context.l10n.taskFormCategoryNone,
          color: category != null
            ? ref.usePrimaryColor(category.colorKey)
            : context.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Ionicons.calendar_outline,
          label: context.l10n.taskDetailsDeadline,
          value: _formatDate(task.endDate),
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Ionicons.time_outline,
          label: context.l10n.taskDetailsCreatedAt,
          value: _formatDate(task.createdAt),
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Ionicons.star_outline,
          label: 'Pontos',
          value: context.l10n.taskDetailsPoints(task.pointsEarned),
        ),
        const SizedBox(height: 24),
        _buildActions(isPending, isCancelled),
      ],
    );
  }

  Widget _buildSubtasks(Task task, Category? category) {
    final subtasksAsync = ref.watch(subtasksProvider(task.id));
    final subtasks = subtasksAsync.asData?.value;
    if (subtasks == null || subtasks.isEmpty) return const SizedBox.shrink();

    final isPending = task.status == TaskStatus.pending &&
        task.endDate.isAfter(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: subtasks.map((subtask) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TouchableOpacity(
              onTap: isPending
                  ? () => ref.read(taskRepositoryProvider).toggleSubtask(
                        task.id, subtask.id, !subtask.isDone)
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    subtask.isDone
                        ? Ionicons.checkmark_circle
                        : Ionicons.ellipse_outline,
                    size: 20,
                    color: subtask.isDone
                        ? category != null 
                          ? ref.usePrimaryColor(category.colorKey) 
                          : context.colorScheme.onSurface
                        : context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      subtask.title,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: subtask.isDone
                            ? context.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoRow({
    IconData? icon,
    String? label,
    required String value,
    Color? color,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: color ?? context.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
        ],
        if (label != null)
          Text(
            '$label: ',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        Expanded(
          child: Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              color: color ?? context.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(bool isPending, bool isCancelled) {
    return Column(
      children: [
        if (isPending) ...[
          AppButton(
            detailColor: ref.usePrimaryColor('green'),
            onPressed: _completeTask,
            text: context.l10n.taskDetailsComplete,
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            if (isPending)
              Expanded(
                child: AppButton(
                  detailColor: ref.usePrimaryColor('orange'),
                  onPressed: _cancelTask,
                  text: context.l10n.taskDetailsCancel,
                ),
              ),
            if (isCancelled && widget.task.canUncancel)
              Expanded(
                child: AppButton(
                  detailColor: ref.usePrimaryColor('orange'),
                  onPressed: _uncancelTask,
                  text: context.l10n.taskDetailsUncancel,
                ),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: widget.task.canDelete 
                ? AppButton(
                    detailColor: context.colorScheme.error,
                    textColor: context.colorScheme.onError,
                    onPressed: _deleteTask,
                    text: _deleteMinutesLeft > 0
                      ? context.l10n.taskDetailsDeleteTimer(_deleteMinutesLeft)
                      : context.l10n.taskDetailsDelete,
                  )
                : const SizedBox(),
            ),
          ],
        ),
      ]
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Category? _findCategory() {
    final categoryId = widget.task.categoryId;
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
