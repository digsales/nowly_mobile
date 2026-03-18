import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/models/subtask.dart';
import 'package:nowly/core/models/task.dart';
import 'package:nowly/core/repositories/task_repository.dart';
import 'package:nowly/core/services/auth_service_provider.dart';
import 'package:nowly/core/validators/field_controller.dart';
import 'package:nowly/core/validators/validators.dart';
import 'package:nowly/l10n/app_localizations.dart';

final taskFormProvider =
    NotifierProvider.autoDispose<TaskFormNotifier, TaskFormState>(
        TaskFormNotifier.new);

enum TaskDeadline {
  oneDay(Duration(days: 1)),
  threeDays(Duration(days: 3)),
  oneWeek(Duration(days: 7)),
  twoWeeks(Duration(days: 14)),
  oneMonth(Duration(days: 30));

  const TaskDeadline(this.duration);
  final Duration duration;

  String label(AppLocalizations l10n) {
    return switch (this) {
      oneDay => l10n.taskFormDeadline1Day,
      threeDays => l10n.taskFormDeadline3Days,
      oneWeek => l10n.taskFormDeadline1Week,
      twoWeeks => l10n.taskFormDeadline2Weeks,
      oneMonth => l10n.taskFormDeadline1Month,
    };
  }
}

class TaskFormState {
  const TaskFormState({
    this.selectedCategoryId,
    this.selectedDeadline = TaskDeadline.oneDay,
    this.isLoading = false,
    this.errorMessage,
    this.subtasks = const [],
  });

  final String? selectedCategoryId;
  final TaskDeadline selectedDeadline;
  final bool isLoading;
  final String? errorMessage;
  final List<Subtask> subtasks;

  int get totalPoints => defaultTaskPoints + (subtasks.length * subtaskPoints);

  TaskFormState copyWith({
    String? selectedCategoryId,
    TaskDeadline? selectedDeadline,
    bool? isLoading,
    String? errorMessage,
    bool clearCategory = false,
    List<Subtask>? subtasks,
  }) {
    return TaskFormState(
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      selectedDeadline: selectedDeadline ?? this.selectedDeadline,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}

class TaskFormNotifier extends Notifier<TaskFormState> {
  late final TaskRepository _taskRepository;
  final title = FieldController();
  final description = FieldController();

  @override
  TaskFormState build() {
    _taskRepository = ref.read(taskRepositoryProvider);
    ref.onDispose(() {
      title.dispose();
      description.dispose();
    });
    return const TaskFormState();
  }

  Future<void> init(Task? task) async {
    if (task == null) return;
    title.controller.text = task.title;
    description.controller.text = task.description ?? '';
    state = state.copyWith(
      selectedCategoryId: task.categoryId,
      clearCategory: task.categoryId == null,
    );

    // Load existing subtasks
    final snapshot = await _taskRepository.watchSubtasks(task.id).first;
    state = state.copyWith(subtasks: snapshot);
  }

  void selectCategory(String? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearCategory: true);
    } else if (categoryId == state.selectedCategoryId) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
    }
  }

  void selectDeadline(TaskDeadline deadline) {
    state = state.copyWith(selectedDeadline: deadline);
  }

  void onTitleChanged(String value) {
    title.onChanged(value);
    state = state.copyWith();
  }

  void onDescriptionChanged(String value) {
    description.onChanged(value);
    state = state.copyWith();
  }

  void addSubtask(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final subtask = Subtask(id: '', title: trimmed);
    state = state.copyWith(subtasks: [...state.subtasks, subtask]);
  }

  void removeSubtask(int index) {
    final updated = [...state.subtasks]..removeAt(index);
    state = state.copyWith(subtasks: updated);
  }

  void reorderSubtask(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final updated = [...state.subtasks];
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    state = state.copyWith(subtasks: updated);
  }

  /// Syncs local subtask list with Firestore for an existing task.
  Future<void> _syncSubtasks(String taskId) async {
    final remote = await _taskRepository.watchSubtasks(taskId).first;
    final localIds = state.subtasks.where((s) => s.id.isNotEmpty).map((s) => s.id).toSet();
    final remoteIds = remote.map((s) => s.id).toSet();

    // Remove subtasks that were deleted locally
    for (final id in remoteIds.difference(localIds)) {
      await _taskRepository.removeSubtask(taskId, id);
    }

    // Add new subtasks (id is empty for locally created ones)
    final newSubtasks = state.subtasks.where((s) => s.id.isEmpty).toList();
    final existingCount = state.subtasks.where((s) => s.id.isNotEmpty).length;
    if (newSubtasks.isNotEmpty) {
      await _taskRepository.addSubtasks(taskId, newSubtasks, startOrder: existingCount);
    }

    // Reorder existing subtasks to match the local order
    final existingSubtasks = state.subtasks.where((s) => s.id.isNotEmpty).toList();
    if (existingSubtasks.isNotEmpty) {
      await _taskRepository.reorderSubtasks(taskId, existingSubtasks);
    }
  }

  Future<bool> save(AppLocalizations l10n, {Task? existing}) async {
    title.validator = Validators.combine([
      Validators.required(l10n.validatorRequired),
      Validators.minLength(2, l10n.validatorMinLength(2)),
    ]);

    if (!title.validate()) {
      state = state.copyWith();
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      final points = state.totalPoints;

      if (existing != null) {
        await _taskRepository.updateTask(
          existing.id,
          categoryId: state.selectedCategoryId,
          clearCategory: state.selectedCategoryId == null,
          title: title.text,
          description: description.text.isEmpty ? null : description.text,
          clearDescription: description.text.isEmpty,
          pointsEarned: points,
        );
        await _syncSubtasks(existing.id);
      } else {
        final uid = ref.read(authServiceProvider).currentUser?.uid;
        if (uid == null) return false;

        final now = DateTime.now();
        final task = Task(
          id: '',
          userId: uid,
          categoryId: state.selectedCategoryId,
          title: title.text,
          description: description.text.isEmpty ? null : description.text,
          endDate: now.add(state.selectedDeadline.duration),
          status: TaskStatus.pending,
          createdAt: now,
          pointsEarned: points,
        );

        final taskId = await _taskRepository.createTask(task);

        if (state.subtasks.isNotEmpty) {
          await _taskRepository.addSubtasks(taskId, state.subtasks);
        }
      }

      state = state.copyWith(isLoading: false);
      return true;
    } on Exception catch (e) {
      debugPrint('Task save error: $e');
      state = state.copyWith(isLoading: false, errorMessage: l10n.authErrorUnknown);
      return false;
    }
  }
}
