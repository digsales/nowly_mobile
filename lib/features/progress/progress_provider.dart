import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/models/task.dart';
import 'package:nowly/core/repositories/task_repository.dart';
import 'package:nowly/core/services/auth_service_provider.dart';

enum ProgressFilter { lastMonth, last6Months, lastYear, allTime }

class ProgressFilterNotifier extends Notifier<ProgressFilter> {
  @override
  ProgressFilter build() => ProgressFilter.allTime;

  void set(ProgressFilter filter) => state = filter;
}

final progressFilterProvider =
    NotifierProvider<ProgressFilterNotifier, ProgressFilter>(
        ProgressFilterNotifier.new);

final allTasksProvider = StreamProvider<List<Task>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final uid = authService.currentUser?.uid;
  if (uid == null) return Stream.value([]);

  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchAllTasks(uid);
});

final filteredTaskStatsProvider = Provider<AsyncValue<TaskStats>>((ref) {
  final tasksAsync = ref.watch(allTasksProvider);
  final filter = ref.watch(progressFilterProvider);

  return tasksAsync.when(
    data: (tasks) => AsyncData(_computeStats(tasks, filter)),
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
  );
});

TaskStats _computeStats(List<Task> tasks, ProgressFilter filter) {
  final now = DateTime.now();
  final DateTime? cutoff = switch (filter) {
    ProgressFilter.lastMonth => DateTime(now.year, now.month - 1, now.day),
    ProgressFilter.last6Months => DateTime(now.year, now.month - 6, now.day),
    ProgressFilter.lastYear => DateTime(now.year - 1, now.month, now.day),
    ProgressFilter.allTime => null,
  };

  final filtered = cutoff == null
      ? tasks
      : tasks.where((t) => t.createdAt.isAfter(cutoff)).toList();

  var completed = 0;
  var cancelled = 0;
  var expired = 0;

  for (final task in filtered) {
    switch (task.status) {
      case TaskStatus.completed:
        completed++;
      case TaskStatus.cancelled:
        cancelled++;
      case TaskStatus.expired:
        expired++;
      case TaskStatus.pending:
        break;
    }
  }

  return TaskStats(
    completed: completed,
    cancelled: cancelled,
    expired: expired,
  );
}

// ─── History ──────────────────────────────────────────────────────────────────

enum HistoryFilter { all, completed, cancelled, expired }

class HistoryFilterNotifier extends Notifier<HistoryFilter> {
  @override
  HistoryFilter build() => HistoryFilter.all;

  void set(HistoryFilter filter) => state = filter;
}

final historyFilterProvider =
    NotifierProvider<HistoryFilterNotifier, HistoryFilter>(
        HistoryFilterNotifier.new);

final historyTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(allTasksProvider);
  final filter = ref.watch(historyFilterProvider);

  return tasksAsync.when(
    data: (tasks) {
      final nonPending =
          tasks.where((t) => t.status != TaskStatus.pending).toList();

      final filtered = switch (filter) {
        HistoryFilter.all => nonPending,
        HistoryFilter.completed =>
          nonPending.where((t) => t.status == TaskStatus.completed).toList(),
        HistoryFilter.cancelled =>
          nonPending.where((t) => t.status == TaskStatus.cancelled).toList(),
        HistoryFilter.expired =>
          nonPending.where((t) => t.status == TaskStatus.expired).toList(),
      };

      filtered.sort((a, b) {
        final dateA = a.status == TaskStatus.completed
            ? (a.completedAt ?? a.endDate)
            : a.endDate;
        final dateB = b.status == TaskStatus.completed
            ? (b.completedAt ?? b.endDate)
            : b.endDate;
        return dateB.compareTo(dateA);
      });
      return AsyncData(filtered);
    },
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
  );
});

class TaskStats {
  final int completed;
  final int cancelled;
  final int expired;

  const TaskStats({
    required this.completed,
    required this.cancelled,
    required this.expired,
  });

  static const empty = TaskStats(completed: 0, cancelled: 0, expired: 0);

  int get total => completed + cancelled + expired;
  bool get isEmpty => total == 0;
}
