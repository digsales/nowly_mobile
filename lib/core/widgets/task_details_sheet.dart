import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/task.dart';
import 'package:nowly/core/repositories/task_repository.dart';
import 'package:nowly/core/theme/primary_colors.dart';
import 'package:nowly/core/widgets/app_bottom_sheet.dart';
import 'package:nowly/core/widgets/app_button.dart';
import 'package:nowly/core/widgets/app_dialog.dart';
import 'package:nowly/core/widgets/app_snack_bar.dart';
import 'package:nowly/core/widgets/status_badge.dart';
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
  bool _isLoading = false;
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
    final confirmed = await _showConfirm(
      icon: Ionicons.checkmark_circle_outline,
      color: ref.usePrimaryColor('green'),
      title: context.l10n.taskDetailsComplete,
      subtitle: context.l10n.taskDetailsCompleteConfirm(widget.task.pointsEarned),
      buttonText: context.l10n.taskDetailsComplete,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(taskRepositoryProvider).completeTask(widget.task);
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackBar.show(context, context.l10n.taskDetailsSuccess, type: SnackBarType.success);
      }
    } on Exception {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackBar.show(context, context.l10n.authErrorUnknown, type: SnackBarType.error);
      }
    }
  }

  Future<void> _cancelTask() async {
    final confirmed = await _showConfirm(
      icon: Ionicons.close_circle_outline,
      color: ref.usePrimaryColor('orange'),
      title: context.l10n.taskDetailsCancel,
      subtitle: context.l10n.taskDetailsCancelConfirm,
      buttonText: context.l10n.taskDetailsCancel,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(taskRepositoryProvider).cancelTask(widget.task);
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackBar.show(context, context.l10n.taskDetailsSuccess, type: SnackBarType.success);
      }
    } on Exception {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackBar.show(context, context.l10n.authErrorUnknown, type: SnackBarType.error);
      }
    }
  }

  Future<void> _uncancelTask() async {
    final confirmed = await _showConfirm(
      icon: Ionicons.refresh_outline,
      color: ref.usePrimaryColor('orange'),
      title: context.l10n.taskDetailsUncancel,
      subtitle: context.l10n.taskDetailsUncancelConfirm,
      buttonText: context.l10n.taskDetailsUncancel,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(taskRepositoryProvider).uncancelTask(widget.task);
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackBar.show(context, context.l10n.taskDetailsSuccess, type: SnackBarType.success);
      }
    } on Exception {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackBar.show(context, context.l10n.authErrorUnknown, type: SnackBarType.error);
      }
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await _showConfirm(
      icon: Ionicons.trash_outline,
      color: context.colorScheme.error,
      onColor: context.colorScheme.onError,
      title: context.l10n.taskDetailsDelete,
      subtitle: context.l10n.taskDetailsDeleteConfirm,
      buttonText: context.l10n.taskDetailsDelete,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(taskRepositoryProvider).deleteTask(widget.task);
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackBar.show(context, context.l10n.taskDetailsDeleteSuccess, type: SnackBarType.success);
      }
    } on Exception {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackBar.show(context, context.l10n.authErrorUnknown, type: SnackBarType.error);
      }
    }
  }

  Future<bool> _showConfirm({
    required IconData icon,
    required Color color,
    Color? onColor,
    required String title,
    required String subtitle,
    required String buttonText,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AppDialog(
        icon: icon,
        color: color,
        onColor: onColor,
        title: title,
        subtitle: subtitle,
        buttonText: buttonText,
        onPressed: () => Navigator.of(ctx).pop(true),
        cancelText: context.l10n.deleteAccountCancel,
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isPending = task.status == TaskStatus.pending &&
        task.endDate.isAfter(DateTime.now());
    final isCancelled = task.status == TaskStatus.cancelled;

    final category = _findCategory();

    return IgnorePointer(
      ignoring: _isLoading,
      child: AnimatedOpacity(
        opacity: _isLoading ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: context.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: task.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.description ?? context.l10n.taskDetailsDescription,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              icon: Ionicons.folder_outline,
              label: context.l10n.taskDetailsCategory,
              value: category?.name ?? context.l10n.taskFormCategoryNone,
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
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: context.textTheme.bodyMedium,
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
            if (widget.task.canDelete) ...[
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  detailColor: context.colorScheme.error,
                  textColor: context.colorScheme.onError,
                  onPressed: _deleteTask,
                  text: _deleteMinutesLeft > 0
                    ? context.l10n.taskDetailsDeleteTimer(_deleteMinutesLeft)
                    : context.l10n.taskDetailsDelete,
                ),
              ),
            ],
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

  dynamic _findCategory() {
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
