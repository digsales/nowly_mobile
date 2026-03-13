import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nowly/core/extensions/context_extensions.dart';
import 'package:nowly/core/models/task.dart';
import 'package:nowly/core/repositories/task_repository.dart';
import 'package:nowly/core/theme/app_palette.dart';
import 'package:nowly/core/widgets/app_bottom_sheet.dart';
import 'package:nowly/core/widgets/app_snack_bar.dart';
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
    final confirmed = await _showConfirmDialog(
      context.l10n.taskDetailsCompleteConfirm(widget.task.pointsEarned),
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
    final confirmed = await _showConfirmDialog(
      context.l10n.taskDetailsCancelConfirm,
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
    final confirmed = await _showConfirmDialog(
      context.l10n.taskDetailsUncancelConfirm,
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
    final confirmed = await _showConfirmDialog(
      context.l10n.taskDetailsDeleteConfirm,
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

  Future<bool> _showConfirmDialog(String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.deleteAccountCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.categoryFormSave),
          ),
        ],
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
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor(task.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusText(context, task.status),
                  style: context.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              task.title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              task.description ?? context.l10n.taskDetailsDescription,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
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
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(bool isPending, bool isCancelled) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (isPending) ...[
          _ActionChip(
            icon: Ionicons.checkmark_circle_outline,
            label: context.l10n.taskDetailsComplete,
            color: AppPalette.success,
            onTap: _completeTask,
          ),
          _ActionChip(
            icon: Ionicons.close_circle_outline,
            label: context.l10n.taskDetailsCancel,
            color: AppPalette.error,
            onTap: _cancelTask,
          ),
        ],
        if (isCancelled && widget.task.canUncancel)
          _ActionChip(
            icon: Ionicons.refresh_outline,
            label: context.l10n.taskDetailsUncancel,
            color: AppPalette.info,
            onTap: _uncancelTask,
          ),
        if (widget.task.canDelete)
          _ActionChip(
            icon: Ionicons.trash_outline,
            label: _deleteMinutesLeft > 0
                ? context.l10n.taskDetailsDeleteTimer(_deleteMinutesLeft)
                : context.l10n.taskDetailsDelete,
            color: AppPalette.error,
            outlined: true,
            onTap: _deleteTask,
          ),
      ],
    );
  }

  String _statusText(BuildContext context, TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => context.l10n.taskStatusPending,
      TaskStatus.completed => context.l10n.taskCompleted,
      TaskStatus.expired => context.l10n.taskExpired,
      TaskStatus.cancelled => context.l10n.taskCancelled,
    };
  }

  Color _statusColor(TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => AppPalette.warning,
      TaskStatus.completed => AppPalette.success,
      TaskStatus.expired => AppPalette.info,
      TaskStatus.cancelled => AppPalette.error,
    };
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

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(20),
          border: outlined ? Border.all(color: color, width: 1.5) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: outlined ? color : Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                color: outlined ? color : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
