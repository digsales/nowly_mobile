import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  });

  final String? selectedCategoryId;
  final TaskDeadline selectedDeadline;
  final bool isLoading;
  final String? errorMessage;

  TaskFormState copyWith({
    String? selectedCategoryId,
    TaskDeadline? selectedDeadline,
    bool? isLoading,
    String? errorMessage,
    bool clearCategory = false,
  }) {
    return TaskFormState(
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      selectedDeadline: selectedDeadline ?? this.selectedDeadline,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
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

  Future<bool> save(AppLocalizations l10n) async {
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
        pointsEarned: defaultTaskPoints,
      );

      await _taskRepository.createTask(task);
      state = state.copyWith(isLoading: false);
      return true;
    } on Exception catch (e) {
      debugPrint('Task save error: $e');
      state = state.copyWith(isLoading: false, errorMessage: l10n.authErrorUnknown);
      return false;
    }
  }
}
