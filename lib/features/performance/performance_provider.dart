import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowly/core/repositories/task_repository.dart';
import 'package:nowly/core/services/auth_service_provider.dart';
import 'package:nowly/features/profile/profile_provider.dart';

enum ProgressFilter { lastMonth, last6Months, lastYear, allTime }

class ProgressFilterNotifier extends Notifier<ProgressFilter> {
  @override
  ProgressFilter build() => ProgressFilter.lastMonth;

  void set(ProgressFilter filter) => state = filter;
}

final progressFilterProvider =
    NotifierProvider<ProgressFilterNotifier, ProgressFilter>(
        ProgressFilterNotifier.new);

class TaskStatsNotifier extends AsyncNotifier<TaskStats> {
  @override
  Future<TaskStats> build() async {
    final filter = ref.watch(progressFilterProvider);

    if (filter == ProgressFilter.allTime) {
      final userAsync = ref.watch(currentUserProvider);
      final user = userAsync.asData?.value;
      if (user == null) return state.asData?.value ?? TaskStats.empty;

      return TaskStats(
        completed: user.totalCompleted,
        cancelled: user.totalCancelled,
        expired: user.totalExpired,
      );
    }

    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return TaskStats.empty;

    final now = DateTime.now();
    final from = switch (filter) {
      ProgressFilter.lastMonth => DateTime(now.year, now.month - 1, now.day),
      ProgressFilter.last6Months => DateTime(now.year, now.month - 6, now.day),
      ProgressFilter.lastYear => DateTime(now.year - 1, now.month, now.day),
      ProgressFilter.allTime => now,
    };

    final stats = await ref.read(taskRepositoryProvider).fetchStatsByPeriod(
      userId: uid,
      from: from,
    );

    return TaskStats(
      completed: stats.completed,
      cancelled: stats.cancelled,
      expired: stats.expired,
    );
  }
}

final filteredTaskStatsProvider =
    AsyncNotifierProvider<TaskStatsNotifier, TaskStats>(TaskStatsNotifier.new);

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
